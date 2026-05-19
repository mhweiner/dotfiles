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

mkdir -p "${FAKE_HOME}/.nvm" "${FAKE_BIN}" "${FAKE_APPS}/iTerm.app"
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

if [[ "${1:-}" == "list" ]]; then
  exit 1
fi

if [[ "${1:-}" == "install" ]]; then
  echo "$*" >>"${BREW_LOG}"
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

HOME="${FAKE_HOME}" PATH="${FAKE_BIN}:${PATH}" APPLICATIONS_DIR="${FAKE_APPS}" BREW_LOG="${FAKE_LOG}" bash "${INSTALL_SCRIPT}" >/dev/null 2>&1

if [[ ! -f "${FAKE_LOG}" ]]; then
  echo "Expected install.sh to run brew installs."
  exit 1
fi

if ! grep -q -- '--cask font-hack-nerd-font' "${FAKE_LOG}"; then
  echo "Expected install.sh to install font-hack-nerd-font."
  exit 1
fi

echo "PASS: install.sh performs package bootstrap."
