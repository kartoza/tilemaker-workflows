#!/usr/bin/env bash

# Stop any running mbtileserver and python HTTP server instances
# started by run_server.sh

KILLED=0

# Stop mbtileserver
PIDS=$(pgrep -f "mbtileserver" 2>/dev/null)
if [ -n "$PIDS" ]; then
  echo "Stopping mbtileserver (PIDs: $PIDS)..."
  kill "$PIDS" 2>/dev/null
  KILLED=$((KILLED + 1))
fi

# Stop the python viewer server (http.server on viewer port)
PIDS=$(pgrep -f "python3 -m http.server" 2>/dev/null)
if [ -n "$PIDS" ]; then
  echo "Stopping viewer server (PIDs: $PIDS)..."
  kill "$PIDS" 2>/dev/null
  KILLED=$((KILLED + 1))
fi

if [ "$KILLED" -eq 0 ]; then
  echo "No running tile servers found."
else
  echo "All tile servers stopped."
fi
