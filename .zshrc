# macOS user-local Python scripts (3.9 layout); only if present
[ -d "$HOME/Library/Python/3.9/bin" ] && export PATH="$HOME/Library/Python/3.9/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
export PATH="$HOME/.local/bin:$PATH" # cursor agent
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"

# === aliases ===

alias ll='ls -lah'
# Helpers (git-cleanup, whatismyip, killport) → ~/.local/bin via install.sh

# === nvm ===

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# === starship ===

eval "$(starship init zsh)"

# === local overrides (not in repo, never overwritten by install) ===
# Source both: home dir first, then repo dir (if you keep it next to zshrc.local.example). Both are gitignored.
[ -f ~/.zshrc.local ] && . ~/.zshrc.local
[ -f ~/dotfiles/.zshrc.local ] && . ~/dotfiles/.zshrc.local
