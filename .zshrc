# macOS user-local Python scripts (3.9 layout); only if present
[ -d "$HOME/Library/Python/3.9/bin" ] && export PATH="$HOME/Library/Python/3.9/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
export PATH="$HOME/.local/bin:$PATH" # cursor agent
[ -d "/opt/homebrew/opt/postgresql@16/bin" ] && export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"

# === aliases ===

alias ll='ls -lah'

# === shell functions (short helpers; `listenport` stays in bin/) ===

git-cleanup() {
  local branch="${1:-main}"
  git checkout "$branch" && git pull -p
  local gone
  gone=$(git branch -vv | grep ': gone]' | awk '{print $1}' | grep -vE '^(main|dev|master)$')
  if [ -n "$gone" ]; then
    echo "$gone" | xargs git branch -D
  fi
}

whatismyip() {
  local pub local_ip
  pub=$(curl -s --max-time 3 https://checkip.amazonaws.com 2>/dev/null) || pub="—"
  local_ip=$(ipconfig getifaddr en0 2>/dev/null) || local_ip=$(ipconfig getifaddr en1 2>/dev/null) || local_ip=$(ifconfig 2>/dev/null | grep 'inet ' | grep -v 127.0.0.1 | awk '{print $2}' | head -1) || local_ip="—"
  echo ""
  echo "  🌐  Public   $pub"
  echo "  🏠  Local    $local_ip"
  echo ""
}

# === nvm ===

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Auto-use Node version from nearest .nvmrc (requires nvm to be loaded above)
autoload -U add-zsh-hook
load-nvmrc() {
  local nvmrc_path wanted v_wanted v_current
  nvmrc_path="$(nvm_find_nvmrc)"
  if [ -n "$nvmrc_path" ]; then
    wanted="$(command head -n 1 "$nvmrc_path" | command tr -d '\r')"
    v_wanted="$(nvm version "$wanted")"
    v_current="$(nvm version)"
    if [ "$v_wanted" = "N/A" ]; then
      nvm install
    elif [ "$v_wanted" != "$v_current" ]; then
      nvm use --silent
    fi
  elif [ "$(nvm version)" != "$(nvm version default)" ]; then
    nvm use default --silent
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

# === npmgh (GitHub Packages via gh) ===
# Use **`npmgh`** like **`npm`** when a project depends on **GitHub Packages** (e.g. first
# **`npmgh i`** / **`npmgh ci`** in chroniton). Plain **`npm`** is unwrapped so **`npm link`**
# and normal installs never block on OAuth.
#
# Ensures active gh account has read:packages (refresh or browser login as needed), then runs
# npm with GITHUB_TOKEN from gh. Must run after nvm loads.
_npmgh_ensure_gh_read_packages() {
  [[ -n ${_LOGFOX_NPM_READ_PACKAGES_CACHED:-} ]] && return 0
  command -v gh >/dev/null 2>&1 || return 0

  local line host scopes
  line=$(gh auth status --json hosts --jq -r '[.hosts | to_entries[] | .value[] | select(.active==true)][0] | "\(.host)\t\(.scopes)"' 2>/dev/null) || line=""
  host=${line%%$'\t'*}
  scopes=${line#*$'\t'}

  if [[ -n $host && $scopes == *read:packages* ]]; then
    _LOGFOX_NPM_READ_PACKAGES_CACHED=1
    return 0
  fi

  if [[ -n $host ]] && gh auth token -h "$host" &>/dev/null; then
    gh auth refresh -h "$host" -s read:packages && _LOGFOX_NPM_READ_PACKAGES_CACHED=1
    return 0
  fi

  gh auth login -h "${host:-github.com}" -s read:packages -w && _LOGFOX_NPM_READ_PACKAGES_CACHED=1
}

npmgh() {
  _npmgh_ensure_gh_read_packages
  GITHUB_TOKEN=$(gh auth token 2>/dev/null) command npm "$@"
}

# === AWS SSO ===
awssso() {
  : "${1:?usage: awssso <profile>}"
  command aws sso login --profile "$1" && export AWS_PROFILE="$1"
}

# === starship ===

eval "$(starship init zsh)"

# Machine-only tweaks: edit ~/.zshrc outside the >>> dotfiles BEGIN block, or fork this repo.
