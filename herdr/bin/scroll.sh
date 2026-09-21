#!/bin/sh
# Scroll the focused Herdr pane. Argument is a signed line delta (`-3`, `3`)
# or `half`/`page` optionally prefixed with `-` for scroll-down.
# Used by [[keys.command]] bindings; talks to the socket API directly because
# the CLI has no `pane scroll` subcommand.
exec python3 - "$1" <<'PY'
import json
import os
import socket
import sys

arg = sys.argv[1]
sock_path = os.environ.get("HERDR_SOCKET_PATH") or os.path.expanduser(
    "~/.config/herdr/herdr.sock"
)
pane_id = os.environ.get("HERDR_ACTIVE_PANE_ID") or os.environ.get("HERDR_PANE_ID")
if not pane_id:
    sys.exit(0)


def call(method, params):
    # The server closes the connection after each request.
    conn = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    conn.connect(sock_path)
    f = conn.makefile("rw")
    f.write(json.dumps({"id": "r", "method": method, "params": params}) + "\n")
    f.flush()
    line = f.readline()
    conn.close()
    return json.loads(line) if line else {}


info = call("pane.get", {"pane_id": pane_id})
scroll = (info.get("result") or {}).get("pane", {}).get("scroll")
if not scroll:
    sys.exit(0)

rows = scroll["viewport_rows"]
if arg.lstrip("-") == "half":
    delta = rows // 2
elif arg.lstrip("-") == "page":
    delta = rows
else:
    delta = int(arg.lstrip("-"))
if arg.startswith("-"):
    delta = -delta

offset = scroll["offset_from_bottom"] + delta
offset = max(0, min(scroll["max_offset_from_bottom"], offset))
call("pane.scroll", {"pane_id": pane_id, "offset_from_bottom": offset})
PY
