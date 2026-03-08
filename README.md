# ✨ dotfiles

**iTerm2 · Starship · zsh** — same setup on every Mac. No more "wait, how did I configure that?"

---

## 🚀 New Mac? Start here

**1.** Install Xcode Command Line Tools (for `git`):

```bash
xcode-select --install
```

**2.** Clone this repo:

```bash
git clone https://github.com/mhweiner/dotfiles.git ~/dotfiles
```

**3.** Run the setup script (TUI — pick which tools to install):

```bash
~/dotfiles/bootstrap.sh
```

The menu lets you choose **iTerm2**, **Starship**, and **nvm** (space to toggle, Enter when done). It will install Homebrew and [gum](https://github.com/charmbracelet/gum) if needed, then install your selections and wire everything up. When it's done, **quit and reopen iTerm2**.

That's it. You're in business. 🎉

---

## 📦 What's in the box

| Path | What it does |
|------|----------------|
| `.zshrc` | PATH, aliases, nvm, starship init (repo-controlled; sources `~/.zshrc.local` at the end) |
| `zshrc.local.example` | Template for `~/.zshrc.local`. Install copies it to `~/.zshrc.local` only if missing — **edit `~/.zshrc.local` for machine-specific stuff; install never overwrites it.** |
| `starship.toml` | [Starship](https://starship.rs/) prompt config |
| `iterm2/` | iTerm2 preferences (auto-saved here when you change settings) |
| `fonts/` | 0xProto Nerd Font (copied to `~/Library/Fonts` by install) |
| `bin/git-cleanup` | Prune merged/gone branches (symlinked to `~/.local/bin`) |
| `install.sh` | Wires everything up with symlinks and points iTerm at this repo |
| `bootstrap.sh` | TUI setup: pick tools (iTerm2, Starship, nvm) to install, then runs install.sh |

---

## 🏠 Local overrides (`~/.zshrc.local`) — never lose your machine-specific stuff

**Where it lives:** `~/.zshrc.local` (in your **home directory**). It is **not** in the repo and is **not** version-controlled.

**How it’s loaded:** The repo’s `.zshrc` is symlinked to `~/.zshrc`. At the **end** of that file we have:

```bash
[ -f ~/.zshrc.local ] && . ~/.zshrc.local
```

So when zsh starts, it runs the repo’s `.zshrc` first (PATH, aliases, nvm, starship), then sources `~/.zshrc.local` if it exists. Anything in the local file overrides or adds to the repo config.

**Bulletproof updates:** Put machine-specific or personal stuff **only** in `~/.zshrc.local` (extra PATH, aliases, secrets, etc.). Then you can always run:

```bash
cd ~/dotfiles && git pull && ~/dotfiles/install.sh
```

Install **never overwrites** `~/.zshrc.local` (it only creates it from the example if the file is missing). So you never lose local changes when you update. This is a common dotfiles pattern.

**First time:** If you don’t have `~/.zshrc.local` yet, `install.sh` copies `zshrc.local.example` there so you have a starter. Edit it as you like.

---

## 🔄 Already set up? Just pulling the latest

```bash
cd ~/dotfiles && git pull && ~/dotfiles/install.sh
```

Safe to run anytime. Repo files get updated; `~/.zshrc.local` is never touched.
