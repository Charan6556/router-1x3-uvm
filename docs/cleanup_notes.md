# Repository preparation and final cleanup

The project was originally imported from `uvm_router.zip`. The [source manifest](../reports/source_manifest.csv) maps retained files to archive paths and records original and current SHA-256 hashes. The [archive inventory](../reports/archive_inventory.csv) records the disposition of every archive entry; it is provenance, not a list of files currently in the repository.

## Preserved source and evidence

Final cleanup leaves all five RTL files, all 27 UVM/testbench files, the SVA file, both archived synthesis netlists and the SDC constraints byte-for-byte unchanged from the starting `main` commit `9c1a8c1`. Earlier import work added explanatory comments to 19 testbench files. The original evidence screenshots and logs, including earlier cleanup logs, remain unchanged.

The two latest supplied architecture PNGs replace/add `docs/uvm_architecture.png` and `docs/router_architecture.png` without image editing. Both are linked from the README and the [architecture guide](README.md).

## Tool flow

- Cadence Xcelium is the active UVM, scoreboard, functional-coverage and SVA flow. `run.sh` includes coverage and bound assertions by default and writes generated products under `build/xcelium/`. Shell checks do not establish a new simulator result.
- Mutation-test evidence demonstrates checker detection in the supplied failing case. Its historical simulator provenance is retained in the [mutation report](../reports/mutation_test.txt); the exact mutation source, seed and full log are unavailable.
- Verilator performs RTL lint with warnings treated as failures.
- Yosys performs generic synthesis and SKY130 HD technology mapping. `SKY130_LIB` selects an external Liberty file. Repeated flows write under `build/`, preserving the archived netlists.
- OpenROAD work remains experimental and incomplete. The [experimental setup](../synthesis/experimental/README.md) documents the failed attempt and input constraints; there is no completed STA, timing closure or place-and-route result.

## Repository hygiene

Generated simulator products, coverage databases, waveforms, machine-specific configuration, editor backups and macOS metadata are excluded by `.gitignore`. Figure planning text and obsolete run instructions have been removed. Report logs, screenshots and provenance manifests are retained because they support the published results.

See [final cleanup validation](../reports/cleanup_validation.txt) for local checks and [results and evidence](../reports/README.md) for the distinction between recorded runs and current local validation.
