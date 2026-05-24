#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=tests/lib.sh
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"

REPO_PLIST="${DOTFILES_DIR}/iterm2/com.googlecode.iterm2.plist"

assert_iterm2_template_font
test_pass "iTerm2 template default profile uses Hack Nerd Font"

assert_iterm2_template_no_deprecated_key_mappings
test_pass "iTerm2 template has no deprecated Sequoia-conflicting key mappings"

assert_iterm2_template_sanitized
test_pass "iTerm2 template has no machine-specific window or path state"

setup_fake_home
install_logging_defaults
LIVE_PLIST="${FAKE_HOME}/Library/Preferences/com.googlecode.iterm2.plist"
mkdir -p "${FAKE_HOME}/Library/Preferences"

DOTFILES_NO_PROMPTS=1 run_install_config >/dev/null 2>&1

[[ -f "${LIVE_PLIST}" ]] || test_fail "expected iTerm2 prefs at ~/Library/Preferences on first install"
cmp -s "${REPO_PLIST}" "${LIVE_PLIST}" || test_fail "expected first install to copy the dotfiles iTerm2 template"
grep -q "PrefsCustomFolder -string ${DOTFILES_DIR}/iterm2" "${DEFAULTS_LOG}" && test_fail "install must not point iTerm2 at the git repo"
grep -q 'LoadPrefsFromCustomFolder -bool true' "${DEFAULTS_LOG}" && test_fail "install must not enable a custom iTerm2 prefs folder"

setup_fake_home
install_fake_defaults
LIVE_PLIST="${FAKE_HOME}/Library/Preferences/com.googlecode.iterm2.plist"
mkdir -p "${FAKE_HOME}/Library/Preferences"
printf '%s\n' 'custom iterm prefs' >"${LIVE_PLIST}"

printf 'n\nn\n' | DOTFILES_ALLOW_STDIN_PROMPTS=1 run_install_config >/dev/null 2>&1
grep -q 'custom iterm prefs' "${LIVE_PLIST}" || test_fail "expected existing iTerm2 prefs to be kept when user declines"

setup_fake_home
install_fake_defaults
LIVE_PLIST="${FAKE_HOME}/Library/Preferences/com.googlecode.iterm2.plist"
mkdir -p "${FAKE_HOME}/Library/Preferences"
cp "${REPO_PLIST}" "${LIVE_PLIST}"
python3 - <<'PY' "${LIVE_PLIST}"
import plistlib
import sys
from pathlib import Path

path = Path(sys.argv[1])
data = plistlib.load(path.open("rb"))
data["Default Arrangement Name"] = "test"
data["Window Arrangements"] = {
    "test": [
        {
            "Tabs": [
                {
                    "Root": {
                        "Subviews": [
                            {
                                "Session": {
                                    "Bookmark": {
                                        "Keyboard Map": {
                                            "0xf700-0x240000": {"Text": "[1;5A", "Action": 10},
                                        }
                                    }
                                }
                            }
                        ]
                    }
                }
            ]
        }
    ]
}
with path.open("wb") as f:
    plistlib.dump(data, f, sort_keys=False)
PY

DOTFILES_NO_PROMPTS=1 run_install_config >/dev/null 2>&1
assert_iterm2_plist_no_deprecated_key_mappings "${LIVE_PLIST}"
python3 - <<'PY' "${LIVE_PLIST}"
import plistlib
import sys
from pathlib import Path

data = plistlib.load(Path(sys.argv[1]).open("rb"))
assert "Window Arrangements" not in data
assert "Default Arrangement Name" not in data
PY
test_pass "install sanitizes live iTerm2 prefs (no saved window arrangements or deprecated keys)"

setup_fake_home
install_fake_defaults
LIVE_PLIST="${FAKE_HOME}/Library/Preferences/com.googlecode.iterm2.plist"
mkdir -p "${FAKE_HOME}/Library/Preferences"
printf '%s\n' 'custom iterm prefs' >"${LIVE_PLIST}"

printf 'n\ny\n' | DOTFILES_ALLOW_STDIN_PROMPTS=1 run_install_config >/dev/null 2>&1
cmp -s "${REPO_PLIST}" "${LIVE_PLIST}" || test_fail "expected dotfiles iTerm2 template when user confirms overwrite"

setup_fake_home
install_iterm2_defaults_stub
LIVE_PLIST="${FAKE_HOME}/Library/Preferences/com.googlecode.iterm2.plist"
ITERM2_LOAD_CUSTOM=1 ITERM2_CUSTOM_FOLDER="${DOTFILES_DIR}/iterm2" \
  DOTFILES_NO_PROMPTS=1 run_install_config >/dev/null 2>&1

[[ -f "${LIVE_PLIST}" ]] || test_fail "expected migrated iTerm2 prefs in ~/Library/Preferences"
grep -q 'LoadPrefsFromCustomFolder -bool false' "${DEFAULTS_LOG}" || test_fail "expected legacy custom-folder setup to be disabled"
assert_git_no_unstaged_changes "iterm2/com.googlecode.iterm2.plist"

test_pass "install manages iTerm2 prefs in the default location and migrates legacy setups"
