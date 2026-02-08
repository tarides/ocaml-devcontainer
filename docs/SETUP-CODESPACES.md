# GitHub Codespaces Setup

Zero-installation OCaml development environment. Perfect for tutorials and workshops.

## Quick Start (Web)

1. Click the green "Code" button on the repository page
2. Select "Codespaces" tab
3. Click "Create codespace on main"
4. Wait ~2-3 minutes for the environment to start
5. You're ready to code!

## Quick Start (CLI)

Using the [GitHub CLI](https://cli.github.com/):

```bash
# Create a codespace
gh codespace create --repo tarides/ocaml-devcontainer

# Connect via SSH
gh codespace ssh

# Or open in VS Code
gh codespace code

# Or run a single command
gh codespace ssh -- dune build
```

### Managing Codespaces

```bash
# List your codespaces
gh codespace list

# Stop a running codespace (avoids charges)
gh codespace stop

# Delete a codespace
gh codespace delete
```

## What's Included

- OCaml 5.4.0 compiler (default)
- OCaml 5.4.0+tsan (ThreadSanitizer variant)
- Full development toolchain:
  - dune (build system)
  - ocaml-lsp-server (editor support)
  - ocamlformat (code formatting)
  - utop (interactive REPL)
- Testing tools: alcotest, ppx_expect, qcheck
- Profiling tools: landmarks, memtrace, olly

## Switching OCaml Versions

```bash
# Use standard OCaml 5.4
opam switch 5.4.0
eval $(opam env)

# Use ThreadSanitizer variant (for race detection)
opam switch 5.4.0+tsan
eval $(opam env)
```

## Building Your Project

```bash
# Build
dune build

# Run tests
dune test

# Start REPL
utop
```

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

### Need more resources

The default Codespace has 4 cores and 8GB RAM. For larger projects, you can request more resources in Codespace settings.

## Tips for Tutorial Instructors

1. Test the Codespace before your session
2. Provide the direct Codespace creation link to attendees
3. Have a backup plan (local devcontainer) for connectivity issues
4. Clean up Codespaces after the tutorial to avoid charges:
   ```bash
   gh codespace list
   gh codespace delete --all
   ```
