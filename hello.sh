#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./hello.sh        -> prints "Hello, there!"
#   ./hello.sh Alice  -> prints "Hello, Alice!"
name="${1:-there}"
echo "Hello, $name!"