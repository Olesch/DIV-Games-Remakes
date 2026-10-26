// Scale switch for the Godot game pages. The game renders into a fixed-size canvas
// (export preset: canvas_resize_policy = None) and this script scales that canvas
// with CSS, nearest-neighbour:
//   "Fit to window": as large as fits, keeping the aspect ratio
//   "Sharp pixels":  only whole-number factors (1x, 2x, ...), so every pixel stays square
// Include as <script src="../scale-switch.js?w=1024&h=768"></script> (the game's size).
(function () {
  const KEY = "divScaleMode";
  const params = new URL(document.currentScript.src).searchParams;
  const gameW = Number(params.get("w")) || 1024;
  const gameH = Number(params.get("h")) || 768;
  let mode = "fit";
  try { mode = localStorage.getItem(KEY) || "fit"; } catch (e) {}

  const css = `
    html, body { width: 100%; height: 100%; margin: 0; overflow: hidden; background: #000; }
    #canvas { position: absolute; image-rendering: pixelated; image-rendering: crisp-edges; }
    #scale-switch { position: fixed; left: 8px; bottom: 8px; z-index: 10; display: flex;
      gap: 2px; padding: 3px; border-radius: 6px; background: rgba(30,30,30,.85);
      font: 12px system-ui, sans-serif; opacity: .35; transition: opacity .2s; }
    #scale-switch:hover, #scale-switch:focus-within { opacity: 1; }
    #scale-switch button { border: 0; border-radius: 4px; padding: 4px 8px; cursor: pointer;
      background: transparent; color: #bbb; font: inherit; }
    #scale-switch button[aria-pressed="true"] { background: #ffd000; color: #000; }`;

  function layout() {
    const canvas = document.getElementById("canvas");
    if (!canvas) return;
    const winW = window.innerWidth, winH = window.innerHeight;
    let scale = Math.min(winW / gameW, winH / gameH);
    // Whole-number factors only; below 1x there is nothing sharper than plain shrinking.
    if (mode === "sharp" && scale >= 1) scale = Math.floor(scale);
    const w = Math.round(gameW * scale), h = Math.round(gameH * scale);
    canvas.style.width = w + "px";
    canvas.style.height = h + "px";
    canvas.style.left = Math.floor((winW - w) / 2) + "px";
    canvas.style.top = Math.floor((winH - h) / 2) + "px";
  }

  function apply(next) {
    mode = next;
    try { localStorage.setItem(KEY, mode); } catch (e) {}
    for (const b of document.querySelectorAll("#scale-switch button")) {
      b.setAttribute("aria-pressed", String(b.dataset.mode === mode));
    }
    layout();
  }

  document.addEventListener("DOMContentLoaded", function () {
    const style = document.createElement("style");
    style.textContent = css;
    document.head.appendChild(style);

    const canvas = document.getElementById("canvas");
    canvas.width = gameW;
    canvas.height = gameH;

    const bar = document.createElement("div");
    bar.id = "scale-switch";
    bar.setAttribute("role", "group");
    bar.setAttribute("aria-label", "Screen scaling");
    bar.innerHTML =
      '<button type="button" data-mode="fit" title="Scale the game to fill the window">Fit to window</button>' +
      '<button type="button" data-mode="sharp" title="Scale only by whole numbers (1x, 2x...) so pixels stay crisp">Sharp pixels</button>';
    bar.addEventListener("click", function (e) {
      const b = e.target.closest("button");
      if (!b) return;
      apply(b.dataset.mode);
      canvas.focus();  // give the keyboard back to the game
    });
    document.body.appendChild(bar);

    window.addEventListener("resize", layout);
    apply(mode);
  });
})();
