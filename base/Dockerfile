# OCaml Base Image
# Contains: OCaml compiler(s), system tools, editors
# Build time: ~35-50 min (multi-arch)
#
# Build args:
#   OCAML_VERSION  - compiler version (default: 5.4.0)
#   ENABLE_TSAN    - build TSan switch (default: true, requires 5.x)

FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ARG OCAML_VERSION=5.4.0
ARG ENABLE_TSAN=true

LABEL org.opencontainers.image.source="https://github.com/tarides/ocaml-devcontainer"
LABEL org.opencontainers.image.description="OCaml ${OCAML_VERSION} development base image"
LABEL org.opencontainers.image.licenses="MIT"

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# ============================================================================
# System Dependencies
# ============================================================================

RUN apt-get update && apt-get install -y --no-install-recommends \
    # Build essentials
    build-essential \
    m4 \
    autoconf \
    automake \
    libtool \
    pkg-config \
    # Libraries
    libunwind-dev \
    libgmp-dev \
    libffi-dev \
    libssl-dev \
    zlib1g-dev \
    # Tools
    git \
    curl \
    wget \
    ssh \
    rsync \
    unzip \
    # Editors
    vim \
    emacs-nox \
    # Debugging & profiling tools
    gdb \
    lldb \
    valgrind \
    strace \
    ltrace \
    # hyperfine for benchmarking
    hyperfine \
    # Python for test scripts
    python3 \
    python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install linux-tools (perf) - optional, depends on kernel version
# May fail in containers due to kernel version mismatch
RUN apt-get update && apt-get install -y --no-install-recommends linux-tools-generic || true \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install rr (record & replay debugger) - may not work in all environments
# Note: rr requires hardware perf counters, works on bare metal and some VMs
RUN apt-get update && apt-get install -y --no-install-recommends rr || true \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install bpftrace (eBPF tracing) - optional, may require kernel support
RUN apt-get update && apt-get install -y --no-install-recommends bpftrace || true \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ============================================================================
# opam Installation
# ============================================================================

# Install opam
RUN curl -fsSL https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh | \
    bash -s -- --no-backup

# Switch to vscode user for opam setup
USER vscode
WORKDIR /home/vscode

# Initialize opam (disable sandboxing for container compatibility)
RUN opam init --disable-sandboxing --auto-setup --yes

# ============================================================================
# OCaml Switches
# ============================================================================

# OCaml platform tools - installed at switch creation time in both switches
ENV OCAML_PLATFORM="dune ocaml-lsp-server merlin utop odoc"

# Create main OCaml switch and install platform tools
RUN opam switch create ${OCAML_VERSION} ocaml-base-compiler.${OCAML_VERSION} --yes && \
    opam install -y ${OCAML_PLATFORM}

# Create ThreadSanitizer switch for race detection and install platform tools
# IMPORTANT: Building TSan requires reduced ASLR entropy on the host:
#   sudo sysctl -w vm.mmap_rnd_bits=28
# See: https://github.com/google/sanitizers/issues/1716
RUN if [ "${ENABLE_TSAN}" = "true" ]; then \
        opam switch create ${OCAML_VERSION}+tsan ocaml-variants.${OCAML_VERSION}+options ocaml-option-tsan --yes && \
        opam install -y ${OCAML_PLATFORM}; \
    fi

# Set default switch
RUN opam switch set ${OCAML_VERSION}

# ============================================================================
# Shell Configuration
# ============================================================================

# Configure bash to initialize opam environment
RUN echo 'eval $(opam env)' >> /home/vscode/.bashrc

# Configure zsh if present
RUN if [ -f /home/vscode/.zshrc ]; then \
        echo 'eval $(opam env)' >> /home/vscode/.zshrc; \
    fi

# ============================================================================
# Editor Configuration (minimal LSP-ready configs)
# ============================================================================

# Emacs: minimal config for eglot + OCaml
RUN mkdir -p /home/vscode/.emacs.d && \
    cat > /home/vscode/.emacs.d/init.el << 'EOF'
;; Minimal Emacs config for OCaml development
;; Enable eglot for LSP support

(require 'eglot)

;; Associate OCaml files with tuareg-mode and eglot
(add-to-list 'auto-mode-alist '("\\.ml[ily]?\\'" . tuareg-mode))
(add-to-list 'auto-mode-alist '("\\.mli\\'" . tuareg-mode))

;; Start eglot automatically for OCaml files
(add-hook 'tuareg-mode-hook 'eglot-ensure)

;; Use ocamllsp as the LSP server
(add-to-list 'eglot-server-programs '(tuareg-mode . ("ocamllsp")))
EOF

# Neovim: minimal config for LSP
RUN mkdir -p /home/vscode/.config/nvim && \
    cat > /home/vscode/.config/nvim/init.lua << 'EOF'
-- Minimal Neovim config for OCaml development
-- Requires nvim 0.8+ for native LSP support

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'ocaml', 'ocaml.interface', 'ocaml.menhir', 'ocaml.ocamllex' },
  callback = function()
    vim.lsp.start({
      name = 'ocamllsp',
      cmd = { 'ocamllsp' },
      root_dir = vim.fs.dirname(vim.fs.find({ 'dune-project', '.git' }, { upward = true })[1]),
    })
  end,
})
EOF

# Vim: minimal config (no LSP, just syntax highlighting)
RUN cat > /home/vscode/.vimrc << 'EOF'
" Minimal Vim config for OCaml
syntax on
filetype plugin indent on
set number
set expandtab
set tabstop=2
set shiftwidth=2
EOF

# ============================================================================
# Cleanup
# ============================================================================

# Clean opam cache to reduce image size
RUN opam clean -a --yes

# Reset to root for any subsequent operations
USER root

# Set default user back to vscode
USER vscode
WORKDIR /home/vscode
