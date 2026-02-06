# OCaml 5.4 DevContainer

Production-ready OCaml development environment for VS Code, Codespaces, and any editor.

[![Create a GitHub Codespace](https://github.com/codespaces/badge.svg)](https://codespaces.new/tarides/ocaml-devcontainer)

## Features

- **OCaml 5.4** with standard and ThreadSanitizer variants
- **Full toolchain**: dune, LSP, merlin, ocamlformat, utop
- **Testing**: alcotest, ppx_expect, qcheck
- **Profiling**: landmarks, memtrace, olly
- **Multi-editor**: VS Code, Vim, Emacs, Neovim, Claude Code
- **Zero setup**: Works instantly in GitHub Codespaces

## Quick Start

### GitHub Codespaces (Instant)

Click "Create a GitHub Codespace" above. Ready in ~2 minutes.

### Local (VS Code)

```bash
git clone https://github.com/tarides/ocaml-devcontainer.git
code ocaml-devcontainer
# Click "Reopen in Container" when prompted
```

### Local (Any Editor)

```bash
npm install -g @devcontainers/cli
git clone https://github.com/tarides/ocaml-devcontainer.git
cd ocaml-devcontainer
devcontainer up --workspace-folder .

# Use your preferred editor
devcontainer exec --workspace-folder . vim examples/hello/hello.ml
devcontainer exec --workspace-folder . dune build
```

## Documentation

| Guide | Description |
|-------|-------------|
| [DEVCONTAINER.md](DEVCONTAINER.md) | Quick start overview |
| [docs/SETUP-CODESPACES.md](docs/SETUP-CODESPACES.md) | GitHub Codespaces setup |
| [docs/SETUP-DEVCONTAINER-EXEC.md](docs/SETUP-DEVCONTAINER-EXEC.md) | Primary local workflow |
| [docs/SETUP-VSCODE.md](docs/SETUP-VSCODE.md) | VS Code integration |
| [docs/SETUP-ADVANCED.md](docs/SETUP-ADVANCED.md) | TRAMP, Neovim, customization |

## OCaml Switches

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

## Project Structure

```
.devcontainer/           # Pre-built image config (fast startup)
.devcontainer-from-scratch/  # Local build config
base/                    # Base image (compilers)
dev/                     # Dev image (tools)
examples/                # Sample projects
test/                    # Integration tests
docs/                    # Setup guides
```

## Building from Source

To build the Docker images locally:

```bash
# Required: reduce ASLR entropy for TSan compilation
sudo sysctl -w vm.mmap_rnd_bits=28

# Build images
docker build -t ocaml-5.4-base base/
docker build -t ocaml-5.4-dev dev/
```

The `vm.mmap_rnd_bits=28` setting is required for the ThreadSanitizer switch to compile.
See [google/sanitizers#1716](https://github.com/google/sanitizers/issues/1716) for details.

## For Tutorial Authors

This environment is designed for OCaml tutorials and workshops. Create a tutorial-specific image:

```dockerfile
FROM ghcr.io/tarides/ocaml-5.4-dev:latest
RUN opam install -y lwt eio  # Add your packages
COPY exercises/ /home/vscode/exercises/
```

## License

MIT
