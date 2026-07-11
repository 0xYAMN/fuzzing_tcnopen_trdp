#!/usr/bin/env bash
#
# Builds all three fuzzing targets:
#   build-afl         plain AFL++ instrumentation
#   build-afl-asan    AFL++ instrumentation + ASan
#   build-afl-cmplog  AFL++ instrumentation + CmpLog
#
# Usage:
#   ./scripts/build_all.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

for tool in cmake afl-clang-fast afl-clang-fast++; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "error: $tool not found on PATH -- install AFL++ and cmake first" >&2
        exit 1
    fi
done

JOBS="$(nproc 2>/dev/null || echo 4)"

build() {
    local dir="$1"
    local toolchain="$2"

    echo "== configuring $dir =="
    cmake -B "$dir" -S . -DCMAKE_TOOLCHAIN_FILE="$toolchain"

    echo "== building $dir =="
    cmake --build "$dir" -j "$JOBS"
}

build build-afl         cmake/toolchains/afl.cmake
build build-afl-asan    cmake/toolchains/afl-asan.cmake
build build-afl-cmplog  cmake/toolchains/afl-cmplog.cmake

echo
echo "All builds done:"
for bin in build-afl/fuzz_xml build-afl-asan/fuzz_xml build-afl-cmplog/fuzz_xml; do
    if [[ -x "$bin" ]]; then
        echo "  OK   $bin"
    else
        echo "  MISSING $bin"
    fi
done
