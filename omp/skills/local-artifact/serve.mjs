#!/usr/bin/env node
// Local stand-in for Claude Artifacts. Serves ~/artifacts/<slug>/index.html at
// http://127.0.0.1:<port>/<slug>/, injects window.claude.use("db") backed by
// ~/artifacts/<slug>/data.json, and reloads the page when index.html changes.
// No dependencies. Usage: node serve.mjs [--root DIR] [--port N]
import http from "node:http";
import fs from "node:fs";
import path from "node:path";
import os from "node:os";

const arg = (name, dflt) => {
  const i = process.argv.indexOf(name);
  return i > 0 ? process.argv[i + 1] : dflt;
};
const ROOT = path.resolve(arg("--root", process.env.ARTIFACT_ROOT || path.join(os.homedir(), "artifacts")));
const PORT = Number(arg("--port", process.env.ARTIFACT_PORT || 4317));
const SLUG = /^[a-z0-9][a-z0-9-]*$/;
const TYPES = { ".html": "text/html", ".js": "text/javascript", ".css": "text/css", ".svg": "image/svg+xml", ".png": "image/png", ".jpg": "image/jpeg", ".json": "application/json" };

fs.mkdirSync(ROOT, { recursive: true });

// slug -> { data, clients:Set<res>, watcher }
const live = new Map();
const dataFile = (slug) => path.join(ROOT, slug, "data.json");

function load(slug) {
  try { return JSON.parse(fs.readFileSync(dataFile(slug), "utf8")); } catch { return {}; }
}
function save(slug, data) {
  const file = dataFile(slug), tmp = file + ".tmp";
  fs.writeFileSync(tmp, JSON.stringify(data, null, 2));
  fs.renameSync(tmp, file);
}
function send(slug, msg) {
  const s = live.get(slug);
  if (!s) return;
  for (const res of s.clients) res.write(`data: ${JSON.stringify(msg)}\n\n`);
}
function state(slug) {
  let s = live.get(slug);
  if (s) return s;
  s = { data: load(slug), clients: new Set() };
  live.set(slug, s);
  let timer;
  // Watch the artifact folder: index.html edits reload the page; data.json edits
  // made outside the page (for example by the agent) are pushed to it.
  const changed = new Set();
  s.watcher = fs.watch(path.join(ROOT, slug), (_e, name) => {
    if (name) changed.add(name);
    clearTimeout(timer);
    timer = setTimeout(() => {
      const names = [...changed];
      changed.clear();
      if (names.includes("data.json")) {
        const next = load(slug);
        if (JSON.stringify(next) !== JSON.stringify(s.data)) {
          s.data = next;
          send(slug, { type: "db", data: s.data });
        }
      }
      if (names.some((n) => n !== "data.json" && !n.endsWith(".tmp"))) send(slug, { type: "reload" });
    }, 80);
  });
  return s;
}

function body(req) {
  return new Promise((resolve, reject) => {
    let b = "";
    req.on("data", (c) => (b += c));
    req.on("end", () => { try { resolve(b ? JSON.parse(b) : {}); } catch (e) { reject(e); } });
  });
}

const RUNTIME = fs.readFileSync(new URL("./runtime.js", import.meta.url), "utf8");

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url, "http://x");
  const parts = url.pathname.split("/").filter(Boolean);

  if (url.pathname === "/__health") return res.end(JSON.stringify({ ok: true, root: ROOT }));
  if (url.pathname === "/__runtime.js") {
    res.setHeader("content-type", "text/javascript");
    return res.end(RUNTIME);
  }

  if (parts.length === 0) {
    const slugs = fs.readdirSync(ROOT).filter((d) => SLUG.test(d) && fs.existsSync(path.join(ROOT, d, "index.html")));
    res.setHeader("content-type", "text/html");
    return res.end(`<!doctype html><meta charset=utf-8><title>Artifacts</title><body style="font:15px system-ui;margin:40px"><h1>Artifacts</h1><ul>${slugs.map((s) => `<li><a href="/${s}/">${s}</a></li>`).join("")}</ul>`);
  }

  const slug = parts[0];
  if (!SLUG.test(slug) || !fs.existsSync(path.join(ROOT, slug))) { res.statusCode = 404; return res.end("not found"); }

  // API: /<slug>/__db (GET all, POST {collection,id,doc|null}), /<slug>/__events (SSE)
  if (parts[1] === "__events") {
    const s = state(slug);
    res.writeHead(200, { "content-type": "text/event-stream", "cache-control": "no-cache", connection: "keep-alive" });
    res.write(`data: ${JSON.stringify({ type: "db", data: s.data })}\n\n`);
    s.clients.add(res);
    req.on("close", () => s.clients.delete(res));
    return;
  }
  if (parts[1] === "__db") {
    const s = state(slug);
    res.setHeader("content-type", "application/json");
    if (req.method === "GET") return res.end(JSON.stringify(s.data));
    if (req.method === "POST") {
      try {
        const { collection, id, doc } = await body(req);
        if (typeof collection !== "string" || typeof id !== "string") throw new Error("collection and id required");
        const col = (s.data[collection] ||= {});
        if (doc === null) delete col[id];
        else col[id] = { ...doc, updatedAt: new Date().toISOString() };
        save(slug, s.data);
        send(slug, { type: "db", data: s.data });
        return res.end(JSON.stringify({ ok: true }));
      } catch (e) {
        res.statusCode = 400;
        return res.end(JSON.stringify({ error: String(e.message || e) }));
      }
    }
    res.statusCode = 405;
    return res.end();
  }

  if (parts.length === 1 && !url.pathname.endsWith("/")) {
    res.writeHead(301, { location: `/${slug}/` });
    return res.end();
  }
  const rel = parts.slice(1).join("/") || "index.html";
  const file = path.resolve(ROOT, slug, rel);
  if (!file.startsWith(path.join(ROOT, slug) + path.sep) || path.basename(file) === "data.json") { res.statusCode = 403; return res.end(); }
  fs.readFile(file, (err, buf) => {
    if (err) { res.statusCode = 404; return res.end("not found"); }
    const ext = path.extname(file);
    res.setHeader("content-type", (TYPES[ext] || "application/octet-stream") + (ext === ".html" ? "; charset=utf-8" : ""));
    res.setHeader("cache-control", "no-store");
    if (ext !== ".html") return res.end(buf);
    // Inject the runtime first so page scripts can call window.claude.use("db").
    const html = buf.toString("utf8");
    const tag = `<script src="/__runtime.js" data-slug="${slug}"></script>`;
    const m = html.match(/<head[^>]*>/i);
    res.end(m ? html.replace(m[0], m[0] + tag) : tag + html);
  });
});

server.on("error", (e) => {
  if (e.code === "EADDRINUSE") { console.error(`port ${PORT} in use`); process.exit(2); }
  throw e;
});
server.listen(PORT, "127.0.0.1", () => console.log(`artifacts on http://127.0.0.1:${PORT}/ (root ${ROOT})`));
