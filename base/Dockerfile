# OCaml 5.4 Base Image
# Contains: OCaml compilers (5.4.0, 5.4.0+tsan), system tools, editors
# Build time: ~35-50 min (multi-arch)

FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

LABEL org.opencontainers.image.source="https://github.com/tarides/ocaml-devcontainer"
LABEL org.opencontainers.image.description="OCaml 5.4 development base image"
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
    neovim \
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

# Install Node.js 22 LTS (prevents Claude Code feature from pulling EOL Node 18)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install nushell (not in Ubuntu repos, fetch from GitHub releases)
RUN ARCH=$(dpkg --print-architecture) && \
    case "$ARCH" in \
        amd64) NU_ARCH="x86_64-unknown-linux-musl" ;; \
        arm64) NU_ARCH="aarch64-unknown-linux-musl" ;; \
        *) echo "Unsupported architecture: $ARCH"; exit 1 ;; \
    esac && \
    NU_VERSION=$(curl -fsSL https://api.github.com/repos/nushell/nushell/releases/latest | grep '"tag_name"' | cut -d'"' -f4) && \
    curl -fsSL "https://github.com/nushell/nushell/releases/download/${NU_VERSION}/nu-${NU_VERSION}-${NU_ARCH}.tar.gz" | \
    tar xz -C /usr/local/bin --strip-components=1 "nu-${NU_VERSION}-${NU_ARCH}/nu"

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

# Create standard OCaml 5.4.0 switch and install platform tools
RUN opam switch create 5.4.0 ocaml-base-compiler.5.4.0 --yes && \
    opam install -y ${OCAML_PLATFORM}

# Create ThreadSanitizer switch for race detection and install platform tools
# IMPORTANT: Building TSan requires reduced ASLR entropy on the host:
#   sudo sysctl -w vm.mmap_rnd_bits=28
# See: https://github.com/google/sanitizers/issues/1716
RUN opam switch create 5.4.0+tsan ocaml-variants.5.4.0+options ocaml-option-tsan --yes && \
    opam install -y ${OCAML_PLATFORM}

# Set default switch
RUN opam switch set 5.4.0

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
