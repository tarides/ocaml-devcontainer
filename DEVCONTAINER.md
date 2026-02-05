# OCaml 5.4 DevContainer

Quick start guide for the OCaml development environment.

## Fastest Start: GitHub Codespaces

Click the button below to open in Codespaces (no local setup required):

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/tarides/ocaml-devcontainer)

## Local Setup

### Option 1: VS Code (Recommended for VS Code users)

1. Install [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
2. Clone and open: `code ocaml-devcontainer`
3. Click "Reopen in Container" when prompted

### Option 2: DevContainer CLI (Works with any editor)

```bash
# Install CLI
npm install -g @devcontainers/cli

# Start container
devcontainer up --workspace-folder .

# Use any editor
devcontainer exec --workspace-folder . vim src/main.ml
devcontainer exec --workspace-folder . emacs src/main.ml
devcontainer exec --workspace-folder . claude
```

## What's Included

| Category | Tools |
|----------|-------|
| **Compilers** | OCaml 5.4.0, OCaml 5.4.0+tsan |
| **Build** | dune, ocaml-lsp-server, merlin, ocamlformat, utop, odoc |
| **Testing** | ounit2, ppx_inline_test, ppx_expect, qcheck, bisect_ppx |
| **Profiling** | landmarks, memtrace, olly |
| **Debugging** | gdb, lldb, valgrind, rr, perf |
| **Editors** | vim, emacs, Claude Code |
| **AI Integration** | ocaml-mcp-server (MCP server) |

## Common Commands

```bash
# Build
dune build

# Test
dune test

# Format
dune fmt

# REPL
utop

# Switch OCaml version
opam switch 5.4.0+tsan
eval $(opam env)
```

## Documentation

- [GitHub Codespaces](docs/SETUP-CODESPACES.md) - Zero-install cloud environment
- [DevContainer Exec](docs/SETUP-DEVCONTAINER-EXEC.md) - Primary local workflow
- [VS Code](docs/SETUP-VSCODE.md) - Native VS Code integration
- [Advanced](docs/SETUP-ADVANCED.md) - TRAMP, Neovim plugins, MCP, customization
