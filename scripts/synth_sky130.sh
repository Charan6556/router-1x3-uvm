#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
: "${SKY130_LIB:?Set SKY130_LIB to the full path of sky130_fd_sc_hd__tt_025C_1v80.lib}"
if [[ "$SKY130_LIB" != /* || ! -f "$SKY130_LIB" ]]; then
  printf '%s\n' 'SKY130_LIB must be an absolute path to an existing Liberty file.' >&2
  exit 1
fi
cd "$repo_dir"
mkdir -p build/sky130
# A local build copy avoids embedding a personal PDK path in the Yosys script.
cp -- "$SKY130_LIB" build/sky130/sky130.lib
yosys -l build/sky130/sky130_synthesis.log -s synthesis/synth_sky130.ys

