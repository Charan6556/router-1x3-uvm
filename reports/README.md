# Results and evidence

Cadence Xcelium is the active UVM verification flow; Verilator supplies RTL lint, and Yosys supplies generic synthesis and SKY130 mapping. OpenROAD is experimental and incomplete. The summaries below distinguish recorded results from checks repeated during repository cleanup.

| Summary | Stored evidence | Scope |
|---|---|---|
| [Xcelium UVM + SVA regression](xcelium_sva_regression.txt) | [Regression screenshot](evidence/xcelium_regression.png), [SVA compilation/elaboration](evidence/xcelium_sva_elaboration.png), [failure-message search](evidence/xcelium_sva_failure_search.png) | 5,024/5,024 matched, 0 mismatches, all queues empty, 100% defined functional coverage, no observed assertion failures |
| [Functional coverage](functional_coverage.txt) | [Xcelium regression screenshot](evidence/xcelium_regression.png) | Defined input-packet bins and crosses |
| [Mutation test](mutation_test.txt) | Preserved [mutation screenshot](evidence/mutation.png) | 74 mismatched packets and 2,516 UVM errors; exact mutation source unavailable |
| [Historical regression](regression_summary.txt) | Preserved [regression screenshot](evidence/regression.png) | Earlier VCS run retained for provenance; separate from the Xcelium summary |
| [Lint](lint_summary.txt) | [Original log](evidence/lint.log), [screenshot](evidence/lint.png), [earlier cleanup](evidence/cleanup_lint.log), [final cleanup](evidence/final_lint.log) | Verilator RTL lint: 0 warnings, 0 errors |
| [Synthesis](synthesis_summary.txt) | [Generic log](evidence/synthesis.log), [generic screenshot](evidence/generic_synthesis.png), [SKY130 log](evidence/sky130_synthesis.log), [final generic rerun](evidence/final_synthesis.log) | Yosys synthesis; SKY130 mapped cell area 23,804.08 µm² |
| [SVA and experimental timing status](verification_status.txt) | [Xcelium SVA screenshots](#xcelium-screenshot-provenance) and [failed OpenROAD log](evidence/timing.log) | No observed SVA failures in the recorded regression; timing flow incomplete |
| [Final cleanup validation](cleanup_validation.txt) | Source/hash comparison, link checks, shell checks and local lint/generic synthesis | Documentation and supporting-flow validation |

The Xcelium regression screenshot shows 0 UVM warnings, errors and fatals. The SVA screenshots show the FIFO/FSM assertion modules and a search of `xcelium_regression.log` for assertion-failure text with no matches displayed. This supports the statement that no assertion failures were observed in the recorded regression. It does not establish formal proof or exhaustive assertion coverage. The full raw log, original launch command and seed remain unavailable; this evidence update did not rerun Xcelium.

## Xcelium screenshot provenance

All three supplied PNGs are stored byte-for-byte without cropping or annotation. Their names below map to the original screenshot filenames dated 2026-09-21.

| Stored screenshot | Original capture time | Visible evidence |
|---|---|---|
| [xcelium_regression.png](evidence/xcelium_regression.png) | 7:11:34 PM | Cadence `XCELIUM2603` installation path, 5,000 random packets completed, 5,024 coverage samples, all eight defined coverage items and total at 100%, 5,024 matched packets, 0 mismatches, all six queues empty, 0 UVM warnings/errors/fatals |
| [xcelium_sva_elaboration.png](evidence/xcelium_sva_elaboration.png) | 7:14:46 PM | `router_assertions.sv`, `worklib.router_fifo_sva`, `worklib.router_fsm_sva`, and 0 UVM errors/fatals in the displayed log search |
| [xcelium_sva_failure_search.png](evidence/xcelium_sva_failure_search.png) | 7:17:33 PM | Assertion-failure searches against `xcelium_regression.log` return to the prompt without matches |

The exact simulator version banner is not visible. The cropped `Assertions` row has no column headings, so its numbers are not interpreted as pass/fail totals or coverage results.

## Other evidence

The mutation and historical passing screenshots identify VCS in their simulator paths. They remain unchanged and are not presented as Xcelium logs. The mutation result establishes detection in that case, not a mutation score across a fault suite.

Earlier Yosys reruns are retained in [cleanup_synthesis.log](evidence/cleanup_synthesis.log) and [cleanup_sky130_synthesis.log](evidence/cleanup_sky130_synthesis.log). Both synthesis flows report limited-tristate-support warnings; SKY130 mapping also emits ABC library/mapping messages. Synthesis is not described as warning-free. Cell area is a synthesis result, with no completed STA, timing closure or place-and-route result.

The [source manifest](source_manifest.csv) records archive-to-repository mappings and original/current hashes. [Evidence checksums](evidence_sha256.txt) cover every stored evidence file. See [preparation notes](../docs/cleanup_notes.md) for source preservation and repository hygiene.
