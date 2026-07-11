#!/usr/bin/env bash
# Runs every saved afl-fuzz crash testcase (across all output/*/crashes/) through an XSD check with libxml2
#
#   VALID     -- schema-valid config that still crashes the parser
#   INVALID   -- well-formed XML, but fails schema validation
#   MALFORMED -- not well-formed XML at all
#
# Usage:
#   ./scripts/check_xml_validity_of_crashes.sh [output_dir] [xsd_path]
#   (defaults: output/, trdp/src/api/trdp-config.xsd)

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${1:-$REPO_ROOT/output}"
XSD_PATH="${2:-$REPO_ROOT/trdp/src/api/trdp-config.xsd}"
XSD_CHECK="$REPO_ROOT/build/xsd_check"

if [[ ! -x "$XSD_CHECK" ]]; then
    echo "error: $XSD_CHECK not found -- build it first: cmake --build build --target xsd_check" >&2
    exit 1
fi

mapfile -t crash_files < <(find "$OUTPUT_DIR" -type f -path '*/crashes/id:*' 2>/dev/null | sort)

if [[ ${#crash_files[@]} -eq 0 ]]; then
    echo "no crash testcases found under $OUTPUT_DIR/*/crashes/"
    exit 0
fi

declare -a valid_files=()
declare -a invalid_files=()
declare -a malformed_files=()

for f in "${crash_files[@]}"; do
    verdict="$("$XSD_CHECK" "$XSD_PATH" "$f" | cut -d' ' -f1)"
    case "$verdict" in
        VALID) valid_files+=("$f") ;;
        INVALID) invalid_files+=("$f") ;;
        *) malformed_files+=("$f") ;;
    esac
done

echo "Checked ${#crash_files[@]} crash testcase(s) against $(basename "$XSD_PATH")"
echo "  VALID     (schema-valid, still crashes): ${#valid_files[@]}"
echo "  INVALID   (well-formed, fails schema):    ${#invalid_files[@]}"
echo "  MALFORMED (not well-formed XML):          ${#malformed_files[@]}"

if [[ ${#valid_files[@]} -gt 0 ]]; then
    echo
    echo "== schema-valid crashes (highest priority) =="
    printf '%s\n' "${valid_files[@]}"
fi
