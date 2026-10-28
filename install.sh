#!/bin/sh
set -eu

base='https://github.com/shravanngoswamii/gh-sandbox/releases/latest/download'
dest_dir=${GHSB_INSTALL_DIR:-"$HOME/.local/bin"}
tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/ghsb-install.XXXXXX")
trap 'rm -rf "$tmp_dir"' EXIT

curl -fsSL "$base/ghsb" -o "$tmp_dir/ghsb"
curl -fsSL "$base/ghsb.sha256" -o "$tmp_dir/ghsb.sha256"
read -r expected _ < "$tmp_dir/ghsb.sha256"
if command -v sha256sum >/dev/null 2>&1; then
  actual=$(sha256sum "$tmp_dir/ghsb")
elif command -v shasum >/dev/null 2>&1; then
  actual=$(shasum -a 256 "$tmp_dir/ghsb")
else
  printf 'ghsb: sha256sum or shasum is required\n' >&2
  exit 1
fi
actual=${actual%% *}
[ "$actual" = "$expected" ] || { printf 'ghsb: download checksum mismatch\n' >&2; exit 1; }

mkdir -p "$dest_dir"
install -m 755 "$tmp_dir/ghsb" "$dest_dir/ghsb"
printf 'Installed ghsb to %s/ghsb\n' "$dest_dir"
case ":$PATH:" in
  *":$dest_dir:"*) ;;
  *) printf 'Add it to your PATH: export PATH="%s:$PATH"\n' "$dest_dir" ;;
esac
