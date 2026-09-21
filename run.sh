#!/usr/bin/env bash
set -euo pipefail

# Use the caller's installed VCS and license configuration.
repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if ! command -v vcs >/dev/null 2>&1; then
  printf '%s\n' 'VCS was not found. Configure a licensed VCS installation with UVM 1.2 first.' >&2
  exit 127
fi

mode=uvm
compile_args=(-full64 -sverilog -ntb_opts uvm-1.2 -timescale=1ns/1ps
  "+incdir+$repo_dir/rtl" "+incdir+$repo_dir/tb"
  "$repo_dir/rtl/router_top.v" "$repo_dir/tb/testbench.sv")
if [[ "${1:-}" == --sva ]]; then
  mode=uvm-sva
  compile_args+=("$repo_dir/sva/router_assertions.sv")
  shift
fi

mkdir -p "$repo_dir/build/$mode"
cd "$repo_dir/build/$mode"

# router_top includes its RTL children; testbench includes the UVM classes.
# Compiling those included files again would duplicate their definitions.
vcs "${compile_args[@]}" -top testbench -o simv -l compile.log

./simv +UVM_VERBOSITY=UVM_LOW "$@" -l simulation.log

# UVM errors may be printed even when the simulator exits successfully.
if ! grep -Eq 'UVM_ERROR[[:space:]]*:[[:space:]]*0[[:space:]]*$' simulation.log || \
   ! grep -Eq 'UVM_FATAL[[:space:]]*:[[:space:]]*0[[:space:]]*$' simulation.log || \
   grep -Eq '(^|[[:space:]])(Error:|Fatal:)|^[[:space:]]*UVM_(ERROR|FATAL)[[:space:]]+[^[:space:]:]' simulation.log; then
  printf '%s\n' 'Simulation did not report a clean result. Review simulation.log.' >&2
  exit 1
fi
printf 'Simulation completed. Review %s/build/%s/simulation.log\n' "$repo_dir" "$mode"
