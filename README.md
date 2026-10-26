# Olesch's DIV Games - Godot remakes

Games Oleg ("Olesch") wrote as a kid in **DIV Game Studio** (DOS, 2004-2007), rewritten as real
Godot 4.7 games (not DIV emulation) and published for the browser at
**https://olesch-div-games.pages.dev/** (Cloudflare Pages project `olesch-div-games`).

## Folder layout

| Path | What |
|---|---|
| `<Game>\` (e.g. `Castle\`, `Microcosm\`, `S-Type\`, ~35 folders) | One Godot 4.7 project per game: `project.godot`, `scenes\`, `scripts\`, `assets\` (converted DIV graphics/fonts/data), `export_presets.cfg` (the "Web" preset), `PORTING_NOTES.md` (controls, deviations, what is verified), `screenshot_gameplay.png` |
| `DIV\` | The DIV Game Studio install. **Only Oleg's own originals are in git** (see below); DIV itself is not committed |
| `DIV\PRG\Olegs\*.PRG` | His original programs (DIV language, cp850 text, CRLF, German comments) |
| `DIV\FPG\Olegs\`, `DIV\FNT\Olegs\` | His graphics and fonts; plus `DIV\FNT\BALLKILL.FNT`, `DIV\FNT\NEW_FONT.FNT` |
| `DIV\MAP\*.MAP`, `DIV\PAL\MANDBROT.PAL`, `DIV\Saves\`, `DIV\DAT\*.DAT`, `DIV\PRG\GAMES\EFFEKTE.PRG` | His maps, palette, level/save/hiscore data, one more program |
| `_shared\DIV_PORTING_GUIDE.md` | How DIV works and how to port a game to Godot (section 1: where things are, section 14: the asset converter) |
| `_shared\PORT_BRIEF.md` | Brief for porting one game (incl. the web export rules) |
| `_shared\GAMES_INDEX.md` | All of Oleg's PRGs: what each game is and which files it loads |
| `_shared\DIV_HELP_REFERENCE.md` | The original DIV help (functions, statements) |
| `_shared\tools\div_convert.py` | DIV -> PNG/JSON/BMFont/WAV asset converter (Python 3, no dependencies) |
| `_web\` | The website: `games.json`, `facts.json`, `changes.json`, `published.txt`, `build_index.py`, `build_and_deploy.sh`, `functions\_middleware.js`, `public\` |
| `OPEN_DECISIONS.md` | Open questions for the owner |
| `DIV.png` | Screenshot of DIV Game Studio (used on the landing page) |
| `setup.bat` | Windows setup: checks prerequisites, imports all projects, optionally builds the web exports |

List of games: `_web\games.json` (title, slug, description, dates, category, original source files) and
`_shared\GAMES_INDEX.md` (all PRGs with what they load). The game folder name is what you pass to the
scripts (e.g. `Castle`), the slug is the URL path (e.g. `/castle/`, set by `export_path` in the preset).

## Prerequisites

- **Godot 4.7.2** on PATH as `godot`, with the **4.7.2 export templates** installed
  (editor: *Editor > Manage Export Templates > Download*; the Web preset uses
  `web_nothreads_release.zip` because `variant/thread_support=false`).
- **Python 3.12** on PATH as `python` (converter and `build_index.py`; standard library only).
- **Git for Windows** (Git Bash runs `_web/build_and_deploy.sh`).
- **brotli** CLI (compresses the `.wasm`; Git for Windows ships one in `mingw64\bin`).
- **Node.js** (for `npx wrangler`, only needed to deploy) and a **Cloudflare account** with access to the
  Pages project `olesch-div-games`; log in once with `npx wrangler login`.

## Setup from scratch

```bat
setup.bat                    rem check prerequisites, then import every Godot project headless
setup.bat check              rem only check prerequisites (prints what is missing)
setup.bat import Castle Fort rem import only these projects
setup.bat build              rem check + import + export ALL games to _web\public\<slug>\ and rebuild
                             rem _web\public\index.html (runs build_and_deploy.sh --no-deploy; never deploys)
setup.bat build Castle       rem same for one or more games
```

Importing runs `godot --headless --path <Game> --import` for every folder with a `project.godot`. It
creates each project's `.godot\` cache (not in git); the `*.import` and `*.uid` files are in git.

## Open / run a game

```bash
godot -e --path Castle      # open in the editor
godot --path Castle         # run the main scene
```
Controls and details are in each `<Game>\PORTING_NOTES.md`. Many projects have a headless debug autotest
(e.g. `godot --path Microcosm res://scenes/game.tscn -- --autotest`, see that project's notes).

## Re-convert assets from the DIV originals

Each project's `assets\` folder is committed, so this is only needed to regenerate them.
See `_shared\DIV_PORTING_GUIDE.md` section 14:

```bash
python _shared/tools/div_convert.py game DIV/PRG/Olegs/MINICOSM.PRG Microcosm/assets
python _shared/tools/div_convert.py info DIV/FPG/Olegs/CASTLE.FPG     # list graphics
```
`game` converts everything a PRG loads (resolving paths the way DIV does) and writes
`assets\manifest.json` with the `resolved` original of each resource. Other commands: `fpg`, `map`, `fnt`,
`sysfont`, `pal`, `pcm`, `dat`, `info`. Some ports post-process or curate their assets (e.g.
`Heatfighter\tools\bake_assets.py`, `Stranded\assets\data`); check the project's `PORTING_NOTES.md`
before overwriting `assets\`. The DIV originals must stay at their paths under `DIV\` (the converter and
`build_index.py` read `DIV\PRG\Olegs\`).

## Export a game to the web

Each project has one export preset, "Web", with `export_path="../_web/public/<slug>/index.html"`,
`html/canvas_resize_policy=0` and a `head_include` that loads `../scale-switch.js?w=<W>&h=<H>` (the page
scales the fixed-size canvas; see `_web\public\scale-switch.js`). Rules for new presets: `_shared\PORT_BRIEF.md`.

```bash
bash _web/build_and_deploy.sh --no-deploy Castle Atoms   # export + compress, rebuild index.html, no deploy
```
For each game this runs `godot --headless --path . --export-release "Web"`, then
`brotli -f -q 11 -o index.wasm.br index.wasm` and deletes `index.wasm`.

## Build the landing page

`python -I _web/build_index.py` (also run by `build_and_deploy.sh`) writes `_web\public\index.html` from:
- `_web\games.json` - one card per game (slug, title, alt text, image size, description, `source` PRGs,
  `made`/`finished` as `YYYY-MM`, `category` `main` or `minor`),
- `_web\facts.json` - slug -> list of facts, `_web\changes.json` - slug -> what the Godot version changes,
- `_web\published.txt` - only these slugs get a card (and are deployed).

It also copies each card's original PRGs to `_web\public\src\<NAME>.PRG.txt` (with the names in `REDACT`
shortened), the porting guide to `src\DIV_PORTING_GUIDE.txt` and `DIV.png` to
`img\div-games-studio.png`. The card picture is `_web\public\img\<slug>.png` (hand-made, in git).

## Deploy

```bash
bash _web/build_and_deploy.sh [Game ...]
```
Exports the listed games (none = only rebuild the page), runs `build_index.py`, assembles `_web\dist\`
from `public\index.html`, `scale-switch.js`, `img\`, `src\` and the `public\<slug>\` folders listed in
`published.txt` (so unfinished ports never go live), then runs
`npx --yes wrangler@4 pages deploy dist --project-name olesch-div-games --branch main --commit-dirty=true`.
To publish a new game: add it to `games.json` (+ `facts.json`, `changes.json`, `img\<slug>.png`), add its
slug to `published.txt`, then run the script with its folder name.

### Why `.wasm.br` and `_middleware.js`

Godot's `index.wasm` is larger than Cloudflare Pages' 25 MiB per-file limit, so only the Brotli-compressed
`index.wasm.br` is uploaded. `_web\functions\_middleware.js` (a Pages Function, deployed by wrangler from
`_web\functions\`) catches every request ending in `.wasm`, fetches `<path>.br` from the static assets and
returns it with `Content-Type: application/wasm` and `Content-Encoding: br`, so the browser decompresses it
transparently and Godot's loader sees a normal `.wasm`.

## What is not in git

`.godot\` caches, `_web\dist\`, `.wrangler\`, the web exports in `_web\public\<slug>\` and the generated
`_web\public\index.html`, `public\src\`, `public\img\div-games-studio.png` (all rebuilt by the scripts above),
and the DIV Game Studio install itself (see `.gitignore`).
