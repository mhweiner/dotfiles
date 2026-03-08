export PATH="/Users/marc/Library/Python/3.9/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
export PATH="$HOME/.local/bin:$PATH" # cursor agent
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"

# === aliases ===

alias ll='ls -lah'
# git-cleanup, whatismyip → ~/.local/bin (via install.sh)

# === helpers ===
killport() { kill $(lsof -ti :$1); }

# === nvm ===

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# === starship ===

eval "$(starship init zsh)"

# === local overrides (not in repo, never overwritten by install) ===
[ -f ~/.zshrc.local ] && . ~/.zshrc.local
