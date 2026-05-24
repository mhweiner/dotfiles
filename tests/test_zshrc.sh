#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=tests/lib.sh
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"

setup_fake_home
install_fake_defaults

DOTFILES_NO_PROMPTS=1 run_install_config >/dev/null 2>&1
assert_zshrc_sources_dotfiles

marker_count="$(grep -cF "${MARK_BEGIN}" "${FAKE_HOME}/.zshrc")"
[[ "${marker_count}" -eq 1 ]] || test_fail "expected exactly one dotfiles marker block, found ${marker_count}"

DOTFILES_NO_PROMPTS=1 run_install_config >/dev/null 2>&1
marker_count="$(grep -cF "${MARK_BEGIN}" "${FAKE_HOME}/.zshrc")"
[[ "${marker_count}" -eq 1 ]] || test_fail "expected install to be idempotent for ~/.zshrc"

test_pass "install wires ~/.zshrc once with a dotfiles source block"
