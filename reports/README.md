# Results and evidence

Results below are traceable to the uploaded ZIP, supplied screenshots, or explicit cleanup reruns. Summaries are transcriptions or interpretations, not fabricated simulator logs.

| Summary | Primary evidence | Status |
|---|---|---|
| [Regression](regression_summary.txt) | [regression.png](evidence/regression.png), supplied 2026-09-20 9:46:28 PM screenshot | Historical result; UVM not rerun during cleanup |
| [Functional coverage](functional_coverage.txt) | Same regression screenshot | Defined input-packet model only |
| [Mutation test](mutation_test.txt) | [mutation.png](evidence/mutation.png), supplied 2026-09-20 9:38:39 PM screenshot | Historical failure evidence; mutated source unavailable |
| [Lint](lint_summary.txt) | [lint.log](evidence/lint.log), [lint.png](evidence/lint.png), [cleanup_lint.log](evidence/cleanup_lint.log) | Archived result and cleanup rerun |
| [Synthesis](synthesis_summary.txt) | [synthesis.log](evidence/synthesis.log), [sky130_synthesis.log](evidence/sky130_synthesis.log), [generic_synthesis.png](evidence/generic_synthesis.png) | Archived results and cleanup reruns |
| [SVA and timing](verification_status.txt) | Source inspection and [timing.log](evidence/timing.log) | SVA execution unverified; timing attempt failed |
| [Cleanup validation](cleanup_validation.txt) | Source comparison, local lint and synthesis checks | Repository preparation checks |

`evidence/cleanup_synthesis.log` and `evidence/cleanup_sky130_synthesis.log` preserve the synthesis reruns. The supplied screenshots were copied without editing. The four original logs were preserved byte-for-byte. The screenshot showing synthesis contains two Yosys warnings; it is not evidence of warning-free synthesis.

`source_manifest.csv` records the archive-to-repository file mapping and SHA-256 hashes for retained project files. `evidence_sha256.txt` records the evidence-file hashes. See [cleanup notes](../docs/cleanup_notes.md) for omitted generated files and path changes.

