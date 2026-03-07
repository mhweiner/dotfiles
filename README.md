# dotfiles

iTerm2, Starship, zsh. Same setup on every Mac.

## New Mac setup

1. **Prereqs:** [Xcode Command Line Tools](https://developer.apple.com/xcode/) (`xcode-select --install`) and [Homebrew](https://brew.sh).

2. **Clone and install:**
   ```bash
   git clone https://github.com/mhweiner/dotfiles.git ~/dotfiles
   ~/dotfiles/install.sh
   ```

3. **Install apps/tools** (pick what you use):
   - **iTerm2:** [iterm2.com](https://iterm2.com) or `brew install --cask iterm2`
   - **Starship:** `brew install starship`
   - **nvm:** `curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash`

4. **Restart iTerm2** so it uses prefs from `~/dotfiles/iterm2`.

## Contents

| Path | What |
|------|------|
| `.zshrc` | PATH, aliases, nvm, starship init |
| `starship.toml` | [Starship](https://starship.rs/) prompt config |
| `iterm2/` | iTerm2 preferences (read/written by iTerm when “Load from custom folder” is set) |
| `bin/git-cleanup` | Prune gone branches (symlinked to `~/.local/bin` by install) |
| `install.sh` | Symlinks the above and points iTerm at this repo |

## Updating

```bash
cd ~/dotfiles && git pull
```

Re-run `install.sh` only on a new machine.
