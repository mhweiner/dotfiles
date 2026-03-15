#!/usr/bin/env bash
set -e
DOTFILES="$(cd "$(dirname "$0")" && pwd)"
cd "$DOTFILES"

echo "Installing dotfiles from $DOTFILES"

# .zshrc (repo-controlled)
if [ -f ~/.zshrc ] && [ ! -L ~/.zshrc ]; then
  echo "  Backing up existing ~/.zshrc to ~/.zshrc.bak"
  cp ~/.zshrc ~/.zshrc.bak
fi
ln -sf "$DOTFILES/.zshrc" ~/.zshrc
echo "  Linked ~/.zshrc"
# .zshrc.local (user-owned, never overwritten). Support both home and repo dir.
if [ ! -f ~/.zshrc.local ]; then
  cp "$DOTFILES/zshrc.local.example" ~/.zshrc.local
  echo "  Created ~/.zshrc.local (edit for local overrides)"
else
  echo "  ~/.zshrc.local exists (unchanged)"
fi
if [ ! -f "$DOTFILES/.zshrc.local" ]; then
  cp "$DOTFILES/zshrc.local.example" "$DOTFILES/.zshrc.local"
  echo "  Created $DOTFILES/.zshrc.local (optional; gitignored)"
else
  echo "  $DOTFILES/.zshrc.local exists (unchanged)"
fi

# starship
mkdir -p ~/.config
ln -sf "$DOTFILES/starship.toml" ~/.config/starship.toml
echo "  Linked ~/.config/starship.toml"

# iTerm2: load/save prefs from dotfiles
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$DOTFILES/iterm2"
echo "  Set iTerm2 to use $DOTFILES/iterm2 for preferences"

# bin (helpers)
mkdir -p ~/.local/bin
for f in git-cleanup whatismyip killport open-prs; do
  [ -f "$DOTFILES/bin/$f" ] && ln -sf "$DOTFILES/bin/$f" ~/.local/bin/$f
done
echo "  Linked ~/.local/bin (git-cleanup, whatismyip, killport, open-prs)"

# fonts
if [ -d "$DOTFILES/fonts" ]; then
  mkdir -p ~/Library/Fonts
  cp -n "$DOTFILES/fonts/"*.ttf ~/Library/Fonts/ 2>/dev/null || true
  echo "  Installed fonts to ~/Library/Fonts"
fi

echo ""
echo "Done. Restart iTerm2 (or open a new tab) so it picks up the preferences folder."
