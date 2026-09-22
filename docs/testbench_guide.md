# Reading the testbench

Use the [UVM architecture](uvm_architecture.png) alongside this guide. Cadence Xcelium is the active UVM, scoreboard, functional-coverage and SVA flow; see the [run instructions](../README.md#run-the-project) and [recorded results](../reports/README.md).

The comments follow the existing short, lowercase `//comment` style. They explain intent around the less obvious code without changing the RTL or testbench behavior.

| Start here | What to look for |
|---|---|
| [testbench.sv](../tb/testbench.sv) | Clock/reset, DUT connections, include order and virtual-interface configuration |
| [environment.sv](../tb/environment.sv) | Agent creation, virtual-sequencer handles and monitor analysis connections |
| [virtual_sequence.sv](../tb/virtual_sequence.sv) | Directed coverage combinations, boundary cases, random stress and concurrent writer/reader startup |
| [write_xtn.sv](../tb/write_xtn.sv) and [router_sequences.sv](../tb/router_sequences.sv) | Header constraints, payload allocation, parity generation and controlled error injection |
| [interface.sv](../tb/interface.sv) | Falling-edge driving, rising-edge monitoring and clocking-block skews |
| [write_monitor.sv](../tb/write_monitor.sv) and [read_monitor1.sv](../tb/read_monitor1.sv) | Packet reconstruction from observed signals and registered FIFO read timing |
| [scoreboard.sv](../tb/scoreboard.sv) | Per-destination matching, byte comparisons and end-of-test accounting |
| [functional_coverage.sv](../tb/functional_coverage.sv) | Input-packet bins, boundary lengths and crossed combinations |

## Why both expected and actual queues exist

Analysis callbacks run when a monitor has assembled a whole packet. Input and output monitors do not have to finish in the same order. If the expected packet arrives first, the scoreboard stores it in that destination's expected queue. If the actual packet arrives first, it stores it in the actual queue. The second arrival pairs with the oldest queued packet for that output.

This preserves order within a destination without requiring a fixed input-to-output latency. Each monitor creates a new transaction object for every packet, so saving the object handle does not overwrite a previously queued packet on the next collection.

## Why the read monitor waits an extra edge

The FIFO updates `data_out` in a rising-edge sequential block. The read monitor's clocking block samples before the rising edge. After detecting a read, the monitor waits until the next clocking event to observe the registered header. It then collects the encoded number of payload bytes and one parity byte. This implementation assumes those subsequent bytes arrive continuously.

## Why a bad-parity packet can still match

The transaction computes the XOR parity and optionally flips bit 0. The write monitor independently classifies the observed parity as normal or erroneous. The scoreboard checks whether the same packet bytes emerge at the selected output, including the deliberately incorrect parity byte. A match establishes correct forwarding for those bytes; it does not establish correct DUT error-pin behavior.

## Why coverage and checking are separate

Coverage samples the input stream, while the scoreboard compares input and output packets. Therefore coverage can reach 100% even in a failing mutation test. Coverage shows which defined scenarios were observed; the scoreboard determines whether the observed routed packets matched.

## Why packet errors and UVM errors differ

One packet may have many incorrect bytes and produce multiple UVM error messages. `mismatch_count` increments once per compared packet. The recorded mutation result therefore contains 74 mismatched packets and 2,516 UVM errors without contradiction.

