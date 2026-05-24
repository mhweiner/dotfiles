#!/usr/bin/env bash
# Shared helpers for dotfiles install tests.
set -euo pipefail

_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
DOTFILES_DIR="$(cd "${_LIB_DIR}/.." && pwd -P)"
INSTALL_SCRIPT="${DOTFILES_DIR}/install.sh"

MARK_BEGIN='>>> dotfiles BEGIN'

test_fail() {
  echo "FAIL: $*" >&2
  exit 1
}

test_pass() {
  echo "PASS: $*"
}

assert_git_no_unstaged_changes() {
  local pathspec="$1"
  if ! git -C "${DOTFILES_DIR}" diff --quiet -- "${pathspec}"; then
    git -C "${DOTFILES_DIR}" diff -- "${pathspec}"
    test_fail "expected no unstaged git changes under ${pathspec}"
  fi
}

setup_fake_home() {
  TMP_DIR="$(mktemp -d)"
  export TMP_DIR
  export FAKE_HOME="${TMP_DIR}/home"
  export FAKE_BIN="${TMP_DIR}/bin"
  mkdir -p "${FAKE_HOME}" "${FAKE_BIN}"
  trap 'rm -rf "${TMP_DIR}"' EXIT
}

install_fake_git() {
  cat >"${FAKE_BIN}/git" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
  chmod +x "${FAKE_BIN}/git"
}

install_fake_node() {
  cat >"${FAKE_BIN}/node" <<'EOF'
#!/usr/bin/env bash
echo "v24.0.0"
EOF
  chmod +x "${FAKE_BIN}/node"
}

install_fake_defaults() {
  cat >"${FAKE_BIN}/defaults" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
  chmod +x "${FAKE_BIN}/defaults"
}

install_logging_defaults() {
  DEFAULTS_LOG="${TMP_DIR}/defaults.log"
  export DEFAULTS_LOG
  cat >"${FAKE_BIN}/defaults" <<EOF
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "\$*" >>"${DEFAULTS_LOG}"
exit 0
EOF
  chmod +x "${FAKE_BIN}/defaults"
}

# Stateful defaults stub for iTerm2 migration tests.
# Set ITERM2_CUSTOM_FOLDER and ITERM2_LOAD_CUSTOM=1 before calling.
install_iterm2_defaults_stub() {
  DEFAULTS_LOG="${TMP_DIR}/defaults.log"
  export DEFAULTS_LOG
  cat >"${FAKE_BIN}/defaults" <<EOF
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "\$*" >>"${DEFAULTS_LOG}"
case "\${1:-}" in
  read)
    case "\${2:-}" in
      com.googlecode.iterm2)
        case "\${3:-}" in
          LoadPrefsFromCustomFolder)
            [[ "\${ITERM2_LOAD_CUSTOM:-0}" == "1" ]] && echo "1" && exit 0
            echo "0"
            exit 0
            ;;
          PrefsCustomFolder)
            if [[ -n "\${ITERM2_CUSTOM_FOLDER:-}" ]]; then
              echo "\${ITERM2_CUSTOM_FOLDER}"
              exit 0
            fi
            exit 1
            ;;
        esac
        ;;
    esac
    ;;
  write|delete)
    exit 0
    ;;
esac
exit 0
EOF
  chmod +x "${FAKE_BIN}/defaults"
}

install_fake_nvm() {
  mkdir -p "${FAKE_HOME}/.nvm"
  printf '%s\n' '# fake nvm loader' >"${FAKE_HOME}/.nvm/nvm.sh"
}

# Logs every brew invocation to BREW_LOG.
install_logging_brew() {
  local installed_casks="${1:-}"
  BREW_LOG="${TMP_DIR}/brew.log"
  export BREW_LOG
  cat >"${FAKE_BIN}/brew" <<EOF
#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '%s\n' "\$*" >>"\${BREW_LOG}"
}

if [[ "\${1:-}" == "shellenv" ]]; then
  exit 0
fi

if [[ "\${1:-}" == "list" ]]; then
  if [[ "\${2:-}" == "--cask" && -n "\${3:-}" ]]; then
    case "\${3}" in
${installed_casks}
      *) exit 1 ;;
    esac
  fi
  exit 1
fi

if [[ "\${1:-}" == "reinstall" || "\${1:-}" == "install" ]]; then
  log "\$*"
fi

exit 0
EOF
  chmod +x "${FAKE_BIN}/brew"
}

run_install() {
  HOME="${FAKE_HOME}" PATH="${FAKE_BIN}:${PATH}" \
    DOTFILES_SKIP_PACKAGES="${DOTFILES_SKIP_PACKAGES:-0}" \
    DOTFILES_NO_PROMPTS="${DOTFILES_NO_PROMPTS:-0}" \
    DOTFILES_ALLOW_STDIN_PROMPTS="${DOTFILES_ALLOW_STDIN_PROMPTS:-0}" \
    DOTFILES_ASSUME_YES="${DOTFILES_ASSUME_YES:-0}" \
    bash "${INSTALL_SCRIPT}"
}

run_install_config() {
  DOTFILES_SKIP_PACKAGES=1 run_install
}

assert_zshrc_sources_dotfiles() {
  local zshrc="${FAKE_HOME}/.zshrc"
  [[ -f "${zshrc}" ]] || test_fail "expected ${zshrc} to exist"
  grep -qF "${MARK_BEGIN}" "${zshrc}" || test_fail "expected dotfiles marker in ${zshrc}"
  grep -qF "source \"${DOTFILES_DIR}/.zshrc\"" "${zshrc}" || test_fail "expected dotfiles source line in ${zshrc}"
}

assert_cursor_terminal_defaults() {
  local settings_path="$1"
  python3 - <<'PY' "${settings_path}"
import json
import sys
from pathlib import Path

settings = json.loads(Path(sys.argv[1]).read_text())

expected = {
    "terminal.external.osxExec": "/Applications/iTerm.app",
    "terminal.integrated.defaultProfile.osx": "zsh",
    "terminal.integrated.fontFamily": "Hack Nerd Font Mono, Menlo, monospace",
    "terminal.integrated.fontSize": 13,
    "terminal.integrated.cursorStyle": "block",
    "terminal.integrated.shellIntegration.enabled": True,
    "terminal.integrated.gpuAcceleration": "on",
}

for key, value in expected.items():
    assert settings.get(key) == value, f"{key}={settings.get(key)!r}, expected {value!r}"

profiles = settings["terminal.integrated.profiles.osx"]
assert profiles["zsh"] == {"path": "zsh", "args": ["-l"]}
PY
}

assert_iterm2_template_font() {
  local plist_path="${DOTFILES_DIR}/iterm2/com.googlecode.iterm2.plist"
  python3 - <<'PY' "${plist_path}"
import plistlib
import sys
from pathlib import Path

plist_path = Path(sys.argv[1])
with plist_path.open("rb") as f:
    data = plistlib.load(f)

default_guid = data["Default Bookmark Guid"]
default_profile = next(
    b for b in data["New Bookmarks"] if b.get("Guid") == default_guid
)

expected_font = "HackNFM-Regular 14"
assert default_profile.get("Normal Font") == expected_font
assert default_profile.get("Non Ascii Font") == expected_font
assert default_profile.get("Use Non-ASCII Font") is True
PY
}

assert_iterm2_template_sanitized() {
  local plist_path="${DOTFILES_DIR}/iterm2/com.googlecode.iterm2.plist"
  python3 - <<'PY' "${plist_path}"
import plistlib
import sys
from pathlib import Path

plist_path = Path(sys.argv[1])
with plist_path.open("rb") as f:
    data = plistlib.load(f)

for key in data:
    assert not key.startswith("NSWindow Frame"), f"machine-specific key in template: {key!r}"
    assert not key.startswith("NoSync"), f"machine-specific key in template: {key!r}"
assert "Window Arrangements" not in data, "template must not ship saved window arrangements"

for bookmark in data.get("New Bookmarks", []):
    wd = bookmark.get("Working Directory")
    assert not wd, f"profile {bookmark.get('Name')!r} has Working Directory={wd!r}"
    assert bookmark.get("Custom Directory") == "No"
PY
}

assert_iterm2_template_no_deprecated_key_mappings() {
  local plist_path="${DOTFILES_DIR}/iterm2/com.googlecode.iterm2.plist"
  python3 - <<'PY' "${plist_path}"
import plistlib
import sys
from pathlib import Path

# iTerm2 3.5.6+ flags these ctrl+arrow mappings as deprecated on macOS Sequoia
# because they conflict with window-tiling shortcuts.
deprecated_keys = {
    "0xf700-0x240000",
    "0xf701-0x240000",
    "0xf702-0x240000",
    "0xf703-0x240000",
}

plist_path = Path(sys.argv[1])
with plist_path.open("rb") as f:
    data = plistlib.load(f)

def find_deprecated(obj, path=""):
    found = []
    if isinstance(obj, dict):
        km = obj.get("Keyboard Map")
        if isinstance(km, dict):
            hits = deprecated_keys.intersection(km)
            if hits:
                found.append((path or "root", sorted(hits)))
        for key, value in obj.items():
            found.extend(find_deprecated(value, f"{path}.{key}" if path else key))
    elif isinstance(obj, list):
        for index, item in enumerate(obj):
            found.extend(find_deprecated(item, f"{path}[{index}]"))
    return found

bad = find_deprecated(data)
assert not bad, f"deprecated key mappings remain: {bad}"
PY
}

assert_iterm2_plist_no_deprecated_key_mappings() {
  local plist_path="$1"
  ITERM2_PLIST_PATH="${plist_path}" python3 - <<'PY'
import os
import plistlib
from pathlib import Path

deprecated_keys = {
    "0xf700-0x240000",
    "0xf701-0x240000",
    "0xf702-0x240000",
    "0xf703-0x240000",
}

plist_path = Path(os.environ["ITERM2_PLIST_PATH"])
with plist_path.open("rb") as f:
    data = plistlib.load(f)

def find_deprecated(obj, path=""):
    found = []
    if isinstance(obj, dict):
        km = obj.get("Keyboard Map")
        if isinstance(km, dict):
            hits = deprecated_keys.intersection(km)
            if hits:
                found.append((path or "root", sorted(hits)))
        for key, value in obj.items():
            found.extend(find_deprecated(value, f"{path}.{key}" if path else key))
    elif isinstance(obj, list):
        for index, item in enumerate(obj):
            found.extend(find_deprecated(item, f"{path}[{index}]"))
    return found

bad = find_deprecated(data)
assert not bad, f"deprecated key mappings remain in {plist_path}: {bad}"
PY
}
