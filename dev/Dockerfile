# OCaml Development Image
# Contains: Full OCaml development toolchain
# Build time: ~15-20 min
#
# Build args:
#   BASE_IMAGE           - base image to build on
#   OCAML_VERSION        - compiler version (default: 5.4.0)
#   ENABLE_TSAN          - install tools in TSan switch too (default: true)
#   OCAML_EXTRA_PROFILE  - version-specific profiling packages (default: "runtime_events_tools")

ARG BASE_IMAGE=ghcr.io/tarides/ocaml-5.4-base:latest
FROM ${BASE_IMAGE}

ARG OCAML_VERSION=5.4.0
ARG ENABLE_TSAN=true
ARG OCAML_EXTRA_PROFILE="runtime_events_tools"

LABEL org.opencontainers.image.source="https://github.com/tarides/ocaml-devcontainer"
LABEL org.opencontainers.image.description="OCaml ${OCAML_VERSION} full development environment"
LABEL org.opencontainers.image.licenses="MIT"

# Limit opam parallelism to control memory usage during builds
# Override with: docker build --build-arg OPAMJOBS=2 ...
ARG OPAMJOBS=""
ENV OPAMJOBS=${OPAMJOBS}

# Switch to vscode user for opam operations
USER vscode
WORKDIR /home/vscode

# ============================================================================
# OCaml Tool Categories
# ============================================================================

# Define tools once - installed identically in all switches
ENV OCAML_BUILD="ocamlformat"
ENV OCAML_TEST="ounit2 ppx_inline_test ppx_expect qcheck"
ENV OCAML_LIBS="core base"
ENV OCAML_PROFILE="landmarks memtrace ${OCAML_EXTRA_PROFILE} printbox"

# Combined toolset
ENV OCAML_TOOLS="${OCAML_BUILD} ${OCAML_TEST} ${OCAML_LIBS} ${OCAML_PROFILE}"

# ============================================================================
# Install Tools in All Switches
# ============================================================================

# Install in main switch
RUN opam switch ${OCAML_VERSION} && \
    eval $(opam env) && \
    opam update && \
    opam install -y ${OCAML_TOOLS}

# Install in TSan switch (if enabled)
RUN if [ "${ENABLE_TSAN}" = "true" ]; then \
        opam switch ${OCAML_VERSION}+tsan && \
        eval $(opam env) && \
        opam update && \
        opam install -y ${OCAML_TOOLS}; \
    fi

# ============================================================================
# Set Default Switch
# ============================================================================

RUN opam switch set ${OCAML_VERSION}

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
