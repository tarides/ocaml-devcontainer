#!/bin/bash
# Fix ASLR entropy for TSan-instrumented binaries (OCaml 5.4.0+tsan switch).
# TSan requires vm.mmap_rnd_bits <= 28; modern kernels default to 32.
# See: https://github.com/google/sanitizers/issues/1716

MMAP_RND_BITS=$(cat /proc/sys/vm/mmap_rnd_bits 2>/dev/null || echo 0)
if [ "$MMAP_RND_BITS" -le 28 ]; then
  exit 0
fi

# Method 1: lower the kernel parameter directly (needs writable /proc/sys)
if sudo sysctl -w vm.mmap_rnd_bits=28 >/dev/null 2>&1; then
  echo "TSan ASLR fix: vm.mmap_rnd_bits set to 28 via sysctl"
  exit 0
fi

# Method 2: install a login-shell hook that re-execs under setarch(1)
# to disable ASLR per-process (needs the personality() syscall)
if setarch "$(uname -m)" --addr-no-randomize /bin/true 2>/dev/null; then
  sudo tee /etc/profile.d/fix-tsan-aslr.sh >/dev/null <<'EOF'
# Disable ASLR so ThreadSanitizer-instrumented binaries can run.
# Installed by .devcontainer/fix-tsan-aslr.sh — safe to remove.
if [ -z "$TSAN_ASLR_FIXED" ]; then
  mmap_rnd_bits=$(cat /proc/sys/vm/mmap_rnd_bits 2>/dev/null || echo 0)
  if [ "$mmap_rnd_bits" -gt 28 ]; then
    export TSAN_ASLR_FIXED=1
    exec setarch "$(uname -m)" --addr-no-randomize "$SHELL" -l
  fi
fi
EOF
  echo "TSan ASLR fix: installed /etc/profile.d/fix-tsan-aslr.sh (setarch)"
  exit 0
fi

echo "WARNING: Cannot fix ASLR entropy for TSan (vm.mmap_rnd_bits=$MMAP_RND_BITS)."
echo "The 5.4.0+tsan switch may not work. See: https://github.com/google/sanitizers/issues/1716"
