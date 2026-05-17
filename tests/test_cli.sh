#!/usr/bin/env bash
set -euo pipefail
bin=${1:-./build/stakeholder}
"$bin" --list-values | grep -q 'code-analyzer'
"$bin" --output-format json --focus-family code_analyzer --seed 123 | grep -q '"family":"code-analyzer"'
"$bin" --output-format json --focus-family platform_engineering --seed 987 > /tmp/fortran-platform-a.json
"$bin" --output-format json --focus-family platform_engineering --seed 987 > /tmp/fortran-platform-b.json
diff -u /tmp/fortran-platform-a.json /tmp/fortran-platform-b.json
"$bin" --output-format json --focus-family fhir_profile_generator --seed 7 | grep -q 'grouped-fallback'
if "$bin" --experimental-provider local-demo >/tmp/fortran-provider.out 2>&1; then
  cat /tmp/fortran-provider.out
  exit 1
fi
grep -Eiq 'experimental|provider|fail-fast' /tmp/fortran-provider.out
