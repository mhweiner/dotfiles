#!/usr/bin/env bash
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
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

# iTerm2
echo "Installing iTerm2..."
brew install --cask iterm2 2>/dev/null || echo "  already installed"

# Starship
echo "Installing Starship..."
brew install starship 2>/dev/null || echo "  already installed"

# GitHub CLI
echo "Installing GitHub CLI..."
brew install gh 2>/dev/null || echo "  already installed"

# AWS CLI
echo "Installing AWS CLI..."
brew install awscli 2>/dev/null || echo "  already installed"

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
