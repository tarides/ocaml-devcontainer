# OCaml 5.4 DevContainer Project Plan

## Motivation & Goals

### Why This Project

Setting up an OCaml development environment is notoriously time-consuming:
- Compiling OCaml from source takes 30+ minutes
- Installing opam packages can fail due to system dependencies
- Configuring editors with LSP, merlin, and formatters requires expertise
- ThreadSanitizer (tsan) builds add further complexity

For **tutorials and training sessions**, this setup friction is a barrier:
- Attendees waste time on environment issues instead of learning
- Inconsistent environments lead to "works on my machine" problems
- Instructors spend time debugging setups instead of teaching

### Goals

1. **Zero-friction onboarding**
   - Codespaces: Click a link → working environment in <3 minutes
   - Local: `devcontainer up` → ready to code
   - No OCaml/opam installation required on host

2. **Multi-editor support**
   - Primary workflow: `devcontainer exec` (works with any editor)
   - VS Code, Vim, Emacs, Claude Code all supported
   - Same container, same tools, user's choice of editor

3. **Production-ready tooling**
   - Full debugging suite: gdb, valgrind, perf, rr
   - OCaml profiling: landmarks, memtrace, olly
   - Testing: ounit2, qcheck, ppx_expect, bisect_ppx
   - Both standard (5.4.0) and tsan (5.4.0+tsan) switches

4. **Fast iteration for tutorial authors**
   - Layered images: base (compilers) + dev (tools)
   - Adding tutorial-specific packages: seconds, not minutes
   - Test materials without rebuilding compilers

5. **Reliability through testing**
   - CI tests all opam packages work (don't trust, verify)
   - Multi-arch (amd64 + arm64) with native runners
   - Editor integration tests for each workflow

### Non-Goals

- Supporting OCaml versions older than 5.4
- Windows native containers (WSL2 works fine)
- Minimal/stripped-down images (we optimize for completeness)

## Decisions Made

| Decision | Choice |
|----------|--------|
| Registry | Both Docker Hub + GHCR |
| Base image | Microsoft devcontainers/base (see comparison below) |
| Editor support | Primary: `devcontainer exec` from host. Vim/Emacs also in base image. |
| Dev tools | Full suite, identical in BOTH switches |
| Package management | Both: traditional opam AND dune pkg workflows |
| Debug/Profile | Full suite: gdb, rr, valgrind, perf, memtrace, landmarks |
| Testing scope | Full integration (LSP protocol, editor workflows) |
| Image strategy | Separate images (base + dev) for fast tutorial iteration |
| GitHub Codespaces | Explicit support (config, docs, CI testing) |
| Shell config | Both: postStartCommand + .bashrc (covers all scenarios) |
| Claude Code | Include via DevContainer Feature (only editor inside container) |
| Architectures | Multi-arch (amd64 + arm64), QEMU fallback if no native ARM runners |
| Hosting | New GitHub repository (organization) |
| MCP support | Both: ocaml-mcp (local) in dev image + odoc-llm (remote) documented |

## Overview

Create a DevContainer setup for OCaml 5.4 and 5.4+tsan that works with VS Code, Emacs, Neovim, and Claude Code. Includes automated CI/CD for Docker builds and multi-editor testing.

## Project Structure

```
ocaml-devcontainer/
├── base/
│   └── Dockerfile                 # ocaml-5.4-base image
├── dev/
│   └── Dockerfile                 # ocaml-5.4-dev image (FROM base)
├── .devcontainer/
│   └── devcontainer.json          # Uses pre-built ocaml-5.4-dev
├── .devcontainer-from-scratch/
│   └── devcontainer.json          # Builds dev locally (for customization)
├── .github/
│   └── workflows/
│       ├── build-push.yml         # Build & push to registries
│       └── test.yml               # Full integration tests
├── test/
│   ├── test-ocaml.sh              # Verify OCaml compilers + tools (both switches)
│   ├── test-lsp.sh                # Full LSP protocol tests (both switches)
│   ├── test-profiling.sh          # landmarks, memtrace, olly, bisect_ppx
│   ├── test-dune-pkg.sh           # Dune package management workflow
│   ├── test-mcp.sh                # MCP server tests (ocaml-mcp local)
│   ├── test-vscode.sh             # VS Code devcontainer integration
│   ├── test-neovim.sh             # Neovim connection pathways
│   ├── test-emacs.sh              # Emacs TRAMP + eglot integration
│   ├── test-claude.sh             # Claude Code installation + execution
│   └── lsp-client.py              # Helper: minimal LSP client for testing
├── examples/
│   ├── hello/                     # Simple dune project (opam workflow)
│   │   ├── dune-project
│   │   ├── dune
│   │   └── hello.ml
│   ├── with-tests/                # Project with inline/expect tests (opam)
│   │   ├── dune-project
│   │   ├── dune
│   │   ├── lib.ml
│   │   └── lib_test.ml
│   └── dune-pkg-demo/             # Dune package management demo
│       ├── dune-project           # With (depends ...)
│       ├── dune-workspace         # With (pkg enabled)
│       ├── dune
│       └── main.ml
├── docs/
│   ├── SETUP-CODESPACES.md        # GitHub Codespaces (zero-install, tutorial attendees)
│   ├── SETUP-DEVCONTAINER-EXEC.md # Primary workflow: devcontainer exec
│   ├── SETUP-VSCODE.md            # VS Code "Reopen in Container"
│   └── SETUP-ADVANCED.md          # TRAMP, nvim plugins, custom setups
├── DEVCONTAINER.md                # Quick start + overview
└── README.md                      # Project overview
```

## Key Components

### 1. Dockerfile

**Base image:** `mcr.microsoft.com/devcontainers/base:ubuntu-24.04`

**OCaml switches to create:**
| Switch | Description |
|--------|-------------|
| `5.4.0` | Standard OCaml 5.4 compiler (default) |
| `5.4.0+tsan` | OCaml 5.4 with ThreadSanitizer for race detection |

**Editors in base image (via apt):**
- vim
- emacs

**Editor config files (quality-of-life):**
To ensure "inside the container" editing matches "devcontainer exec" experience:
- `.emacs` - minimal config enabling eglot + ocaml-lsp-server
- `init.lua` (Neovim) - minimal config calling `vim.lsp.start` for OCaml

This prevents users who SSH in from getting a "naked" editor without LSP.

**OCaml development tools (installed identically in BOTH switches):**

*Build & Editor Support:*
- dune (build system)
- ocaml-lsp-server (LSP for all editors)
- merlin (code intelligence backend)
- ocamlformat (code formatter)
- utop (interactive REPL)
- odoc (documentation generator)

*Testing:*
- ounit2 (unit testing)
- ppx_inline_test (inline tests)
- ppx_expect (expect tests)
- qcheck (property-based testing)
- bisect_ppx (code coverage)

*Libraries:*
- core (Jane Street standard library)
- base (minimal Jane Street stdlib)

*Profiling & Debugging:*
- landmarks, landmarks-ppx (instrumentation profiling)
- memtrace (memory profiling via statmemprof)
- olly (runtime events / GC latency)
- printbox (pretty-print data structures)

*MCP (Model Context Protocol):*
- ocaml-mcp (local MCP server for AI agent integration)

**Dockerfile pattern for identical switches:**
```dockerfile
# Define tools once, install in both switches
ENV OCAML_BUILD="dune ocaml-lsp-server merlin ocamlformat utop odoc"
ENV OCAML_TEST="ounit2 ppx_inline_test ppx_expect qcheck bisect_ppx"
ENV OCAML_LIBS="core base"
ENV OCAML_PROFILE="landmarks landmarks-ppx memtrace olly printbox"
ENV OCAML_MCP="ocaml-mcp"
ENV OCAML_TOOLS="$OCAML_BUILD $OCAML_TEST $OCAML_LIBS $OCAML_PROFILE $OCAML_MCP"

RUN opam install --switch=5.4.0 -y $OCAML_TOOLS && \
    opam install --switch=5.4.0+tsan -y $OCAML_TOOLS && \
    opam clean -a
```

**System dependencies:**
- m4, build-essential, autoconf, pkg-config
- libunwind-dev (stack traces)
- git, curl, ssh
- sudo (vscode user needs it)

**Debugging & profiling tools (apt) - in base image:**
- gdb, lldb (native debuggers)
- valgrind (memcheck, massif, helgrind, drd)
- strace, ltrace (syscall/library tracing)
- linux-tools-generic, perf (CPU profiling)
- rr (record & replay, reverse debugging) *
- bpftrace (eBPF tracing)
- hyperfine (CLI benchmarking)
- inferno (flamegraph generator, via cargo)

*Note: rr requires hardware perf counters. Works on bare metal and
some VMs (not most cloud VMs). Document fallback to valgrind if unavailable.

### 2. devcontainer.json (Primary)

```json
{
  "name": "OCaml 5.4 Development",
  "image": "ghcr.io/<GITHUB_ORG>/ocaml-5.4-dev:latest",
  "features": {
    "ghcr.io/anthropics/devcontainer-features/claude-code:1.0": {}
  },
  "customizations": {
    "vscode": {
      "extensions": [
        "ocamllabs.ocaml-platform"
      ]
    }
  },
  "postStartCommand": "eval $(opam env)",
  "remoteUser": "vscode",

  // Persist dune pkg cache across container rebuilds
  "mounts": [
    "source=dune-cache,target=/home/vscode/.cache/dune,type=volume"
  ],
  "remoteEnv": {
    "DUNE_CACHE_ROOT": "/home/vscode/.cache/dune"
  },

  // GitHub Codespaces configuration
  "hostRequirements": {
    "cpus": 4,
    "memory": "8gb",
    "storage": "32gb"
  },
  "codespaces": {
    "openFiles": ["README.md"]
  }
}
```

### GitHub Codespaces Support

**Why explicit support matters for tutorials:**
- Attendees need zero local setup (no Docker installation)
- Click "Open in Codespaces" → working environment in ~2 minutes
- Consistent environment across all participants

**Configuration includes:**
- `hostRequirements`: Ensure adequate resources for OCaml compilation
- `codespaces.openFiles`: Welcome file opens automatically
- Pre-built image: Fast startup (no build wait)

**Repository setup:**
- Add "Open in Codespaces" badge to README
- Prebuild configuration (optional): `.github/codespaces/prebuild.yml`

**Documentation:**
- `docs/SETUP-CODESPACES.md`: Step-by-step for attendees
- Troubleshooting common issues (storage, timeouts)

### 3. CI/CD Workflows

#### build-push.yml
- **Trigger:** Push to main, tags, manual dispatch

**Job: build-base**
- **Condition:** Only if `base/` changed OR manual dispatch OR tag
- **Steps:**
  1. Set up QEMU (for ARM emulation if no native runners)
  2. Set up Docker Buildx
  3. Login to Docker Hub + GHCR
  4. Build multi-arch `ocaml-5.4-base` (amd64, arm64)
  5. Push to both registries
- **Caching:** Use GitHub Actions cache (`type=gha`)
- **Note:** Test ARM runner availability early; fall back to QEMU if needed

**Job: build-dev**
- **Needs:** build-base (waits if base is building)
- **Condition:** Always runs on push to main
- **Steps:**
  1. Pull latest `ocaml-5.4-base`
  2. Build multi-arch `ocaml-5.4-dev`
  3. Push to both registries

#### test.yml
- **Trigger:** PR, push to main, after build-push completes
- **Jobs:**

  **1. test-ocaml** (matrix: switch × arch)
  ```yaml
  matrix:
    switch: [5.4.0, 5.4.0+tsan]
    arch: [amd64, arm64]
  runs-on:
    amd64: ubuntu-latest
    arm64: ubuntu-24.04-arm  # If available (paid/Enterprise)
  # Fallback: QEMU emulation via docker/setup-qemu-action
  ```

  **ARM Runner Note:** Native ARM runners (`ubuntu-24.04-arm`) require GitHub
  paid/Enterprise tier. Free tier must use QEMU emulation via `docker/setup-qemu-action`,
  which is ~10x slower but functional. Test early to determine which path to use.
  - Compiler version check
  - Compile and run sample program
  - Dune build + test
  - Verify all tools installed

  **2. test-lsp** (matrix: switch)
  ```yaml
  matrix:
    switch: [5.4.0, 5.4.0+tsan]
  ```
  - Full LSP protocol test (initialize, hover, completion, formatting)

  **3. test-profiling** (matrix: switch)
  ```yaml
  matrix:
    switch: [5.4.0, 5.4.0+tsan]
  ```
  - landmarks, memtrace, olly, bisect_ppx (opam packages)

  **4. test-dune-pkg**
  - dune pkg lock, dune build with (pkg enabled)
  - dune tools exec ocamllsp/ocamlformat
  - Verify both package management workflows work

  **5. test-mcp** (matrix: switch)
  ```yaml
  matrix:
    switch: [5.4.0, 5.4.0+tsan]
  ```
  - ocaml-mcp server startup and tool invocation

  **6. test-editors** (matrix: editor)
  ```yaml
  matrix:
    editor: [vscode, neovim, emacs, claude]
  ```
  - Editor-specific integration tests

### 4. Test Scripts (Full Integration Testing)

**Testing philosophy:**
- **Trust apt (distro packages):** gdb, valgrind, perf, vim, emacs - just install, don't test
- **Test opam packages:** dune, LSP, merlin, landmarks, memtrace - verify they work

**Scope:** Full integration testing for opam-installed tools and editor workflows.

#### test-ocaml.sh (both switches)
1. Verify switch exists: `opam switch list`
2. Check compiler version: `ocaml -version`
3. Compile sample program: `ocamlopt -o hello hello.ml && ./hello`
4. Build with dune: `dune build`
5. Run tests with dune: `dune test`
6. Verify all tools present: ocamlformat, utop, merlin

#### test-lsp.sh (both switches)
1. Start ocaml-lsp-server
2. Send LSP `initialize` request
3. Send `textDocument/didOpen` with sample file
4. Request `textDocument/hover` - verify response
5. Request `textDocument/completion` - verify suggestions
6. Request `textDocument/formatting` - verify ocamlformat integration
7. Shutdown cleanly

#### test-vscode.sh
1. Use `devcontainer` CLI to start container
2. Verify VS Code extensions would load (check extension manifest)
3. Simulate LSP connection via stdio

#### test-emacs.sh
1. Start container with known name
2. Use `docker exec` to verify TRAMP path would resolve
3. Test LSP via JSON-RPC over `docker exec`
4. Verify eglot-compatible responses

#### test-neovim.sh
1. Test `devcontainer exec` pathway works
2. Verify LSP responds correctly via stdio
3. Test path mapping (host path ↔ container path)

#### test-claude.sh
1. Verify Claude Code is installed: `claude --version`
2. Test basic command execution
3. Verify file access within workspace

#### test-profiling.sh (opam tools only, both switches)
1. landmarks: Instrument sample code, verify report generated
2. memtrace: Generate trace file, verify CTF output
3. olly: Capture runtime events from sample program
4. bisect_ppx: Run coverage on sample, verify report

#### test-dune-pkg.sh (dune package management)
1. Create test project with `(pkg enabled)` in dune-workspace
2. Add dependencies in dune-project
3. Run `dune pkg lock` - verify lock directory created
4. Run `dune build` - verify deps downloaded and built
5. Run `dune tools exec ocamllsp -- --version` - verify works
6. Run `dune tools exec ocamlformat -- --version` - verify works
7. Test `eval $(dune tools env)` sets PATH correctly

#### test-mcp.sh (ocaml-mcp local server)
1. Verify ocaml-mcp is installed: `ocaml-mcp --version`
2. Start MCP server: `ocaml-mcp serve`
3. Send MCP `initialize` request via JSON-RPC
4. List available tools: verify dune, merlin tools present
5. Test `dune/build` tool invocation
6. Test `merlin/type-at-position` tool invocation
7. Shutdown cleanly

### 5. Documentation

**DEVCONTAINER.md** will cover:
- Quick start (5 min) with pre-built image
- Local build option (30+ min)
- Editor-specific setup:
  - VS Code: Just open in container
  - Neovim: `devcontainer exec --workspace-folder . nvim`
  - Emacs: TRAMP method `/docker:<container>:/path`
  - Claude Code: Pre-installed via feature
- MCP integration (AI assistants):
  - ocaml-mcp: pre-installed, local project tooling
  - odoc-llm: optional, ecosystem-wide package search
- Switching between OCaml versions
- Troubleshooting common issues

## Implementation Steps

### Phase 1: Base Image
1. Initialize repository structure
2. Write `base/Dockerfile`:
   - Base: `mcr.microsoft.com/devcontainers/base:ubuntu-24.04`
   - Install opam and system dependencies (include `sudo`!)
   - Install vim, emacs (apt)
   - Create both switches (5.4.0, 5.4.0+tsan)
   - Use ENV pattern to avoid code duplication between switches
   - Configure shell: `eval $(opam env)` in .bashrc
   - Add minimal editor configs (.emacs, init.lua) for LSP
   - NO OCaml tools yet (just compilers + editors)
3. Write `build-push.yml` immediately to test ARM runner access
   - If native ARM runners unavailable, configure QEMU fallback

### Phase 2: Dev Image
3. Write `dev/Dockerfile`:
   - FROM ocaml-5.4-base
   - Install identical OCaml toolset in both switches
   - Clean opam cache
4. Create `.devcontainer/devcontainer.json`:
   - Uses pre-built ocaml-5.4-dev image
   - Adds Claude Code via DevContainer Feature
   - Configures Codespaces requirements
5. Create `.devcontainer-from-scratch/devcontainer.json` for local builds

### Phase 3: CI/CD Pipeline
6. Create build-push.yml workflow:
   - Job 1: Build base (only if base/ changed or manual)
   - Job 2: Build dev (depends on base, always runs)
   - Multi-arch builds (amd64 + arm64)
   - Push to Docker Hub + GHCR
7. Set up repository secrets documentation

### Phase 3: Test Infrastructure
7. Create example OCaml projects:
   - `examples/hello/` - minimal dune project
   - `examples/with-tests/` - project with ppx_inline_test, ppx_expect
8. Write `test/lsp-client.py` - minimal LSP test client
9. Write test scripts:
   - `test-ocaml.sh` - compiler + tools verification (both switches)
   - `test-lsp.sh` - full LSP protocol testing
   - `test-mcp.sh` - MCP server verification (ocaml-mcp)
   - `test-vscode.sh` - devcontainer CLI integration
   - `test-neovim.sh` - exec pathway + LSP connection
   - `test-emacs.sh` - TRAMP simulation + LSP
   - `test-claude.sh` - Claude Code verification
10. Create test.yml workflow with matrix strategy

### Phase 4: Documentation
11. Write setup guides (emphasize `devcontainer exec` as primary):
    - `docs/SETUP-CODESPACES.md` - zero-install for tutorial attendees
    - `docs/SETUP-DEVCONTAINER-EXEC.md` - primary workflow (all editors)
    - `docs/SETUP-VSCODE.md` - VS Code "Reopen in Container"
    - `docs/SETUP-ADVANCED.md` - TRAMP, nvim plugins, etc.
12. Write `DEVCONTAINER.md` - quick start overview
13. Write `README.md`:
    - Project overview
    - "Open in Codespaces" badge
    - Primary: `devcontainer exec` examples
    - Links to detailed guides

## Verification

After implementation, verify:

### Local testing
1. `docker build -t ocaml-5.4-base base/` succeeds
2. `docker build -t ocaml-5.4-dev dev/` succeeds (uses local base)
3. `devcontainer up --workspace-folder .` starts container
4. Both switches work: `opam switch 5.4.0 && ocaml -version`
5. All tools present in both switches (identical)
6. LSP responds: run `test/test-lsp.sh`

### CI verification
7. GitHub Actions builds both images (base, dev)
8. Multi-arch manifests correct (amd64 + arm64)
9. Images pushed to both Docker Hub and GHCR
10. All matrix tests pass (switches × editors)

### Editor integration (manual)
11. **Codespaces:** Create codespace from repo, verify startup < 3 min
12. VS Code: "Reopen in Container" works, LSP provides completions
13. Neovim: `devcontainer exec nvim examples/hello/hello.ml` - LSP works
14. Emacs: TRAMP + eglot connects to LSP
15. Claude Code: `claude` command works inside container

### ThreadSanitizer verification
16. Switch to tsan: `opam switch 5.4.0+tsan`
17. Verify switch works: compile and run sample program (trust tsan if switch builds)

### Profiling tools verification (opam packages only)
18. landmarks: Profile sample OCaml code, view report
19. memtrace: Generate trace, verify CTF output
20. olly: Capture runtime events
21. bisect_ppx: Generate coverage report

### Dune package management verification
22. `dune pkg lock` creates lock directory
23. `dune build` with `(pkg enabled)` works
24. `dune tools exec ocamllsp` runs correctly
25. `dune tools env` sets up PATH

### MCP verification
26. ocaml-mcp installed: `ocaml-mcp --version` works
27. ocaml-mcp serves: `ocaml-mcp serve` starts and responds to JSON-RPC
28. MCP tools work: dune build via MCP, merlin type queries via MCP
29. Document odoc-llm connection: `claude mcp add -t sse ...` works

### Tutorial author workflow
30. Create minimal tutorial Dockerfile (FROM ocaml-5.4-dev)
31. Add one opam package → verify fast rebuild (<2 min)
32. Test dune pkg workflow in tutorial context

## Configuration Required

Before running CI/CD, you'll need to set up:

1. **GitHub repository secrets:**
   - `DOCKERHUB_USERNAME` - Your Docker Hub username
   - `DOCKERHUB_TOKEN` - Docker Hub access token (not password)

2. **Replace placeholders in files:**
   - `<GITHUB_ORG>` - Your GitHub organization name
   - `<DOCKER_USERNAME>` - Your Docker Hub username
   - `<REPO_NAME>` - Repository name (e.g., `ocaml-devcontainer`)

The images will be published to:
- `docker.io/<DOCKER_USERNAME>/<REPO_NAME>:latest`
- `ghcr.io/<GITHUB_ORG>/<REPO_NAME>:latest`

## Build Configuration

- **Architectures:** linux/amd64, linux/arm64

---

## Image Architecture (Separate Images)

**Use case:** Tutorials and training sessions need stable base + fast iteration.

```
┌─────────────────────────────────────────────────────────┐
│  ocaml-5.4-base                                         │
│  ─────────────────                                      │
│  • Ubuntu 24.04 + system deps                           │
│  • opam initialized                                     │
│  • Switch: 5.4.0                                        │
│  • Switch: 5.4.0+tsan                                   │
│  • vim, emacs (apt)                                     │
│  • gdb, lldb, valgrind, rr, perf, strace (apt)          │
│  • bpftrace, hyperfine, inferno (apt/cargo)             │
│  • Shell config: eval $(opam env) in .bashrc            │
│                                                         │
│  Build time: ~35-50 min (multi-arch)                    │
│  Rebuild frequency: Rare (new OCaml release)            │
│  Size: ~2.2 GB                                          │
└───────────────────────────┬─────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│  ocaml-5.4-dev                                          │
│  ─────────────────                                      │
│  FROM ocaml-5.4-base                                    │
│  • Build: dune, ocaml-lsp-server, merlin, ocamlformat   │
│  • REPL/Docs: utop, odoc                                │
│  • Testing: ounit2, ppx_inline_test, ppx_expect, qcheck │
│  • Coverage: bisect_ppx                                 │
│  • Profiling: landmarks, memtrace, olly                 │
│  • MCP: ocaml-mcp (local AI agent integration)          │
│  • Libraries: core, base                                │
│  (identical in both switches)                           │
│  • Claude Code (via DevContainer Feature)               │
│                                                         │
│  Build time: ~15-20 min                                 │
│  Rebuild frequency: When tools update                   │
│  Size: ~3.5 GB                                          │
└───────────────────────────┬─────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│  [tutorial-specific] (optional, user-created)           │
│  ─────────────────────────────────────                  │
│  FROM ocaml-5.4-dev                                     │
│  • Tutorial-specific opam packages                      │
│  • Exercise files, starter code                         │
│                                                         │
│  Build time: seconds to minutes                         │
│  Rebuild frequency: During tutorial development         │
└─────────────────────────────────────────────────────────┘
```

### Published Images

| Image | Tag | Description |
|-------|-----|-------------|
| `ocaml-5.4-base` | `latest`, `5.4.0` | Compilers only |
| `ocaml-5.4-dev` | `latest`, `5.4.0` | Full development environment |

Both published to:
- `docker.io/<DOCKER_USERNAME>/ocaml-5.4-base`
- `docker.io/<DOCKER_USERNAME>/ocaml-5.4-dev`
- `ghcr.io/<GITHUB_ORG>/ocaml-5.4-base`
- `ghcr.io/<GITHUB_ORG>/ocaml-5.4-dev`

### CI/CD Workflow

```yaml
# build-push.yml
jobs:
  build-base:
    # Only runs if base/ changed or manual trigger
    # Builds and pushes ocaml-5.4-base

  build-dev:
    needs: build-base  # Wait for base if it's building
    # Always runs
    # Pulls latest base, builds and pushes ocaml-5.4-dev
```

### For Tutorial Authors

```dockerfile
# Example: my-eio-tutorial/Dockerfile
FROM ghcr.io/yourorg/ocaml-5.4-dev:latest

# Add tutorial-specific packages (fast, base already has compilers)
RUN opam install -y eio eio_main

# Add exercise files
COPY exercises/ /workspace/exercises/
```

Iteration cycle: edit exercises → rebuild → test → repeat (seconds, not minutes)

---

## Base Image Decision: Microsoft DevContainer vs ocaml/opam

**Decision:** Use `mcr.microsoft.com/devcontainers/base:ubuntu-24.04`

### Comparison

| Aspect | `ocaml/opam` | `mcr.microsoft.com/devcontainers/base` |
|--------|--------------|----------------------------------------|
| **Default user** | `opam` (uid 1000) | `vscode` (uid 1000) |
| **opam pre-installed** | Yes, fully initialized | No, must install manually |
| **Image size** | Smaller (one compiler per image) | Larger base, but more flexible |
| **opam-repository** | Pre-checked out at `/home/opam/opam-repository` | Must clone/init |
| **DevContainer features** | Not designed for them | Full support |
| **Editors/tools** | Minimal | Common dev tools included |
| **Sandboxing** | Bubblewrap available (disabled) | None |

### opam Switch Handling Differences

**With `ocaml/opam`:**
- Each image tag = one compiler version (e.g., `ocaml/opam:debian-ocaml-5.4`)
- Multiple switches require manual creation or multiple images
- Environment pre-configured via `/Dockerfile.ocaml`
- Best practice: use `opam exec --` rather than `eval $(opam env)`

**With Microsoft base:**
- Start from scratch: `opam init`, then `opam switch create`
- More Dockerfile commands, but explicit control
- Must handle environment setup carefully

### Why Microsoft Base for This Project

1. Need **multiple switches in one container** (5.4.0, 5.4.0+tsan)
2. Better **DevContainer features** integration (Claude Code feature)
3. Explicit control over opam initialization
4. Follows OxCaml tutorial pattern (proven approach)

### Future: Supporting ocaml/opam Base

To support `ocaml/opam` as an alternative later:
```dockerfile
# Alternative Dockerfile.ocaml-opam
FROM ocaml/opam:debian-ocaml-5.4
RUN opam switch create 5.4.0+tsan ocaml-variants.5.4.0+options ocaml-option-tsan
RUN opam exec -- opam install -y dune ocaml-lsp-server merlin ocamlformat utop
# User is already 'opam', adjust devcontainer.json remoteUser accordingly
```

Could provide both via:
- `.devcontainer/devcontainer.json` (Microsoft base, default)
- `.devcontainer-ocaml-opam/devcontainer.json` (ocaml/opam base, alternative)

---

## Editor Architecture

**Primary workflow:** Use `devcontainer exec` from host to run tools inside container.

**Convenience:** vim, emacs, Claude Code are also available inside the container.

| Editor | Primary (recommended) | Alternative |
|--------|----------------------|-------------|
| **VS Code** | "Reopen in Container" | - |
| **Vim** | `devcontainer exec vim file.ml` | Also installed in base image |
| **Neovim** | `devcontainer exec nvim file.ml` | Install in container if needed |
| **Emacs** | `devcontainer exec emacs file.ml` | Also installed in base image |
| **Claude Code** | `devcontainer exec claude` | Pre-installed in dev image |

### What the container provides:

**Base image (ocaml-5.4-base):**
- OCaml compilers (5.4.0, 5.4.0+tsan)
- vim, emacs (via apt)
- opam initialized, shell configured

**Dev image (ocaml-5.4-dev):**
- Everything in base, plus:
- LSP server (ocaml-lsp-server)
- Build tools (dune)
- Development tools (merlin, ocamlformat, utop)
- MCP server (ocaml-mcp for AI agent integration)
- Claude Code (via DevContainer Feature)

### Documentation approach:

**Emphasize `devcontainer exec` as primary:**
```bash
# Start container
devcontainer up --workspace-folder .

# Run any editor/tool
devcontainer exec --workspace-folder . vim src/main.ml
devcontainer exec --workspace-folder . emacs src/main.ml
devcontainer exec --workspace-folder . claude
devcontainer exec --workspace-folder . dune build
```

**Mention alternatives:**
- VS Code: Native "Reopen in Container" experience
- Emacs TRAMP: `/docker:container:/path` for remote editing
- Neovim plugins: `nvim-dev-container` for VS Code-like experience

### Why this approach:

1. **Consistent:** Same workflow for all editors
2. **Simple:** No complex host-container LSP bridging
3. **Flexible:** Users can still use native integrations if preferred
4. **Tutorial-friendly:** One command pattern to teach

---

## MCP (Model Context Protocol) Integration

**Purpose:** Give AI coding assistants (Claude Code, etc.) deep understanding of OCaml projects and ecosystem.

### Two Complementary MCP Servers

| MCP Server | Scope | Transport | Use Case |
|------------|-------|-----------|----------|
| **ocaml-mcp** (Thibault Mattio) | Local project | stdio | "Build this", "What's the type here?" |
| **odoc-llm** (Ludlam/Jaffer) | Entire opam ecosystem | SSE (remote) | "What package handles HTTP?" |

### ocaml-mcp (Local - included in dev image)

**Repository:** https://github.com/tmattio/ocaml-mcp

**Tools provided:**
- Dune RPC integration (build status, run targets)
- Merlin integration (type info at position)
- Expression evaluation in project context
- Module signature extraction
- Project structure analysis
- Test execution

**Installation:** Pre-installed in `ocaml-5.4-dev` image via opam.

### odoc-llm (Remote - hosted service)

**Repository:** https://github.com/sadiqj/odoc-llm/

**Tools provided:**
- Package search (semantic search across all opam packages)
- Module search (find modules within packages)
- Type-based search (via sherlodoc)

**Architecture:** Uses embeddings from documentation generated by `ocaml-docs-ci` for every package in opam-repository. Ranks by embedding similarity + popularity.

**Demo server:** `dill.caelum.ci.dev:8000/sse`

**Configuration:** Users add this to their MCP config:
```bash
claude mcp add -t sse ocaml-ecosystem http://dill.caelum.ci.dev:8000/sse
```

### Integration in DevContainer

**In devcontainer.json:**
```json
{
  "postStartCommand": "eval $(opam env) && ocaml-mcp serve &",
  "customizations": {
    "vscode": {
      "settings": {
        "mcp.servers": {
          "ocaml-local": {
            "command": "ocaml-mcp",
            "args": ["serve"]
          }
        }
      }
    }
  }
}
```

**For Claude Code:** Document in `docs/SETUP-ADVANCED.md` how to configure both MCP servers.

### Why Both?

| Question | MCP Server |
|----------|------------|
| "What package handles HTTP clients?" | odoc-llm (ecosystem search) |
| "What's the type of this expression?" | ocaml-mcp (local tooling) |
| "Show me packages similar to lwt" | odoc-llm |
| "Build and run my tests" | ocaml-mcp |
| "What modules does this package export?" | Either (local or ecosystem) |

---

## Package Management: Dual Support (opam + dune pkg)

The container supports **both** package management workflows:

### Traditional opam Workflow

For existing projects and tutorials using opam:

```bash
# Tools pre-installed in both switches
opam switch 5.4.0
dune build
ocamllsp          # Pre-installed, works immediately
ocamlformat       # Pre-installed
```

### Modern dune pkg Workflow

For projects using Dune's integrated package management:

```lisp
;; dune-project
(lang dune 3.17)
(name my-project)
(package
 (name my-project)
 (depends
  (ocaml (>= 5.4))
  (lwt (>= 5.7))))

;; dune-workspace
(lang dune 3.21)
(pkg enabled)
```

```bash
dune pkg lock                          # Create lock directory
dune build                             # Downloads + builds all deps
dune tools exec ocamllsp               # Project-local LSP
eval $(dune tools env)                 # Set PATH for editors
```

### What the Container Provides

| Component | Purpose |
|-----------|---------|
| **opam** | Repository metadata for dune solver, traditional workflow |
| **opam switches** | Pre-configured 5.4.0 and 5.4.0+tsan with tools |
| **dune 3.21+** | Latest dune with pkg support |
| **Pre-installed tools** | ocamllsp, ocamlformat, merlin (global, for opam workflow) |
| **dune tools support** | Works out-of-box for per-project tools |

### Why Support Both?

1. **Existing tutorials** use opam workflow
2. **New projects** benefit from dune pkg (reproducible, per-project deps)
3. **Transition period** - ecosystem moving toward dune pkg
4. **Tutorial authors** can choose which approach to teach

### Editor Integration

**opam workflow:**
```bash
# Tools in PATH, editors find them automatically
devcontainer exec ocamllsp
```

**dune pkg workflow:**
```bash
# Option A: Run via dune tools
devcontainer exec dune tools exec ocamllsp

# Option B: Set up environment first
eval $(dune tools env)
ocamllsp  # Now in PATH
```

### Testing Both Workflows

The container tests verify:
1. opam switches work with pre-installed tools
2. `dune pkg lock` resolves dependencies correctly
3. `dune build` with `(pkg enabled)` builds projects
4. `dune tools exec ocamllsp` works
5. Both workflows produce working LSP integration
