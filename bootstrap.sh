#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd -P)"
exec "${DOTFILES}/install.sh" "$@"
