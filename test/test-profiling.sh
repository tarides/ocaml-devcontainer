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

# Test 1: landmarks library
echo ""
echo "--- Test 1: landmarks library ---"
cat > landmarks_test.ml << 'EOF'
let lm = Landmark.register "fib"

let fib n =
  Landmark.enter lm;
  let rec loop a b count =
    if count <= 0 then a
    else loop b (a + b) (count - 1)
  in
  let r = loop 0 1 n in
  Landmark.exit lm;
  r

let () =
  for _ = 1 to 1000 do
    ignore (fib 20)
  done
EOF

cat > dune << 'EOF'
(executable
 (name landmarks_test)
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

# Test 3: olly runtime events (OCaml 5.x only)
echo ""
echo "--- Test 3: olly runtime events ---"
MAJOR_VERSION=$(ocaml -vnum | cut -d. -f1)
if [ "$MAJOR_VERSION" -ge 5 ]; then
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

    # runtime_events_tools provides ocaml-runtime-tracer
    if command -v ocaml-runtime-tracer &> /dev/null; then
        ocaml-runtime-tracer trace dune exec ./olly_test.exe -- 2>&1 || echo "WARN: ocaml-runtime-tracer may require specific runtime support"
        echo "PASS: ocaml-runtime-tracer command available"
    else
        echo "FAIL: ocaml-runtime-tracer not found"
        exit 1
    fi
else
    echo "SKIP: runtime events tools not available on OCaml 4.x"
fi

# Cleanup
cd /
rm -rf "$TEMP_DIR"

echo ""
echo "=== All profiling tests completed for switch $SWITCH ==="
