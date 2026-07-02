#!/bin/bash
# GateMatch — quick local server
# Usage:  ./serve.sh        (then open the printed URL)
cd "$(dirname "$0")" || exit 1
PORT="${1:-5173}"
URL="http://localhost:${PORT}"
echo ""
echo "  GateMatch is serving at  →  ${URL}"
echo "  (Ctrl+C to stop)"
echo ""
# open the browser automatically on macOS
( sleep 1; command -v open >/dev/null 2>&1 && open "${URL}" ) &
exec python3 -m http.server "${PORT}"
