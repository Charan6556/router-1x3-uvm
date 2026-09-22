# Results and evidence

Cadence Xcelium is the active UVM verification flow; Verilator supplies RTL lint, and Yosys supplies generic synthesis and SKY130 mapping. OpenROAD is experimental and incomplete. The summaries below distinguish recorded results from checks repeated during repository cleanup.

| Summary | Stored evidence | Scope |
|---|---|---|
| [Xcelium UVM + SVA regression](xcelium_sva_regression.txt) | Recorded 2026-09-21 summary; full raw log and original screenshots are not committed | 5,024/5,024 matched, 0 mismatches, all queues empty, 100% defined functional coverage, no observed assertion failures |
| [Functional coverage](functional_coverage.txt) | Xcelium summary and earlier [regression screenshot](evidence/regression.png) | Defined input-packet bins and crosses |
| [Mutation test](mutation_test.txt) | Preserved [mutation screenshot](evidence/mutation.png) | 74 mismatched packets and 2,516 UVM errors; exact mutation source unavailable |
| [Historical regression](regression_summary.txt) | Preserved [regression screenshot](evidence/regression.png) | Earlier VCS run retained for provenance; separate from the Xcelium summary |
| [Lint](lint_summary.txt) | [Original log](evidence/lint.log), [screenshot](evidence/lint.png), [earlier cleanup](evidence/cleanup_lint.log), [final cleanup](evidence/final_lint.log) | Verilator RTL lint: 0 warnings, 0 errors |
| [Synthesis](synthesis_summary.txt) | [Generic log](evidence/synthesis.log), [generic screenshot](evidence/generic_synthesis.png), [SKY130 log](evidence/sky130_synthesis.log), [final generic rerun](evidence/final_synthesis.log) | Yosys synthesis; SKY130 mapped cell area 23,804.08 µm² |
| [SVA and experimental timing status](verification_status.txt) | Xcelium summary and [failed OpenROAD log](evidence/timing.log) | No observed SVA failures in the recorded regression; timing flow incomplete |
| [Final cleanup validation](cleanup_validation.txt) | Source/hash comparison, link checks, shell checks and local lint/generic synthesis | Documentation and supporting-flow validation |

The Xcelium summary records 0 UVM warnings, errors and fatals and reports that a search of the completed run log found no assertion-failure messages. The raw log and seed are not available in this repository, and the final cleanup did not rerun Xcelium. This is recorded simulation evidence, not formal proof or exhaustive assertion coverage.

The mutation and historical passing screenshots identify VCS in their simulator paths. They remain unchanged and are not presented as Xcelium logs. The mutation result establishes detection in that case, not a mutation score across a fault suite.

Earlier Yosys reruns are retained in [cleanup_synthesis.log](evidence/cleanup_synthesis.log) and [cleanup_sky130_synthesis.log](evidence/cleanup_sky130_synthesis.log). Both synthesis flows report limited-tristate-support warnings; SKY130 mapping also emits ABC library/mapping messages. Synthesis is not described as warning-free. Cell area is a synthesis result, with no completed STA, timing closure or place-and-route result.

The [source manifest](source_manifest.csv) records archive-to-repository mappings and original/current hashes. [Evidence checksums](evidence_sha256.txt) cover every stored evidence file. See [preparation notes](../docs/cleanup_notes.md) for source preservation and repository hygiene.
