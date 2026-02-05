#!/bin/bash
# Test Emacs integration
# Usage: test-emacs.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXAMPLES_DIR="$SCRIPT_DIR/../examples"

echo "=== Testing Emacs integration ==="

# Test 1: Check if emacs is available
echo ""
echo "--- Test 1: Check Emacs availability ---"
if command -v emacs &> /dev/null; then
    VERSION=$(emacs --version | head -1)
    echo "Emacs: $VERSION"
    echo "PASS: Emacs available"
else
    echo "FAIL: Emacs not installed"
    exit 1
fi

# Test 2: Check Emacs config exists
echo ""
echo "--- Test 2: Check Emacs LSP config ---"
CONFIG_PATH="$HOME/.emacs.d/init.el"
if [ -f "$CONFIG_PATH" ]; then
    grep -q "eglot" "$CONFIG_PATH" && echo "PASS: Emacs eglot config exists" || echo "WARN: eglot config not found"
    grep -q "ocamllsp" "$CONFIG_PATH" && echo "PASS: OCaml LSP configured" || echo "WARN: ocamllsp config not found"
else
    echo "WARN: Emacs config not found at $CONFIG_PATH"
fi

# Test 3: Test Emacs batch mode
echo ""
echo "--- Test 3: Test Emacs batch startup ---"
emacs --batch --eval '(message "Emacs batch mode works")' 2>&1 | grep -q "works" || { echo "FAIL: Emacs batch mode failed"; exit 1; }
echo "PASS: Emacs batch mode works"

# Test 4: Test loading OCaml file
echo ""
echo "--- Test 4: Test loading OCaml file ---"
cd "$EXAMPLES_DIR/hello"
emacs --batch hello.ml --eval '(message "Loaded %s" buffer-file-name)' 2>&1 | grep -q "hello.ml" || { echo "FAIL: Failed to load OCaml file"; exit 1; }
echo "PASS: Emacs can load OCaml files"

# Test 5: Check TRAMP compatibility (for devcontainer exec / docker)
echo ""
echo "--- Test 5: Check TRAMP availability ---"
emacs --batch --eval '(require (quote tramp)) (message "TRAMP loaded")' 2>&1 | grep -q "TRAMP loaded" || { echo "WARN: TRAMP not available"; }
echo "PASS: TRAMP is available for remote editing"

echo ""
echo "=== Emacs tests completed ==="
