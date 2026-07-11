#!/usr/bin/env bash
#
# Usage:
#   ./scripts/start_fuzzing.sh
#
# To watch the logs:
#   tail -f run/main.log   (or asan.log / sec1.log)


set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUN_DIR="$REPO_ROOT/run"
mkdir -p "$RUN_DIR" "$REPO_ROOT/output"

cd "$REPO_ROOT"

for bin in build-afl/fuzz_xml build-afl-asan/fuzz_xml build-afl-cmplog/fuzz_xml; do
    if [[ ! -x "$bin" ]]; then
        echo "error: $bin not found or not executable -- build it first (see cmake/toolchains/)" >&2
        exit 1
    fi
done

start_instance() {
    local name="$1"
    shift
    local pidfile="$RUN_DIR/${name}.pid"
    local logfile="$RUN_DIR/${name}.log"

    if [[ -f "$pidfile" ]] && kill -0 "$(cat "$pidfile")" 2>/dev/null; then
        echo "== $name already running (pid $(cat "$pidfile")), skipping -- stop_fuzzing.sh first to restart =="
        return
    fi

    nohup "$@" < /dev/null > "$logfile" 2>&1 &
    local pid=$!
    disown
    echo "$pid" > "$pidfile"

    sleep 1
    if ! kill -0 "$pid" 2>/dev/null; then
        echo "error: $name exited immediately -- check $logfile" >&2
        rm -f "$pidfile"
        return
    fi
    echo "== started $name (pid $pid), logging to $logfile =="
}

start_instance main \
    nix develop --command env AFL_NO_UI=1 AFL_AUTORESUME=1 \
    afl-fuzz -M main -i inputs/ -o output/ -x xml.dict \
    -c ./build-afl-cmplog/fuzz_xml -- ./build-afl/fuzz_xml @@

sleep 2

start_instance asan \
    nix develop --command env AFL_NO_UI=1 AFL_AUTORESUME=1 ASAN_OPTIONS=abort_on_error=1:detect_leaks=0:symbolize=0 \
    afl-fuzz -S asan -m none -i inputs/ -o output/ -x xml.dict \
    -- ./build-afl-asan/fuzz_xml @@

start_instance sec1 \
    nix develop --command env AFL_NO_UI=1 AFL_AUTORESUME=1 \
    afl-fuzz -S sec1 -p exploit -i inputs/ -o output/ -x xml.dict \
    -- ./build-afl/fuzz_xml @@

echo
echo "PID files + logs in $RUN_DIR/"
echo "Watch live: tail -f $RUN_DIR/main.log   (or asan.log / sec1.log)"
echo "Status:     $REPO_ROOT/scripts/status_fuzzing.sh"
echo "Stop:       $REPO_ROOT/scripts/stop_fuzzing.sh"
