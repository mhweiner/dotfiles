#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
BOOTSTRAP_SCRIPT="${DOTFILES_DIR}/bootstrap.sh"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

FAKE_HOME="${TMP_DIR}/home"
FAKE_BIN="${TMP_DIR}/bin"
FAKE_APPS="${TMP_DIR}/Applications"
FAKE_LOG="${TMP_DIR}/brew.log"

mkdir -p "${FAKE_HOME}/.nvm" "${FAKE_BIN}" "${FAKE_APPS}/iTerm.app"
printf '%s\n' '# fake nvm loader' >"${FAKE_HOME}/.nvm/nvm.sh"

cat >"${FAKE_BIN}/brew" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "list" && "${2:-}" == "--cask" && "${3:-}" == "iterm2" ]]; then
  exit 1
fi

if [[ "${1:-}" == "install" && "${2:-}" == "--cask" && "${3:-}" == "iterm2" ]]; then
  echo "install --cask iterm2" >>"${BREW_LOG}"
  echo "Error: It seems there is already an App at '${APPLICATIONS_DIR}/iTerm.app'." >&2
  exit 1
fi

if [[ "${1:-}" == "install" ]]; then
  exit 0
fi

if [[ "${1:-}" == "list" ]]; then
  exit 1
fi

exit 0
EOF
chmod +x "${FAKE_BIN}/brew"

cat >"${FAKE_BIN}/node" <<'EOF'
#!/usr/bin/env bash
echo "v22.0.0"
EOF
chmod +x "${FAKE_BIN}/node"

if HOME="${FAKE_HOME}" PATH="${FAKE_BIN}:${PATH}" APPLICATIONS_DIR="${FAKE_APPS}" BREW_LOG="${FAKE_LOG}" bash "${BOOTSTRAP_SCRIPT}" >/dev/null 2>&1; then
  :
else
  echo "Expected bootstrap.sh to succeed when iTerm app bundle already exists."
  exit 1
fi

if [[ -f "${FAKE_LOG}" ]]; then
  echo "Expected bootstrap.sh to skip cask install when app bundle already exists."
  exit 1
fi

echo "PASS: bootstrap.sh skips iterm2 cask install when app bundle exists."
