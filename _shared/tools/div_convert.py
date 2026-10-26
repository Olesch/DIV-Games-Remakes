#!/usr/bin/env python3
"""
div_convert.py - Convert DIV Game Studio 1 resources to Godot-friendly files.

Pure Python 3 (no third-party modules; PNGs are written with zlib).

Sub-commands (run with -h for details):
  fpg  <file.fpg> <outdir>            FPG graphics library  -> folder
  map  <file.map> <outdir>            single MAP graphic     -> folder
  fnt  <file.fnt> <outdir>            FNT bitmap font        -> folder
  sysfont <SYS06X08.BIN> <outdir>     DIV system font (font 0, 6x8) -> folder
  pal  <file.pal|fpg|map|fnt> <outdir>  palette -> palette.json + palette.png
  pcm  <file.pcm> <out.wav> [--rate N] raw 8-bit unsigned PCM -> WAV
  dat  <file.dat> <out.json>          load()/save() data block -> JSON int32 list
  info <file>                          print a summary of any DIV file
  game <file.PRG> <assets_dir> [--div DIR]
        Resolve every load_fpg/load_fnt/load_map/load_pal/load_pcm/load()
        literal in a PRG exactly like DIV does (case-insensitive, with the
        DIV directory fallbacks), convert everything into <assets_dir>/
        {fpg,fnt,map,pal,pcm,dat}/<name>/ and write <assets_dir>/manifest.json.
        Also always converts the DIV system font to <assets_dir>/fnt/system.
        All images/fonts are rendered with the GAME palette (first FPG/MAP/FNT
        loaded), as DIV did; use --keep-own-palettes to disable.

Output folder layout for fpg / map / fnt / sysfont:
  meta.json     metadata (see DIV_PORTING_GUIDE.md "Converted asset format")
  indices.bin   raw 8-bit palette indices (all graphics concatenated at
                meta.json "offset", or the font atlas). Needed to reproduce
                map_get_pixel() "hardness maps" exactly (colour INDEX lookups).
  <code>.png    RGBA PNG per graphic (index 0 = fully transparent) - for
                previews or for plain Sprite2D use.  Fonts: atlas.png
  palette.png   256x1 RGBA palette strip, palette.json
  font_bmfont.fnt (fonts only) BMFont text descriptor usable by Godot's
                font importer together with atlas.png
"""
import argparse
import json
import os
import re
import struct
import sys
import wave
import zlib

# ----------------------------------------------------------------------------
# PNG writer
# ----------------------------------------------------------------------------

def _png_chunk(tag, data):
    c = struct.pack('>I', len(data)) + tag + data
    return c + struct.pack('>I', zlib.crc32(tag + data) & 0xffffffff)


def write_png_rgba(path, width, height, rgba):
    """rgba: bytes-like of length width*height*4"""
    stride = width * 4
    raw = bytearray()
    for y in range(height):
        raw.append(0)
        raw += rgba[y * stride:(y + 1) * stride]
    data = b'\x89PNG\r\n\x1a\n'
    data += _png_chunk(b'IHDR', struct.pack('>IIBBBBB', width, height, 8, 6, 0, 0, 0))
    data += _png_chunk(b'IDAT', zlib.compress(bytes(raw), 6))
    data += _png_chunk(b'IEND', b'')
    with open(path, 'wb') as f:
        f.write(data)


def indices_to_rgba(indices, palette, transparent0=True):
    """indices: bytes; palette: list of 256 (r,g,b) 8-bit tuples."""
    n = len(indices)
    rt = bytes(p[0] for p in palette)
    gt = bytes(p[1] for p in palette)
    bt = bytes(p[2] for p in palette)
    at = bytes([0] + [255] * 255) if transparent0 else bytes([255] * 256)
    out = bytearray(n * 4)
    ib = bytes(indices)
    out[0::4] = ib.translate(rt)
    out[1::4] = ib.translate(gt)
    out[2::4] = ib.translate(bt)
    out[3::4] = ib.translate(at)
    return out

# ----------------------------------------------------------------------------
# Palette helpers
# ----------------------------------------------------------------------------

def vga6_to_8(v):
    v &= 63
    return (v << 2) | (v >> 4)


def parse_palette(raw768):
    """DIV stores 256 * (r,g,b), each 0..63 (6-bit VGA DAC)."""
    pal6 = [tuple(raw768[i * 3 + k] & 63 for k in range(3)) for i in range(256)]
    pal8 = [tuple(vga6_to_8(c) for c in p) for p in pal6]
    return pal6, pal8


def write_palette_files(outdir, pal6, pal8):
    with open(os.path.join(outdir, 'palette.json'), 'w') as f:
        json.dump({'palette_rgb8': [list(p) for p in pal8],
                   'palette_vga6': [list(p) for p in pal6]}, f)
    rgba = bytearray()
    for p in pal8:
        rgba += bytes([p[0], p[1], p[2], 255])
    write_png_rgba(os.path.join(outdir, 'palette.png'), 256, 1, rgba)

# ----------------------------------------------------------------------------
# File readers
# ----------------------------------------------------------------------------

MAGIC_FPG = b'fpg\x1a\x0d\x0a\x00'
MAGIC_MAP = b'map\x1a\x0d\x0a\x00'
MAGIC_FNT = b'fnt\x1a\x0d\x0a\x00'
MAGIC_PAL = b'pal\x1a\x0d\x0a\x00'


def cstr(b):
    b = b.split(b'\x00', 1)[0]
    return b.decode('cp850', errors='replace').strip()


def read_fpg(data):
    """Returns (pal6, pal8, graphics list). Layout:
       0    char[8]  "fpg\\x1a\\x0d\\x0a\\x00" + version byte (0)
       8    768      palette (6-bit)
       776  576      colour gradients (16*36, editor only)
       1352 entries until EOF:
            int32 code, int32 length (of whole entry incl. this 64-byte header),
            char[32] description, char[12] filename,
            int32 width, int32 height, int32 npoints,
            int16 points[npoints][2] (x,y; -1,-1 = undefined),
            uint8 pixels[width*height] (row-major, index 0 = transparent)
    """
    if data[:7] != MAGIC_FPG:
        raise ValueError('not an FPG file')
    pal6, pal8 = parse_palette(data[8:8 + 768])
    pos = 1352
    graphics = []
    while pos + 64 <= len(data):
        code, length = struct.unpack_from('<ii', data, pos)
        desc = cstr(data[pos + 8:pos + 40])
        fname = cstr(data[pos + 40:pos + 52])
        w, h, npts = struct.unpack_from('<iii', data, pos + 52)
        if length <= 0 or w <= 0 or h <= 0 or npts < 0 or npts > 1000:
            print(f'  warning: bad FPG entry at offset {pos} (code={code} len={length} '
                  f'{w}x{h} npts={npts}); stopping', file=sys.stderr)
            break
        p = pos + 64
        pts = [list(struct.unpack_from('<hh', data, p + i * 4)) for i in range(npts)]
        p += npts * 4
        pix = data[p:p + w * h]
        if len(pix) < w * h:
            print(f'  warning: truncated graphic {code}', file=sys.stderr)
            pix = pix + bytes(w * h - len(pix))
        expected = 64 + npts * 4 + w * h
        if expected != length:
            print(f'  note: graphic {code}: length field {length} != computed {expected}',
                  file=sys.stderr)
        graphics.append({'code': code, 'name': desc, 'filename': fname,
                         'width': w, 'height': h, 'points': pts, 'pixels': pix})
        pos += length
    return pal6, pal8, graphics


def read_map(data):
    """MAP layout:
       0    char[8] magic "map\\x1a\\x0d\\x0a\\x00\\x00"
       8    int16 width, int16 height
       12   int32 code (graphic code stored by the editor)
       16   char[32] description
       48   768 palette, 816 576 gradients
       1392 int16 npoints, then int16 points[npoints][2]
       ...  uint8 pixels[width*height]
    """
    if data[:7] != MAGIC_MAP:
        raise ValueError('not a MAP file')
    w, h = struct.unpack_from('<hh', data, 8)
    code = struct.unpack_from('<i', data, 12)[0]
    desc = cstr(data[16:48])
    pal6, pal8 = parse_palette(data[48:48 + 768])
    npts = struct.unpack_from('<h', data, 1392)[0]
    p = 1394
    pts = [list(struct.unpack_from('<hh', data, p + i * 4)) for i in range(npts)]
    p += npts * 4
    pix = data[p:p + w * h]
    if len(pix) < w * h:
        pix = pix + bytes(w * h - len(pix))
    return pal6, pal8, {'code': code, 'name': desc, 'filename': '', 'width': w,
                        'height': h, 'points': pts, 'pixels': pix}


def read_fnt(data):
    """FNT layout:
       0    char[8] magic "fnt\\x1a\\x0d\\x0a\\x00\\x00"
       8    768 palette, 776 576 gradients
       1352 int32 charset flags (bit0 digits, bit1 upper, bit2 lower,
            bit3 symbols, bit4 extended) - informational only
       1356 256 * {int32 width, int32 height, int32 yoffset, int32 file_offset}
       5452 glyph pixel data (each glyph width*height bytes at file_offset)
    """
    if data[:7] != MAGIC_FNT:
        raise ValueError('not an FNT file')
    pal6, pal8 = parse_palette(data[8:8 + 768])
    flags = struct.unpack_from('<i', data, 1352)[0]
    glyphs = {}
    for c in range(256):
        w, h, yo, off = struct.unpack_from('<iiii', data, 1356 + c * 16)
        if w > 0 and h > 0 and off > 0:
            pix = data[off:off + w * h]
            if len(pix) < w * h:
                pix = pix + bytes(w * h - len(pix))
            glyphs[c] = {'w': w, 'h': h, 'yoffset': yo, 'pixels': pix}
    return pal6, pal8, flags, glyphs


def read_any_palette(data):
    m = data[:7]
    if m in (MAGIC_FPG, MAGIC_FNT, MAGIC_PAL):
        return parse_palette(data[8:8 + 768])
    if m == MAGIC_MAP:
        return parse_palette(data[48:48 + 768])
    raise ValueError('file has no DIV palette')

# ----------------------------------------------------------------------------
# Converters
# ----------------------------------------------------------------------------

def _norm_points(pts, w, h):
    """Return list where undefined points are None, plus resolved cp0."""
    out = []
    for x, y in pts:
        out.append(None if (x == -1 and y == -1) else [x, y])
    cp0 = out[0] if out and out[0] is not None else [w // 2, h // 2]
    return out, cp0


def convert_graphics(graphics, pal6, pal8, outdir, kind, source, png=True):
    os.makedirs(outdir, exist_ok=True)
    meta = {'type': kind, 'source': source, 'format': 1,
            'palette_rgb8': [list(p) for p in pal8], 'graphics': []}
    offset = 0
    with open(os.path.join(outdir, 'indices.bin'), 'wb') as fb:
        for g in graphics:
            pts, cp0 = _norm_points(g['points'], g['width'], g['height'])
            entry = {'code': g['code'], 'name': g['name'], 'filename': g['filename'],
                     'width': g['width'], 'height': g['height'],
                     'cp0': cp0, 'cp0_defined': bool(pts and pts[0] is not None),
                     'points': pts, 'offset': offset,
                     'png': f"{g['code']}.png" if png else None}
            fb.write(g['pixels'])
            offset += len(g['pixels'])
            if png:
                write_png_rgba(os.path.join(outdir, f"{g['code']}.png"), g['width'],
                               g['height'], indices_to_rgba(g['pixels'], pal8))
            meta['graphics'].append(entry)
    write_palette_files(outdir, pal6, pal8)
    with open(os.path.join(outdir, 'meta.json'), 'w') as f:
        json.dump(meta, f, indent=1)
    return meta


def load_palette_override(path):
    """Palette from any PAL/FPG/MAP/FNT file, or None."""
    if not path:
        return None
    return read_any_palette(open(path, 'rb').read())


def cmd_fpg(src, outdir, png=True, pal=None):
    data = open(src, 'rb').read()
    pal6, pal8, graphics = read_fpg(data)
    if pal:
        pal6, pal8 = pal
    meta = convert_graphics(graphics, pal6, pal8, outdir, 'fpg', os.path.basename(src), png)
    print(f'FPG {src}: {len(graphics)} graphics -> {outdir}')
    return meta


def cmd_map(src, outdir, png=True, pal=None):
    data = open(src, 'rb').read()
    pal6, pal8, g = read_map(data)
    if pal:
        pal6, pal8 = pal
    meta = convert_graphics([g], pal6, pal8, outdir, 'map', os.path.basename(src), png)
    print(f'MAP {src}: {g["width"]}x{g["height"]} -> {outdir}')
    return meta


def _pack_atlas(glyphs, max_w=1024):
    """Simple shelf packer with 1px padding. Returns (W,H,placements)."""
    items = sorted(glyphs.items(), key=lambda kv: -kv[1]['h'])
    widest = max((g['w'] for _, g in items), default=1)
    max_w = max(max_w, widest + 2)
    x = y = 1
    shelf_h = 0
    place = {}
    for c, g in items:
        if x + g['w'] + 1 > max_w:
            x = 1
            y += shelf_h + 1
            shelf_h = 0
        place[c] = (x, y)
        x += g['w'] + 1
        shelf_h = max(shelf_h, g['h'])
    W = max_w
    H = y + shelf_h + 1
    return W, H, place


def write_font(glyphs, pal6, pal8, outdir, source, charset_flags=None, system=False):
    os.makedirs(outdir, exist_ok=True)
    W, H, place = _pack_atlas(glyphs)
    atlas = bytearray(W * H)
    for c, g in glyphs.items():
        px, py = place[c]
        for row in range(g['h']):
            atlas[(py + row) * W + px:(py + row) * W + px + g['w']] = \
                g['pixels'][row * g['w']:(row + 1) * g['w']]
    with open(os.path.join(outdir, 'indices.bin'), 'wb') as f:
        f.write(atlas)
    write_png_rgba(os.path.join(outdir, 'atlas.png'), W, H, indices_to_rgba(atlas, pal8))
    write_palette_files(outdir, pal6, pal8)
    line_h = max((g['h'] + g['yoffset'] for g in glyphs.values()), default=8)
    # Width of characters missing from the font (notably the space, which DIV
    # fonts usually leave undefined).  Not stored in the file; see guide.
    # Convention used here (same as BennuGD's DIV font loader): if the space
    # glyph is missing use the width of 'j', else half the average width.
    if 32 in glyphs:
        space_w = glyphs[32]['w']
    elif ord('j') in glyphs:
        space_w = glyphs[ord('j')]['w']
    else:
        widths = [g['w'] for g in glyphs.values()]
        space_w = max(1, (sum(widths) // len(widths)) // 2) if widths else 4
    meta = {'type': 'fnt', 'source': source, 'format': 1, 'system': system,
            'charset_flags': charset_flags,
            'atlas_width': W, 'atlas_height': H,
            'line_height': line_h, 'space_advance': space_w,
            'palette_rgb8': [list(p) for p in pal8],
            'glyphs': {str(c): {'x': place[c][0], 'y': place[c][1], 'w': g['w'],
                                'h': g['h'], 'yoffset': g['yoffset'],
                                'advance': g['w']}
                       for c, g in sorted(glyphs.items())}}
    with open(os.path.join(outdir, 'meta.json'), 'w') as f:
        json.dump(meta, f, indent=1)
    # BMFont text descriptor (Godot imports *.fnt BMFont files as FontFile)
    lines = [f'info face="{source}" size={line_h} bold=0 italic=0 charset="" unicode=1 '
             f'stretchH=100 smooth=0 aa=1 padding=0,0,0,0 spacing=0,0',
             f'common lineHeight={line_h} base={line_h} scaleW={W} scaleH={H} pages=1 packed=0',
             'page id=0 file="atlas.png"',
             f'chars count={len(glyphs) + (0 if 32 in glyphs else 1)}']
    for c, g in sorted(glyphs.items()):
        uc = bytes([c]).decode('cp850') if c >= 32 else chr(c)
        lines.append(f'char id={ord(uc)} x={place[c][0]} y={place[c][1]} width={g["w"]} '
                     f'height={g["h"]} xoffset=0 yoffset={g["yoffset"]} xadvance={g["w"]} '
                     f'page=0 chnl=15')
    if 32 not in glyphs:
        lines.append(f'char id=32 x=0 y=0 width=0 height=0 xoffset=0 yoffset=0 '
                     f'xadvance={space_w} page=0 chnl=15')
    with open(os.path.join(outdir, 'font_bmfont.fnt'), 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines) + '\n')
    return meta


def cmd_fnt(src, outdir, pal=None):
    data = open(src, 'rb').read()
    pal6, pal8, flags, glyphs = read_fnt(data)
    if pal:
        pal6, pal8 = pal
    meta = write_font(glyphs, pal6, pal8, outdir, os.path.basename(src), flags)
    print(f'FNT {src}: {len(glyphs)} glyphs, line height {meta["line_height"]} -> {outdir}')
    return meta


def cmd_sysfont(src, outdir):
    """SYSTEM\\SYS06X08.BIN: 256 glyphs * 6x8, one byte per pixel (0/1).
    Stored with index 1 = foreground, rendered white (DIV draws the system
    font in the palette's brightest colour, i.e. white)."""
    data = open(src, 'rb').read()
    cw, ch = 6, 8
    m = re.search(r'(\d\d)X(\d\d)', os.path.basename(src).upper())
    if m:
        cw, ch = int(m.group(1)), int(m.group(2))
    n = cw * ch
    glyphs = {}
    for c in range(256):
        pix = data[c * n:(c + 1) * n]
        if len(pix) < n:
            break
        glyphs[c] = {'w': cw, 'h': ch, 'yoffset': 0,
                     'pixels': bytes(1 if b else 0 for b in pix)}
    pal8 = [(0, 0, 0)] + [(255, 255, 255)] * 255
    pal6 = [(0, 0, 0)] + [(63, 63, 63)] * 255
    meta = write_font(glyphs, pal6, pal8, outdir, os.path.basename(src), None, system=True)
    print(f'System font {src}: {len(glyphs)} glyphs {cw}x{ch} -> {outdir}')
    return meta


def cmd_pal(src, outdir):
    data = open(src, 'rb').read()
    pal6, pal8 = read_any_palette(data)
    os.makedirs(outdir, exist_ok=True)
    write_palette_files(outdir, pal6, pal8)
    print(f'Palette {src} -> {outdir}')


def cmd_pcm(src, dst, rate=11025):
    data = open(src, 'rb').read()
    if data[:4] == b'RIFF':
        with open(dst, 'wb') as f:
            f.write(data)
        print(f'PCM {src} is already a WAV; copied')
        return
    os.makedirs(os.path.dirname(os.path.abspath(dst)), exist_ok=True)
    with wave.open(dst, 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(1)      # 8-bit WAV is unsigned, same as DIV PCM
        w.setframerate(rate)
        w.writeframes(data)
    print(f'PCM {src}: {len(data)} samples @ {rate} Hz -> {dst}')


def cmd_dat(src, dst):
    data = open(src, 'rb').read()
    n = len(data) // 4
    vals = list(struct.unpack_from(f'<{n}i', data, 0))
    os.makedirs(os.path.dirname(os.path.abspath(dst)), exist_ok=True)
    with open(dst, 'w') as f:
        json.dump({'source': os.path.basename(src), 'int32_le': vals}, f)
    print(f'DAT {src}: {n} int32 values -> {dst}')


def cmd_info(src):
    data = open(src, 'rb').read()
    m = data[:7]
    if m == MAGIC_FPG:
        _, _, gs = read_fpg(data)
        print(f'FPG, {len(gs)} graphics')
        for g in gs:
            print(f"  {g['code']:4d}  {g['width']:4d}x{g['height']:<4d} pts={len(g['points']):3d} "
                  f"{g['points'][:3]}  '{g['name']}' file='{g['filename']}'")
    elif m == MAGIC_MAP:
        _, _, g = read_map(data)
        print(f"MAP {g['width']}x{g['height']} code={g['code']} pts={g['points'][:5]} '{g['name']}'")
    elif m == MAGIC_FNT:
        _, _, flags, gl = read_fnt(data)
        print(f'FNT flags={flags} glyphs={len(gl)}')
        for c, g in sorted(gl.items()):
            ch = bytes([c]).decode('cp850')
            print(f"  {c:3d} {ch!r} {g['w']}x{g['h']} yoff={g['yoffset']}")
    elif m == MAGIC_PAL:
        print('PAL file')
    else:
        print(f'unknown/raw file ({len(data)} bytes)')

# ----------------------------------------------------------------------------
# DIV path resolution (for the "game" command)
# ----------------------------------------------------------------------------

def find_ci(base, rel):
    """Case-insensitive lookup of relative path rel (with / or \\) under base."""
    parts = [p for p in re.split(r'[\\/]+', rel) if p]
    cur = base
    for part in parts:
        if not os.path.isdir(cur):
            return None
        hit = None
        for e in os.listdir(cur):
            if e.lower() == part.lower():
                hit = e
                break
        if hit is None:
            return None
        cur = os.path.join(cur, hit)
    return cur if os.path.isfile(cur) else None


def dos83(name):
    stem, dot, ext = name.rpartition('.')
    if not dot:
        stem, ext = name, ''
    return (stem[:8] + ('.' + ext[:3] if ext else ''))


def resolve_div_path(divdir, literal, kind):
    """DIV looks for a file as given (relative to the DIV directory), then in
    the default directory for its type (FPG\\, FNT\\, MAP\\, PAL\\, PCM\\),
    then the bare file name in that directory.  Long names were truncated to
    DOS 8.3 by the file system, so we also try that."""
    defaults = {'fpg': 'FPG', 'fnt': 'FNT', 'map': 'MAP', 'pal': 'PAL', 'pcm': 'PCM',
                'dat': 'DAT'}
    d = defaults.get(kind, '')
    base = re.split(r'[\\/]', literal)[-1]
    cands = [literal]
    if d:
        cands += [d + '/' + literal, d + '/' + base]
    cands += [base]
    if dos83(base) != base:
        cands += [re.sub(re.escape(base) + '$', dos83(base), c) for c in list(cands)]
    for c in cands:
        hit = find_ci(divdir, c)
        if hit:
            return hit
    # last resort for palettes: palette inside an FPG/MAP with that stem
    return None


LOAD_RE = re.compile(r'\b(load_fpg|load_fnt|load_map|load_pal|load_pcm|load|save)\s*\(\s*"([^"]*)"',
                     re.IGNORECASE)


def strip_comments(src):
    src = re.sub(r'/\*.*?\*/', lambda m: '\n' * m.group(0).count('\n'), src, flags=re.S)
    return re.sub(r'//[^\n]*', '', src)


def safe_name(path):
    stem = os.path.splitext(os.path.basename(path))[0]
    return re.sub(r'[^A-Za-z0-9_-]+', '_', stem).lower()


def cmd_game(prg, assets, divdir, png=True, keep_own=False):
    raw = open(prg, 'rb').read().decode('cp850')
    code = strip_comments(raw)
    os.makedirs(assets, exist_ok=True)
    manifest = {'prg': os.path.basename(prg), 'div_dir': divdir, 'resources': [],
                'missing': [], 'commented_out': []}
    active = set((m.group(1).lower(), m.group(2)) for m in LOAD_RE.finditer(code))
    allrefs = [(m.group(1).lower(), m.group(2)) for m in LOAD_RE.finditer(raw)]
    seen = set()
    # DIV uses ONE palette for the whole screen: the palette of the first
    # FPG/MAP/FNT loaded (or the last load_pal()). Fonts and maps drawn with
    # another palette appeared in the game's palette, so convert everything
    # with the game palette unless --keep-own-palettes is given.
    game_pal = None
    if not keep_own:
        for func, lit in allrefs:
            if (func, lit) in active and func in ('load_fpg', 'load_map', 'load_fnt', 'load_pal'):
                kind0 = {'load_fpg': 'fpg', 'load_fnt': 'fnt', 'load_map': 'map', 'load_pal': 'pal'}[func]
                h0 = resolve_div_path(divdir, lit, kind0)
                if h0:
                    try:
                        game_pal = read_any_palette(open(h0, 'rb').read())
                        manifest['palette_from'] = os.path.relpath(h0, divdir)
                        break
                    except ValueError:
                        pass
    done_paths = set()
    for func, lit in allrefs:
        key = (func, lit.lower())
        if key in seen:
            continue
        seen.add(key)
        if (func, lit) not in active:
            manifest['commented_out'].append({'call': func, 'literal': lit})
            continue
        kind = {'load_fpg': 'fpg', 'load_fnt': 'fnt', 'load_map': 'map',
                'load_pal': 'pal', 'load_pcm': 'pcm', 'load': 'dat', 'save': 'dat'}[func]
        hit = resolve_div_path(divdir, lit, kind)
        entry = {'call': func, 'literal': lit, 'kind': kind,
                 'resolved': os.path.relpath(hit, divdir) if hit else None}
        if not hit:
            if func == 'save':
                entry['note'] = 'file written by the game (save); not present yet'
            manifest['missing'].append(entry)
            print(f'  MISSING: {func}("{lit}")')
            continue
        name = safe_name(hit)
        out = os.path.join(assets, kind, name)
        if kind in ('pcm', 'dat'):
            out = os.path.join(assets, kind, name + ('.wav' if kind == 'pcm' else '.json'))
        if hit in done_paths:
            entry['converted'] = os.path.relpath(out, assets).replace(os.sep, '/')
            manifest['resources'].append(entry)
            continue
        done_paths.add(hit)
        try:
            if kind == 'fpg':
                cmd_fpg(hit, out, png, game_pal)
            elif kind == 'fnt':
                cmd_fnt(hit, out, game_pal)
            elif kind == 'map':
                cmd_map(hit, out, png, game_pal)
            elif kind == 'pal':
                cmd_pal(hit, out)
            elif kind == 'pcm':
                out = os.path.join(assets, 'pcm', name + '.wav')
                cmd_pcm(hit, out)
            elif kind == 'dat':
                out = os.path.join(assets, 'dat', name + '.json')
                cmd_dat(hit, out)
                import shutil
                shutil.copyfile(hit, os.path.join(assets, 'dat', name + '.dat'))
        except Exception as e:  # keep going
            entry['error'] = str(e)
            print(f'  ERROR converting {hit}: {e}')
        entry['converted'] = os.path.relpath(out, assets).replace('\\', '/')
        manifest['resources'].append(entry)
        seen.add(key)
    sysfont = find_ci(divdir, 'SYSTEM/SYS06X08.BIN')
    if sysfont:
        cmd_sysfont(sysfont, os.path.join(assets, 'fnt', 'system'))
        manifest['system_font'] = 'fnt/system'
    with open(os.path.join(assets, 'manifest.json'), 'w') as f:
        json.dump(manifest, f, indent=1)
    print(f'manifest -> {os.path.join(assets, "manifest.json")}')
    return manifest

# ----------------------------------------------------------------------------

def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest='cmd', required=True)
    for name in ('fpg', 'map', 'fnt'):
        p = sub.add_parser(name)
        p.add_argument('src')
        p.add_argument('outdir')
        p.add_argument('--palette', default=None,
                       help='render with the palette of this PAL/FPG/MAP/FNT file')
        if name != 'fnt':
            p.add_argument('--no-png', action='store_true', help='skip per-graphic PNGs')
    for name in ('sysfont', 'pal'):
        p = sub.add_parser(name)
        p.add_argument('src')
        p.add_argument('outdir')
    p = sub.add_parser('pcm')
    p.add_argument('src')
    p.add_argument('dst')
    p.add_argument('--rate', type=int, default=11025)
    p = sub.add_parser('dat')
    p.add_argument('src')
    p.add_argument('dst')
    p = sub.add_parser('info')
    p.add_argument('src')
    p = sub.add_parser('game')
    p.add_argument('prg')
    p.add_argument('assets')
    p.add_argument('--div', default=None,
                   help='DIV install dir (default: the PRG\'s ../.. or ../../..)')
    p.add_argument('--no-png', action='store_true')
    p.add_argument('--keep-own-palettes', action='store_true',
                   help='convert each file with its own palette instead of the game palette')
    a = ap.parse_args()
    if a.cmd == 'fpg':
        cmd_fpg(a.src, a.outdir, not a.no_png, load_palette_override(a.palette))
    elif a.cmd == 'map':
        cmd_map(a.src, a.outdir, not a.no_png, load_palette_override(a.palette))
    elif a.cmd == 'fnt':
        cmd_fnt(a.src, a.outdir, load_palette_override(a.palette))
    elif a.cmd == 'sysfont':
        cmd_sysfont(a.src, a.outdir)
    elif a.cmd == 'pal':
        cmd_pal(a.src, a.outdir)
    elif a.cmd == 'pcm':
        cmd_pcm(a.src, a.dst, a.rate)
    elif a.cmd == 'dat':
        cmd_dat(a.src, a.dst)
    elif a.cmd == 'info':
        cmd_info(a.src)
    elif a.cmd == 'game':
        divdir = a.div
        if not divdir:
            d = os.path.dirname(os.path.abspath(a.prg))
            for _ in range(4):
                if os.path.isdir(os.path.join(d, 'FPG')) or os.path.isdir(os.path.join(d, 'fpg')):
                    divdir = d
                    break
                d = os.path.dirname(d)
        if not divdir:
            sys.exit('cannot find DIV directory; pass --div')
        cmd_game(a.prg, a.assets, divdir, not a.no_png, a.keep_own_palettes)


if __name__ == '__main__':
    main()
