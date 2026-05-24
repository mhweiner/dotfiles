# ✨ dotfiles

Personal macOS terminal setup: shell config, prompt, common CLI tools, and small helpers.


## Requirements 🍎

- macOS
- [Xcode Command Line Tools](https://developer.apple.com/documentation/xcode/installing-the-command-line-tools) (includes `git`)

```bash
xcode-select --install
```


## First-time setup 🚀

Clone into **`~/dotfiles`** and run install.

```bash
git clone https://github.com/mhweiner/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

After install, quit and reopen **iTerm2** so it reloads preferences.


## What `install.sh` installs 🧰

| Installed | What it's for |
|-----------|---------------|
| 🍺 [Homebrew](https://brew.sh/) | Install and update CLI tools and Mac apps |
| 🖥️ [iTerm2](https://iterm2.com/) | Terminal with tabs, splits, and profiles |
| 🚀 [Starship](https://starship.rs/) | Shell prompt in your terminal |
| 🐙 [GitHub CLI](https://cli.github.com/) (`gh`) | Work with GitHub from the terminal |
| ☁️ [AWS CLI](https://aws.amazon.com/cli/) (`aws`) | Work with AWS from the terminal |
| 📦 [nvm](https://github.com/nvm-sh/nvm) + Node **LTS** | Install and switch Node versions per project |
| 🔭 [open-prs](https://github.com/logfoxai/open-prs) ([tap](https://github.com/logfoxai/homebrew-tap)) | See open PRs across a GitHub org |
| 🔤 [Hack Nerd Font](https://www.nerdfonts.com/) | Monospace font with icons for the terminal |

`install.sh` is safe to rerun. It prompts before installing Homebrew packages (say no to wire config only). Already-installed packages are skipped; Node LTS is installed only when `node` is missing.


## What `install.sh` configures 🤫

The config phase always runs (even if you skip Homebrew packages). It wires repo files into the places macOS and your apps expect them. Existing files are left alone unless install prompts you first.

**Optional:** Homebrew apps and CLI tools (iTerm, Starship, `gh`, fonts, etc.) are a separate prompt — see [What `install.sh` installs](#what-installsh-installs-) above. Say no there to get only the config below.

### What you get

| Where it lands | From | What's in it |
|----------------|------|--------------|
| **`~/.zshrc`** (sources repo) | `~/dotfiles/.zshrc` | Shared shell: Homebrew/`~/.local/bin` on `PATH`, Starship prompt, nvm + auto-`.nvmrc`, helpers (`ll`, `git-cleanup`, `whatismyip`, `npmgh`, `awssso`). Your machine-only lines stay outside the `>>> dotfiles BEGIN` block. |
| **`~/.config/starship.toml`** | `~/dotfiles/starship.toml` | Starship theme (default layout; customize in the repo file). |
| **`~/.vimrc`** | `~/dotfiles/vimrc` | Shared Vim defaults: syntax/filetypes, line numbers, search, tabs, undo, system clipboard. Symlinked when missing; prompts if you already have a `~/.vimrc`. |
| **`~/Library/Preferences/com.googlecode.iterm2.plist`** | `~/dotfiles/iterm2/` template | iTerm2 **Default** profile: Hack Nerd Font Mono 14, `xterm-256color`, light/dark colors. Copied to the normal prefs location (not a symlink). Prompts before overwrite; sanitizes live prefs to drop saved window layouts and machine junk. |
| **Cursor `settings.json`** | dotfiles terminal defaults | **Terminal-only** keys merged into `~/Library/Application Support/Cursor/User/settings.json`: zsh login shell, iTerm as external terminal, Hack Nerd Font stack, block cursor, shell integration, GPU acceleration. Prompts if you already have different terminal settings. |
| **`~/.local/bin/`** | `~/dotfiles/bin/` | `listenport` (and removes legacy helper symlinks that moved into `.zshrc`). |

See **Helpers** below for what the shell functions and scripts do day to day.

### How install applies it

1. **Shell** — Adds an idempotent `source ~/dotfiles/.zshrc` block to `~/.zshrc` (won't duplicate on rerun).
2. **Vim** — Symlinks `~/.vimrc` → `~/dotfiles/vimrc` when absent, or asks before replacing an existing file.
3. **Starship** — Symlinks `~/.config/starship.toml` → `~/dotfiles/starship.toml`.
4. **iTerm2** — Copies the repo template into `~/Library/Preferences/`, migrates off legacy "custom prefs folder" setups, and sanitizes deprecated keys / saved arrangements on your live prefs.
5. **Bin helpers** — Symlinks `listenport` into `~/.local/bin` and removes obsolete symlinks from older dotfiles layouts.
6. **Cursor** — Merges terminal settings into your existing `settings.json` when needed (prompts before overwriting).

Quit and reopen **iTerm2** (and Cursor if you changed terminal settings) so apps pick up the new config.


## Where to edit things 📝

| Goal | File or location |
|------|-------------------|
| Shared zsh (commit in this repo) | `~/dotfiles/.zshrc` |
| Machine-only zsh | `~/.zshrc` (outside the `>>> dotfiles BEGIN` … `END` block, or after it) |
| Shared Vim | `~/dotfiles/vimrc` (used when `~/.vimrc` is the symlink install created) |
| Machine-only Vim | Your own `~/.vimrc` — install leaves it untouched if it already exists |


## Updating ⬆️

```bash
cd ~/dotfiles && git pull && ./install.sh
```


## Helpers 🧪

| Name | Where | What |
|------|-------|------|
| `listenport` | `bin/` | Port usage (`lsof`); **`-k <port>`** kills listeners. |
| `ll` | `.zshrc` | Long listing (`ls -lah`): all entries, human sizes, dotfiles. |
| `git-cleanup` | `.zshrc` | Checkout/pull, prune `: gone]` branches (default **`main`**). |
| `whatismyip` | `.zshrc` | Print public and local IP. |
| `npmgh` | `.zshrc` | **`npmgh install`**, **`npmgh ci`**, etc. — same as **`npm`** but sets **`GITHUB_TOKEN`** from **`gh auth token`** for **GitHub Packages** and ensures **`read:packages`** on **`gh`** when missing. Plain **`npm`** is not wrapped (so **`npm link`** never forces OAuth). |
| `awssso` | `.zshrc` | **`aws sso login`**, then **`export AWS_PROFILE`**. |
