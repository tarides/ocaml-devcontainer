# OCaml DevContainer

Production-ready OCaml development environment for VS Code, GitHub Codespaces, and any editor. Designed for tutorials and workshops where zero-friction onboarding is critical.

## Quick Start

### GitHub Codespaces (Instant)

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/tarides/ocaml-devcontainer)

### GitHub CLI

```bash
gh codespace create --repo tarides/ocaml-devcontainer
gh codespace ssh
```

### Local (Any Editor)

```bash
npm install -g @devcontainers/cli
git clone https://github.com/tarides/ocaml-devcontainer.git
cd ocaml-devcontainer
devcontainer up --workspace-folder .
devcontainer exec --workspace-folder . dune build
```

## What's Included

- **OCaml 5.4** (single `ocaml` switch)
- **Build**: dune, ocaml-lsp-server, merlin, utop
- **Testing**: alcotest, ppx_expect, qcheck
- **Profiling**: landmarks, memtrace, olly
- **Editors**: VS Code, Vim, Emacs, Neovim, Claude Code

For ThreadSanitizer support, use the TSan variant: `cuihtlauac/ocaml-devcontainer-tsan`.

## For Tutorial Authors

```dockerfile
FROM cuihtlauac/ocaml-devcontainer:latest
RUN opam install -y lwt eio
COPY exercises/ /home/vscode/exercises/
```

## Source

[github.com/tarides/ocaml-devcontainer](https://github.com/tarides/ocaml-devcontainer)
