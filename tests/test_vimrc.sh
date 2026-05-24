#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=tests/lib.sh
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"

setup_fake_home
install_fake_defaults

DOTFILES_NO_PROMPTS=1 run_install_config >/dev/null 2>&1
[[ -L "${FAKE_HOME}/.vimrc" ]] || test_fail "expected ~/.vimrc symlink on first install"
[[ "$(readlink "${FAKE_HOME}/.vimrc")" == "${DOTFILES_DIR}/vimrc" ]] || test_fail "expected ~/.vimrc to point at dotfiles/vimrc"

setup_fake_home
install_fake_defaults
printf '%s\n' 'custom vim settings' >"${FAKE_HOME}/.vimrc"

printf 'n\nn\n' | DOTFILES_ALLOW_STDIN_PROMPTS=1 run_install_config >/dev/null 2>&1
[[ -f "${FAKE_HOME}/.vimrc" && ! -L "${FAKE_HOME}/.vimrc" ]] || test_fail "expected existing ~/.vimrc to be kept when user declines"
grep -q 'custom vim settings' "${FAKE_HOME}/.vimrc" || test_fail "expected custom ~/.vimrc content to remain"

setup_fake_home
install_fake_defaults
printf '%s\n' 'custom vim settings' >"${FAKE_HOME}/.vimrc"

printf 'n\ny\n' | DOTFILES_ALLOW_STDIN_PROMPTS=1 run_install_config >/dev/null 2>&1
[[ -L "${FAKE_HOME}/.vimrc" ]] || test_fail "expected ~/.vimrc symlink when user confirms overwrite"
[[ "$(readlink "${FAKE_HOME}/.vimrc")" == "${DOTFILES_DIR}/vimrc" ]] || test_fail "expected ~/.vimrc to point at dotfiles/vimrc after overwrite"

test_pass "install links ~/.vimrc when absent and respects overwrite prompts"
