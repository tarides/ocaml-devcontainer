# GitHub Codespaces Setup

Zero-installation OCaml development environment. Perfect for tutorials and workshops.

GitHub Codespaces runs the devcontainer on GitHub's cloud infrastructure — nothing is installed on your machine. Each user can run [several codespaces simultaneously](https://docs.github.com/en/codespaces/overview#billing-for-codespaces); the exact limits depend on your GitHub subscription plan. Your files are persisted across stops and restarts, but a codespace that stays inactive is [automatically deleted after 30 days](https://docs.github.com/en/codespaces/setting-your-user-preferences/configuring-automatic-deletion-of-your-codespaces) — push your work to a branch to keep it safe.

## Quick start (web)

1. Click the green "Code" button on the repository page
2. Select "Codespaces" tab
3. Click "Create codespace on main"
4. Wait ~2-3 minutes for the environment to start
5. You're ready to code!

## Quick start (CLI)

Using the [GitHub CLI](https://cli.github.com/):

```bash
# One-time: ensure the codespace scope is authorized
gh auth refresh -h github.com -s codespace

# Create a codespace
gh codespace create --repo tarides/ocaml-devcontainer

# Connect via SSH
gh codespace ssh

# Or open in VS Code
gh codespace code

# Or run a single command
gh codespace ssh -- dune build
```

> **HTTP 403 error?** First check that `gh` is authenticated with GitHub
> (see [Authenticating with GitHub CLI](https://docs.github.com/en/codespaces/developing-in-a-codespace/using-github-codespaces-with-github-cli#prerequisites)).
> If authentication is fine, the issue is likely a missing scope — run
> `gh auth refresh -h github.com -s codespace` to grant it, then retry.

### Managing codespaces

```bash
# List your codespaces
gh codespace list

# Stop a running codespace (avoids charges)
gh codespace stop

# Delete a codespace
gh codespace delete
```

## Switching OCaml versions

```bash
# Use standard OCaml 5.4
opam switch 5.4.0
eval $(opam env)

# Use ThreadSanitizer variant (for race detection)
opam switch 5.4.0+tsan
eval $(opam env)
```

See the [README](../README.md#ocaml-switches) for the list of available switches.

## Troubleshooting

### Codespace is slow to start

Pre-built images are used for fast startup. If it's taking longer than 5 minutes:
- Check GitHub Status page
- Try creating a new codespace

### Out of storage

Codespaces have limited storage. To free space:
```bash
dune clean
opam clean -a
```

### Disconnected after inactivity

Codespaces stop automatically after a period of inactivity (default: 30 minutes). Reconnect with `gh codespace ssh`; your work is preserved until the codespace is deleted.

### Need more resources

The default Codespace has 4 cores and 8GB RAM. For larger projects, you can request more resources in Codespace settings.

---

See the [README](../README.md) for installed tools, common commands, and switch details.
