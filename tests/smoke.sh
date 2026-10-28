#!/bin/sh
set -eu

repo=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
work=$(mktemp -d "${TMPDIR:-/tmp}/ghsb-test.XXXXXX")
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin"
export GH_SANDBOX_HOME="$work/sandboxes" GHSB_TEST_REPO="$repo" GHSB_TEST_WORK="$work"

cat > "$work/bin/gh" <<'EOF'
#!/bin/sh
set -eu
case "$1 $2" in
  'auth login')
    [ "$GH_CONFIG_DIR" = "$GH_SANDBOX_HOME/work/config" ]
    [ "$GIT_CONFIG_GLOBAL" = "$GH_SANDBOX_HOME/work/gitconfig" ]
    [ "$GIT_CONFIG_COUNT" = 0 ]
    [ "$GIT_CONFIG_NOSYSTEM" = 1 ]
    [ "$(pwd -P)" = "$(cd "$GH_SANDBOX_HOME/work" && pwd -P)" ]
    [ -z "${GH_TOKEN:-}${GITHUB_TOKEN:-}${GH_ENTERPRISE_TOKEN:-}${GITHUB_ENTERPRISE_TOKEN:-}" ]
    printf 'browser-token' > "$GH_CONFIG_DIR/mock-token"
    ;;
  'auth token') cat "$GH_CONFIG_DIR/mock-token" ;;
  'api user') printf 'testuser\t12345\tTest User\n' ;;
  *) exit 2 ;;
esac
EOF
cat > "$work/bin/curl" <<'EOF'
#!/bin/sh
set -eu
case "$2" in
  */ghsb) cp "$GHSB_TEST_REPO/ghsb" "$4" ;;
  */ghsb.sha256) cp "$GHSB_TEST_WORK/ghsb.sha256" "$4" ;;
  *) exit 2 ;;
esac
EOF
chmod 755 "$work/bin/gh" "$work/bin/curl"
export PATH="$work/bin:$PATH"

bash -n "$repo/ghsb"
sh -n "$repo/install.sh"
GH_TOKEN=outer GH_ENTERPRISE_TOKEN=outer "$repo/ghsb" create work >/dev/null
[ "$(cat "$GH_SANDBOX_HOME/work/token")" = browser-token ]
[ "$(cat "$GH_SANDBOX_HOME/work/login")" = testuser ]
[ "$(cat "$GH_SANDBOX_HOME/work/git-email")" = '12345+testuser@users.noreply.github.com' ]
[ "$(find "$GH_SANDBOX_HOME/work/token" -perm 600 -print)" = "$GH_SANDBOX_HOME/work/token" ]

git config --file "$work/globalgitconfig" credential.helper '!f() { printf "username=wrong\npassword=wrong\n"; }; f'
actual=$(printf 'protocol=https\nhost=github.com\n\n' | GIT_CONFIG_GLOBAL="$work/globalgitconfig" GIT_TERMINAL_PROMPT=0 "$repo/ghsb" git work credential fill)
expected=$(printf 'protocol=https\nhost=github.com\nusername=x-access-token\npassword=browser-token')
[ "$actual" = "$expected" ]
if "$repo/ghsb" destroy .. --yes >/dev/null 2>&1; then exit 1; fi
[ -d "$GH_SANDBOX_HOME/work" ]
printf 'pat-token' | "$repo/ghsb" create pat --token-stdin --no-verify --login bot >/dev/null 2>&1
[ "$(cat "$GH_SANDBOX_HOME/pat/token")" = pat-token ]

if command -v sha256sum >/dev/null 2>&1; then
  digest=$(sha256sum "$repo/ghsb")
else
  digest=$(shasum -a 256 "$repo/ghsb")
fi
printf '%s  ghsb\n' "${digest%% *}" > "$work/ghsb.sha256"
GHSB_INSTALL_DIR="$work/install" sh "$repo/install.sh" >/dev/null
[ -x "$work/install/ghsb" ]
"$work/install/ghsb" --help >/dev/null 2>&1

printf 'smoke checks passed\n'
