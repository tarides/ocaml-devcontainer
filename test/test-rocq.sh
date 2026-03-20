#!/bin/bash
# Test Rocq (formerly Coq) installation
# Usage: test-rocq.sh

set -e

SWITCH="${1:-ocaml}"

echo "=== Testing Rocq installation (switch: $SWITCH) ==="

# Activate the switch
echo "Activating switch $SWITCH..."
opam switch "$SWITCH"
eval $(opam env)

# Test 1: Verify rocq-prover is installed
echo ""
echo "--- Test 1: Verify rocq-prover installed ---"
opam list --installed | grep -q "rocq-prover" || { echo "FAIL: rocq-prover not installed"; exit 1; }
echo "PASS: rocq-prover installed"

# Test 2: Check rocq binary exists
echo ""
echo "--- Test 2: Check rocq binary ---"
command -v rocq &> /dev/null || { echo "FAIL: rocq binary not found"; exit 1; }
echo "  rocq: $(which rocq)"
echo "PASS: rocq binary found"

# Test 3: Check rocq version
echo ""
echo "--- Test 3: Check rocq version ---"
rocq --version
echo "PASS: rocq --version works"

# Test 4: Compile a small Rocq file
echo ""
echo "--- Test 4: Compile a Rocq file ---"
TEMP_DIR=$(mktemp -d)
cat > "$TEMP_DIR/test.v" << 'EOF'
Theorem plus_O_n : forall n : nat, 0 + n = n.
Proof.
  intros n. simpl. reflexivity.
Qed.
EOF
rocq compile "$TEMP_DIR/test.v" || { echo "FAIL: rocq compile failed"; exit 1; }
rm -rf "$TEMP_DIR"
echo "PASS: Rocq compilation works"

echo ""
echo "=== All Rocq tests passed ==="
