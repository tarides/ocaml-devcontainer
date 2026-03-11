# OCaml 5.4 Development Image
# Contains: Full OCaml development toolchain
# Build time: ~15-20 min

ARG BASE_IMAGE=ghcr.io/tarides/ocaml-devcontainer-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.source="https://github.com/tarides/ocaml-devcontainer"
LABEL org.opencontainers.image.description="OCaml 5.4 full development environment"
LABEL org.opencontainers.image.licenses="MIT"

# Limit opam parallelism to control memory usage during builds
# Override with: docker build --build-arg OPAMJOBS=2 ...
ARG OPAMJOBS

# Switch to vscode user for opam operations
USER vscode
WORKDIR /home/vscode

# ============================================================================
# OCaml Tool Categories
# ============================================================================

# Define tools once — also used by tsan/Dockerfile (keep in sync)
ENV OCAML_TEST="alcotest ppx_inline_test ppx_expect qcheck dscheck qcheck-stm qcheck-lin"
ENV OCAML_LIBS="base backoff"
ENV OCAML_PROFILE="landmarks memtrace runtime_events_tools printbox"

# Combined toolset
ENV OCAML_TOOLS="${OCAML_TEST} ${OCAML_LIBS} ${OCAML_PROFILE}"

# ============================================================================
# Install Tools
# ============================================================================

RUN opam switch ocaml && \
    eval $(opam env) && \
    opam update && \
    opam install -y ${OCAML_TOOLS}

# ============================================================================
# Cleanup
# ============================================================================

# Clean opam cache to reduce image size
RUN opam clean -a --yes

# ============================================================================
# Final Configuration
# ============================================================================

# Ensure opam env is loaded
RUN echo 'eval $(opam env)' >> /home/vscode/.bashrc

# Set working directory
WORKDIR /home/vscode

# Default command
CMD ["/bin/bash"]
