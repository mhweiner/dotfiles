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
