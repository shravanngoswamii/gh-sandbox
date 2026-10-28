# gh-sandbox

Use a separate GitHub account for `gh` and Git without changing your regular login. Each named sandbox lives in `~/.gh-sandboxes/`.

## Install (Linux or macOS)

Requires Bash, [GitHub CLI](https://cli.github.com/), Git 2.31+, and curl.

```sh
curl -fsSL https://github.com/shravanngoswamii/gh-sandbox/releases/latest/download/install.sh | sh
```

This installs `ghsb` in `~/.local/bin`. If your shell cannot find it, add this line to `~/.bashrc` or `~/.zshrc`, then open a new terminal:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

## Use

```sh
ghsb create work                 # opens GitHub browser login for this sandbox
ghsb status work                 # check which account signed in
ghsb gh work repo list          # run a gh command as that account
ghsb git work -C my-repo push   # push an HTTPS remote as that account
ghsb shell work                 # enter a shell where plain gh and git use it
exit                            # return to your regular shell
ghsb destroy work               # delete the sandbox and its credentials
```

`ghsb create` uses `gh auth login` with credentials kept inside the sandbox, not your regular `gh` login or OS keyring. For headless setup, pipe a token into `ghsb create work --token-stdin`. Run `ghsb help` for all commands. Set `GH_SANDBOX_HOME` to change where sandboxes are stored.

To publish a new release, push a `v*` tag; the workflow checks Linux and macOS and uploads the installer and CLI as release assets.
