#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=tests/lib.sh
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"

setup_fake_home
install_fake_defaults
mkdir -p "${FAKE_HOME}/.local/bin"
ln -sf /tmp/legacy-killport "${FAKE_HOME}/.local/bin/killport"
ln -sf /tmp/legacy-npm-gh "${FAKE_HOME}/.local/bin/npm-gh"

DOTFILES_NO_PROMPTS=1 run_install_config >/dev/null 2>&1

[[ -L "${FAKE_HOME}/.config/starship.toml" ]] || test_fail "expected ~/.config/starship.toml symlink"
[[ "$(readlink "${FAKE_HOME}/.config/starship.toml")" == "${DOTFILES_DIR}/starship.toml" ]] || test_fail "expected starship.toml to point at dotfiles"

[[ -L "${FAKE_HOME}/.local/bin/listenport" ]] || test_fail "expected ~/.local/bin/listenport symlink"
[[ "$(readlink "${FAKE_HOME}/.local/bin/listenport")" == "${DOTFILES_DIR}/bin/listenport" ]] || test_fail "expected listenport to point at dotfiles/bin/listenport"

[[ ! -e "${FAKE_HOME}/.local/bin/killport" ]] || test_fail "expected legacy killport symlink to be removed"
[[ ! -e "${FAKE_HOME}/.local/bin/npm-gh" ]] || test_fail "expected legacy npm-gh symlink to be removed"
[[ ! -d "${FAKE_HOME}/Library/Fonts" ]] || test_fail "install must not copy fonts into ~/Library/Fonts"

test_pass "install symlinks starship and bin helpers and removes legacy symlinks"
