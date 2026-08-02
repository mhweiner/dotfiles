#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=tests/lib.sh
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"

setup_fake_home
install_fake_git
install_fake_node
install_fake_nvm
install_fake_defaults
install_logging_brew
FAKE_APPS="${TMP_DIR}/Applications"
mkdir -p "${FAKE_APPS}"

APPLICATIONS_DIR="${FAKE_APPS}" DOTFILES_ASSUME_YES=1 run_install >/dev/null 2>&1

for expected in \
  'install --cask iterm2' \
  'install --cask cursor' \
  'install --cask font-hack-nerd-font' \
  'install starship' \
  'install gh' \
  'install awscli' \
  'install logfoxai/tap/open-prs'
do
  grep -qF -- "${expected}" "${BREW_LOG}" || test_fail "expected brew to run: ${expected}"
done

setup_fake_home
install_fake_git
install_fake_node
install_fake_nvm
install_fake_defaults
install_logging_brew iterm2 cursor font-hack-nerd-font
FAKE_APPS="${TMP_DIR}/Applications"
mkdir -p "${FAKE_APPS}"

APPLICATIONS_DIR="${FAKE_APPS}" DOTFILES_ASSUME_YES=1 run_install >/dev/null 2>&1

grep -qF -- 'reinstall --cask iterm2' "${BREW_LOG}" || test_fail "expected iterm2 cask reinstall when app bundle is missing"
grep -qF -- 'reinstall --cask cursor' "${BREW_LOG}" || test_fail "expected cursor cask reinstall when app bundle is missing"
grep -qF -- 'reinstall --cask font-hack-nerd-font' "${BREW_LOG}" || test_fail "expected font cask reinstall when font files are missing"

test_pass "install bootstraps Homebrew packages and reinstalls broken casks"
