#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=tests/lib.sh
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"

setup_fake_home

GIT_CLEANUP="${DOTFILES_DIR}/bin/git-cleanup"
chmod +x "${GIT_CLEANUP}"

repo="${TMP_DIR}/repo"
wt="${TMP_DIR}/repo-feature"
mkdir -p "${repo}"

git -C "${repo}" init -b main
git -C "${repo}" config user.email "test@example.com"
git -C "${repo}" config user.name "test"
echo init >"${repo}/README"
git -C "${repo}" add README
git -C "${repo}" commit -m "init"

git -C "${repo}" branch feature/wt
git -C "${repo}" worktree add "${wt}" feature/wt

rm -rf "${wt}"

bare="${TMP_DIR}/origin.git"
git init --bare "${bare}"
git -C "${repo}" remote add origin "${bare}"
git -C "${repo}" push -u origin main
git -C "${repo}" push origin feature/wt
git -C "${repo}" branch -u origin/feature/wt feature/wt
git -C "${repo}" push origin --delete feature/wt
git -C "${repo}" fetch -p

PATH="${FAKE_BIN}:${PATH}"
export PATH

# Fake origin fetch is not needed; branch -vv should show : gone]
cd "${repo}"
"${GIT_CLEANUP}" main

if git worktree list | grep -q "${wt}"; then
  test_fail "expected stale worktree path to be pruned/removed"
fi

if git branch --list feature/wt | grep -q feature/wt; then
  test_fail "expected local feature/wt branch to be deleted"
fi

test_pass "git-cleanup prunes stale worktrees and deletes gone branches"

# Live linked worktrees: `git branch -vv` marks these branches with "+ ".
live_wt="${TMP_DIR}/repo-live"
dirty_wt="${TMP_DIR}/repo-dirty"
for b in feature/live feature/dirty; do
  git -C "${repo}" branch "${b}"
  git -C "${repo}" push -u origin "${b}"
done
git -C "${repo}" worktree add "${live_wt}" feature/live
git -C "${repo}" worktree add "${dirty_wt}" feature/dirty
echo wip >>"${dirty_wt}/README"
for b in feature/live feature/dirty; do
  git -C "${repo}" push origin --delete "${b}"
done

"${GIT_CLEANUP}" main

[[ ! -d "${live_wt}" ]] || test_fail "expected clean live worktree to be removed"
if git branch --list feature/live | grep -q feature/live; then
  test_fail "expected local feature/live branch to be deleted"
fi

[[ -d "${dirty_wt}" ]] || test_fail "expected worktree with uncommitted changes to be kept"
grep -q wip "${dirty_wt}/README" || test_fail "expected uncommitted changes to survive"
git branch --list feature/dirty | grep -q feature/dirty ||
  test_fail "expected branch of kept worktree to survive"

test_pass "git-cleanup removes clean live worktrees and keeps dirty ones"
