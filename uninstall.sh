#!/bin/sh
set -eu

dest_dir=${GHSB_INSTALL_DIR:-"$HOME/.local/bin"}
target="$dest_dir/ghsb"
if [ -e "$target" ] || [ -L "$target" ]; then
  rm -- "$target"
  printf 'Removed %s\n' "$target"
else
  printf 'ghsb is not installed at %s\n' "$target"
fi
printf 'Sandboxes in %s were kept.\n' "${GH_SANDBOX_HOME:-$HOME/.gh-sandboxes}"
