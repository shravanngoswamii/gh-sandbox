# gh-sandbox

`ghsb` runs GitHub CLI and Git with a named account, without changing your usual `gh` login or Git config. Each sandbox keeps a personal access token and commit identity in `~/.gh-sandboxes/<name>/`. `destroy` removes that folder.

## Install

Requires Bash, [GitHub CLI](https://cli.github.com/), and Git 2.31 or newer. On macOS, use an up-to-date Git if the system version is older. Works in Bash or zsh on Linux and macOS.

```sh
mkdir -p "$HOME/.local/bin"
install -m 755 ghsb "$HOME/.local/bin/ghsb"
```

Add `$HOME/.local/bin` to your `PATH` if needed.

## Use

```sh
ghsb create work                 # paste a GitHub personal access token at the hidden prompt
ghsb gh work repo list          # run gh as that account
ghsb git work -C my-repo push   # use that token for an HTTPS Git remote
ghsb shell work                 # enter a shell where gh and git use the sandbox
exit                            # leave the shell
ghsb list                       # show sandboxes
ghsb destroy work               # remove one (asks for confirmation)
```

The token needs permission for the operations you run. For offline setup, use `ghsb create work --no-verify --login USER`. `ghsb help` lists all commands. Set `GH_SANDBOX_HOME` to use a different storage directory. Tokens are stored as files readable only by your user; avoid `ghsb env` unless you need its token-bearing output.
