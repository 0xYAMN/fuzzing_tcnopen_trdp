#!/usr/bin/env bash
#
# Usage:
#   ./scripts/stop_fuzzing.sh

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUN_DIR="$REPO_ROOT/run"

for name in main asan sec1; do
    pidfile="$RUN_DIR/${name}.pid"

    if [[ -f "$pidfile" ]] && kill -0 "$(cat "$pidfile")" 2>/dev/null; then
        pid="$(cat "$pidfile")"
        kill -TERM "$pid"
        for _ in $(seq 1 10); do
            kill -0 "$pid" 2>/dev/null || break
            sleep 0.5
        done
        if kill -0 "$pid" 2>/dev/null; then
            echo "== $name (pid $pid) still alive after SIGTERM, sending SIGKILL =="
            kill -KILL "$pid" 2>/dev/null
        else
            echo "== stopped $name (pid $pid) =="
        fi
    else
        echo "== $name not running =="
    fi

    rm -f "$pidfile"
done
