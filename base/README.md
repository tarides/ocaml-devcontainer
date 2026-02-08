# OCaml DevContainer Base

Base image containing OCaml compilers only. **This is not the image you want to use directly.**

## Use the dev image instead

```bash
docker pull cuihtlauac/ocaml-devcontainer
```

Or in a Dockerfile:

```dockerfile
FROM cuihtlauac/ocaml-devcontainer:latest
```

See [cuihtlauac/ocaml-devcontainer](https://hub.docker.com/r/cuihtlauac/ocaml-devcontainer) for the full development environment with all tools pre-installed.

## What this base image contains

- OCaml 5.4.0 compiler
- OCaml 5.4.0+tsan compiler (ThreadSanitizer variant)
- opam package manager

The dev image (`cuihtlauac/ocaml-devcontainer`) builds on top of this base and adds dune, LSP, merlin, ocamlformat, utop, testing and profiling tools.

## Source

[github.com/tarides/ocaml-devcontainer](https://github.com/tarides/ocaml-devcontainer)
