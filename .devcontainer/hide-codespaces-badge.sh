#!/bin/bash
# Hide the "Open in GitHub Codespaces" badge when running in Codespaces
# This prevents the confusing/useless button from appearing

if [ "$GITHUB_CODESPACES" = "true" ]; then
  # Comment out the badge line in README.md if not already commented
  if grep -q "^\[!\[Open in GitHub Codespaces\]" README.md 2>/dev/null; then
    sed -i '/^\[!\[Open in GitHub Codespaces\]/s/^/<!-- /' README.md
    sed -i '/^\[!\[Open in GitHub Codespaces\]/s/$/ -->/' README.md
  fi
fi
