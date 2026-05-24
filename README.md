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

`install.sh` is safe to rerun. It skips already-installed packages and only installs Node LTS when `node` is missing.


## What `install.sh` configures 🤫

It configures:

1. Ensures **`~/.zshrc`** includes an idempotent block that `source`s `~/dotfiles/.zshrc`.
2. If **`~/.vimrc`** already exists, prompts whether to overwrite it with a symlink to **`~/dotfiles/vimrc`**.
3. Symlinks **`starship.toml`** into `~/.config/`.
4. Copies the **iTerm2** template from `~/dotfiles/iterm2` into the normal `~/Library/Preferences` location (prompts before overwriting existing prefs; migrates away from legacy custom-folder setups).
5. Symlinks **`bin/`** helpers into **`~/.local/bin`**.
6. Sets Cursor user terminal settings in `~/Library/Application Support/Cursor/User/settings.json` (zsh login shell, iTerm external terminal, Nerd Font stack), and prompts before overwriting different existing terminal settings.


## Where to edit things 📝

| Goal | File or location |
|------|-------------------|
| Shared zsh (commit in this repo) | `~/dotfiles/.zshrc` |
| Machine-only zsh | `~/.zshrc` (outside the `>>> dotfiles BEGIN` … `END` block, or after it) |
| Shared Vim | `~/dotfiles/vimrc` (used when `~/.vimrc` is the symlink install created) |
| Machine-only Vim | Your own `~/.vimrc` — install leaves it untouched if it already exists |


## Updating ⬆️

**Everything** (recommended):

```bash
cd ~/dotfiles && git pull && ./install.sh
```

**Config only** (skip Homebrew/nvm/Node):

```bash
cd ~/dotfiles && git pull && DOTFILES_SKIP_PACKAGES=1 ./install.sh
```


## Repository layout 📂

| Path | Role |
|------|------|
| `.zshrc` | Shared zsh configuration |
| `vimrc` | Shared Vim configuration |
| `starship.toml` | Starship prompt theme |
| `iterm2/` | iTerm2 preferences template (copied into `~/Library/Preferences` on install) |
| `bin/` | Scripts symlinked to `~/.local/bin` (see **Helpers**) |
| `install.sh` | Installs packages, checks nvm/Node, wires `~/.zshrc`, optionally replaces `~/.vimrc`, configures iTerm/Cursor terminal settings, and links `bin/` helpers |


## Helpers 🧪

| Name | Where | What |
|------|-------|------|
| `listenport` | `bin/` | Port usage (`lsof`); **`-k <port>`** kills listeners. |
| `ll` | `.zshrc` | Long listing (`ls -lah`): all entries, human sizes, dotfiles. |
| `git-cleanup` | `.zshrc` | Checkout/pull, prune `: gone]` branches (default **`main`**). |
| `whatismyip` | `.zshrc` | Print public and local IP. |
| `npmgh` | `.zshrc` | **`npmgh install`**, **`npmgh ci`**, etc. — same as **`npm`** but sets **`GITHUB_TOKEN`** from **`gh auth token`** for **GitHub Packages** and ensures **`read:packages`** on **`gh`** when missing. Plain **`npm`** is not wrapped (so **`npm link`** never forces OAuth). |
| `awssso` | `.zshrc` | **`aws sso login`**, then **`export AWS_PROFILE`**. |
