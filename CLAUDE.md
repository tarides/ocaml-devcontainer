# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an **OCaml DevContainer Project** - a production-ready development environment for OCaml that runs in Docker containers. Designed for tutorials and training sessions where zero-friction onboarding is critical.

Supports **OCaml 5.4** (with ThreadSanitizer) and **OCaml 4.14** (LTS).

## Image Architecture

Two-layer Docker image strategy for fast iteration, built for each supported OCaml version:

```
ocaml-5.4-base (5.4.0 + 5.4.0+tsan compilers, ~35-50 min build)
    └── ocaml-5.4-dev (tools, ~15-20 min build)
        └── [tutorial-specific] (optional, user-created, seconds to build)

ocaml-4.14-base (4.14.2 compiler, ~20-30 min build)
    └── ocaml-4.14-dev (tools, ~15-20 min build)
        └── [tutorial-specific] (optional, user-created, seconds to build)
```

The Dockerfiles are parameterized with build ARGs (`OCAML_VERSION`, `ENABLE_TSAN`, `OCAML_EXTRA_PROFILE`).

**OCaml 5.4 image** switches:
- `5.4.0` - Standard compiler (default)
- `5.4.0+tsan` - ThreadSanitizer variant for race detection

**OCaml 4.14 image** switches:
- `4.14.2` - Single switch (no TSan support on 4.x)

## Build Commands

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

# Start container with pre-built images
devcontainer up --workspace-folder .
```

**Note:** The `vm.mmap_rnd_bits=28` setting is required for building the TSan switch (5.4 only).
Without it, TSan compilation fails with "unexpected memory mapping" errors.
See [google/sanitizers#1716](https://github.com/google/sanitizers/issues/1716).

## Running Tests

```bash
# Individual test scripts
./test/test-ocaml.sh      # Compiler + tools verification (both switches)
./test/test-lsp.sh        # Full LSP protocol testing
./test/test-profiling.sh  # landmarks, memtrace, olly, bisect_ppx
./test/test-dune-pkg.sh   # Dune package management workflow
./test/test-vscode.sh     # VS Code devcontainer integration
./test/test-neovim.sh     # Neovim exec pathway + LSP
./test/test-emacs.sh      # Emacs TRAMP + eglot integration
./test/test-claude.sh     # Claude Code installation
```

CI runs matrix tests: `[5.4.0, 5.4.0+tsan, 4.14.2] × [amd64, arm64]`

## Key Design Decisions

- **Primary workflow:** `devcontainer exec` from host (works with any editor)
- **Package management:** Support both opam (traditional) and dune pkg (modern)
- **Base image:** Microsoft devcontainers/base (not ocaml/opam) for DevContainer Feature support
- **Registries:** Publish to both Docker Hub and GHCR
- **Claude Code:** Installed via DevContainer Feature

## Project Structure

```
base/                       # Parameterized Dockerfile for base images (compilers)
dev/                        # Parameterized Dockerfile for dev images (tools)
.devcontainer/              # OCaml 5.4 pre-built image config (default)
.devcontainer-4.14/         # OCaml 4.14 pre-built image config
.devcontainer-from-scratch/ # Local build config (customizable)
test/                       # Integration test scripts
examples/                   # Sample OCaml projects (hello, with-tests, dune-pkg-demo)
docs/                       # Setup guides for different workflows
```

## Configuration Placeholders

Before deployment, set up GitHub repository secrets:
- `DOCKERHUB_USERNAME` - Docker Hub username
- `DOCKERHUB_TOKEN` - Docker Hub access token

## Package Installation Pattern

Platform tools (dune, LSP, merlin, utop, odoc) are installed in `base/Dockerfile` at switch creation time. Additional tools are installed in `dev/Dockerfile` using build ARGs for version-specific packages:

```dockerfile
ARG OCAML_EXTRA_PROFILE="runtime_events_tools"  # empty for 4.14
ENV OCAML_PROFILE="landmarks memtrace ${OCAML_EXTRA_PROFILE} printbox"
```

`runtime_events_tools` is OCaml 5.x-only and excluded from 4.14 builds.
