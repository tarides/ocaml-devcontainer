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
- You have [Docker](https://docs.docker.com/get-started/get-docker/) installed locally

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
- You have [Docker](https://docs.docker.com/get-started/get-docker/) and [Node.js](https://nodejs.org/) installed locally

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

### OCaml switches

Two switches are pre-configured with identical tools:

| Switch | Description |
|--------|-------------|
| `5.4.0` | Standard [OCaml 5.4](https://ocaml.org/releases/5.4.0) (default) |
| `5.4.0+tsan` | [ThreadSanitizer](https://github.com/google/sanitizers/wiki/ThreadSanitizerCppManual) for race detection |

Switch between them:
```bash
opam switch 5.4.0+tsan
eval $(opam env)
```

### Installed tools

| Category | Tools |
|----------|-------|
| **Compilers** | [OCaml](https://ocaml.org/) 5.4.0, OCaml 5.4.0+tsan |
| **Build & dev** | [dune](https://dune.build/), [ocaml-lsp-server](https://github.com/ocaml/ocaml-lsp), [merlin](https://ocaml.github.io/merlin/), [ocamlformat](https://github.com/ocaml-ppx/ocamlformat), [utop](https://github.com/ocaml-community/utop), [odoc](https://ocaml.github.io/odoc/) |
| **Testing** | [alcotest](https://github.com/mirage/alcotest), [ppx_inline_test](https://github.com/janestreet/ppx_inline_test), [ppx_expect](https://github.com/janestreet/ppx_expect), [qcheck](https://github.com/c-cube/qcheck) |
| **Profiling** | [landmarks](https://github.com/LexiFi/landmarks), [memtrace](https://github.com/janestreet/memtrace), [runtime_events_tools](https://github.com/tarides/runtime_events_tools) (olly), [printbox](https://github.com/c-cube/printbox) |
| **Libraries** | [core](https://github.com/janestreet/core), [base](https://github.com/janestreet/base) |
| **Debugging** | [gdb](https://sourceware.org/gdb/), [lldb](https://lldb.llvm.org/), [valgrind](https://valgrind.org/), [rr](https://rr-project.org/), [perf](https://perf.wiki.kernel.org/), [strace](https://strace.io/), [ltrace](https://man7.org/linux/man-pages/man1/ltrace.1.html), [bpftrace](https://github.com/bpftrace/bpftrace), [hyperfine](https://github.com/sharkdp/hyperfine) |
| **Editors** | [vim](https://www.vim.org/), [emacs](https://www.gnu.org/software/emacs/) |

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

## Hacking

See [HACKING.md](HACKING.md) for building images, running tests, and CI details.
