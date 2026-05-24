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
DEFAULTS_LOG="${TMP_DIR}/defaults.log"

mkdir -p "${FAKE_HOME}/Library/Preferences" "${FAKE_BIN}"

cat >"${FAKE_BIN}/defaults" <<EOF
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "\$*" >>"${DEFAULTS_LOG}"
exit 0
EOF
chmod +x "${FAKE_BIN}/defaults"

HOME="${FAKE_HOME}" PATH="${FAKE_BIN}:${PATH}" DOTFILES_SKIP_PACKAGES=1 DOTFILES_NO_PROMPTS=1 bash "${INSTALL_SCRIPT}" >/dev/null 2>&1

if [[ ! -f "${LIVE_PLIST}" ]]; then
  echo "Expected install.sh to seed iTerm2 prefs in ~/Library/Preferences."
  exit 1
fi

if ! cmp -s "${REPO_PLIST}" "${LIVE_PLIST}"; then
  echo "Expected default iTerm2 prefs to match the dotfiles template on first install."
  exit 1
fi

if grep -q "PrefsCustomFolder -string ${DOTFILES_DIR}/iterm2" "${DEFAULTS_LOG}"; then
  echo "Expected install.sh not to point iTerm2 at the git repo iterm2/ directory."
  exit 1
fi

if grep -q 'LoadPrefsFromCustomFolder -bool true' "${DEFAULTS_LOG}"; then
  echo "Expected install.sh to use iTerm2's default prefs location, not a custom folder."
  exit 1
fi

echo "PASS: install.sh installs iTerm2 prefs into the default Library/Preferences location."
