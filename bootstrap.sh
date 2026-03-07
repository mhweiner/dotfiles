#!/usr/bin/env bash
set -e

REPO_URL="https://github.com/mhweiner/dotfiles.git"
DOTFILES="$HOME/dotfiles"
NVM_VERSION="v0.40.1"

echo "=== dotfiles bootstrap ==="

# 1. Need git (Xcode Command Line Tools)
if ! command -v git &>/dev/null; then
  echo "Git is not installed. Run: xcode-select --install"
  echo "Then re-run this script."
  exit 1
fi

# 2. Homebrew
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
# Ensure brew is on PATH (e.g. after fresh install)
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null)" || eval "$(/usr/local/bin/brew shellenv 2>/dev/null)" || true

# 3. Clone repo if we don't have it
if [ ! -d "$DOTFILES/.git" ]; then
  echo "Cloning dotfiles..."
  git clone "$REPO_URL" "$DOTFILES"
else
  echo "Dotfiles repo already at $DOTFILES"
fi

# 4. Install tools via Homebrew
echo "Installing iTerm2 and Starship..."
brew install --cask iterm2
brew install starship

# 5. nvm
if [ ! -s "$HOME/.nvm/nvm.sh" ]; then
  echo "Installing nvm..."
  curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
else
  echo "nvm already installed"
fi

# 6. Wire everything up
echo ""
"$DOTFILES/install.sh"

echo ""
echo "Bootstrap done. Quit and reopen iTerm2 to use your new setup."
