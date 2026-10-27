"""Builds public/index.html from games.json (cards), facts.json (slug -> facts, usually 3) and
changes.json (slug -> what the Godot version changes, shown as its own line), and copies
each game's original DIV source into public/src/ as a .txt file browsers show inline.
Usage: python -I build_index.py   (run from anywhere; build_and_deploy.sh runs it)"""
import json
import shutil
from html import escape
from pathlib import Path

WEB = Path(__file__).resolve().parent
PRG_DIR = WEB.parent / "DIV" / "PRG" / "Olegs"
PUBLIC = WEB / "public"

PAGE = """<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Olesch's DIV Games</title>
<style>
  body {{ background: #000; color: #ddd; font-family: system-ui, sans-serif; margin: 0; padding: 32px 16px; }}
  main {{ max-width: 720px; margin: 0 auto; }}
  h1 {{ color: #ffd000; margin-top: 0; }}
  img {{ display: block; width: 100%; height: auto; border-radius: 4px; image-rendering: pixelated; }}
  figure {{ margin: 24px 0 32px; }}
  figure img {{ image-rendering: auto; }}
  figcaption {{ margin-top: 12px; line-height: 1.5; }}
  article.game {{ padding: 16px; margin: 16px 0; border: 1px solid #333; border-radius: 8px; }}
  article.game:hover {{ border-color: #ffd000; }}
  article.game > a {{ color: #ddd; text-decoration: none; }}
  article.game > a img {{ margin-bottom: 12px; }}
  article.game strong {{ color: #fff; font-size: 1.2em; }}
  article.game p {{ margin: 4px 0 0; }}
  ul.facts {{ margin: 12px 0 0; padding-left: 20px; color: #bbb; font-size: .95em; }}
  ul.facts li {{ margin: 4px 0; }}
  p.changes {{ font-size: .9em; color: #9cf; margin-top: 8px; }}
  p.made {{ font-size: .9em; color: #ffd000; }}
  p.src {{ font-size: .9em; color: #888; }}
  p.src a {{ color: #ffd000; }}
  p.note {{ border: 1px solid #ffd000; border-radius: 8px; padding: 8px 12px; color: #ffd000; }}
  p.small {{ color: #888; font-size: .9em; }}
  p.small a {{ color: #ffd000; }}
  h2 {{ color: #ffd000; margin: 40px 0 0; }}
  h2 + p {{ color: #888; margin: 4px 0 0; }}
  nav {{ border: 1px solid #333; border-radius: 8px; padding: 4px 16px 12px; margin: 16px 0; }}
  nav h3 {{ color: #fff; font-size: 1em; margin: 12px 0 4px; }}
  nav ul {{ list-style: none; margin: 0; padding: 0; display: flex; flex-wrap: wrap; gap: 4px 16px; }}
  nav a {{ color: #ffd000; text-decoration: none; }}
  nav a:hover {{ text-decoration: underline; }}
  article.game {{ scroll-margin-top: 16px; }}
</style>
</head>
<body>
<main>
  <h1>Olesch's DIV Games</h1>
  <p class="note">You need a keyboard and mouse to play: these are DOS games and won't work on phones or tablets.</p>
  <p>Games I wrote as a kid in DIV Game Studio (DOS) between summer 2004 and spring 2007, when I was 14 to 16, rewritten in Godot to play in the browser.</p>
  <p>My two brothers and I often played together, all three of us on one PC with one keyboard, and you can see it in the games: many of them are for two, three or four players sharing a single keyboard.</p>
  <p>Claude rewrote every game in Godot from my original DIV code, which is written in DIV's own Pascal-like language. I played them and checked that they are true to the originals, and the original code is linked under every game. The Godot projects, my original DIV files and this website are all on <a href="https://github.com/Olesch/DIV-Games-Remakes">GitHub</a>.</p>
  <p>Some games also got an options screen from Claude for settings that were hard-coded in the original. I really didn't feel motivated to go back to programming in DIV: looking back, it is really clunky.</p>
  <p>Most of the facts under each game were written by Claude, from what it found in the code while porting; the ones about where a game came from are mine. A blue line under each game lists what the Godot version changes.</p>
{nav}
  <figure>
    <img src="img/div-games-studio.png" alt="DIV Game Studio in DOSBox: menus at the top, the graphics list of SIEGE.FPG on the left and the source code of SIEGE.PRG in a blue editor window on the right" width="1022" height="792">
    <figcaption>{div_caption}</figcaption>
  </figure>
  <p>If you stumbled upon this page by accident and also want to port your own DIV games to the web, feel free to use the <a href="src/DIV_PORTING_GUIDE.txt">DIV to Godot porting guide</a> Claude worked from. The converter for DIV graphics and fonts and everything else is in the <a href="https://github.com/Olesch/DIV-Games-Remakes">GitHub</a> repository.</p>
{sections}
  <p class="small">Needs a desktop browser with mouse and keyboard.</p>
  <p class="small">Games, code and website are under the <a href="https://github.com/Olesch/DIV-Games-Remakes/blob/main/LICENSE">MIT License</a>. Made with <a href="https://godotengine.org/license">Godot Engine</a> (MIT License, &copy; Godot Engine contributors, Juan Linietsky, Ariel Manzur); see <a href="https://github.com/Olesch/DIV-Games-Remakes/blob/main/THIRD_PARTY.md">third-party notices</a>.</p>
</main>
</body>
</html>
"""

DIV_CAPTION = (
    "This is where it all started: DIV Game Studio running in DOSBox, with my window layout from back then. "
    "On the right is the source code of Siege with its German comments, on the left the game's graphics file "
    "with airships and golems. DIV had its own code editor, paint program, font and sound tools, and turned "
    "everything into a real DOS game."
)


MONTHS = "Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec".split()


def _month(value: str) -> str:
    year, month = value.split("-")
    return f"{MONTHS[int(month) - 1]} {year}"


def made_line(made: str | None, finished: str | None) -> str:
    """games.json "made" / "finished": "YYYY-MM" (first and last dated work on the game) or null."""
    if not made:
        return f"Finished by {_month(finished)}" if finished else "Date unknown"
    if finished in (None, made):
        return f"Finished {_month(made)}"
    return f"Started {_month(made)} · finished {_month(finished)}"


def card(game: dict, facts: list, changes: str) -> str:
    slug = game["slug"]
    lines = [
        f'  <article class="game" id="{slug}">',
        f'    <a href="{slug}/">',
        f'      <img src="img/{slug}.png" alt="{escape(game["alt"])}" width="{game["width"]}" height="{game["height"]}">',
        f'      <strong>{escape(game["title"], quote=False)}</strong>',
        "    </a>",
        f'    <p>{escape(game["description"], quote=False)}</p>',
        f'    <p class="made">{made_line(game.get("made"), game.get("finished"))}</p>',
    ]
    if facts:
        lines.append('    <ul class="facts">')
        lines += [f"      <li>{escape(f, quote=False)}</li>" for f in facts]
        lines.append("    </ul>")
    if changes:
        lines.append(f'    <p class="changes"><b>Changed by Claude:</b> {escape(changes, quote=False)}</p>')
    links = ", ".join(f'<a href="src/{name}.txt">{name}</a>' for name in game["source"])
    lines.append(f'    <p class="src">Original DIV source: {links}</p>')
    lines.append("  </article>")
    return "\n".join(lines)


SECTIONS = [
    ("main", "Games", "The finished, bigger games, in the order I made them."),
    ("minor", "Small games, toys and experiments",
     "Tutorials, quick ideas, unfinished projects, a level editor and maths toys, in the order I made them."),
]


def release_key(game: dict) -> tuple:
    """Sort by finish month; games without any date go last."""
    when = game.get("finished") or game.get("made")
    return (when is None, when or "")


def main() -> None:
    games = json.loads((WEB / "games.json").read_text(encoding="utf-8"))
    facts_file = WEB / "facts.json"
    facts = json.loads(facts_file.read_text(encoding="utf-8")) if facts_file.exists() else {}
    changes_file = WEB / "changes.json"
    changes = json.loads(changes_file.read_text(encoding="utf-8")) if changes_file.exists() else {}
    published = set((WEB / "published.txt").read_text(encoding="utf-8").split())
    games = [g for g in games if g["slug"] in published]

    src_dir = PUBLIC / "src"
    src_dir.mkdir(exist_ok=True)
    for game in games:
        for name in game["source"]:
            shutil.copyfile(PRG_DIR / name, src_dir / f"{name}.txt")
    shutil.copyfile(WEB.parent / "_shared" / "DIV_PORTING_GUIDE.md", src_dir / "DIV_PORTING_GUIDE.txt")
    shutil.copyfile(WEB.parent / "DIV.png", PUBLIC / "img" / "div-games-studio.png")

    nav = ["  <nav>"]
    sections = []
    for category, heading, intro in SECTIONS:
        group = sorted((g for g in games if g["category"] == category), key=release_key)
        nav.append(f"    <h3>{escape(heading, quote=False)}</h3>")
        nav.append("    <ul>")
        nav += [f'      <li><a href="#{g["slug"]}">{escape(g["title"], quote=False)}</a></li>' for g in group]
        nav.append("    </ul>")
        sections.append(f'  <h2 id="{category}">{escape(heading, quote=False)}</h2>')
        sections.append(f"  <p>{escape(intro, quote=False)}</p>")
        sections += [card(g, facts.get(g["slug"], []), changes.get(g["slug"], "")) for g in group]
    nav.append("  </nav>")
    page = PAGE.format(div_caption=escape(DIV_CAPTION, quote=False), nav="\n".join(nav), sections="\n".join(sections))
    (PUBLIC / "index.html").write_text(page, encoding="utf-8", newline="\n")
    print(f"index.html: {len(games)} games, {sum(1 for g in games if facts.get(g['slug']))} with facts")


if __name__ == "__main__":
    main()
