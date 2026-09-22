# Architecture and testbench guide

Both architecture figures are included at their final paths and displayed in the root README. The supplied PNGs are preserved at their original resolution.

| Figure | What it shows |
|---|---|
| [Router architecture](router_architecture.png) | FSM, register, synchronizer, three output FIFOs and their data/control/status connections through `router_top` |
| [UVM architecture](uvm_architecture.png) | Test/environment hierarchy, virtual sequence and sequencer, active agents, interface/DUT, monitor analysis connections, scoreboard, coverage and bound assertions |

The router diagram follows [router_top.v](../rtl/router_top.v). All three FIFO data inputs receive `router_reg.dout`; destination selection controls the FIFO write enables. `router_sync` produces output-valid and timeout-reset signals.

The UVM diagram follows [testbench.sv](../tb/testbench.sv) and [environment.sv](../tb/environment.sv). Read agents 1, 2 and 3 service outputs 0, 1 and 2 respectively. The virtual sequencer holds agent-sequencer handles. Monitor analysis ports feed the scoreboard, and the write monitor also feeds functional coverage.

The clock period shown is the simulation stimulus. The SVA annotation refers to the [recorded Xcelium regression](../reports/xcelium_sva_regression.txt); neither figure establishes timing closure or exhaustive verification.

Continue with the [testbench reading guide](testbench_guide.md), [evidence index](../reports/README.md), or [repository preparation notes](cleanup_notes.md).
