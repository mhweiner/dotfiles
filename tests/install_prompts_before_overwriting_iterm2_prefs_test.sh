#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
INSTALL_SCRIPT="${DOTFILES_DIR}/install.sh"
REPO_PLIST="${DOTFILES_DIR}/iterm2/com.googlecode.iterm2.plist"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

FAKE_HOME="${TMP_DIR}/home"
FAKE_BIN="${TMP_DIR}/bin"
LIVE_PLIST="${FAKE_HOME}/Library/Preferences/com.googlecode.iterm2.plist"

mkdir -p "${FAKE_HOME}/Library/Preferences" "${FAKE_BIN}"
printf '%s\n' 'custom iterm prefs' >"${LIVE_PLIST}"

cat >"${FAKE_BIN}/defaults" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "${FAKE_BIN}/defaults"

printf 'y\n' | HOME="${FAKE_HOME}" PATH="${FAKE_BIN}:${PATH}" DOTFILES_SKIP_PACKAGES=1 DOTFILES_ALLOW_STDIN_PROMPTS=1 bash "${INSTALL_SCRIPT}" >/dev/null 2>&1

if ! cmp -s "${REPO_PLIST}" "${LIVE_PLIST}"; then
  echo "Expected install.sh to prompt and replace existing iTerm2 prefs when user confirms."
  exit 1
fi

echo "PASS: install.sh prompts before overwriting existing iTerm2 preferences."
