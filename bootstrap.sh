#!/usr/bin/env bash
set -e

# Run from repo root (user clones first)
DOTFILES="$(cd "$(dirname "$0")" && pwd)"
NVM_VERSION="v0.40.1"

# Ensure we're in the dotfiles repo
if [ ! -f "$DOTFILES/install.sh" ]; then
  echo "Run this script from your dotfiles repo, e.g. ~/dotfiles/bootstrap.sh"
  exit 1
fi

echo ""
echo "  ✨ dotfiles setup"
echo ""

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
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null)" || eval "$(/usr/local/bin/brew shellenv 2>/dev/null)" || true

# 3. gum (for TUI)
if ! command -v gum &>/dev/null; then
  echo "Installing gum (for this menu)..."
  brew install gum
fi

# 4. TUI: pick tools to install
echo "Select tools to install (space to toggle, Enter when done):"
echo ""

SELECTED=$(gum choose --no-limit --header "Pick what you want" \
  "iTerm2" \
  "Starship" \
  "nvm" \
  --cursor-prefix "○ " \
  --selected-prefix "● " \
  --unselected-prefix "○ " \
  --cursor.foreground="212" \
  --selected.foreground="212" \
  || true)

# 5. Install selected
if [ -n "$SELECTED" ]; then
  echo "$SELECTED" | while read -r choice; do
    case "$choice" in
      iTerm2)
        echo ""
        echo "Installing iTerm2..."
        brew install --cask iterm2
        ;;
      Starship)
        echo ""
        echo "Installing Starship..."
        brew install starship
        ;;
      nvm)
        echo ""
        if [ ! -s "$HOME/.nvm/nvm.sh" ]; then
          echo "Installing nvm..."
          curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
        else
          echo "nvm already installed"
        fi
        # Install Node (LTS) so npm is available
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        if ! command -v node &>/dev/null; then
          echo "Installing Node (LTS)..."
          nvm install --lts
        else
          echo "Node already installed ($(node -v))"
        fi
        ;;
    esac
  done
fi

# 6. Always wire everything up
echo ""
"$DOTFILES/install.sh"

echo ""
echo "Done. Quit and reopen iTerm2 to use your new setup."
