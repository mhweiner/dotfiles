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

HOME="${FAKE_HOME}" PATH="${FAKE_BIN}:${PATH}" DOTFILES_SKIP_PACKAGES=1 bash "${INSTALL_SCRIPT}" >/dev/null 2>&1

if [[ -d "${FAKE_HOME}/Library/Fonts" ]]; then
  echo "Expected install.sh not to copy fonts from the repo."
  exit 1
fi

echo "PASS: install.sh does not copy repo fonts."
