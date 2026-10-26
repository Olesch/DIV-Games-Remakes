// Godot's .wasm is larger than Cloudflare Pages' 25 MiB per-file limit, so only a
// Brotli-compressed copy (index.wasm.br) is uploaded. Serve it as the .wasm with
// Content-Encoding: br; the browser decompresses it transparently.
export async function onRequest({ request, env, next }) {
  const url = new URL(request.url);
  if (!url.pathname.endsWith(".wasm")) return next();

  const asset = await env.ASSETS.fetch(new URL(url.pathname + ".br", url), request);
  if (!asset.ok) return asset;

  const headers = new Headers(asset.headers);
  headers.set("Content-Type", "application/wasm");
  headers.set("Content-Encoding", "br");
  headers.set("Cache-Control", "public, max-age=3600");
  return new Response(asset.body, { status: 200, headers, encodeBody: "manual" });
}
