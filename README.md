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


## What `install.sh` does 🧰

`install.sh` is safe to rerun. You're prompted for packages, then config — it prints what config will do before that second prompt.

**Packages** — iTerm, fonts, CLI tools, nvm, and Node via Homebrew. Skips what's already installed; Node LTS only if `node` is missing.

**Config** — creates missing files. Asks before overwriting anything you already have.

### In order

1. **Packages** — Homebrew bootstrap: iTerm2, Hack Nerd Font, Starship, `gh`, AWS CLI, open-prs, nvm, Node LTS.
2. **Config** — prints what will be wired (see below), then asks whether to apply.
3. **Shell** — idempotent `source ~/dotfiles/.zshrc` block in `~/.zshrc`.
4. **Vim** — symlink `~/.vimrc` → `~/dotfiles/vimrc` when absent; prompts if you already have one.
5. **Starship** — symlink `~/.config/starship.toml` → `~/dotfiles/starship.toml`.
6. **iTerm2** — copy template to `~/Library/Preferences/`, migrate off legacy custom-folder prefs, sanitize live plist.
7. **Bin** — symlink `listenport` into `~/.local/bin`; remove obsolete helper symlinks from older layouts.
8. **Cursor** — merge terminal-only keys into `settings.json`; prompts if yours differ.

Quit and reopen **iTerm2** (and Cursor if you changed terminal settings) so apps pick up the new config.

### Shell (`~/dotfiles/.zshrc`)

PATH (Homebrew, `~/.local/bin`), Starship prompt, nvm + auto-`.nvmrc`, helpers: `ll`, `git-cleanup`, `whatismyip`, `npmgh`, `awssso`. Machine-only lines live outside the `>>> dotfiles BEGIN` block in `~/.zshrc`.

### Vim, Starship, iTerm, Cursor, bin

- **Vim** — syntax, line numbers, search, tabs, undo, system clipboard.
- **Starship** — default theme in `starship.toml`.
- **iTerm2** — Default profile: Hack Nerd Font Mono 14, `xterm-256color`, light/dark colors.
- **Cursor** — zsh login shell, iTerm external terminal, Nerd Font stack, block cursor, shell integration, GPU acceleration (terminal keys only).
- **`listenport`** — port usage / kill listeners (`bin/`). See **Helpers** below.


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
