#!/usr/bin/env python3
"""Extract the original DIV 1 help (HELP\\HELP.DIV, cp437 hypertext) into Markdown.

Usage:
    python div_help_extract.py <DIV dir>/HELP/HELP.DIV <out.md>

Only the programming-language part is exported (functions 100-199,
language topics 1000-1249). Editor/menu/compiler-error topics are skipped.
"""
import re
import sys


def convert_inline(s):
    s = s.replace('{{}', '\x01').replace('{}}', '\x02')
    s = re.sub(r'\{#\d+,([^{}]*)\}', r'\1', s)       # links -> text
    s = re.sub(r'\{@\d+\}', '', s)
    s = re.sub(r'\{\+\d+,\d+\}', '[image]', s)
    s = s.replace('{-}', '').replace('{/}', '\n\n---\n')
    s = re.sub(r'\{([^{}]*)\}', r'**\1**', s)        # bold
    s = s.replace('\x01', '{').replace('\x02', '}')
    s = s.replace('·', '  ')                     # cp437 0xFA soft line break
    return s


def main(src, dst):
    text = open(src, 'rb').read().decode('cp437')
    lines = text.replace('\r', '').split('\n')
    topics = []  # (num, title, [lines])
    cur = None
    for ln in lines:
        if ln.startswith('#'):
            continue
        m = re.match(r'^\{\.(\d+),(.*)\}\s*$', ln)
        if m:
            cur = [int(m.group(1)), m.group(2).strip(), []]
            topics.append(cur)
            continue
        if cur is not None:
            cur[2].append(ln)

    def keep(n):
        return 100 <= n < 200 or 1000 <= n < 1250

    out = ['# DIV Game Studio 1 - original help (language & functions)',
           '',
           'Auto-extracted from DIV\\HELP\\HELP.DIV by _shared/tools/div_help_extract.py.',
           'Each topic is "## [N] title". Sample programs are in ```div code blocks.',
           '']
    for num, title, body in topics:
        if not keep(num):
            continue
        out.append(f'## [{num}] {title}')
        out.append('')
        in_code = False
        for ln in body:
            if not in_code and '{#9999,' in ln:
                pre, _, _ = ln.partition('{#9999,')
                if pre.strip():
                    out.append(convert_inline(pre))
                out.append('Sample program:')
                out.append('```div')
                in_code = True
                continue
            if in_code:
                if ln.strip() == '{-}':
                    out.append('```')
                    in_code = False
                    continue
                out.append(ln.replace('·', ''))
                continue
            if ln.startswith('See:') and len(out) and out[-1] == '':
                # navigation line, drop
                continue
            out.append(convert_inline(ln))
        if in_code:
            out.append('```')
        out.append('')
    s = '\n'.join(out)
    s = re.sub(r'\n{3,}', '\n\n', s)
    open(dst, 'w', encoding='utf-8', newline='\n').write(s)
    print(f'wrote {dst}: {sum(1 for t in topics if keep(t[0]))} topics')


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
