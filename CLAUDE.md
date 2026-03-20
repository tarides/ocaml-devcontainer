# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an **OCaml 5.4 DevContainer Project** - a production-ready development environment for OCaml that runs in Docker containers. Designed for tutorials and training sessions where zero-friction onboarding is critical.

## Image Architecture

Three-layer Docker image strategy for fast iteration:

```
ocaml-devcontainer-base (compiler, ~20-30 min build, rebuild rare)
    └── ocaml-devcontainer (tools, ~15-20 min build, rebuild when tools update)
        ├── [tutorial-specific] (optional, user-created, seconds to build)
        ├── ocaml-devcontainer-rocq (adds Rocq, ~10-15 min build)
        └── ocaml-devcontainer-tsan (adds ocaml+tsan switch, ~20-30 min build)

oxcaml-devcontainer-base (compiler, ~25-35 min build, rebuild rare)
    └── oxcaml-devcontainer (tools, ~10-15 min build, rebuild when tools update)
        └── [tutorial-specific] (optional, user-created, seconds to build)
```

### OCaml images

The base image creates a single `ocaml` switch (OCaml 5.4.0). The dev image installs tools in that switch. The TSan image layers on top and adds an `ocaml+tsan` switch with all the same tools.

| Switch | Image | Description |
|--------|-------|-------------|
| `ocaml` | ocaml-devcontainer | Standard compiler (default) |
| `ocaml` | ocaml-devcontainer-rocq | Standard compiler + Rocq proof assistant |
| `ocaml+tsan` | ocaml-devcontainer-tsan | ThreadSanitizer variant for race detection |

### OxCaml images

The base image creates a single switch. The dev image installs additional tools:
- `oxcaml` - Jane Street's OxCaml compiler (5.2.0+ox) via oxcaml/opam-repository

## Build Commands

```bash
# OCaml images (no ASLR sysctl needed)
docker build -t ocaml-devcontainer-base base/
docker build -t ocaml-devcontainer dev/

# Rocq image (no special requirements)
docker build -t ocaml-devcontainer-rocq rocq/

# TSan image (requires reduced ASLR entropy)
sudo sysctl -w vm.mmap_rnd_bits=28
docker build -t ocaml-devcontainer-tsan tsan/

# OxCaml images
docker build -t oxcaml-devcontainer-base oxcaml-base/
docker build -t oxcaml-devcontainer --build-arg BASE_IMAGE=oxcaml-devcontainer-base oxcaml-dev/

# Start container with pre-built images
devcontainer up --workspace-folder .
```

**Note:** Only the TSan image build requires `vm.mmap_rnd_bits=28`.
See [google/sanitizers#1716](https://github.com/google/sanitizers/issues/1716).

## Running Tests

```bash
# Individual test scripts (default switch: ocaml)
./test/test-ocaml.sh      # Compiler + tools verification
./test/test-lsp.sh        # Full LSP protocol testing
./test/test-profiling.sh  # landmarks, memtrace, olly
./test/test-rocq.sh        # Rocq installation and compilation
./test/test-dune-pkg.sh   # Dune package management workflow
./test/test-vscode.sh     # VS Code devcontainer integration
./test/test-vim.sh        # Vim installation + config
./test/test-neovim.sh     # Neovim exec pathway + LSP
./test/test-emacs.sh      # Emacs TRAMP + eglot integration
./test/test-claude.sh     # Claude Code installation

# TSan switch (requires TSan image + ASLR fix)
./test/test-ocaml.sh ocaml+tsan

# OxCaml-specific
./test/test-oxcaml-switch.sh  # OxCaml compiler, packages, local_ allocations (oxcaml switch)
```

CI runs: single `ocaml` switch for main image, `[ocaml, ocaml+tsan]` matrix for TSan image, `oxcaml` for OxCaml. Rocq image runs `test-rocq.sh` plus reuses `test-ocaml.sh`, `test-lsp.sh`, `test-profiling.sh`.

## Key Design Decisions

- **Primary workflow:** `devcontainer exec` from host (works with any editor)
- **Package management:** Support both opam (traditional) and dune pkg (modern)
- **Base image:** Microsoft devcontainers/base (not ocaml/opam) for DevContainer Feature support
- **Registries:** Publish to both Docker Hub and GHCR
- **Claude Code:** Installed via DevContainer Feature
- **TSan as separate image:** Keeps the default image lighter (~4.5 GB vs ~7.5 GB) and Codespace-friendly

## Project Structure

```
base/                               # Dockerfile for ocaml-devcontainer-base (compiler only)
dev/                                # Dockerfile for ocaml-devcontainer (full dev tools)
rocq/                               # Dockerfile for ocaml-devcontainer-rocq (adds Rocq)
tsan/                               # Dockerfile for ocaml-devcontainer-tsan (adds ocaml+tsan)
oxcaml-base/                        # Dockerfile for oxcaml-devcontainer-base
oxcaml-dev/                         # Dockerfile for oxcaml-devcontainer (full dev tools)
.devcontainer/                      # OCaml: uses pre-built images (fast startup)
.devcontainer-from-scratch/         # OCaml: builds locally (for customization)
.devcontainer-rocq/                 # Rocq: uses pre-built images
.devcontainer-rocq-from-scratch/    # Rocq: builds locally
.devcontainer-tsan/                 # TSan: uses pre-built images
.devcontainer-tsan-from-scratch/    # TSan: builds locally
.devcontainer-oxcaml/               # OxCaml: uses pre-built images (fast startup)
.devcontainer-oxcaml-from-scratch/  # OxCaml: builds locally (for customization)
test/                               # Integration test scripts
examples/                           # Sample OCaml projects (hello, with-tests, dune-pkg-demo)
docs/                               # Setup guides (SETUP-VSCODE, SETUP-DEVCONTAINER-EXEC, SETUP-CODESPACES)
HACKING.md                          # Building images, running tests, CI details
```

## Configuration Placeholders

Before deployment, set up GitHub repository secrets:
- `DOCKERHUB_USERNAME` - Docker Hub username
- `DOCKERHUB_TOKEN` - Docker Hub access token

## Package Installation Pattern

Tools are defined once in `dev/Dockerfile` and must be kept in sync in `tsan/Dockerfile`:

```dockerfile
ENV OCAML_TEST="alcotest ppx_inline_test ppx_expect qcheck dscheck qcheck-stm qcheck-lin"
ENV OCAML_LIBS="base backoff"
ENV OCAML_PROFILE="landmarks memtrace runtime_events_tools printbox"
ENV OCAML_TOOLS="${OCAML_TEST} ${OCAML_LIBS} ${OCAML_PROFILE}"

RUN opam switch ocaml && \
    eval $(opam env) && \
    opam update && \
    opam install -y ${OCAML_TOOLS}
```
