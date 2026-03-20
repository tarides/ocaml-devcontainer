# OCaml 5.4 + Rocq Image
# Adds Rocq (formerly Coq) on top of the dev image
# Build time: ~10-15 min

ARG BASE_IMAGE=ghcr.io/tarides/ocaml-devcontainer:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.source="https://github.com/tarides/ocaml-devcontainer"
LABEL org.opencontainers.image.description="OCaml 5.4 development environment with Rocq"
LABEL org.opencontainers.image.licenses="MIT"

# Limit opam parallelism to control memory usage during builds
# Override with: docker build --build-arg OPAMJOBS=2 ...
ARG OPAMJOBS

# Switch to vscode user for opam operations
USER vscode
WORKDIR /home/vscode

# ============================================================================
# Install Rocq
# ============================================================================

RUN opam switch ocaml && \
    eval $(opam env) && \
    opam update && \
    opam install -y rocq-prover

# ============================================================================
# Cleanup
# ============================================================================

RUN opam clean -a --yes

WORKDIR /home/vscode
CMD ["/bin/bash"]
