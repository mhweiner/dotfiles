#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
INSTALL_SCRIPT="${DOTFILES_DIR}/install.sh"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

FAKE_HOME="${TMP_DIR}/home"
FAKE_BIN="${TMP_DIR}/bin"
FAKE_APPS="${TMP_DIR}/Applications"
FAKE_LOG="${TMP_DIR}/brew.log"

mkdir -p "${FAKE_HOME}/.nvm" "${FAKE_BIN}" "${FAKE_APPS}"
printf '%s\n' '# fake nvm loader' >"${FAKE_HOME}/.nvm/nvm.sh"

cat >"${FAKE_BIN}/git" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "${FAKE_BIN}/git"

cat >"${FAKE_BIN}/brew" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "shellenv" ]]; then
  exit 0
fi

if [[ "${1:-}" == "list" && "${2:-}" == "--cask" && "${3:-}" == "iterm2" ]]; then
  exit 0
fi

if [[ "${1:-}" == "list" && "${2:-}" == "--cask" && "${3:-}" == "font-hack-nerd-font" ]]; then
  exit 0
fi

if [[ "${1:-}" == "list" ]]; then
  exit 1
fi

if [[ "${1:-}" == "reinstall" ]]; then
  echo "$*" >>"${BREW_LOG}"
  exit 0
fi

if [[ "${1:-}" == "install" && "${2:-}" == "--cask" ]]; then
  echo "Unexpected install path used for cask recovery: $*" >&2
  exit 1
fi

if [[ "${1:-}" == "install" ]]; then
  exit 0
fi

exit 0
EOF
chmod +x "${FAKE_BIN}/brew"

cat >"${FAKE_BIN}/node" <<'EOF'
#!/usr/bin/env bash
echo "v24.0.0"
EOF
chmod +x "${FAKE_BIN}/node"

cat >"${FAKE_BIN}/defaults" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "${FAKE_BIN}/defaults"

HOME="${FAKE_HOME}" PATH="${FAKE_BIN}:${PATH}" APPLICATIONS_DIR="${FAKE_APPS}" BREW_LOG="${FAKE_LOG}" DOTFILES_NO_PROMPTS=1 bash "${INSTALL_SCRIPT}" >/dev/null 2>&1

if ! grep -q -- 'reinstall --cask iterm2' "${FAKE_LOG}"; then
  echo "Expected install.sh to reinstall iterm2 when app bundle is missing."
  exit 1
fi

if ! grep -q -- 'reinstall --cask font-hack-nerd-font' "${FAKE_LOG}"; then
  echo "Expected install.sh to reinstall font cask when Nerd Font files are missing."
  exit 1
fi

echo "PASS: install.sh reinstalls casks when local artifacts are missing."
