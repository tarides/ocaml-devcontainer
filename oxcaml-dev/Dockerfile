# OxCaml Development Image
# Contains: Full development toolchain for OxCaml
# Build time: ~10-15 min

ARG BASE_IMAGE=ghcr.io/tarides/oxcaml-devcontainer-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.source="https://github.com/tarides/ocaml-devcontainer"
LABEL org.opencontainers.image.description="OxCaml full development environment"
LABEL org.opencontainers.image.licenses="MIT"

# Limit opam parallelism to control memory usage during builds
# Override with: docker build --build-arg OPAMJOBS=2 ...
ARG OPAMJOBS

# Switch to vscode user for opam operations
USER vscode
WORKDIR /home/vscode

# ============================================================================
# OxCaml Tool Categories
# ============================================================================

# Tools for the oxcaml switch (different availability in oxcaml opam repo)
ENV OXCAML_TEST="alcotest ppx_inline_test ppx_expect"
ENV OXCAML_LIBS="core base await parallel"
ENV OXCAML_TOOLS="${OXCAML_TEST} ${OXCAML_LIBS}"

# ============================================================================
# Install Tools
# ============================================================================

RUN opam switch oxcaml && \
    eval $(opam env) && \
    opam update && \
    opam install -y ${OXCAML_TOOLS}

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
