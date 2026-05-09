# ✨ dotfiles

My personal macOS setup, built around a **terminal-focused workflow**: shell, prompt, common CLI tools, and small helpers. Feel free to fork, steal ideas, or copy bits wholesale; I put it here so others can use it too.


## Requirements 🍎

- macOS  
- [Xcode Command Line Tools](https://developer.apple.com/documentation/xcode/installing-the-command-line-tools) (includes `git`)

```bash
xcode-select --install
```


## First-time setup 🚀

Clone into **`~/dotfiles`** (the install script adds a line to **`~/.zshrc`** that sources this repo, using your real clone path).

```bash
git clone https://github.com/mhweiner/dotfiles.git ~/dotfiles
~/dotfiles/bootstrap.sh
```

Quit and reopen **iTerm2** when the script finishes so it picks up the preferences folder.


## What `bootstrap.sh` installs 🧰

| Installed | What it is | Typical use |
|-----------|----------------|-------------|
| 🍺 [Homebrew](https://brew.sh/) | macOS package manager | Install and upgrade CLI tools and casks |
| 🖥️ [iTerm2](https://iterm2.com/) | Terminal emulator | Tabs, splits, profiles |
| 🚀 [Starship](https://starship.rs/) | Shell prompt | Fast, informative `zsh` prompt |
| 🐙 [GitHub CLI](https://cli.github.com/) (`gh`) | GitHub from the terminal | PRs, issues, `gh auth login` |
| ☁️ [AWS CLI](https://aws.amazon.com/cli/) (`aws`) | AWS from the terminal | SSO, profiles, resource commands |
| 📦 [nvm](https://github.com/nvm-sh/nvm) + Node **LTS** | Node version manager | Per-project Node versions via `.nvmrc` |
| 🔭 [open-prs](https://github.com/logfoxai/open-prs) ([tap](https://github.com/logfoxai/homebrew-tap)) | Org-wide PR dashboard | TUI or `--once` summary for a GitHub org |
| 🔤 [0xProto Nerd Font](https://www.nerdfonts.com/) | Monospace font with icons | Starship / terminal icons (if `fonts/` is present in the repo) |

`bootstrap.sh` is **safe to run again** on an already set up Mac: it skips Homebrew if present, skips each formula or cask that is already installed (no mass upgrade), skips nvm if it is already installed, installs Node LTS only if `node` is missing, then runs **`install.sh`**.


## What `install.sh` does 🤫

Runs silently (no log spam — *stealth mode engaged*). It:

1. Ensures **`~/.zshrc`** contains a small, idempotent block that **`source`s** `~/dotfiles/.zshrc` (shared zsh config from this repo). If `~/.zshrc` does not exist, it creates it; otherwise it **appends** the block only if it is missing. Your file is never replaced wholesale.
2. If **`~/.vimrc` does not exist yet**, creates **`~/.vimrc`** as a **symlink** to **`~/dotfiles/vimrc`**. If you already have a `~/.vimrc`, install **does not** change it (no appends, no `source` injection).
3. Symlinks **`starship.toml`** into `~/.config/`.
4. Points **iTerm2** at `~/dotfiles/iterm2` for preferences.
5. Symlinks **`bin/`** helpers into **`~/.local/bin`**.
6. Copies **fonts** from `~/dotfiles/fonts/` into `~/Library/Fonts/` when that directory exists (skips existing files).


## Where to edit things 📝

| Goal | File or location |
|------|-------------------|
| Shared zsh (commit in this repo) | `~/dotfiles/.zshrc` |
| Machine-only zsh | `~/.zshrc` (outside the `>>> dotfiles BEGIN` … `END` block, or after it) |
| Shared Vim | `~/dotfiles/vimrc` (used when `~/.vimrc` is the symlink install created) |
| Machine-only Vim | Your own `~/.vimrc` — install leaves it untouched if it already exists |


## Updating ⬆️

**Config only** (zsh, Vim, Starship, `bin`, iTerm prefs path):

```bash
cd ~/dotfiles && git pull && ./install.sh
```

**Toolchain as well** (Homebrew packages, nvm, Node check):

```bash
cd ~/dotfiles && git pull && ./bootstrap.sh
```


## Repository layout 📂

| Path | Role |
|------|------|
| `.zshrc` | Shared zsh configuration |
| `vimrc` | Shared Vim configuration |
| `starship.toml` | Starship prompt theme |
| `iterm2/` | iTerm2 preferences (folder iTerm reads/writes) |
| `fonts/` | Optional `.ttf` files copied to `~/Library/Fonts` |
| `bin/` | Scripts symlinked to `~/.local/bin` (see **Helpers**) |
| `install.sh` | `~/.zshrc` dotfiles include, optional `~/.vimrc` symlink, Starship, iTerm path, `bin`, fonts (no stdout) |
| `bootstrap.sh` | Installs the table above, then runs `install.sh` |


## Helpers 🧪

| Name | Where | What |
|------|-------|------|
| `listenport` | `bin/` | Port usage (`lsof`); **`-k <port>`** kills listeners. |
| `ll` | `.zshrc` | Long listing (`ls -lah`): all entries, human sizes, dotfiles. |
| `git-cleanup` | `.zshrc` | Checkout/pull, prune `: gone]` branches (default **`main`**). |
| `whatismyip` | `.zshrc` | Print public and local IP. |
| `npm` | `.zshrc` | Overrides **`npm`** so installs can use **GitHub Packages** with **`GITHUB_TOKEN`** from **`gh`** (after nvm). |
| `awssso` | `.zshrc` | **`aws sso login`**, then **`export AWS_PROFILE`**. |
