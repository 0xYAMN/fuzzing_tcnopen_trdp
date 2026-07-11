#!/usr/bin/env bash
#
# Usage:
#   ./scripts/status_fuzzing.sh

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUN_DIR="$REPO_ROOT/run"

for name in main asan sec1; do
    pidfile="$RUN_DIR/${name}.pid"
    logfile="$RUN_DIR/${name}.log"

    if [[ -f "$pidfile" ]] && kill -0 "$(cat "$pidfile")" 2>/dev/null; then
        echo "== $name: running (pid $(cat "$pidfile")) =="
    else
        echo "== $name: not running =="
    fi

    if [[ -f "$logfile" ]]; then
        tail -n 3 "$logfile" | sed 's/^/     /'
    fi
    echo
done
