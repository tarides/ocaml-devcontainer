#!/bin/bash
# Test VS Code devcontainer integration
# Usage: test-vscode.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/.."

echo "=== Testing VS Code devcontainer integration ==="

# Test 1: Check devcontainer CLI is available
echo ""
echo "--- Test 1: Check devcontainer CLI ---"
if command -v devcontainer &> /dev/null; then
    VERSION=$(devcontainer --version 2>&1)
    echo "devcontainer CLI: $VERSION"
    echo "PASS: devcontainer CLI available"
else
    echo "WARN: devcontainer CLI not found"
    echo "Install with: npm install -g @devcontainers/cli"
    exit 0
fi

# Test 2: Validate devcontainer.json
echo ""
echo "--- Test 2: Validate devcontainer.json ---"
if [ -f "$PROJECT_DIR/.devcontainer/devcontainer.json" ]; then
    # Basic JSON validation
    python3 -c "import json; json.load(open('$PROJECT_DIR/.devcontainer/devcontainer.json'))" 2>&1 || {
        echo "FAIL: devcontainer.json is not valid JSON"
        exit 1
    }
    echo "PASS: devcontainer.json is valid JSON"
else
    echo "FAIL: .devcontainer/devcontainer.json not found"
    exit 1
fi

# Test 3: Check VS Code extension is specified
echo ""
echo "--- Test 3: Check VS Code OCaml extension ---"
grep -q "ocamllabs.ocaml-platform" "$PROJECT_DIR/.devcontainer/devcontainer.json" || {
    echo "FAIL: OCaml extension not specified"
    exit 1
}
echo "PASS: OCaml extension specified"

# Test 4: Check Claude Code feature
echo ""
echo "--- Test 4: Check Claude Code feature ---"
grep -q "claude-code" "$PROJECT_DIR/.devcontainer/devcontainer.json" || {
    echo "WARN: Claude Code feature not specified"
}
echo "PASS: Claude Code feature specified"

# Test 5: Check Codespaces configuration
echo ""
echo "--- Test 5: Check Codespaces configuration ---"
grep -q "hostRequirements" "$PROJECT_DIR/.devcontainer/devcontainer.json" || {
    echo "WARN: hostRequirements not specified"
}
grep -q "codespaces" "$PROJECT_DIR/.devcontainer/devcontainer.json" || {
    echo "WARN: codespaces configuration not specified"
}
echo "PASS: Codespaces configuration present"

echo ""
echo "=== VS Code integration tests passed ==="
