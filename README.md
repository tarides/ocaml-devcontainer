# OCaml DevContainer

[![Build](https://github.com/tarides/ocaml-devcontainer/actions/workflows/build-push.yml/badge.svg)](https://github.com/tarides/ocaml-devcontainer/actions/workflows/build-push.yml)
[![Tests](https://github.com/tarides/ocaml-devcontainer/actions/workflows/test.yml/badge.svg)](https://github.com/tarides/ocaml-devcontainer/actions/workflows/test.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/cuihtlauac/ocaml-devcontainer)](https://hub.docker.com/r/cuihtlauac/ocaml-devcontainer)

[![Create a GitHub Codespace](https://github.com/codespaces/badge.svg)](https://codespaces.new/tarides/ocaml-devcontainer)

A ready-to-use OCaml 5.4 development environment packaged as a [devcontainer](https://containers.dev/). Designed for tutorials and workshops where zero-friction onboarding is critical — participants get a working environment in minutes, regardless of their OS or editor.

## Choose your workflow

### VS Code

This is for you if:
- You use VS Code as your primary editor
- You want graphical IDE features (hover types, diagnostics, go-to-definition)
- You have Docker installed locally

```bash
git clone https://github.com/tarides/ocaml-devcontainer.git
code ocaml-devcontainer
# Click "Reopen in Container" when prompted
```

[Full guide](docs/SETUP-VSCODE.md)

### DevContainer CLI

This is for you if:
- You prefer Vim, Emacs, Neovim, or another terminal editor
- You want to use Claude Code inside the container
- You have Docker and Node.js installed locally

```bash
npm install -g @devcontainers/cli
git clone https://github.com/tarides/ocaml-devcontainer.git
cd ocaml-devcontainer
devcontainer up --workspace-folder .
devcontainer exec --workspace-folder . vim examples/hello/hello.ml
```

[Full guide](docs/SETUP-DEVCONTAINER-EXEC.md)

### GitHub Codespaces

This is for you if:
- You don't want to install anything on your machine
- You want the fastest possible start (~2 minutes)
- You're attending a workshop or tutorial

Click "Create a GitHub Codespace" above, or:

```bash
gh codespace create --repo tarides/ocaml-devcontainer
gh codespace ssh
```

[Full guide](docs/SETUP-CODESPACES.md)

## What's inside

### OCaml switches

Two switches are pre-configured with identical tools:

| Switch | Description |
|--------|-------------|
| `5.4.0` | Standard OCaml 5.4 (default) |
| `5.4.0+tsan` | ThreadSanitizer for race detection |

Switch between them:
```bash
opam switch 5.4.0+tsan
eval $(opam env)
```

### Installed tools

| Category | Tools |
|----------|-------|
| **Compilers** | OCaml 5.4.0, OCaml 5.4.0+tsan |
| **Build & dev** | dune, ocaml-lsp-server, merlin, ocamlformat, utop, odoc |
| **Testing** | alcotest, ppx_inline_test, ppx_expect, qcheck |
| **Profiling** | landmarks, memtrace, runtime_events_tools (olly), printbox |
| **Libraries** | core, base |
| **Debugging** | gdb, lldb, valgrind, rr, perf, strace, ltrace, bpftrace, hyperfine |
| **Editors** | vim, emacs-nox |

### Common commands

```bash
dune build           # Build the project
dune test            # Run tests
dune fmt             # Format code (ocamlformat)
utop                 # Interactive REPL
odoc                 # Generate documentation
```

## For tutorial and workshop authors

This environment is designed to be extended. Create a tutorial-specific image layered on top:

```dockerfile
FROM ghcr.io/tarides/ocaml-devcontainer:latest
RUN opam install -y lwt eio        # Add your packages
COPY exercises/ /home/vscode/exercises/
```

Tips:
- **Test beforehand** — spin up a Codespace and run through your exercises
- **Provide a Codespace link** — attendees click one button to get started
- **Have a local fallback** — some venues have poor wifi; the DevContainer CLI workflow works offline once images are pulled
- **Clean up after** — remind attendees to delete their Codespaces to avoid charges (`gh codespace delete --all`)

## Project structure

```
.devcontainer/             # Pre-built image config (fast startup)
.devcontainer-from-scratch/  # Local build config (for customization)
base/                      # Base image Dockerfile (compilers + system tools)
dev/                       # Dev image Dockerfile (opam packages)
examples/                  # Sample OCaml projects
test/                      # Integration test scripts
docs/                      # Setup guides per workflow
```

## Hacking

See [HACKING.md](HACKING.md) for building images, running tests, and CI details.

## License

MIT
