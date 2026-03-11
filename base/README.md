# OCaml DevContainer Base

Base image containing the OCaml compiler only. **This is not the image you want to use directly.**

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

- OCaml 5.4.0 compiler (switch name: `ocaml`)
- opam package manager

The dev image (`cuihtlauac/ocaml-devcontainer`) builds on top of this base and adds testing, profiling and library packages. The TSan variant (`cuihtlauac/ocaml-devcontainer-tsan`) builds on top of the dev image and adds an `ocaml+tsan` switch.

## Source

[github.com/tarides/ocaml-devcontainer](https://github.com/tarides/ocaml-devcontainer)
