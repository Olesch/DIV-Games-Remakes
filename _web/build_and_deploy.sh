#!/usr/bin/env bash
# Builds each listed game's "Web" export preset into public/<slug>/ and deploys to
# Cloudflare Pages (olesch-div-games.pages.dev).
# Usage: ./build_and_deploy.sh [--no-deploy] Microcosm [OtherGame ...]
# --no-deploy: only export the games and rebuild public/index.html, skip dist/ and wrangler.
# Each game's export_presets.cfg must export to ../_web/public/<slug>/index.html, with
# html/canvas_resize_policy=0 and html/head_include loading ../scale-switch.js?w=<width>&h=<height>
# (the page scales the fixed-size canvas; see public/scale-switch.js).
# The .wasm is over Pages' 25 MiB file limit, so it is shipped Brotli-compressed
# and served by functions/_middleware.js.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
deploy=1
if [ "${1:-}" = "--no-deploy" ]; then deploy=0; shift; fi

for game in "$@"; do
  (cd "$root/$game" && godot --headless --path . --export-release "Web")
  out="$(sed -n 's#^export_path="\.\./_web/\(.*\)/index\.html"#\1#p' "$root/$game/export_presets.cfg")"
  wasm="$root/_web/$out/index.wasm"
  brotli -f -q 11 -o "$wasm.br" "$wasm"
  rm "$wasm"
done

# Deploy only the shared files plus the games listed in published.txt, so unfinished
# exports from ports in progress never go live.
cd "$root/_web"
python -I build_index.py  # index.html from games.json + facts.json, sources into public/src
[ "$deploy" = 1 ] || exit 0
rm -rf dist
mkdir dist
cp public/index.html public/scale-switch.js dist/
cp -r public/img public/src dist/
while read -r slug; do
  [ -n "$slug" ] && cp -r "public/$slug" dist/
done < published.txt
npx --yes wrangler@4 pages deploy dist --project-name olesch-div-games --branch main --commit-dirty=true
