# Hacking on ocaml-devcontainer

Notes for maintainers and contributors.

## Image architecture

Two-layer Docker image strategy for fast iteration:

```
ocaml-devcontainer-base   (~35-50 min, compilers + system tools, rebuild rare)
    └── ocaml-devcontainer  (~15-20 min, opam packages, rebuild when tools update)
        └── [tutorial-specific]  (seconds, user-created FROM image)

oxcaml-devcontainer-base  (~45-60 min, 3 compilers + system tools, rebuild rare)
    └── oxcaml-devcontainer (~15-25 min, opam packages, rebuild when tools update)
        └── [tutorial-specific]  (seconds, user-created FROM image)
```

### OCaml images

- **Base image** (`base/Dockerfile`): [Ubuntu 24.04](https://releases.ubuntu.com/24.04/), [opam](https://opam.ocaml.org/), two OCaml switches (5.4.0 and 5.4.0+[tsan](https://github.com/google/sanitizers/wiki/ThreadSanitizerCppManual)), platform tools ([dune](https://dune.build/), [ocaml-lsp-server](https://github.com/ocaml/ocaml-lsp), [merlin](https://ocaml.github.io/merlin/), [utop](https://github.com/ocaml-community/utop), [odoc](https://ocaml.github.io/odoc/)), editors ([vim](https://www.vim.org/), [emacs-nox](https://www.gnu.org/software/emacs/)), debugging tools ([gdb](https://sourceware.org/gdb/), [lldb](https://lldb.llvm.org/), [valgrind](https://valgrind.org/), [rr](https://rr-project.org/), [perf](https://perf.wiki.kernel.org/), [strace](https://strace.io/), [ltrace](https://man7.org/linux/man-pages/man1/ltrace.1.html), [bpftrace](https://github.com/bpftrace/bpftrace), [hyperfine](https://github.com/sharkdp/hyperfine)).
- **Dev image** (`dev/Dockerfile`): Additional [opam](https://opam.ocaml.org/) packages — testing ([alcotest](https://github.com/mirage/alcotest), [ppx_inline_test](https://github.com/janestreet/ppx_inline_test), [ppx_expect](https://github.com/janestreet/ppx_expect), [qcheck](https://github.com/c-cube/qcheck)), profiling ([landmarks](https://github.com/LexiFi/landmarks), [memtrace](https://github.com/janestreet/memtrace), [runtime_events_tools](https://github.com/tarides/runtime_events_tools), [printbox](https://github.com/c-cube/printbox)), libraries ([core](https://github.com/janestreet/core), [base](https://github.com/janestreet/base)), formatting ([ocamlformat](https://github.com/ocaml-ppx/ocamlformat)).

### OxCaml images

- **Base image** (`oxcaml-base/Dockerfile`): Same system dependencies as the OCaml base image. Three switches: `oxcaml` ([OxCaml](https://github.com/oxcaml) 5.2.0+ox via [oxcaml/opam-repository](https://github.com/oxcaml/opam-repository), default), `ocaml` (5.4.0), `ocaml+tsan` (5.4.0+tsan). Platform tools in all switches.
- **Dev image** (`oxcaml-dev/Dockerfile`): The `ocaml` and `ocaml+tsan` switches get the same tools as the standard dev image. The `oxcaml` switch gets [core](https://github.com/janestreet/core), [base](https://github.com/janestreet/base), `await`, `parallel`, [alcotest](https://github.com/mirage/alcotest), [ppx_inline_test](https://github.com/janestreet/ppx_inline_test), [ppx_expect](https://github.com/janestreet/ppx_expect).

All images are published to [Docker Hub](https://hub.docker.com/r/cuihtlauac/ocaml-devcontainer) and [GHCR](https://github.com/tarides/ocaml-devcontainer/pkgs/container/ocaml-devcontainer) as multi-arch (amd64 + arm64) manifests.

## Building images locally

### ASLR entropy requirement

The [ThreadSanitizer](https://github.com/google/sanitizers/wiki/ThreadSanitizerCppManual) (TSan) switch requires reduced [ASLR](https://en.wikipedia.org/wiki/Address_space_layout_randomization) entropy on the **build host**:

```bash
sudo sysctl -w vm.mmap_rnd_bits=28
```

Without this, TSan compilation fails with "unexpected memory mapping" errors.
See [google/sanitizers#1716](https://github.com/google/sanitizers/issues/1716).

### Build commands

```bash
# Build OCaml base image (compilers — takes ~35-50 min)
docker build -t ocaml-devcontainer-base base/

# Build OCaml dev image (tools — takes ~15-20 min)
docker build -t ocaml-devcontainer dev/

# Build OxCaml base image (3 compilers — takes ~45-60 min)
docker build -t oxcaml-devcontainer-base oxcaml-base/

# Build OxCaml dev image (tools — takes ~15-25 min)
docker build -t oxcaml-devcontainer --build-arg BASE_IMAGE=oxcaml-devcontainer-base oxcaml-dev/
```

To limit memory usage during [opam](https://opam.ocaml.org/) installs, pass `--build-arg OPAMJOBS=2`.

### Using the local build

The `-from-scratch` configurations build from source instead of pulling pre-built images:

```bash
# OCaml
devcontainer up --workspace-folder . --config .devcontainer-from-scratch/devcontainer.json

# OxCaml
devcontainer up --workspace-folder . --config .devcontainer-oxcaml-from-scratch/devcontainer.json
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
| `test-oxcaml-switch.sh` | OxCaml compiler, packages, `local_` allocations |

## CI/CD

### OCaml build pipeline (`build-push.yml`)

Triggered by pushes to `main` that touch `base/` or `dev/`, version tags, or [manual dispatch](https://docs.github.com/en/actions/managing-workflow-runs-and-deployments/managing-workflow-runs/manually-running-a-workflow).

```
changes ──► build-base-{amd64,arm64} ──► merge-base (multi-arch manifest)
              │
              └──► build-dev-{amd64,arm64} ──► merge-dev (multi-arch manifest)
```

Each architecture builds on a native runner (no cross-compilation). Dev image builds depend only on their own architecture's base image, so amd64 and arm64 pipelines run in parallel.

### OxCaml build pipeline (`build-push-oxcaml.yml`)

Same fan-out/fan-in pattern as the OCaml pipeline. Triggered by pushes to `main` that touch `oxcaml-base/` or `oxcaml-dev/`.

### OCaml test pipeline (`test.yml`)

Triggered on push/PR to `main` and after successful image builds.

Matrix: `[5.4.0, 5.4.0+tsan]` for test-ocaml, test-lsp, test-profiling. Other tests run once against the default switch.

### OxCaml test pipeline (`test-oxcaml-image.yml`)

Triggered on push/PR to `main` and after successful OxCaml image builds.

Matrix: `[ocaml, ocaml+tsan]` for test-ocaml and test-profiling. `[oxcaml, ocaml, ocaml+tsan]` for test-lsp. test-oxcaml-switch runs once on the oxcaml switch.

### Required secrets

| Secret | Purpose |
|--------|---------|
| `DOCKERHUB_USERNAME` | [Docker Hub](https://hub.docker.com/) username |
| `DOCKERHUB_TOKEN` | [Docker Hub access token](https://docs.docker.com/security/for-developers/access-tokens/) |
| `GITHUB_TOKEN` | [Automatic](https://docs.github.com/en/actions/security-for-github-actions/security-guides/automatic-token-authentication) — used for GHCR push |

## Performance tuning

### [Dune cache](https://dune.readthedocs.io/en/stable/caching.html)

Mount a persistent [dune](https://dune.build/) cache to speed up rebuilds across container restarts:

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

### [GDB](https://sourceware.org/gdb/)

```bash
dune build
gdb _build/default/src/main.exe
```

### [Valgrind](https://valgrind.org/)

```bash
valgrind --leak-check=full ./_build/default/src/main.exe
```

### [rr](https://rr-project.org/) (Record & Replay)

Requires hardware perf counters — works on bare metal and some VMs, not in most cloud containers.

```bash
rr record ./_build/default/src/main.exe
rr replay
```
