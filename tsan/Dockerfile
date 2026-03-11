# OCaml 5.4 TSan Image
# Adds an "ocaml+tsan" switch on top of the dev image
# Build time: ~20-30 min
# IMPORTANT: Building requires reduced ASLR entropy on the host:
#   sudo sysctl -w vm.mmap_rnd_bits=28
# See: https://github.com/google/sanitizers/issues/1716

ARG BASE_IMAGE=ghcr.io/tarides/ocaml-devcontainer:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.source="https://github.com/tarides/ocaml-devcontainer"
LABEL org.opencontainers.image.description="OCaml 5.4 development environment with ThreadSanitizer"
LABEL org.opencontainers.image.licenses="MIT"

# Limit opam parallelism to control memory usage during builds
# Override with: docker build --build-arg OPAMJOBS=2 ...
ARG OPAMJOBS

# Switch to vscode user for opam operations
USER vscode
WORKDIR /home/vscode

# ============================================================================
# Platform tools — must match base/Dockerfile (source of truth)
# ============================================================================

ENV OCAML_PLATFORM="dune ocaml-lsp-server ocamlformat merlin utop"

# ============================================================================
# Dev tools — must match dev/Dockerfile (source of truth)
# ============================================================================

ENV OCAML_TEST="alcotest ppx_inline_test ppx_expect qcheck dscheck qcheck-stm qcheck-lin"
ENV OCAML_LIBS="base backoff"
ENV OCAML_PROFILE="landmarks memtrace runtime_events_tools printbox"
ENV OCAML_TOOLS="${OCAML_TEST} ${OCAML_LIBS} ${OCAML_PROFILE}"

# ============================================================================
# Create TSan switch and install all tools
# ============================================================================

RUN opam update && \
    opam switch create ocaml+tsan ocaml-variants.5.4.0+options ocaml-option-tsan --yes && \
    opam install -y ${OCAML_PLATFORM} ${OCAML_TOOLS}

# Set default switch back to ocaml
RUN opam switch set ocaml

# ============================================================================
# ASLR fix for TSan at shell startup
# ============================================================================

# Fix ASLR entropy for TSan: modern kernels set vm.mmap_rnd_bits=32 but
# ThreadSanitizer requires <= 28.  Try sysctl first (works on Docker Desktop
# and privileged CI), fall back to setarch (works if the personality() syscall
# is allowed).
# See: https://github.com/google/sanitizers/issues/1716
RUN cat > /home/vscode/.fix-tsan-aslr.sh << 'EOF'
if [ -z "$TSAN_ASLR_FIXED" ] && [ -r /proc/sys/vm/mmap_rnd_bits ]; then
  _mmap_rnd_bits=$(cat /proc/sys/vm/mmap_rnd_bits 2>/dev/null)
  if [ "${_mmap_rnd_bits:-0}" -gt 28 ]; then
    if sudo sysctl -w vm.mmap_rnd_bits=28 >/dev/null 2>&1; then
      true
    elif setarch "$(uname -m)" --addr-no-randomize /bin/true >/dev/null 2>&1; then
      export TSAN_ASLR_FIXED=1
      exec setarch "$(uname -m)" --addr-no-randomize "$SHELL"
    fi
  fi
  unset _mmap_rnd_bits
fi
EOF

RUN echo 'source ~/.fix-tsan-aslr.sh' >> /home/vscode/.bashrc && \
    if [ -f /home/vscode/.zshrc ]; then \
        echo 'source ~/.fix-tsan-aslr.sh' >> /home/vscode/.zshrc; \
    fi

# ============================================================================
# Cleanup
# ============================================================================

RUN opam clean -a --yes

WORKDIR /home/vscode
CMD ["/bin/bash"]
