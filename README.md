# OCaml DevContainer

Production-ready OCaml development environment for VS Code, Cursor, Antigravity, Codespaces, and any editor.

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/tarides/ocaml-devcontainer)

## Features

- **OCaml 5.4** with standard and ThreadSanitizer variants
- **OCaml 4.14** LTS for projects targeting older OCaml
- **Full toolchain**: dune, LSP, merlin, ocamlformat, utop
- **Testing**: ounit2, ppx_expect, qcheck
- **Profiling**: landmarks, memtrace, olly (5.x)
- **Multi-editor**: VS Code, Vim, Emacs, Neovim, Claude Code
- **Zero setup**: Works instantly in GitHub Codespaces

## Quick Start

### GitHub Codespaces (Instant)

Click "Open in GitHub Codespaces" above. Ready in ~2 minutes.

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

## OCaml Images & Switches

Two image sets are published, each with pre-configured switches:

| Image | Switches | Description |
|-------|----------|-------------|
| `ocaml-5.4-dev` | `5.4.0` (default), `5.4.0+tsan` | OCaml 5.4 with ThreadSanitizer |
| `ocaml-4.14-dev` | `4.14.2` | OCaml 4.14 LTS |

Switch between compilers (within the 5.4 image):
```bash
opam switch 5.4.0+tsan
eval $(opam env)
```

To use the 4.14 image instead, open from `.devcontainer-4.14/` or use:
```bash
devcontainer up --workspace-folder . --config .devcontainer-4.14/devcontainer.json
```

## Project Structure

```
.devcontainer/              # OCaml 5.4 pre-built image config (default)
.devcontainer-4.14/         # OCaml 4.14 pre-built image config
.devcontainer-from-scratch/ # Local build config
base/                       # Base image Dockerfile (parameterized)
dev/                        # Dev image Dockerfile (parameterized)
examples/                   # Sample projects
test/                       # Integration tests
docs/                       # Setup guides
```

## Building from Source

To build the Docker images locally:

```bash
# OCaml 5.4 (default — includes TSan switch)
sudo sysctl -w vm.mmap_rnd_bits=28  # Required for TSan
docker build -t ocaml-5.4-base base/
docker build --build-arg BASE_IMAGE=ocaml-5.4-base -t ocaml-5.4-dev dev/

# OCaml 4.14
docker build --build-arg OCAML_VERSION=4.14.2 --build-arg ENABLE_TSAN=false \
  -t ocaml-4.14-base base/
docker build --build-arg BASE_IMAGE=ocaml-4.14-base \
  --build-arg OCAML_VERSION=4.14.2 --build-arg ENABLE_TSAN=false \
  --build-arg OCAML_EXTRA_PROFILE="" -t ocaml-4.14-dev dev/
```

The `vm.mmap_rnd_bits=28` setting is required for the ThreadSanitizer switch (5.4 only).
See [google/sanitizers#1716](https://github.com/google/sanitizers/issues/1716) for details.

## For Tutorial Authors

This environment is designed for OCaml tutorials and workshops. Create a tutorial-specific image:

```dockerfile
# For OCaml 5.x tutorials
FROM ghcr.io/tarides/ocaml-5.4-dev:latest
RUN opam install -y lwt eio  # Add your packages
COPY exercises/ /home/vscode/exercises/

# For OCaml 4.x tutorials
FROM ghcr.io/tarides/ocaml-4.14-dev:latest
RUN opam install -y lwt  # Add your packages
COPY exercises/ /home/vscode/exercises/
```

## License

MIT
