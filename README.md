# dotfiles

My settings for iTerm, Starship, Cursor, and more.

Shell, prompt, and iTerm2 config. Same setup on every Mac.

## New Mac setup

1. **Clone this repo:**
   ```bash
   git clone https://github.com/mhweiner/dotfiles.git ~/dotfiles
   ```

2. **Run the install script:**
   ```bash
   ~/dotfiles/install.sh
   ```

3. **Install dependencies** (if not already present):
   - [iTerm2](https://iterm2.com/)
   - [Starship](https://starship.rs/): `brew install starship`
   - [nvm](https://github.com/nvm-sh/nvm) (for .zshrc): install from nvm repo

4. **Restart iTerm2** so it loads preferences from `~/dotfiles/iterm2`.

## What’s in here

| File / folder      | Purpose |
|--------------------|--------|
| `.zshrc`           | Shell config (PATH, aliases, nvm, starship init) |
| `starship.toml`    | [Starship](https://starship.rs/) prompt config |
| `iterm2/`          | iTerm2 preferences (iTerm2 reads/writes here when “Load from custom folder” is set) |
| `install.sh`       | Symlinks the above into `~` / `~/.config` and points iTerm2 at this repo |

## Updating another machine

```bash
cd ~/dotfiles && git pull
```

No need to re-run `install.sh` unless you’re on a brand-new machine.
