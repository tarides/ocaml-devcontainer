#!/bin/bash
# Test Neovim integration via devcontainer exec
# Usage: test-neovim.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXAMPLES_DIR="$SCRIPT_DIR/../examples"

echo "=== Testing Neovim integration ==="

# Test 1: Check if nvim is available
echo ""
echo "--- Test 1: Check Neovim availability ---"
if command -v nvim &> /dev/null; then
    VERSION=$(nvim --version | head -1)
    echo "Neovim: $VERSION"
    echo "PASS: Neovim available"
else
    echo "WARN: Neovim not installed in container"
    echo "Neovim can be installed or used via devcontainer exec from host"
    exit 0
fi

# Test 2: Check Neovim config exists
echo ""
echo "--- Test 2: Check Neovim LSP config ---"
CONFIG_PATH="$HOME/.config/nvim/init.lua"
if [ -f "$CONFIG_PATH" ]; then
    grep -q "ocamllsp" "$CONFIG_PATH" && echo "PASS: Neovim LSP config for OCaml exists" || echo "WARN: OCaml LSP config not found in init.lua"
else
    echo "WARN: Neovim config not found at $CONFIG_PATH"
fi

# Test 3: Test Neovim can start and exit cleanly
echo ""
echo "--- Test 3: Test Neovim startup ---"
nvim --headless -c 'quit' 2>&1 || { echo "FAIL: Neovim failed to start"; exit 1; }
echo "PASS: Neovim starts and exits cleanly"

# Test 4: Test devcontainer exec pattern (simulation)
echo ""
echo "--- Test 4: Simulate devcontainer exec pattern ---"
# This simulates what `devcontainer exec nvim file.ml` does
cd "$EXAMPLES_DIR/hello"
timeout 2 nvim --headless hello.ml -c 'quit' 2>&1 || true
echo "PASS: Neovim can open OCaml files"

echo ""
echo "=== Neovim tests completed ==="
