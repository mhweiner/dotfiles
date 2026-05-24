#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd -P)"
cd "$ROOT"

shell_files=(
  install.sh
  validate.sh
  bin/listenport
  tests/*.sh
)

echo "==> shellcheck"
if ! command -v shellcheck &>/dev/null; then
  echo "shellcheck not found. Install with: brew install shellcheck"
  exit 1
fi
shellcheck -x "${shell_files[@]}"

echo "==> tests"
for test_script in tests/*.sh; do
  echo "-- ${test_script}"
  bash "${test_script}"
done

echo "validate: OK"
