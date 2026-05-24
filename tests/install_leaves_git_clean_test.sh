#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
INSTALL_SCRIPT="${DOTFILES_DIR}/install.sh"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

FAKE_HOME="${TMP_DIR}/home"
FAKE_BIN="${TMP_DIR}/bin"

mkdir -p "${FAKE_HOME}/Library/Preferences" "${FAKE_BIN}"

cat >"${FAKE_BIN}/defaults" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "${FAKE_BIN}/defaults"

git -C "${DOTFILES_DIR}" checkout -- iterm2/com.googlecode.iterm2.plist 2>/dev/null || true
rm -f "${DOTFILES_DIR}/package-lock.json"

HOME="${FAKE_HOME}" PATH="${FAKE_BIN}:${PATH}" DOTFILES_SKIP_PACKAGES=1 DOTFILES_NO_PROMPTS=1 bash "${INSTALL_SCRIPT}" >/dev/null 2>&1

if [[ -n "$(git -C "${DOTFILES_DIR}" status --porcelain iterm2/com.googlecode.iterm2.plist package-lock.json)" ]]; then
  echo "Expected install.sh to leave tracked iTerm2 prefs and package-lock.json unchanged."
  git -C "${DOTFILES_DIR}" status --porcelain iterm2/com.googlecode.iterm2.plist package-lock.json
  exit 1
fi

echo "PASS: install.sh leaves the dotfiles git tree clean."
