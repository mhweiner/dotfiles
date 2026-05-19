#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
INSTALL_SCRIPT="${DOTFILES_DIR}/install.sh"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

FAKE_HOME="${TMP_DIR}/home"
FAKE_BIN="${TMP_DIR}/bin"
SETTINGS_PATH="${FAKE_HOME}/Library/Application Support/Cursor/User/settings.json"

mkdir -p "${FAKE_HOME}" "${FAKE_BIN}" "$(dirname "${SETTINGS_PATH}")"

cat >"${FAKE_BIN}/defaults" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "${FAKE_BIN}/defaults"

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

HOME="${FAKE_HOME}" PATH="${FAKE_BIN}:${PATH}" DOTFILES_SKIP_PACKAGES=1 bash "${INSTALL_SCRIPT}" >/dev/null 2>&1

python3 - <<'PY' "${SETTINGS_PATH}"
import json
import sys
from pathlib import Path

settings = json.loads(Path(sys.argv[1]).read_text())

assert settings["window.commandCenter"] is True
assert settings["terminal.external.osxExec"] == "/Applications/iTerm.app"
assert settings["terminal.integrated.defaultProfile.osx"] == "zsh"
assert settings["terminal.integrated.fontSize"] == 13
assert settings["terminal.integrated.cursorStyle"] == "block"
assert settings["terminal.integrated.shellIntegration.enabled"] is True
assert settings["terminal.integrated.gpuAcceleration"] == "on"
assert settings["terminal.integrated.fontFamily"] == "Hack Nerd Font Mono, Menlo, monospace"

profiles = settings["terminal.integrated.profiles.osx"]
assert "fish" in profiles
assert profiles["zsh"] == {"path": "zsh", "args": ["-l"]}

print("PASS: install.sh configures Cursor terminal settings idempotently.")
PY
