# dotfiles

My personal Mac setup. This repo exists so I can clone it onto a new machine and be productive in minutes. Feel free to fork, steal ideas, or submit PRs.

## Setup

```bash
xcode-select --install
git clone https://github.com/mhweiner/dotfiles.git ~/dotfiles
~/dotfiles/bootstrap.sh
```

`bootstrap.sh` installs everything below, wires up symlinks, and configures iTerm2. Safe to re-run — it skips anything already installed. Reopen iTerm2 when it's done.

To pull updates later:

```bash
cd ~/dotfiles && git pull && ~/dotfiles/bootstrap.sh
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
| [0xProto Nerd Font](https://www.nerdfonts.com/) | Monospace font with icons |

## What's in the repo

| Path | What it does |
|------|--------------|
| `.zshrc` | PATH, aliases, nvm, starship init. Sources `~/.zshrc.local` for machine-specific overrides. |
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
| `open-prs <org>` | List open PRs across a GitHub org with CI badges and clickable titles. `--watch` for a full-screen dashboard (refreshes every 5 min, `r` refresh, `c` clear merged, `q` quit). Requires `gh`. |

## Local overrides

Machine-specific config goes in `~/.zshrc.local` (and/or `~/dotfiles/.zshrc.local`, which is gitignored). Both are sourced at the end of `.zshrc` if they exist. Install never overwrites them.
