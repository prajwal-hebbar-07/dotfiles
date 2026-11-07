#!/usr/bin/env python3
"""Serve a detox checklist on 127.0.0.1 and save the reviewer's decisions.

Usage: serve.py <run-dir> [port]

GET  /               checklist.html (next to this script)
GET  /findings.json  <run-dir>/findings.json
POST /decisions      writes <run-dir>/decisions.json
"""
import json
import os
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

HERE = os.path.dirname(os.path.realpath(__file__))
RUN_DIR = os.path.realpath(sys.argv[1])
PORT = int(sys.argv[2]) if len(sys.argv) > 2 else 0


class Handler(BaseHTTPRequestHandler):
    def send(self, status, body, ctype):
        self.send_response(status)
        self.send_header("Content-Type", ctype)
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        path = self.path.split("?", 1)[0]
        if path in ("/", "/index.html"):
            name, ctype = os.path.join(HERE, "checklist.html"), "text/html; charset=utf-8"
        elif path == "/findings.json":
            name, ctype = os.path.join(RUN_DIR, "findings.json"), "application/json"
        else:
            return self.send(404, b"not found", "text/plain")
        with open(name, "rb") as f:
            self.send(200, f.read(), ctype)

    def do_POST(self):
        if self.path != "/decisions":
            return self.send(404, b"not found", "text/plain")
        try:
            data = json.loads(self.rfile.read(int(self.headers.get("Content-Length", 0))))
            if not isinstance(data.get("items"), list):
                raise ValueError("items must be a list")
        except ValueError as err:
            return self.send(400, str(err).encode(), "text/plain")
        tmp = os.path.join(RUN_DIR, "decisions.json.tmp")
        with open(tmp, "w") as f:
            json.dump(data, f, indent=2)
        os.replace(tmp, os.path.join(RUN_DIR, "decisions.json"))
        print("Decisions saved: %d item(s)" % len(data["items"]), flush=True)
        self.send(200, b'{"ok":true}', "application/json")

    def log_message(self, *args):
        pass


server = ThreadingHTTPServer(("127.0.0.1", PORT), Handler)
print("Serving http://127.0.0.1:%d/" % server.server_address[1], flush=True)
server.serve_forever()
