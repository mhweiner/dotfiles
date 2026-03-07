#!/usr/bin/env bash
set -e
DOTFILES="$(cd "$(dirname "$0")" && pwd)"
cd "$DOTFILES"

echo "Installing dotfiles from $DOTFILES"

# .zshrc
if [ -f ~/.zshrc ] && [ ! -L ~/.zshrc ]; then
  echo "  Backing up existing ~/.zshrc to ~/.zshrc.bak"
  cp ~/.zshrc ~/.zshrc.bak
fi
ln -sf "$DOTFILES/.zshrc" ~/.zshrc
echo "  Linked ~/.zshrc"

# starship
mkdir -p ~/.config
ln -sf "$DOTFILES/starship.toml" ~/.config/starship.toml
echo "  Linked ~/.config/starship.toml"

# iTerm2: load/save prefs from dotfiles
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$DOTFILES/iterm2"
echo "  Set iTerm2 to use $DOTFILES/iterm2 for preferences"

echo ""
echo "Done. Restart iTerm2 (or open a new tab) so it picks up the preferences folder."
