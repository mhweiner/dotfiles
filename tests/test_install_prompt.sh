#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=tests/lib.sh
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"

setup_fake_home
install_fake_git
install_fake_node
install_fake_nvm
install_fake_defaults
install_logging_brew ""

DOTFILES_NO_PROMPTS=1 run_install >/dev/null 2>&1
[[ ! -f "${BREW_LOG:-}" ]] || ! grep -q . "${BREW_LOG}" 2>/dev/null || test_fail "expected no brew activity when package prompt declined"
[[ ! -f "${FAKE_HOME}/.zshrc" ]] || test_fail "expected no config when config prompt declined"

setup_fake_home
install_fake_git
install_fake_node
install_fake_nvm
install_fake_defaults
install_logging_brew ""
install_logging_defaults

printf 'n\ny\n' | DOTFILES_ALLOW_STDIN_PROMPTS=1 run_install >/dev/null 2>&1
[[ ! -f "${BREW_LOG:-}" ]] || ! grep -q . "${BREW_LOG}" 2>/dev/null || test_fail "expected no brew when packages declined"
assert_zshrc_sources_dotfiles

setup_fake_home
install_fake_git
install_fake_node
install_fake_nvm
install_fake_defaults
install_logging_brew ""
install_logging_defaults
FAKE_APPS="${TMP_DIR}/Applications"
mkdir -p "${FAKE_APPS}"

APPLICATIONS_DIR="${FAKE_APPS}" DOTFILES_ASSUME_YES=1 run_install >/dev/null 2>&1
grep -qF 'install --cask iterm2' "${BREW_LOG}" || test_fail "expected brew package install when package prompt accepted"

test_pass "install prompts for packages and config; skips or runs each phase accordingly"
