# Architecture figures

The README currently describes both architectures in text. These image files are intentionally pending; no broken image links are displayed.

| Planned file | Content to show |
|---|---|
| `router_architecture.png` | Input data into `router_reg`, register data into three FIFOs, FSM control, destination selection and timeout logic in `router_sync`, plus the three output ports |
| `uvm_architecture.png` | Test/environment, virtual sequence and sequencer, one write agent, three read agents, DUT/interface, scoreboard, and coverage subscriber |

For the router diagram, distinguish data paths from control/status connections. The RTL blocks are connected through `router_top`; they are not a simple serial chain.

For the UVM diagram, show sequence traffic toward drivers, monitor analysis traffic toward the scoreboard, and a separate connection from the write monitor to coverage. Label read agent 1 as output 0, read agent 2 as output 1, and read agent 3 as output 2.

After adding the images, replace each README placeholder with its commented Markdown image line. SVG files may be used instead if the filenames and links are updated together.

