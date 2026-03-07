# ✨ dotfiles

**iTerm2 · Starship · zsh** — same setup on every Mac. No more “wait, how did I configure that?”

---

## 🚀 New Mac? Start here

**1.** Get the basics (if you don’t have them yet):
- [Xcode Command Line Tools](https://developer.apple.com/xcode/) → `xcode-select --install`
- [Homebrew](https://brew.sh)

**2.** Clone this repo and run the installer:

```bash
git clone https://github.com/mhweiner/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

**3.** Install the apps/tools you actually use:
- **iTerm2** → [iterm2.com](https://iterm2.com) or `brew install --cask iterm2`
- **Starship** → `brew install starship`
- **nvm** → `curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash`

**4.** Quit and reopen iTerm2 so it picks up the preferences from `~/dotfiles/iterm2`.

That’s it. You’re in business. 🎉

---

## 📦 What’s in the box

| Path | What it does |
|------|----------------|
| `.zshrc` | PATH, aliases, nvm, starship init |
| `starship.toml` | [Starship](https://starship.rs/) prompt config |
| `iterm2/` | iTerm2 preferences (auto-saved here when you change settings) |
| `bin/git-cleanup` | Prune merged/gone branches (symlinked to `~/.local/bin`) |
| `install.sh` | Wires everything up with symlinks and points iTerm at this repo |

---

## 🔄 Already set up? Just pulling the latest

```bash
cd ~/dotfiles && git pull
```

You only need to run `install.sh` again on a brand-new machine.
