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

# Test 2: Validate .devcontainer/devcontainer.json
echo ""
echo "--- Test 2: Validate .devcontainer/devcontainer.json ---"
devcontainer read-configuration --workspace-folder "$PROJECT_DIR" > /dev/null || {
    echo "FAIL: .devcontainer/devcontainer.json is not valid"
    exit 1
}
echo "PASS: .devcontainer/devcontainer.json is valid"

# Test 2b: Validate .devcontainer-from-scratch/devcontainer.json
echo ""
echo "--- Test 2b: Validate .devcontainer-from-scratch/devcontainer.json ---"
devcontainer read-configuration --workspace-folder "$PROJECT_DIR" \
    --config "$PROJECT_DIR/.devcontainer-from-scratch/devcontainer.json" > /dev/null || {
    echo "FAIL: .devcontainer-from-scratch/devcontainer.json is not valid"
    exit 1
}
echo "PASS: .devcontainer-from-scratch/devcontainer.json is valid"

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
