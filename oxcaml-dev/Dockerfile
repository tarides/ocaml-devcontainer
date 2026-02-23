# OxCaml + OCaml 5.4 Development Image
# Contains: Full development toolchain for OxCaml and OCaml
# Build time: ~15-25 min

ARG BASE_IMAGE=ghcr.io/tarides/oxcaml-devcontainer-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.source="https://github.com/tarides/ocaml-devcontainer"
LABEL org.opencontainers.image.description="OxCaml + OCaml 5.4 full development environment"
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

# Tools for the ocaml and ocaml+tsan switches (same as standard dev image)
ENV OCAML_BUILD="ocamlformat"
ENV OCAML_TEST="alcotest ppx_inline_test ppx_expect qcheck"
ENV OCAML_LIBS="core base"
ENV OCAML_PROFILE="landmarks memtrace runtime_events_tools printbox"
ENV OCAML_TOOLS="${OCAML_BUILD} ${OCAML_TEST} ${OCAML_LIBS} ${OCAML_PROFILE}"

# Tools for the oxcaml switch (different availability in oxcaml opam repo)
ENV OXCAML_TEST="alcotest ppx_inline_test ppx_expect"
ENV OXCAML_LIBS="core base await parallel"
ENV OXCAML_TOOLS="${OXCAML_TEST} ${OXCAML_LIBS}"

# ============================================================================
# Install Tools in All Switches
# ============================================================================

# Install in oxcaml switch
RUN opam switch oxcaml && \
    eval $(opam env) && \
    opam update && \
    opam install -y ${OXCAML_TOOLS}

# Install in ocaml switch
RUN opam switch ocaml && \
    eval $(opam env) && \
    opam update && \
    opam install -y ${OCAML_TOOLS}

# Install in ocaml+tsan switch
RUN opam switch ocaml+tsan && \
    eval $(opam env) && \
    opam update && \
    opam install -y ${OCAML_TOOLS}

# ============================================================================
# Set Default Switch
# ============================================================================

RUN opam switch set oxcaml

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
