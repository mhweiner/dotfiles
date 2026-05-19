#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
INSTALL_SCRIPT="${DOTFILES_DIR}/install.sh"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

FAKE_HOME="${TMP_DIR}/home"
FAKE_BIN="${TMP_DIR}/bin"
mkdir -p "${FAKE_HOME}" "${FAKE_BIN}"

cat >"${FAKE_BIN}/defaults" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "${FAKE_BIN}/defaults"

printf '%s\n' 'custom vim settings' >"${FAKE_HOME}/.vimrc"

printf 'y\n' | HOME="${FAKE_HOME}" PATH="${FAKE_BIN}:${PATH}" DOTFILES_SKIP_PACKAGES=1 DOTFILES_ALLOW_STDIN_PROMPTS=1 bash "${INSTALL_SCRIPT}" >/dev/null 2>&1

if [[ ! -L "${FAKE_HOME}/.vimrc" ]]; then
  echo "Expected install.sh to prompt and replace ~/.vimrc when user confirms."
  exit 1
fi

echo "PASS: install.sh prompts before overwriting ~/.vimrc."
