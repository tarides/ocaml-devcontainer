#!/bin/bash
# Test OxCaml switch: compiler, packages, and language features
# Usage: test-oxcaml-switch.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Testing OxCaml switch ==="

# Activate the oxcaml switch
echo "Activating switch oxcaml..."
opam switch oxcaml
eval $(opam env)

# Test 1: Verify oxcaml switch exists
echo ""
echo "--- Test 1: Verify oxcaml switch exists ---"
opam switch list | grep -q "oxcaml" || { echo "FAIL: Switch oxcaml not found"; exit 1; }
echo "PASS: oxcaml switch exists"

# Test 2: Verify oxcaml compiler version (5.2.x)
echo ""
echo "--- Test 2: Check OxCaml compiler version ---"
VERSION=$(ocaml -version)
echo "OxCaml version: $VERSION"
echo "$VERSION" | grep -q "5.2" || { echo "FAIL: Expected OxCaml 5.2.x"; exit 1; }
echo "PASS: OxCaml 5.2.x installed"

# Test 3: Verify oxcaml-specific packages
echo ""
echo "--- Test 3: Verify OxCaml packages ---"
opam list --installed | grep -q "await" || { echo "FAIL: await not installed"; exit 1; }
opam list --installed | grep -q "parallel" || { echo "FAIL: parallel not installed"; exit 1; }
echo "PASS: OxCaml-specific packages installed"

# Test 4: Compile with ocamlopt
echo ""
echo "--- Test 4: Compile with ocamlopt ---"
TEMP_DIR=$(mktemp -d)
cat > "$TEMP_DIR/hello.ml" << 'EOF'
let () = print_endline "Hello from OxCaml!"
EOF
ocamlopt -o "$TEMP_DIR/hello" "$TEMP_DIR/hello.ml"
OUTPUT=$("$TEMP_DIR/hello")
[ "$OUTPUT" = "Hello from OxCaml!" ] || { echo "FAIL: Unexpected output: $OUTPUT"; exit 1; }
rm -rf "$TEMP_DIR"
echo "PASS: ocamlopt compilation works"

# Test 5: Compile a program using local_ allocations
echo ""
echo "--- Test 5: OxCaml local_ allocations ---"
TEMP_DIR=$(mktemp -d)
cat > "$TEMP_DIR/dune-project" << 'EOF'
(lang dune 3.17)
EOF

cat > "$TEMP_DIR/dune" << 'EOF'
(executable (name local_test))
EOF

cat > "$TEMP_DIR/local_test.ml" << 'EOF'
(* Test local_ allocations — an OxCaml feature *)
let[@inline never] use_local () =
  let local_ pair = (1, 2) in
  let (a, b) = pair in
  a + b

let () =
  let result = use_local () in
  Printf.printf "result = %d\n" result;
  assert (result = 3);
  print_endline "PASS: local_ allocations work"
EOF

cd "$TEMP_DIR"
dune build
OUTPUT=$(dune exec ./local_test.exe)
echo "$OUTPUT" | grep -q "PASS" || { echo "FAIL: local_ allocation test failed"; echo "$OUTPUT"; exit 1; }
cd /
rm -rf "$TEMP_DIR"
echo "PASS: OxCaml local_ allocations compile and run"

# Test 6: Verify platform tools
echo ""
echo "--- Test 6: Verify tools installed ---"
# utop and odoc don't compile with OxCaml yet
TOOLS="ocamlmerlin ocamllsp"
for tool in $TOOLS; do
    if command -v "$tool" &> /dev/null; then
        echo "  $tool: $(which $tool)"
    else
        echo "FAIL: $tool not found"
        exit 1
    fi
done
echo "PASS: Platform tools installed"

# Test 7: Verify oxcaml is the default switch
echo ""
echo "--- Test 7: Verify default switch ---"
DEFAULT=$(opam switch show)
[ "$DEFAULT" = "oxcaml" ] || { echo "FAIL: Default switch is $DEFAULT, expected oxcaml"; exit 1; }
echo "PASS: oxcaml is the default switch"

echo ""
echo "=== All OxCaml tests passed ==="
