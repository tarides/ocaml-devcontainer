# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an **OCaml 5.4 DevContainer Project** - a production-ready development environment for OCaml that runs in Docker containers. Designed for tutorials and training sessions where zero-friction onboarding is critical.

**Current state:** Planning phase. The detailed implementation plan is in `ocaml-devcontainer-plan.md`.

## Image Architecture

Two-layer Docker image strategy for fast iteration:

```
ocaml-5.4-base (compilers, ~35-50 min build, rebuild rare)
    └── ocaml-5.4-dev (tools, ~15-20 min build, rebuild when tools update)
        └── [tutorial-specific] (optional, user-created, seconds to build)
```

The base image creates both OCaml switches (compilers only). The dev image installs **identical tools** in both switches:
- `5.4.0` - Standard compiler (default)
- `5.4.0+tsan` - ThreadSanitizer variant for race detection

## Build Commands

```bash
# IMPORTANT: TSan requires reduced ASLR entropy on the build host
sudo sysctl -w vm.mmap_rnd_bits=28

# Local build (for customization)
docker build -t ocaml-5.4-base base/
docker build -t ocaml-5.4-dev dev/

# Start container with pre-built images
devcontainer up --workspace-folder .
```

**Note:** The `vm.mmap_rnd_bits=28` setting is required for building the TSan switch.
Without it, TSan compilation fails with "unexpected memory mapping" errors.
See [google/sanitizers#1716](https://github.com/google/sanitizers/issues/1716).

## Running Tests

```bash
# Individual test scripts
./test/test-ocaml.sh      # Compiler + tools verification (both switches)
./test/test-lsp.sh        # Full LSP protocol testing
./test/test-profiling.sh  # landmarks, memtrace, olly, bisect_ppx
./test/test-dune-pkg.sh   # Dune package management workflow
./test/test-mcp.sh        # MCP server verification
./test/test-vscode.sh     # VS Code devcontainer integration
./test/test-neovim.sh     # Neovim exec pathway + LSP
./test/test-emacs.sh      # Emacs TRAMP + eglot integration
./test/test-claude.sh     # Claude Code installation
```

CI runs matrix tests: `[5.4.0, 5.4.0+tsan] × [amd64, arm64]`

## Key Design Decisions

- **Primary workflow:** `devcontainer exec` from host (works with any editor)
- **Package management:** Support both opam (traditional) and dune pkg (modern)
- **MCP integration:** ocaml-mcp-server (local) pre-installed, odoc-llm (remote) documented
- **Base image:** Microsoft devcontainers/base (not ocaml/opam) for DevContainer Feature support
- **Registries:** Publish to both Docker Hub and GHCR
- **Claude Code:** Installed via DevContainer Feature

## Project Structure

```
base/                     # Dockerfile for ocaml-5.4-base (compilers only)
dev/                      # Dockerfile for ocaml-5.4-dev (full dev tools)
.devcontainer/            # Uses pre-built images (fast startup)
.devcontainer-from-scratch/ # Builds locally (for customization)
test/                     # Integration test scripts
examples/                 # Sample OCaml projects (hello, with-tests, dune-pkg-demo)
docs/                     # Setup guides for different workflows
```

## Configuration Placeholders

Before deployment, set up GitHub repository secrets:
- `DOCKERHUB_USERNAME` - Docker Hub username
- `DOCKERHUB_TOKEN` - Docker Hub access token

## Package Installation Pattern

Tools are defined once and installed identically in both switches:

```dockerfile
ENV OCAML_BUILD="dune ocaml-lsp-server merlin ocamlformat utop odoc"
ENV OCAML_TEST="ounit2 ppx_inline_test ppx_expect qcheck bisect_ppx"
ENV OCAML_LIBS="core base"
ENV OCAML_PROFILE="landmarks landmarks-ppx memtrace runtime_events_tools printbox"
ENV OCAML_MCP="ocaml-mcp-server"
ENV OCAML_TOOLS="$OCAML_BUILD $OCAML_TEST $OCAML_LIBS $OCAML_PROFILE $OCAML_MCP"

RUN opam install --switch=5.4.0 -y $OCAML_TOOLS && \
    opam install --switch=5.4.0+tsan -y $OCAML_TOOLS && \
    opam clean -a
```
