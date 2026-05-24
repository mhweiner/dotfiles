#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=tests/lib.sh
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"

REPO_PLIST="${DOTFILES_DIR}/iterm2/com.googlecode.iterm2.plist"

assert_iterm2_template_font
test_pass "iTerm2 template default profile uses Hack Nerd Font"

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

printf 'n\n' | DOTFILES_ALLOW_STDIN_PROMPTS=1 run_install_config >/dev/null 2>&1
grep -q 'custom iterm prefs' "${LIVE_PLIST}" || test_fail "expected existing iTerm2 prefs to be kept when user declines"

setup_fake_home
install_fake_defaults
LIVE_PLIST="${FAKE_HOME}/Library/Preferences/com.googlecode.iterm2.plist"
mkdir -p "${FAKE_HOME}/Library/Preferences"
printf '%s\n' 'custom iterm prefs' >"${LIVE_PLIST}"

printf 'y\n' | DOTFILES_ALLOW_STDIN_PROMPTS=1 run_install_config >/dev/null 2>&1
cmp -s "${REPO_PLIST}" "${LIVE_PLIST}" || test_fail "expected dotfiles iTerm2 template when user confirms overwrite"

setup_fake_home
install_iterm2_defaults_stub
LIVE_PLIST="${FAKE_HOME}/Library/Preferences/com.googlecode.iterm2.plist"
ITERM2_LOAD_CUSTOM=1 ITERM2_CUSTOM_FOLDER="${DOTFILES_DIR}/iterm2" \
  DOTFILES_NO_PROMPTS=1 run_install_config >/dev/null 2>&1

[[ -f "${LIVE_PLIST}" ]] || test_fail "expected migrated iTerm2 prefs in ~/Library/Preferences"
grep -q 'LoadPrefsFromCustomFolder -bool false' "${DEFAULTS_LOG}" || test_fail "expected legacy custom-folder setup to be disabled"
if [[ -n "$(git -C "${DOTFILES_DIR}" status --porcelain iterm2/com.googlecode.iterm2.plist)" ]]; then
  test_fail "expected legacy migration to leave tracked iTerm2 template unchanged in git"
fi

test_pass "install manages iTerm2 prefs in the default location and migrates legacy setups"
