#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if ! command -v xrun >/dev/null 2>&1; then
  printf '%s\n' 'Xcelium xrun was not found. Configure a licensed Cadence Xcelium installation with UVM support first.' >&2
  exit 127
fi

# Accept the former explicit SVA switch; assertions are now included by default.
if [[ "${1:-}" == --sva ]]; then
  shift
fi

mkdir -p "$repo_dir/build/xcelium"
cd "$repo_dir/build/xcelium"
# Do not let an incomplete run reuse an earlier clean summary.
: > simulation.log

# router_top includes its RTL children; testbench includes the UVM classes.
# Compile each top-level source once, with coverage and bound SVA enabled.
xrun -64bit -sv -uvm -timescale 1ns/1ps \
  -access +rwc -coverage all -covoverwrite \
  -incdir "$repo_dir/rtl" -incdir "$repo_dir/tb" \
  "$repo_dir/rtl/router_top.v" \
  "$repo_dir/sva/router_assertions.sv" \
  "$repo_dir/tb/testbench.sv" \
  -top testbench +UVM_VERBOSITY=UVM_LOW "$@" -l simulation.log

# UVM and assertion errors may be printed even when the simulator exits zero.
if ! grep -Eq 'UVM_ERROR[[:space:]]*:[[:space:]]*0[[:space:]]*$' simulation.log || \
   ! grep -Eq 'UVM_FATAL[[:space:]]*:[[:space:]]*0[[:space:]]*$' simulation.log || \
   grep -Eq '\*[EF],|(^|[[:space:]])(Error:|Fatal:)|^[[:space:]]*UVM_(ERROR|FATAL)[[:space:]]+[^[:space:]:]' simulation.log || \
   grep -Eiq 'fifo (full and empty high|reset failed|soft reset failed|full changed without read|empty changed without write)|busy (high in decode state|low in load first data state|low in fifo full state)' simulation.log; then
  printf '%s\n' 'Simulation did not report a clean result. Review simulation.log.' >&2
  exit 1
fi
printf 'Simulation completed. Review %s/build/xcelium/simulation.log for scoreboard, coverage and assertion results.\n' "$repo_dir"
