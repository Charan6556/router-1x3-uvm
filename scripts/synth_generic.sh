#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_dir"
mkdir -p build/generic
yosys -l build/generic/synthesis.log -s synthesis/synth.ys

