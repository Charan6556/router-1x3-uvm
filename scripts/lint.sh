#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_dir"
mkdir -p build/lint
# Warnings are fatal here; the archived run used -Wno-fatal and also had zero.
verilator --lint-only -Wall --sv -Irtl rtl/router_top.v \
  --top-module router_top 2>&1 | tee build/lint/lint.log

