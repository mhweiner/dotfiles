# ✨ dotfiles

**iTerm2 · Starship · zsh** — same setup on every Mac. No more "wait, how did I configure that?"

---

## 🚀 New Mac? Start here

**One command** (installs Homebrew, iTerm2, Starship, nvm, clones this repo, runs install):

```bash
curl -fsSL https://raw.githubusercontent.com/mhweiner/dotfiles/main/bootstrap.sh | bash
```

You need **Xcode Command Line Tools** first (for `git`). If you don't have them:

```bash
xcode-select --install
```

Then run the one-liner above. When it's done, **quit and reopen iTerm2**.

---

**Or do it step by step:**

1. Xcode CLT → `xcode-select --install` · [Homebrew](https://brew.sh)
2. Clone → `git clone https://github.com/mhweiner/dotfiles.git ~/dotfiles`
3. Install tools → `brew install --cask iterm2` and `brew install starship` · [nvm](https://github.com/nvm-sh/nvm#installing-and-updating)
4. Run → `~/dotfiles/install.sh`
5. Quit and reopen iTerm2

That's it. You're in business. 🎉

---

## 📦 What's in the box

| Path | What it does |
|------|----------------|
| `.zshrc` | PATH, aliases, nvm, starship init |
| `starship.toml` | [Starship](https://starship.rs/) prompt config |
| `iterm2/` | iTerm2 preferences (auto-saved here when you change settings) |
| `fonts/` | 0xProto Nerd Font (copied to `~/Library/Fonts` by install) |
| `bin/git-cleanup` | Prune merged/gone branches (symlinked to `~/.local/bin`) |
| `install.sh` | Wires everything up with symlinks and points iTerm at this repo |
| `bootstrap.sh` | One-shot: installs Homebrew, tools, clones repo, runs install.sh (use via curl one-liner) |

---

## 🔄 Already set up? Just pulling the latest

```bash
cd ~/dotfiles && git pull
```

You only need to run `install.sh` again on a brand-new machine.
