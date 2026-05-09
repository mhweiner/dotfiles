#!/usr/bin/env bash
# Idempotent: safe to re-run. Wires ~/.zshrc and ~/.vimrc with marked blocks; never replaces whole files.
set -e
DOTFILES="$(cd "$(dirname "$0")" && pwd -P)"
cd "$DOTFILES"

echo "Installing dotfiles from $DOTFILES"

MARK_BEGIN='>>> dotfiles BEGIN'
MARK_END='<<< dotfiles END'

realpath_file() {
  python3 -c 'import os, sys; print(os.path.realpath(sys.argv[1]))' "$1" 2>/dev/null || echo "$1"
}

# --- zsh: ~/.zshrc runs your lines first, then sources this repo's .zshrc (Homebrew-style stub).
wire_zshrc() {
  local home_rc="${HOME}/.zshrc"
  if [[ -L "${home_rc}" ]]; then
    local resolved
    resolved="$(realpath_file "${home_rc}")"
    if [[ "${resolved}" == "${DOTFILES}/.zshrc" ]]; then
      echo "  Removing legacy symlink ~/.zshrc → dotfiles/.zshrc (replacing with stub)"
      rm "${home_rc}"
    fi
  fi

  if [[ -f "${home_rc}" ]] && grep -qF "${MARK_BEGIN}" "${home_rc}"; then
    echo "  ~/.zshrc already wired to dotfiles"
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
      echo "  Created ~/.zshrc with dotfiles include"
    else
      printf '%s' "${blk}" >>"${home_rc}"
      echo "  Appended dotfiles include to existing ~/.zshrc"
    fi
  fi
}

# --- vim: ~/.vimrc sources repo vimrc; never overwrite an existing ~/.vimrc without the marker.
wire_vimrc() {
  local home_vim="${HOME}/.vimrc"
  if [[ -f "${home_vim}" ]] && grep -qF "${MARK_BEGIN}" "${home_vim}"; then
    echo "  ~/.vimrc already wired to dotfiles"
    return 0
  fi

  local blk
  blk=$(
    cat <<EOF

" ${MARK_BEGIN}
if filereadable('${DOTFILES}/vimrc')
  source ${DOTFILES}/vimrc
endif
" ${MARK_END}
EOF
  )

  if [[ ! -f "${home_vim}" ]]; then
    cat <<EOF >"${home_vim}"
" ~/.vimrc — add your own settings above or below the dotfiles block.
" Shared Vim defaults: https://github.com/mhweiner/dotfiles
${blk}
EOF
    echo "  Created ~/.vimrc with dotfiles include"
  else
    printf '%s' "${blk}" >>"${home_vim}"
    echo "  Appended dotfiles include to existing ~/.vimrc"
  fi
}

wire_zshrc
wire_vimrc

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
for f in git-cleanup whatismyip killport; do
  [ -f "$DOTFILES/bin/$f" ] && ln -sf "$DOTFILES/bin/$f" ~/.local/bin/$f
done
echo "  Linked ~/.local/bin (git-cleanup, whatismyip, killport)"

# fonts
if [ -d "$DOTFILES/fonts" ]; then
  mkdir -p ~/Library/Fonts
  cp -n "$DOTFILES/fonts/"*.ttf ~/Library/Fonts/ 2>/dev/null || true
  echo "  Installed fonts to ~/Library/Fonts"
fi

echo ""
echo "Done. Restart iTerm2 (or open a new tab) so it picks up the preferences folder."
