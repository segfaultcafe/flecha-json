#!/usr/bin/env bash
set -euo pipefail

repository_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
work_root=$(mktemp -d "${TMPDIR:-/tmp}/flecha-json-readme.XXXXXX")
project_root="$work_root/example"

cleanup() {
    rm -rf -- "$work_root"
}
trap cleanup EXIT

mkdir -p "$project_root/src"
printf '%s\n' \
    '[package]' \
    'name = "readme_example"' \
    'version = "0.1.0"' \
    'kind = "program"' \
    '' \
    '[dependencies]' \
    "json = { path = \"$repository_root\" }" \
    > "$project_root/longbow.toml"

awk '
    /^<!-- checked-example:start -->$/ { section = 1; next }
    section && /^```flecha$/ && !found { found = 1; capture = 1; next }
    capture && /^```$/ { capture = 0; exit }
    capture { print }
    END { if (!found) exit 1 }
' "$repository_root/README.md" > "$project_root/src/main.fl"

output=$(
    LONGBOW_CACHE_DIR="$work_root/cache" \
        longbow run "$project_root"
)
expected=$'{"display_name":"Ada","active":true}\nAda'
if [[ "$output" != "$expected" ]]; then
    printf 'README example produced unexpected output:\n%s\n' "$output" >&2
    exit 1
fi
