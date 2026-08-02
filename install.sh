#!/usr/bin/env bash
# Idempotent: safe to re-run on an already-configured Mac.
# Single entrypoint for package bootstrap + config wiring.
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd -P)"
cd "$DOTFILES"

NVM_VERSION="v0.40.1"
APPLICATIONS_DIR="${APPLICATIONS_DIR:-/Applications}"
MARK_BEGIN='>>> dotfiles BEGIN'
MARK_END='<<< dotfiles END'

realpath_file() {
  python3 -c 'import os, sys; print(os.path.realpath(sys.argv[1]))' "$1" 2>/dev/null || echo "$1"
}

prompt_yes_no() {
  local message="$1"
  local response=""

  if [[ "${DOTFILES_ASSUME_YES:-0}" == "1" ]]; then
    return 0
  fi
  if [[ "${DOTFILES_NO_PROMPTS:-0}" == "1" ]]; then
    return 1
  fi

  if [[ -t 0 ]]; then
    printf "%s [y/N] " "$message"
    IFS= read -r response || true
  elif [[ "${DOTFILES_ALLOW_STDIN_PROMPTS:-0}" == "1" ]]; then
    IFS= read -r response || true
  else
    return 1
  fi

  [[ "$response" =~ ^([Yy]|[Yy][Ee][Ss])$ ]]
}

brew_install_formula() {
  local spec="$1"
  local name="${spec##*/}"
  if brew list --formula "$name" &>/dev/null; then
    echo "  $name already installed"
  else
    echo "  Installing $spec..."
    brew install "$spec"
  fi
}

known_cask_app_bundle_path() {
  local c="$1"
  case "$c" in
    iterm2) printf '%s/iTerm.app\n' "$APPLICATIONS_DIR" ;;
    cursor) printf '%s/Cursor.app\n' "$APPLICATIONS_DIR" ;;
    *) return 1 ;;
  esac
}

cask_artifacts_present() {
  local c="$1"
  case "$c" in
    iterm2)
      [ -d "${APPLICATIONS_DIR}/iTerm.app" ]
      ;;
    cursor)
      [ -d "${APPLICATIONS_DIR}/Cursor.app" ]
      ;;
    font-hack-nerd-font)
      [ -f "${HOME}/Library/Fonts/HackNerdFontMono-Regular.ttf" ]
      ;;
    *)
      return 0
      ;;
  esac
}

brew_install_cask() {
  local c="$1"
  local app_bundle_path=""
  app_bundle_path="$(known_cask_app_bundle_path "$c" 2>/dev/null || true)"

  if brew list --cask "$c" &>/dev/null; then
    if cask_artifacts_present "$c"; then
      echo "  $c already installed"
    else
      echo "  $c is marked installed, but local files are missing. Reinstalling..."
      brew reinstall --cask "$c" || brew install --cask "$c"
    fi
  elif [ -n "$app_bundle_path" ] && [ -d "$app_bundle_path" ]; then
    if prompt_yes_no "  $c app exists at $app_bundle_path. Overwrite/reinstall with Homebrew cask?"; then
      echo "  Reinstalling $c..."
      brew install --cask --force "$c"
    else
      echo "  Keeping existing app at $app_bundle_path"
    fi
  else
    echo "  Installing $c..."
    brew install --cask "$c"
  fi
}

install_packages() {
  if ! command -v git &>/dev/null; then
    echo "  Git is not installed. Run: xcode-select --install"
    echo "  Then re-run this script."
    exit 1
  fi

  if ! command -v brew &>/dev/null; then
    echo "  Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  if command -v brew &>/dev/null; then
    eval "$(brew shellenv 2>/dev/null)" || true
  else
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null)" || eval "$(/usr/local/bin/brew shellenv 2>/dev/null)" || true
  fi

  echo "  Homebrew packages (skipped if already present)..."
  brew_install_cask iterm2
  brew_install_cask cursor
  brew_install_cask font-hack-nerd-font
  brew_install_formula starship
  brew_install_formula gh
  brew_install_formula awscli
  brew_install_formula logfoxai/tap/open-prs

  if [ ! -s "$HOME/.nvm/nvm.sh" ]; then
    echo "  Installing nvm..."
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
  else
    echo "  nvm already installed"
  fi
  export NVM_DIR="$HOME/.nvm"
  # shellcheck source=/dev/null
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  if ! command -v node &>/dev/null; then
    echo "  Installing Node (LTS)..."
    nvm install --lts
  else
    echo "  Node already installed ($(node -v))"
  fi
}

wire_zshrc() {
  local home_rc="${HOME}/.zshrc"
  if [[ -L "${home_rc}" ]]; then
    local resolved
    resolved="$(realpath_file "${home_rc}")"
    if [[ "${resolved}" == "${DOTFILES}/.zshrc" ]]; then
      rm "${home_rc}"
    fi
  fi

  if [[ -f "${home_rc}" ]] && grep -qF "${MARK_BEGIN}" "${home_rc}"; then
    :
  else
    local blk
    blk=$(
      cat <<EOF

# ${MARK_BEGIN}
[[ -f "${DOTFILES}/.zshrc" ]] && source "${DOTFILES}/.zshrc"
# ${MARK_END}
EOF
    )
    if [[ ! -f "${home_rc}" ]]; then
      cat <<EOF >"${home_rc}"
# ~/.zshrc — your customizations go above the dotfiles block (or after it, if you prefer).
# Shared shell config: https://github.com/mhweiner/dotfiles
${blk}
EOF
    else
      printf '%s' "${blk}" >>"${home_rc}"
    fi
  fi
}

link_vimrc() {
  local home_vim="${HOME}/.vimrc"
  local target_vim="${DOTFILES}/vimrc"

  if [[ -L "${home_vim}" ]]; then
    local resolved
    resolved="$(realpath_file "${home_vim}")"
    if [[ "${resolved}" == "${target_vim}" ]]; then
      return 0
    fi
  fi

  if [[ -e "${home_vim}" ]] || [[ -L "${home_vim}" ]]; then
    if prompt_yes_no "  ~/.vimrc already exists. Overwrite it with a symlink to dotfiles/vimrc?"; then
      ln -sf "${target_vim}" "${home_vim}"
    else
      echo "  Keeping existing ~/.vimrc"
    fi
  else
    ln -sf "${target_vim}" "${home_vim}"
  fi
}

iterm2_loads_custom_folder() {
  local load_custom
  load_custom="$(defaults read com.googlecode.iterm2 LoadPrefsFromCustomFolder 2>/dev/null || echo "0")"
  [[ "${load_custom}" == "1" || "${load_custom}" == "true" || "${load_custom}" == "yes" ]]
}

iterm2_legacy_custom_folder() {
  local folder="$1"
  [[ "${folder}" == "${DOTFILES}/iterm2" || "${folder}" == "${HOME}/.config/iterm2" ]]
}

iterm2_disable_custom_folder() {
  defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool false
  defaults delete com.googlecode.iterm2 PrefsCustomFolder 2>/dev/null || true
}

iterm2_sanitize_live_prefs() {
  local plist_path="$1"
  [[ -f "${plist_path}" ]] || return 0
  python3 "${DOTFILES}/iterm2/sanitize_plist.py" "${plist_path}" >/dev/null
}

configure_iterm2_prefs() {
  local repo_plist="${DOTFILES}/iterm2/com.googlecode.iterm2.plist"
  local live_plist="${HOME}/Library/Preferences/com.googlecode.iterm2.plist"
  local current_folder=""
  current_folder="$(defaults read com.googlecode.iterm2 PrefsCustomFolder 2>/dev/null || true)"

  if iterm2_loads_custom_folder && [[ -n "${current_folder}" ]]; then
    if iterm2_legacy_custom_folder "${current_folder}"; then
      if [[ -f "${current_folder}/com.googlecode.iterm2.plist" ]]; then
        mkdir -p "${HOME}/Library/Preferences"
        cp "${current_folder}/com.googlecode.iterm2.plist" "${live_plist}"
      fi
      if [[ "${current_folder}" == "${DOTFILES}/iterm2" ]] && command -v git &>/dev/null && git -C "${DOTFILES}" rev-parse --is-inside-work-tree &>/dev/null; then
        git -C "${DOTFILES}" checkout -- "iterm2/com.googlecode.iterm2.plist" 2>/dev/null || true
      fi
      iterm2_disable_custom_folder
    elif ! prompt_yes_no "  iTerm2 prefs folder is '${current_folder}'. Switch to the default location and apply dotfiles template?"; then
      echo "  Keeping existing iTerm2 prefs folder"
      return 0
    else
      if [[ -f "${current_folder}/com.googlecode.iterm2.plist" ]]; then
        mkdir -p "${HOME}/Library/Preferences"
        cp "${current_folder}/com.googlecode.iterm2.plist" "${live_plist}"
      fi
      iterm2_disable_custom_folder
    fi
  fi

  mkdir -p "${HOME}/Library/Preferences"

  if [[ -f "${live_plist}" ]]; then
    if prompt_yes_no "  iTerm2 preferences already exist. Overwrite with dotfiles template?"; then
      cp "${repo_plist}" "${live_plist}"
    else
      echo "  Keeping existing iTerm2 preferences"
    fi
  else
    cp "${repo_plist}" "${live_plist}"
  fi

  iterm2_sanitize_live_prefs "${live_plist}"
}

cursor_settings_overwrite_prompt_needed() {
  local cursor_settings_path="$1"
  CURSOR_SETTINGS_PATH="${cursor_settings_path}" python3 <<'PY'
import json
import os
from pathlib import Path

path = Path(os.environ["CURSOR_SETTINGS_PATH"])
if not path.exists():
    raise SystemExit(1)

data = json.loads(path.read_text())
if not isinstance(data, dict):
    raise SystemExit(0)

desired = {
    "terminal.external.osxExec": "/Applications/iTerm.app",
    "terminal.integrated.defaultProfile.osx": "zsh",
    "terminal.integrated.fontFamily": "Hack Nerd Font Mono, Menlo, monospace",
    "terminal.integrated.fontSize": 13,
    "terminal.integrated.cursorStyle": "block",
    "terminal.integrated.shellIntegration.enabled": True,
    "terminal.integrated.gpuAcceleration": "on",
}

for key, value in desired.items():
    if key in data and data[key] != value:
        raise SystemExit(0)

profiles_key = "terminal.integrated.profiles.osx"
if profiles_key in data:
    profiles = data[profiles_key]
    if not isinstance(profiles, dict):
        raise SystemExit(0)
    if "zsh" in profiles and profiles["zsh"] != {"path": "zsh", "args": ["-l"]}:
        raise SystemExit(0)

raise SystemExit(1)
PY
}

configure_cursor_terminal_settings() {
  local cursor_settings_dir="${HOME}/Library/Application Support/Cursor/User"
  local cursor_settings_path="${cursor_settings_dir}/settings.json"

  mkdir -p "${cursor_settings_dir}"

  if [[ -f "${cursor_settings_path}" ]] && ! python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "${cursor_settings_path}" >/dev/null 2>&1; then
    if prompt_yes_no "  Cursor settings.json is invalid. Overwrite it with dotfiles terminal defaults?"; then
      printf '%s\n' '{}' >"${cursor_settings_path}"
    else
      echo "  Keeping existing Cursor settings.json"
      return 0
    fi
  fi

  if cursor_settings_overwrite_prompt_needed "${cursor_settings_path}"; then
    if ! prompt_yes_no "  Cursor terminal settings already exist. Overwrite with dotfiles defaults?"; then
      echo "  Keeping existing Cursor terminal settings"
      return 0
    fi
  fi

  CURSOR_SETTINGS_PATH="${cursor_settings_path}" python3 <<'PY'
import json
import os
from pathlib import Path

path = Path(os.environ["CURSOR_SETTINGS_PATH"])
data = {}

if path.exists():
    parsed = json.loads(path.read_text())
    if isinstance(parsed, dict):
        data = parsed

profiles = data.get("terminal.integrated.profiles.osx")
if not isinstance(profiles, dict):
    profiles = {}

profiles["zsh"] = {"path": "zsh", "args": ["-l"]}
data["terminal.integrated.profiles.osx"] = profiles
data["terminal.integrated.defaultProfile.osx"] = "zsh"
data["terminal.integrated.fontFamily"] = "Hack Nerd Font Mono, Menlo, monospace"
data["terminal.integrated.fontSize"] = 13
data["terminal.integrated.cursorStyle"] = "block"
data["terminal.integrated.shellIntegration.enabled"] = True
data["terminal.integrated.gpuAcceleration"] = "on"
data["terminal.external.osxExec"] = "/Applications/iTerm.app"

path.write_text(json.dumps(data, indent=2) + "\n")
PY
}

install_config() {
  wire_zshrc
  link_vimrc

  mkdir -p ~/.config
  ln -sf "$DOTFILES/starship.toml" ~/.config/starship.toml

  configure_iterm2_prefs

  mkdir -p ~/.local/bin
  local -a bin_helpers=(listenport)
  for f in "${bin_helpers[@]}"; do
    [ -f "$DOTFILES/bin/$f" ] && ln -sf "$DOTFILES/bin/$f" ~/.local/bin/"$f"
  done
  # Legacy symlinks (helpers removed or moved into dotfiles .zshrc)
  rm -f ~/.local/bin/killport ~/.local/bin/npm-gh ~/.local/bin/awssso ~/.local/bin/git-cleanup ~/.local/bin/whatismyip

  configure_cursor_terminal_settings
}

print_config_summary() {
  echo "  Config will wire:"
  echo "    • Shell     ~/.zshrc sources this repo — PATH, Starship, nvm, helpers"
  echo "    • Vim       ~/.vimrc → dotfiles/vimrc (prompts if you already have one)"
  echo "    • Starship  ~/.config/starship.toml"
  echo "    • iTerm2    Default profile prefs (prompts before overwrite)"
  echo "    • Cursor    terminal settings only (prompts before overwrite)"
  echo "    • Bin       listenport in ~/.local/bin"
  echo ""
  echo "  New files are created as needed. Existing files prompt before overwrite."
  echo ""
}

echo ""
echo "  ✨ dotfiles setup"
echo ""

if [[ "${DOTFILES_SKIP_PACKAGE_PROMPT:-0}" != "1" ]]; then
  if prompt_yes_no "  Install Homebrew packages (iTerm2, Cursor, fonts, CLI tools, nvm/Node)?"; then
    install_packages
  else
    echo "  Skipping package bootstrap"
  fi
elif [[ "${DOTFILES_INSTALL_PACKAGES:-0}" == "1" ]]; then
  install_packages
fi

echo ""

print_config_summary

if [[ "${DOTFILES_SKIP_CONFIG_PROMPT:-0}" == "1" ]]; then
  install_config
elif prompt_yes_no "  Apply dotfiles config (items above)?"; then
  install_config
else
  echo "  Skipping config"
fi

echo ""
echo "  Done. Quit and reopen iTerm2/Cursor to use your new setup."
