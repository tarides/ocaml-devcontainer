# Hacking on ocaml-devcontainer

Notes for maintainers and contributors.

## Image architecture

Two-layer Docker image strategy for fast iteration:

```
ocaml-devcontainer-base   (~35-50 min, compilers + system tools, rebuild rare)
    └── ocaml-devcontainer  (~15-20 min, opam packages, rebuild when tools update)
        └── [tutorial-specific]  (seconds, user-created FROM image)
```

- **Base image** (`base/Dockerfile`): Ubuntu 24.04, opam, two OCaml switches (5.4.0 and 5.4.0+tsan), platform tools (dune, ocaml-lsp-server, merlin, utop, odoc), editors (vim, emacs-nox), debugging tools (gdb, lldb, valgrind, rr, perf, strace, ltrace, bpftrace, hyperfine).
- **Dev image** (`dev/Dockerfile`): Additional opam packages — testing (alcotest, ppx_inline_test, ppx_expect, qcheck), profiling (landmarks, memtrace, runtime_events_tools, printbox), libraries (core, base), formatting (ocamlformat).

Both images are published to Docker Hub and GHCR as multi-arch (amd64 + arm64) manifests.

## Building images locally

### ASLR entropy requirement

The ThreadSanitizer (TSan) switch requires reduced ASLR entropy on the **build host**:

```bash
sudo sysctl -w vm.mmap_rnd_bits=28
```

Without this, TSan compilation fails with "unexpected memory mapping" errors.
See [google/sanitizers#1716](https://github.com/google/sanitizers/issues/1716).

### Build commands

```bash
# Build base image (compilers — takes ~35-50 min)
docker build -t ocaml-devcontainer-base base/

# Build dev image (tools — takes ~15-20 min)
docker build -t ocaml-devcontainer dev/
```

To limit memory usage during opam installs, pass `--build-arg OPAMJOBS=2`.

### Using the local build

The `.devcontainer-from-scratch/` configuration builds from source instead of pulling pre-built images:

```bash
devcontainer up --workspace-folder . --config .devcontainer-from-scratch/devcontainer.json
```

## Running tests

Test scripts live in `test/` and run inside the container:

| Script | What it tests |
|--------|---------------|
| `test-ocaml.sh [switch]` | Compiler + tools verification (both switches) |
| `test-lsp.sh [switch]` | Full LSP protocol testing |
| `test-profiling.sh [switch]` | landmarks, memtrace, olly |
| `test-dune-pkg.sh` | Dune package management workflow |
| `test-vscode.sh` | VS Code devcontainer integration |
| `test-neovim.sh` | Neovim exec pathway + LSP |
| `test-emacs.sh` | Emacs TRAMP + eglot integration |
| `test-claude.sh` | Claude Code installation |

## CI/CD

### Build pipeline (`build-push.yml`)

Triggered by pushes to `main` that touch `base/` or `dev/`, version tags, or manual dispatch.

```
changes ──► build-base-{amd64,arm64} ──► merge-base (multi-arch manifest)
              │
              └──► build-dev-{amd64,arm64} ──► merge-dev (multi-arch manifest)
```

Each architecture builds on a native runner (no cross-compilation). Dev image builds depend only on their own architecture's base image, so amd64 and arm64 pipelines run in parallel.

### Test pipeline (`test.yml`)

Triggered on push/PR to `main` and after successful image builds.

Matrix: `[5.4.0, 5.4.0+tsan]` for test-ocaml, test-lsp, test-profiling. Other tests run once against the default switch.

### Required secrets

| Secret | Purpose |
|--------|---------|
| `DOCKERHUB_USERNAME` | Docker Hub username |
| `DOCKERHUB_TOKEN` | Docker Hub access token |
| `GITHUB_TOKEN` | Automatic — used for GHCR push |

## Performance tuning

### Dune cache

Mount a persistent dune cache to speed up rebuilds across container restarts:

```json
{
  "mounts": [
    "source=dune-cache,target=/home/vscode/.cache/dune,type=volume"
  ]
}
```

Enable caching via environment:

```bash
export DUNE_CACHE=enabled
```

## Debugging tools

The base image includes several debugging tools:

### GDB

```bash
dune build
gdb _build/default/src/main.exe
```

### Valgrind

```bash
valgrind --leak-check=full ./_build/default/src/main.exe
```

### rr (Record & Replay)

Requires hardware perf counters — works on bare metal and some VMs, not in most cloud containers.

```bash
rr record ./_build/default/src/main.exe
rr replay
```
