# dotfiles

My personal Mac setup. This repo exists so I can clone it onto a new machine and be productive in minutes. Feel free to fork, steal ideas, or submit PRs.

## Setup

```bash
xcode-select --install
git clone https://github.com/mhweiner/dotfiles.git ~/dotfiles
~/dotfiles/bootstrap.sh
```

`bootstrap.sh` installs everything below, wires up symlinks, and configures iTerm2. **Safe to re-run** on a machine that is already set up: it skips Homebrew if present, skips each brew formula or cask that is already installed (it does **not** bulk-upgrade), skips nvm if `~/.nvm/nvm.sh` exists, skips Node if `node` is already on your `PATH`, then always runs `install.sh` (symlinks and iTerm prefs path are reapplied). Reopen iTerm2 when it is done.

To pull **dotfile config** updates on an existing machine (typical day-to-day):

```bash
cd ~/dotfiles && git pull && ./install.sh
```

To also re-check Homebrew / nvm / Node / `open-prs` (same as a fresh machine, still non-destructive):

```bash
cd ~/dotfiles && git pull && ./bootstrap.sh
```

## What gets installed

| Tool | What it is |
|------|------------|
| [Homebrew](https://brew.sh/) | Package manager |
| [iTerm2](https://iterm2.com/) | Terminal emulator |
| [Starship](https://starship.rs/) | Cross-shell prompt |
| [GitHub CLI](https://cli.github.com/) (`gh`) | GitHub from the terminal |
| [AWS CLI](https://aws.amazon.com/cli/) (`aws`) | AWS from the terminal |
| [nvm](https://github.com/nvm-sh/nvm) + Node LTS | Node.js version manager |
| [open-prs](https://github.com/logfoxai/open-prs) | GitHub org PR dashboard TUI |
| [0xProto Nerd Font](https://www.nerdfonts.com/) | Monospace font with icons |

## What's in the repo

| Path | What it does |
|------|--------------|
| `.zshrc` | PATH, aliases, nvm, starship init. Sources **`~/.zshrc.local`** only for machine-specific overrides. |
| `starship.toml` | Starship prompt config |
| `iterm2/` | iTerm2 preferences (auto-saved when you change settings) |
| `fonts/` | 0xProto Nerd Font |
| `bin/` | CLI helpers (symlinked to `~/.local/bin`) |
| `install.sh` | Symlinks config files and points iTerm at this repo |
| `bootstrap.sh` | Installs tools + runs `install.sh` |

## CLI helpers

| Command | Description |
|---------|-------------|
| `git-cleanup` | Prune merged/gone branches. Default branch: `main`. |
| `whatismyip` | Print public and local IP. |
| `killport <port>` | Kill whatever's listening on a port. |
| [`open-prs`](https://github.com/logfoxai/open-prs) `<org>` | Full-screen TUI dashboard for all open PRs across a GitHub org. Live CI badges, post-merge deploy tracking, clickable titles. `--once` for a one-shot print. Installed from [logfoxai/open-prs](https://github.com/logfoxai/open-prs). |

## Local overrides

Machine-specific config lives in **`~/.zshrc.local`** only. It is sourced at the end of `.zshrc` if the file exists. `install.sh` creates it from `zshrc.local.example` once and **never overwrites** it.

If you previously used **`~/dotfiles/.zshrc.local`**, merge anything you still need into `~/.zshrc.local` and remove the old file when you are ready; it is no longer sourced.
