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

# === npm (GitHub Packages via gh) ===
# GITHUB_TOKEN from gh per invocation; must run after nvm loads.
npm() {
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
