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

Safe to rerun. You're prompted before installing packages. Skips what's already installed; Node LTS only if `node` is missing.


## What `install.sh` configures ⚙️

- **Shell** — `~/dotfiles/.zshrc`: PATH, Starship, nvm, helpers
- **Vim** — `~/dotfiles/vimrc`
- **Starship** — `~/dotfiles/starship.toml`
- **iTerm2** — Default profile prefs (Hack Nerd Font, `xterm-256color`)
- **Cursor** — terminal settings only (zsh, iTerm, Nerd Font, shell integration)
- **Bin scripts** — `~/dotfiles/bin/` → `~/.local/bin`

You're prompted before applying config (install prints a summary first). Creates missing files; asks before overwriting existing ones.


## How install configures it

1. Adds an idempotent `source ~/dotfiles/.zshrc` block to `~/.zshrc`.
2. Symlinks `~/.vimrc` → `~/dotfiles/vimrc` (prompts if you already have one).
3. Symlinks `~/.config/starship.toml` → `~/dotfiles/starship.toml`.
4. Copies iTerm2 template to `~/Library/Preferences/`; migrates legacy custom-folder setups; sanitizes live prefs.
5. Symlinks `bin/` scripts into `~/.local/bin`; removes obsolete helper symlinks.
6. Merges Cursor terminal keys into `settings.json` (prompts if yours differ).

Quit and reopen **iTerm2** (and Cursor if you changed terminal settings).

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
