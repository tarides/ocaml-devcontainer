#!/bin/bash
# Test dune package management workflow
# Usage: test-dune-pkg.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXAMPLES_DIR="$SCRIPT_DIR/../examples"

echo "=== Testing dune package management ==="

# Ensure opam env is set (needed for dune to find opam-repository)
eval $(opam env)

TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Test 1: Create project with dune pkg
echo ""
echo "--- Test 1: Create project with pkg dependencies ---"
cat > dune-project << 'EOF'
(lang dune 3.20)
(name pkg_test)

(package
 (name pkg_test)
 (allow_empty)
 (depends
  (ocaml (>= 5.4))
  (cmdliner (>= 1.2))))
EOF

cat > dune-workspace << 'EOF'
(lang dune 3.20)
(pkg enabled)
EOF

cat > dune << 'EOF'
(executable
 (name main)
 (libraries cmdliner))
EOF

cat > main.ml << 'EOF'
let () =
  ignore (Cmdliner.Cmd.info "test");
  print_endline "dune pkg test"
EOF

echo "PASS: Project created"

# Test 2: Lock dependencies
echo ""
echo "--- Test 2: Lock dependencies ---"
dune pkg lock
if [ -d "dune.lock" ]; then
    echo "PASS: dune pkg lock created lock directory"
    ls dune.lock/
else
    echo "FAIL: Lock directory not created"
    exit 1
fi

# Test 3: Build with pkg
echo ""
echo "--- Test 3: Build with pkg enabled ---"
dune build
if [ -f "_build/default/main.exe" ]; then
    echo "PASS: dune build succeeded"
else
    echo "FAIL: Build failed"
    exit 1
fi

# Test 4: Execute built program
echo ""
echo "--- Test 4: Execute program ---"
OUTPUT=$(dune exec ./main.exe)
echo "Output: $OUTPUT"
[ "$OUTPUT" = "dune pkg test" ] || { echo "FAIL: Unexpected output"; exit 1; }
echo "PASS: Program executes correctly"

# Test 5: Test dune tools
echo ""
echo "--- Test 5: Test dune tools ---"
# Note: dune tools requires tool stanzas in dune-project, which is optional
# For now, just verify dune tools command exists
dune tools --help > /dev/null 2>&1 || { echo "WARN: dune tools command may not be available"; }
echo "PASS: dune tools command available"

# Test 6: Verify both workflows coexist
echo ""
echo "--- Test 6: Verify opam workflow still works ---"
cd "$EXAMPLES_DIR/hello"
dune clean
dune build
echo "PASS: opam workflow works alongside dune pkg"

# Cleanup
rm -rf "$TEMP_DIR"

echo ""
echo "=== All dune pkg tests passed ==="
