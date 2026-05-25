#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=tests/lib.sh
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"

setup_fake_home
install_fake_defaults

NVM_LOADED_MARKER="${TMP_DIR}/nvm-loaded"
mkdir -p "${FAKE_HOME}/.nvm"
cat >"${FAKE_HOME}/.nvm/nvm.sh" <<EOF
#!/usr/bin/env bash
: >"${NVM_LOADED_MARKER}"
nvm() { :; }
node() { echo v24.0.0; }
npm() { :; }
nvm_find_nvmrc() { :; }
EOF
chmod +x "${FAKE_HOME}/.nvm/nvm.sh"

HOME="${FAKE_HOME}" zsh -fc '
  source "'"${DOTFILES_DIR}"'/.zshrc"
  typeset -f nvm >/dev/null || exit 1
  typeset -f node >/dev/null || exit 1
' || test_fail "expected lazy nvm wrapper functions after sourcing .zshrc"

[[ ! -f "${NVM_LOADED_MARKER}" ]] || test_fail "expected nvm.sh not to load until first use"

HOME="${FAKE_HOME}" zsh -fc '
  source "'"${DOTFILES_DIR}"'/.zshrc"
  node >/dev/null
' || test_fail "expected node wrapper to invoke lazy nvm load"

[[ -f "${NVM_LOADED_MARKER}" ]] || test_fail "expected nvm.sh to load on first node use"

test_pass "nvm lazy-loads on first use, not at shell startup"
