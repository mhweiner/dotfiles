#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=tests/lib.sh
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"

setup_fake_home
install_fake_git
install_fake_node
install_fake_nvm

# Report Linux as the OS
cat >"${FAKE_BIN}/uname" <<'EOF'
#!/usr/bin/env bash
echo "Linux"
EOF
chmod +x "${FAKE_BIN}/uname"

# sudo passes straight through to the command
cat >"${FAKE_BIN}/sudo" <<'EOF'
#!/usr/bin/env bash
exec "$@"
EOF
chmod +x "${FAKE_BIN}/sudo"

PACMAN_LOG="${TMP_DIR}/pacman.log"
export PACMAN_LOG
cat >"${FAKE_BIN}/pacman" <<EOF
#!/usr/bin/env bash
printf '%s\n' "\$*" >>"${PACMAN_LOG}"
exit 0
EOF
chmod +x "${FAKE_BIN}/pacman"

CHSH_LOG="${TMP_DIR}/chsh.log"
export CHSH_LOG
cat >"${FAKE_BIN}/chsh" <<EOF
#!/usr/bin/env bash
printf '%s\n' "\$*" >>"${CHSH_LOG}"
exit 0
EOF
chmod +x "${FAKE_BIN}/chsh"

# No brew shim on purpose: any brew call on the Linux path must fail the test.
SHELL=/bin/bash DOTFILES_ASSUME_YES=1 run_install >/dev/null 2>&1

grep -qF -- '-S --needed' "${PACMAN_LOG}" || test_fail "expected pacman -S --needed on Arch"
grep -qF 'starship' "${PACMAN_LOG}" || test_fail "expected starship in pacman package list"
grep -qF 'ttf-hack-nerd' "${PACMAN_LOG}" || test_fail "expected Nerd Font in pacman package list"

assert_zshrc_sources_dotfiles
[[ -L "${FAKE_HOME}/.vimrc" ]] || test_fail "expected ~/.vimrc symlink"
[[ -L "${FAKE_HOME}/.config/starship.toml" ]] || test_fail "expected starship.toml symlink"
[[ -L "${FAKE_HOME}/.local/bin/git-cleanup" ]] || test_fail "expected bin helper symlink"

[[ ! -e "${FAKE_HOME}/Library" ]] || test_fail "macOS-only steps (iTerm2/Cursor) must not run on Linux"

grep -qF -- '-s' "${CHSH_LOG}" || test_fail "expected chsh -s <zsh> offer to run on Linux"

test_pass "linux (arch): pacman packages, config wiring, no macOS steps, chsh offered"
