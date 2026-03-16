# OCaml DevContainer

[![Build](https://github.com/tarides/ocaml-devcontainer/actions/workflows/build-push.yml/badge.svg)](https://github.com/tarides/ocaml-devcontainer/actions/workflows/build-push.yml)
[![Tests](https://github.com/tarides/ocaml-devcontainer/actions/workflows/test.yml/badge.svg)](https://github.com/tarides/ocaml-devcontainer/actions/workflows/test.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/cuihtlauac/ocaml-devcontainer)](https://hub.docker.com/r/cuihtlauac/ocaml-devcontainer)

[![Create a GitHub Codespace](https://github.com/codespaces/badge.svg)](https://codespaces.new/tarides/ocaml-devcontainer)

A ready-to-use [OCaml](https://ocaml.org/) 5.4 development environment packaged as a [devcontainer](https://containers.dev/). Designed for tutorials and workshops where zero-friction onboarding is critical — participants get a working environment in minutes, regardless of their OS or editor.

## Choose your workflow

### [VS Code](https://code.visualstudio.com/)

This is for you if:
- You use VS Code as your primary editor
- You want graphical IDE features (hover types, diagnostics, go-to-definition)
- You have [Docker](https://docs.docker.com/get-started/get-docker/) (or [Podman](https://blog.okikio.dev/from-docker-to-podman-vs-code-devcontainers)) installed locally

```bash
git clone https://github.com/tarides/ocaml-devcontainer.git
code ocaml-devcontainer
# Click "Reopen in Container" when prompted
```

[Full guide](docs/SETUP-VSCODE.md)

### [DevContainer CLI](https://github.com/devcontainers/cli)

This is for you if:
- You prefer [Vim](https://www.vim.org/), [Emacs](https://www.gnu.org/software/emacs/), [Neovim](https://neovim.io/), or another terminal editor
- You want to use [Claude Code](https://docs.anthropic.com/en/docs/claude-code) inside the container
- You have [Docker](https://docs.docker.com/get-started/get-docker/) (or [Podman](https://blog.okikio.dev/from-docker-to-podman-vs-code-devcontainers)) and [Node.js](https://nodejs.org/) installed locally

```bash
npm install -g @devcontainers/cli
git clone https://github.com/tarides/ocaml-devcontainer.git
cd ocaml-devcontainer
devcontainer up --workspace-folder .
devcontainer exec --workspace-folder . vim examples/hello/hello.ml
```

[Full guide](docs/SETUP-DEVCONTAINER-EXEC.md)

### [GitHub Codespaces](https://github.com/features/codespaces)

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

### Image variants

| Image | Switches | Size | Codespaces |
|-------|----------|------|------------|
| `ocaml-devcontainer` | `ocaml` | ~4.5 GB | Yes |
| `ocaml-devcontainer-tsan` | `ocaml`, `ocaml+tsan` | ~7.5 GB | No |
| `oxcaml-devcontainer` | `oxcaml` | ~18.8 GB | Yes |

The default image (`ocaml-devcontainer`) ships a single `ocaml` switch. The TSan variant adds an `ocaml+tsan` switch for [ThreadSanitizer](https://github.com/google/sanitizers/wiki/ThreadSanitizerCppManual) race detection.

### Using the TSan variant

The TSan image requires `vm.mmap_rnd_bits <= 28` at runtime. Use it for local development or CI, not Codespaces:

```bash
# Pre-built image
devcontainer up --workspace-folder . --config .devcontainer-tsan/devcontainer.json

# Switch to TSan
opam switch ocaml+tsan
eval $(opam env)
```

### Installed tools

| Category | Tools |
|----------|-------|
| **Compilers** | [OCaml](https://ocaml.org/) 5.4.0 |
| **Build & dev** | [dune](https://dune.build/), [ocaml-lsp-server](https://github.com/ocaml/ocaml-lsp), [merlin](https://ocaml.github.io/merlin/), [utop](https://github.com/ocaml-community/utop) |
| **Testing** | [alcotest](https://github.com/mirage/alcotest), [ppx_inline_test](https://github.com/janestreet/ppx_inline_test), [ppx_expect](https://github.com/janestreet/ppx_expect), [qcheck](https://github.com/c-cube/qcheck) |
| **Profiling** | [landmarks](https://github.com/LexiFi/landmarks), [memtrace](https://github.com/janestreet/memtrace), [runtime_events_tools](https://github.com/tarides/runtime_events_tools) (olly), [printbox](https://github.com/c-cube/printbox) |
| **Libraries** | [base](https://github.com/janestreet/base) |
| **Debugging** | [gdb](https://sourceware.org/gdb/), [lldb](https://lldb.llvm.org/), [valgrind](https://valgrind.org/), [rr](https://rr-project.org/), [perf](https://perf.wiki.kernel.org/), [strace](https://strace.io/), [ltrace](https://man7.org/linux/man-pages/man1/ltrace.1.html), [bpftrace](https://github.com/bpftrace/bpftrace), [hyperfine](https://github.com/sharkdp/hyperfine) |
| **Editors** | [vim](https://www.vim.org/), [emacs](https://www.gnu.org/software/emacs/) |

### Common commands

```bash
dune build           # Build the project
dune test            # Run tests
utop                 # Interactive REPL
```

## Using this devcontainer in your project

Want contributors to your OCaml project to get a working environment with one click? Add a `.devcontainer/devcontainer.json` that references the pre-built image.

[Full guide](docs/SETUP-YOUR-PROJECT.md)

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

## OxCaml variant

An OxCaml variant is available with [Jane Street](https://www.janestreet.com/)'s [OxCaml](https://oxcaml.org/) compiler. It has a single `oxcaml` switch with [OxCaml](https://github.com/oxcaml) 5.2.0+ox — supports `local_` allocations and other OxCaml features.

The switch includes `await` and `parallel` packages from the [oxcaml opam repository](https://github.com/oxcaml/opam-repository).

To use the OxCaml images:

```bash
# Pre-built image
devcontainer up --workspace-folder . --config .devcontainer-oxcaml/devcontainer.json

# Local build
docker build -t oxcaml-devcontainer-base oxcaml-base/
docker build -t oxcaml-devcontainer --build-arg BASE_IMAGE=oxcaml-devcontainer-base oxcaml-dev/
devcontainer up --workspace-folder . --config .devcontainer-oxcaml-from-scratch/devcontainer.json
```

## Hacking

See [HACKING.md](HACKING.md) for building images, running tests, and CI details.
