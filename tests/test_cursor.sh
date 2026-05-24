#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=tests/lib.sh
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"

setup_fake_home
install_fake_defaults
SETTINGS_DIR="${FAKE_HOME}/Library/Application Support/Cursor/User"
SETTINGS_PATH="${SETTINGS_DIR}/settings.json"
mkdir -p "${SETTINGS_DIR}"

cat >"${SETTINGS_PATH}" <<'EOF'
{
  "window.commandCenter": true,
  "terminal.integrated.profiles.osx": {
    "fish": {
      "path": "fish"
    }
  }
}
EOF

DOTFILES_NO_PROMPTS=1 run_install_config >/dev/null 2>&1

python3 - <<'PY' "${SETTINGS_PATH}"
import json
import sys
from pathlib import Path

settings = json.loads(Path(sys.argv[1]).read_text())
assert settings["window.commandCenter"] is True
assert "fish" in settings["terminal.integrated.profiles.osx"]
PY

assert_cursor_terminal_defaults "${SETTINGS_PATH}"

setup_fake_home
install_fake_defaults
SETTINGS_DIR="${FAKE_HOME}/Library/Application Support/Cursor/User"
SETTINGS_PATH="${SETTINGS_DIR}/settings.json"
mkdir -p "${SETTINGS_DIR}"

cat >"${SETTINGS_PATH}" <<'EOF'
{
  "terminal.integrated.fontSize": 20
}
EOF

printf 'n\n' | DOTFILES_ALLOW_STDIN_PROMPTS=1 run_install_config >/dev/null 2>&1

python3 - <<'PY' "${SETTINGS_PATH}"
import json
import sys
from pathlib import Path

settings = json.loads(Path(sys.argv[1]).read_text())
assert settings["terminal.integrated.fontSize"] == 20
assert "terminal.integrated.defaultProfile.osx" not in settings
PY

test_pass "install merges Cursor terminal defaults and respects overwrite prompts"
