#!/usr/bin/env bash
# Idempotent: safe to re-run on an already-configured Mac.
# - Installs Homebrew only if missing; otherwise skips.
# - Each brew formula/cask is skipped if already installed (does not upgrade).
# - nvm is installed once; Node LTS is installed only if node is not on PATH.
# - Always runs install.sh (~/.zshrc wiring, optional ~/.vimrc symlink, iTerm prefs path); safe to repeat.
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd -P)"
NVM_VERSION="v0.40.1"

if [ ! -f "$DOTFILES/install.sh" ]; then
  echo "Run this script from your dotfiles repo, e.g. ~/dotfiles/bootstrap.sh"
  exit 1
fi

echo ""
echo "  ✨ dotfiles setup"
echo ""

# git (Xcode Command Line Tools)
if ! command -v git &>/dev/null; then
  echo "Git is not installed. Run: xcode-select --install"
  echo "Then re-run this script."
  exit 1
fi

# Homebrew
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null)" || eval "$(/usr/local/bin/brew shellenv 2>/dev/null)" || true

brew_install_formula() {
  local spec="$1"
  local name="${spec##*/}"
  if brew list --formula "$name" &>/dev/null; then
    echo "  $name already installed"
  else
    echo "Installing $spec..."
    brew install "$spec"
  fi
}

brew_install_cask() {
  local c="$1"
  if brew list --cask "$c" &>/dev/null; then
    echo "  $c already installed"
  else
    echo "Installing $c..."
    brew install --cask "$c"
  fi
}

echo "Homebrew packages (skipped if already present)..."
brew_install_cask iterm2
brew_install_formula starship
brew_install_formula gh
brew_install_formula awscli
brew_install_formula logfoxai/tap/open-prs

# nvm + Node LTS
if [ ! -s "$HOME/.nvm/nvm.sh" ]; then
  echo "Installing nvm..."
  curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
else
  echo "nvm already installed"
fi
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
if ! command -v node &>/dev/null; then
  echo "Installing Node (LTS)..."
  nvm install --lts
else
  echo "Node already installed ($(node -v))"
fi

# Wire up symlinks, fonts, iTerm prefs
echo ""
"$DOTFILES/install.sh"

echo ""
echo "Done. Quit and reopen iTerm2 to use your new setup."
