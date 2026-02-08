#!/bin/bash
# Test Vim integration
# Usage: test-vim.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXAMPLES_DIR="$SCRIPT_DIR/../examples"

echo "=== Testing Vim integration ==="

# Test 1: Check if vim is available
echo ""
echo "--- Test 1: Check Vim availability ---"
if command -v vim &> /dev/null; then
    VERSION=$(vim --version | head -1)
    echo "Vim: $VERSION"
    echo "PASS: Vim available"
else
    echo "FAIL: Vim not installed"
    exit 1
fi

# Test 2: Check Vim config exists
echo ""
echo "--- Test 2: Check Vim config ---"
CONFIG_PATH="$HOME/.vimrc"
if [ -f "$CONFIG_PATH" ]; then
    grep -q "syntax on" "$CONFIG_PATH" && echo "PASS: Vim syntax highlighting enabled" || echo "WARN: syntax highlighting not configured"
    grep -q "filetype plugin indent on" "$CONFIG_PATH" && echo "PASS: Vim filetype detection enabled" || echo "WARN: filetype detection not configured"
else
    echo "WARN: Vim config not found at $CONFIG_PATH"
fi

# Test 3: Test Vim can start and exit cleanly
echo ""
echo "--- Test 3: Test Vim startup ---"
vim -es -c 'quit' 2>&1 || { echo "FAIL: Vim failed to start"; exit 1; }
echo "PASS: Vim starts and exits cleanly"

# Test 4: Test opening an OCaml file
echo ""
echo "--- Test 4: Test opening OCaml file ---"
cd "$EXAMPLES_DIR/hello"
vim -es hello.ml -c 'quit' 2>&1 || { echo "FAIL: Vim failed to open OCaml file"; exit 1; }
echo "PASS: Vim can open OCaml files"

echo ""
echo "=== Vim tests completed ==="
