# Experimental timing setup — incomplete

The preserved [OpenROAD log](../../reports/evidence/timing.log) ends with `ORD-2010: no technology has been read`. This attempt did not produce a completed STA result. No achieved frequency, slack, critical path, timing closure or place-and-route result is claimed.

[sta.tcl](sta.tcl) retains the timing commands, configurable `SKY130_LIB` path, archived SKY130 netlist path and SDC loading. It does not supply the technology/physical setup required to complete the OpenROAD flow and is not a validated launcher.

[constraints.sdc](constraints.sdc) specifies a 10 ns clock period, 0.2 ns clock uncertainty and 1 ns I/O delays. These are input targets; they do not establish operation at 100 MHz.

Completed synthesis evidence belongs to the [Yosys flows](../../reports/synthesis_summary.txt). The reported SKY130 cell area of 23,804.08 µm² does not establish a physical implementation result.
