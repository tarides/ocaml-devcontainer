#!/bin/bash
# Test OCaml compiler and tools installation
# Usage: test-ocaml.sh [switch]
# Default switch: 5.4.0

set -e

SWITCH="${1:-5.4.0}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXAMPLES_DIR="$SCRIPT_DIR/../examples"

echo "=== Testing OCaml switch: $SWITCH ==="

# Activate the switch
echo "Activating switch $SWITCH..."
opam switch "$SWITCH"
eval $(opam env)

# Test 1: Verify switch exists
echo ""
echo "--- Test 1: Verify switch exists ---"
opam switch list | grep -q "$SWITCH" || { echo "FAIL: Switch $SWITCH not found"; exit 1; }
echo "PASS: Switch $SWITCH exists"

# Test 2: Check compiler version
echo ""
echo "--- Test 2: Check compiler version ---"
VERSION=$(ocaml -version)
echo "OCaml version: $VERSION"
echo "$VERSION" | grep -q "5.4" || { echo "FAIL: Expected OCaml 5.4.x"; exit 1; }
echo "PASS: OCaml 5.4.x installed"

# Test 3: Compile sample program with ocamlopt
echo ""
echo "--- Test 3: Compile with ocamlopt ---"
TEMP_DIR=$(mktemp -d)
cat > "$TEMP_DIR/hello.ml" << 'EOF'
let () = print_endline "Hello from ocamlopt!"
EOF
ocamlopt -o "$TEMP_DIR/hello" "$TEMP_DIR/hello.ml"
OUTPUT=$("$TEMP_DIR/hello")
[ "$OUTPUT" = "Hello from ocamlopt!" ] || { echo "FAIL: Unexpected output: $OUTPUT"; exit 1; }
rm -rf "$TEMP_DIR"
echo "PASS: ocamlopt compilation works"

# Test 4: Build with dune
echo ""
echo "--- Test 4: Build with dune ---"
cd "$EXAMPLES_DIR/hello"
dune clean
dune build
OUTPUT=$(dune exec ./hello.exe)
echo "$OUTPUT" | grep -q "Hello" || { echo "FAIL: dune build/exec failed"; exit 1; }
echo "PASS: dune build works"

# Test 5: Run tests with dune
echo ""
echo "--- Test 5: Run tests with dune ---"
cd "$EXAMPLES_DIR/with-tests"
dune clean
dune runtest
echo "PASS: dune runtest works"

# Test 6: Verify all tools present
echo ""
echo "--- Test 6: Verify tools installed ---"
TOOLS="ocamlformat utop merlin ocamllsp odoc"
for tool in $TOOLS; do
    if command -v "$tool" &> /dev/null; then
        echo "  $tool: $(which $tool)"
    else
        echo "FAIL: $tool not found"
        exit 1
    fi
done
echo "PASS: All tools installed"

# Test 7: Verify testing tools
echo ""
echo "--- Test 7: Verify testing tools ---"
# Check that ppx packages are installed by looking for them in opam
opam list --installed | grep -q "ppx_inline_test" || { echo "FAIL: ppx_inline_test not installed"; exit 1; }
opam list --installed | grep -q "ppx_expect" || { echo "FAIL: ppx_expect not installed"; exit 1; }
opam list --installed | grep -q "qcheck" || { echo "FAIL: qcheck not installed"; exit 1; }
opam list --installed | grep -q "ounit2" || { echo "FAIL: ounit2 not installed"; exit 1; }
echo "PASS: Testing tools installed"

# Test 8: Verify profiling tools
echo ""
echo "--- Test 8: Verify profiling tools ---"
opam list --installed | grep -q "landmarks" || { echo "FAIL: landmarks not installed"; exit 1; }
opam list --installed | grep -q "memtrace" || { echo "FAIL: memtrace not installed"; exit 1; }
opam list --installed | grep -q "olly" || { echo "FAIL: olly not installed"; exit 1; }
opam list --installed | grep -q "bisect_ppx" || { echo "FAIL: bisect_ppx not installed"; exit 1; }
echo "PASS: Profiling tools installed"

echo ""
echo "=== All tests passed for switch $SWITCH ==="
