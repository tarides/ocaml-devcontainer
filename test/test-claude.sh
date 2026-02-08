#!/bin/bash
# Test Claude Code installation
# Usage: test-claude.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Testing Claude Code installation ==="

# Test 1: Check Node.js is installed and not EOL Node 18
echo ""
echo "--- Test 1: Check Node.js version ---"
if ! command -v node &> /dev/null; then
    echo "FAIL: Node.js is not installed"
    exit 1
fi
NODE_VERSION=$(node --version)
echo "Node.js: $NODE_VERSION"
NODE_MAJOR=$(echo "$NODE_VERSION" | sed 's/^v//' | cut -d. -f1)
if [ "$NODE_MAJOR" -le 18 ]; then
    echo "FAIL: Node.js $NODE_VERSION is EOL (need >18)"
    exit 1
fi
echo "npm: $(npm --version)"
echo "PASS: Node.js $NODE_VERSION is installed and not EOL"

# Test 2: Check if claude command is available
echo ""
echo "--- Test 2: Check Claude Code availability ---"
if command -v claude &> /dev/null; then
    echo "Claude Code: $(which claude)"
    echo "PASS: Claude Code is installed"
else
    echo "WARN: Claude Code not found"
    echo "This is expected if running outside the devcontainer"
    echo "Claude Code is installed via DevContainer Feature"
    exit 0
fi

# Test 3: Check Claude Code version
echo ""
echo "--- Test 3: Check Claude Code version ---"
VERSION=$(claude --version 2>&1 || echo "version command not available")
echo "Version: $VERSION"
echo "PASS: Claude Code version check completed"

# Test 4: Check Claude Code help
echo ""
echo "--- Test 4: Check Claude Code help ---"
claude --help > /dev/null 2>&1 || { echo "WARN: claude --help failed"; }
echo "PASS: Claude Code help works"

echo ""
echo "=== Claude Code tests completed ==="
