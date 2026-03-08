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
| `zshrc.local.example` | Template for local overrides. Install copies to `~/.zshrc.local` and/or `~/dotfiles/.zshrc.local` only if missing (both gitignored / never overwritten). |
| `starship.toml` | [Starship](https://starship.rs/) prompt config |
| `iterm2/` | iTerm2 preferences (auto-saved here when you change settings) |
| `fonts/` | 0xProto Nerd Font (copied to `~/Library/Fonts` by install) |
| `bin/` | Helper scripts (symlinked to `~/.local/bin` by install). See **Helpers** below. |
| `install.sh` | Wires everything up with symlinks and points iTerm at this repo |
| `bootstrap.sh` | TUI setup: pick tools (iTerm2, Starship, nvm) to install, then runs install.sh |

---

## Helpers (`bin/` → `~/.local/bin`)

Install symlinks these into `~/.local/bin` (already on PATH in `.zshrc`). Run them from any terminal.

| Command | What it does |
|--------|----------------|
| **`git-cleanup`** | Prune merged/gone branches. `git-cleanup` (default: main) or `git-cleanup dev`. |
| **`whatismyip`** | Print your public IP and local IP (with emojis). |
| **`killport <port>`** | Kill any process listening on the given port. Example: `killport 3000`. |

---

## 🏠 Local overrides (`.zshrc.local`) — never lose your machine-specific stuff

**Where it can live (either or both):**

- **`~/.zshrc.local`** — in your home directory. Not in the repo.
- **`~/dotfiles/.zshrc.local`** — next to `zshrc.local.example` in the repo folder. **Gitignored**, so it’s never committed even though the file sits in the repo directory.

**How it’s loaded:** The repo’s `.zshrc` is symlinked to `~/.zshrc`. At the **end** it runs:

```bash
[ -f ~/.zshrc.local ] && . ~/.zshrc.local
[ -f ~/dotfiles/.zshrc.local ] && . ~/dotfiles/.zshrc.local
```

So when zsh starts, it runs the repo’s `.zshrc` first, then sources both local files if they exist (home first, then dotfiles dir). Anything in either file overrides or adds to the repo config.

**Bulletproof updates:** Put machine-specific or personal stuff only in one or both of those local files. Then you can always run:

```bash
cd ~/dotfiles && git pull && ~/dotfiles/install.sh
```

Install **never overwrites** either `.zshrc.local` (it only creates them from the example if missing). The repo’s `.gitignore` lists `.zshrc.local`, so even if you keep it in `~/dotfiles/`, it won’t be committed. You never lose local changes when you update.

**First time:** Install creates both `~/.zshrc.local` and `~/dotfiles/.zshrc.local` from the example if they’re missing. Edit whichever you prefer (or both).

---

## 🔄 Already set up? Just pulling the latest

```bash
cd ~/dotfiles && git pull && ~/dotfiles/install.sh
```

Safe to run anytime. Repo files get updated; `~/.zshrc.local` is never touched.
