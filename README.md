# dotfiles

Personal macOS shell + terminal setup. Clone to **`~/dotfiles`** so paths match the README; `install.sh` embeds your clone path when it adds the stub to `~/.zshrc` and `~/.vimrc`.

## Setup

```bash
xcode-select --install
git clone https://github.com/mhweiner/dotfiles.git ~/dotfiles
~/dotfiles/bootstrap.sh
```

`bootstrap.sh` installs Homebrew packages, nvm, Node LTS, `open-prs`, then runs **`install.sh`**. **Safe to re-run** on an already-configured Mac: it skips Homebrew if present, skips each brew formula or cask that is already installed (it does **not** bulk-upgrade), skips nvm if `~/.nvm/nvm.sh` exists, skips Node if `node` is on your `PATH`, re-downloads `open-prs`, then runs `install.sh` again. Reopen iTerm2 when it finishes.

### How shell config is wired (Homebrew-style)

- **Version-controlled config** lives in **`~/dotfiles/.zshrc`** in this repo (PATH, nvm, Starship, aliases — no `GITHUB_TOKEN` or other secrets).
- **`~/.zshrc`** on the machine is **yours**: `install.sh` **creates** it if missing, or **appends** a single marked block if it already exists. It **never** replaces your whole `~/.zshrc`.
- If you used an older install that **symlinked** `~/dotfiles/.zshrc` → `~/.zshrc`, the next `install.sh` removes that symlink and replaces it with the stub pattern.

Put anything machine-specific in **`~/.zshrc`** above or below the `>>> dotfiles BEGIN` … `END` block (or fork this repo).

### Vim

- Defaults live in **`~/dotfiles/vimrc`** (syntax, numbers, undo dir, etc.).
- **`~/.vimrc`** is created or gets an appended marked block that **`source`s** that file. Your existing `~/.vimrc` is **never** overwritten wholesale.

## After clone: where to look

| What you want | Where it is |
|----------------|-------------|
| Shared zsh (edit + `git pull`) | `~/dotfiles/.zshrc` |
| This Mac only | `~/.zshrc` (outside the dotfiles block, or after it) |
| Shared Vim | `~/dotfiles/vimrc` |
| This Mac only | `~/.vimrc` (outside the dotfiles block) |

## Pull updates

Dotfile **content** (zsh, vim, starship, scripts):

```bash
cd ~/dotfiles && git pull && ./install.sh
```

Re-check **Homebrew / nvm / Node / open-prs**:

```bash
cd ~/dotfiles && git pull && ./bootstrap.sh
```

## What gets installed (bootstrap)

| Tool | What it is |
|------|------------|
| [Homebrew](https://brew.sh/) | Package manager |
| [iTerm2](https://iterm2.com/) | Terminal emulator |
| [Starship](https://starship.rs/) | Cross-shell prompt |
| [GitHub CLI](https://cli.github.com/) (`gh`) | GitHub from the terminal |
| [AWS CLI](https://aws.amazon.com/cli/) (`aws`) | AWS from the terminal |
| [nvm](https://github.com/nvm-sh/nvm) + Node LTS | Node.js version manager |
| [open-prs](https://github.com/logfoxai/open-prs) | GitHub org PR dashboard TUI |
| [0xProto Nerd Font](https://www.nerdfonts.com/) | Monospace font with icons (if `fonts/` exists) |

## Repo layout

| Path | Role |
|------|------|
| `.zshrc` | Shared zsh config (sourced from `~/.zshrc` stub). |
| `vimrc` | Shared Vim defaults (sourced from `~/.vimrc` stub). |
| `starship.toml` | Starship prompt |
| `iterm2/` | iTerm2 preferences folder |
| `fonts/` | Nerd Font copies (optional) |
| `bin/` | Helpers → `~/.local/bin` |
| `install.sh` | Wires `~/.zshrc` / `~/.vimrc`, symlinks starship + bins, iTerm prefs path |
| `bootstrap.sh` | Installs tools + runs `install.sh` |

## CLI helpers

| Command | Description |
|---------|-------------|
| `git-cleanup` | Prune merged/gone branches. Default branch: `main`. |
| `whatismyip` | Print public and local IP. |
| `killport <port>` | Kill whatever is listening on a port. |
| [`open-prs`](https://github.com/logfoxai/open-prs) `<org>` | Org PR dashboard TUI; `--once` for a one-shot print. |

## GitHub Packages / npm

Do **not** put `export GITHUB_TOKEN=…` in shared zsh. Prefer a per-command wrapper, e.g. `npm() { GITHUB_TOKEN=$(gh auth token 2>/dev/null) command npm "$@"; }` in your personal `~/.zshrc` if you need it.
