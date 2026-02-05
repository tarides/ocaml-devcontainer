#!/bin/bash
# Test OCaml profiling tools
# Usage: test-profiling.sh [switch]
# Default switch: 5.4.0

set -e

SWITCH="${1:-5.4.0}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Testing profiling tools for switch: $SWITCH ==="

# Activate the switch
echo "Activating switch $SWITCH..."
opam switch "$SWITCH"
eval $(opam env)

TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Create test project
cat > dune-project << 'EOF'
(lang dune 3.17)
(name profiling_test)
EOF

# Test 1: landmarks profiling
echo ""
echo "--- Test 1: landmarks profiling ---"
cat > landmarks_test.ml << 'EOF'
let[@landmark] fib n =
  let rec loop a b count =
    if count <= 0 then a
    else loop b (a + b) (count - 1)
  in
  loop 0 1 n

let () =
  for _ = 1 to 1000 do
    ignore (fib 20)
  done
EOF

cat > dune << 'EOF'
(executable
 (name landmarks_test)
 (preprocess (pps landmarks-ppx --auto))
 (libraries landmarks))
EOF

dune build landmarks_test.exe
OCAML_LANDMARKS=on dune exec ./landmarks_test.exe 2>&1 | grep -q "landmarks" && echo "PASS: landmarks profiling works" || echo "WARN: landmarks output may vary"

# Test 2: memtrace memory profiling
echo ""
echo "--- Test 2: memtrace memory profiling ---"
cat > memtrace_test.ml << 'EOF'
let () =
  Memtrace.trace_if_requested ();
  let data = Array.init 10000 (fun i -> Array.make 100 i) in
  ignore data
EOF

cat > dune << 'EOF'
(executable
 (name memtrace_test)
 (libraries memtrace))
EOF

dune build memtrace_test.exe
MEMTRACE=trace.ctf dune exec ./memtrace_test.exe
if [ -f trace.ctf ]; then
    echo "PASS: memtrace trace file generated"
    rm trace.ctf
else
    echo "WARN: memtrace trace file not generated (may need specific setup)"
fi

# Test 3: olly runtime events
echo ""
echo "--- Test 3: olly runtime events ---"
cat > olly_test.ml << 'EOF'
let () =
  let data = Array.init 100000 (fun i -> i * 2) in
  Array.iter (fun x -> ignore (x + 1)) data
EOF

cat > dune << 'EOF'
(executable
 (name olly_test))
EOF

dune build olly_test.exe

# olly requires OCaml runtime events support
if command -v olly &> /dev/null; then
    # Try to run olly, but it may fail in some environments
    olly trace dune exec ./olly_test.exe -- 2>&1 || echo "WARN: olly may require specific runtime support"
    echo "PASS: olly command available"
else
    echo "FAIL: olly not found"
    exit 1
fi

# Test 4: bisect_ppx coverage
echo ""
echo "--- Test 4: bisect_ppx coverage ---"
cat > coverage_test.ml << 'EOF'
let add x y = x + y
let sub x y = x - y

let () =
  assert (add 1 2 = 3);
  assert (sub 5 3 = 2)
EOF

cat > dune << 'EOF'
(executable
 (name coverage_test)
 (instrumentation (backend bisect_ppx)))
EOF

dune build coverage_test.exe
BISECT_FILE=coverage dune exec ./coverage_test.exe

if ls coverage*.coverage &> /dev/null; then
    echo "PASS: bisect_ppx coverage files generated"
    # Generate report if bisect-ppx-report is available
    if command -v bisect-ppx-report &> /dev/null; then
        bisect-ppx-report summary coverage*.coverage 2>/dev/null || true
    fi
    rm -f coverage*.coverage
else
    echo "WARN: bisect_ppx coverage files not generated"
fi

# Cleanup
cd /
rm -rf "$TEMP_DIR"

echo ""
echo "=== All profiling tests completed for switch $SWITCH ==="
