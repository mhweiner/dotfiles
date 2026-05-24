#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=tests/lib.sh
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"

git -C "${DOTFILES_DIR}" checkout -- iterm2/com.googlecode.iterm2.plist 2>/dev/null || true
rm -f "${DOTFILES_DIR}/package-lock.json"

setup_fake_home
install_fake_defaults
mkdir -p "${FAKE_HOME}/Library/Preferences"

DOTFILES_NO_PROMPTS=1 run_install_config >/dev/null 2>&1

assert_git_no_unstaged_changes "iterm2/com.googlecode.iterm2.plist"
[[ ! -f "${DOTFILES_DIR}/package-lock.json" ]] || test_fail "install must not create package-lock.json"

setup_fake_home
install_iterm2_defaults_stub
ITERM2_LOAD_CUSTOM=1 ITERM2_CUSTOM_FOLDER="${DOTFILES_DIR}/iterm2" \
  DOTFILES_NO_PROMPTS=1 run_install_config >/dev/null 2>&1

assert_git_no_unstaged_changes "iterm2/com.googlecode.iterm2.plist"

test_pass "install leaves the dotfiles git tree clean"
