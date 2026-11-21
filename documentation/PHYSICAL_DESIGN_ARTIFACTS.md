# Physical-Design Artifact Manifest

**Design:** `soc_top_sram`
**Platform:** SKY130 HD
**Retained candidate:** Accelerator write-decode
**Status:** Placement completed; timing closure and signoff incomplete.

## 1. Retained local implementation artifacts

The following generated files are preserved locally under `physical_design/results/` and excluded from Git to avoid committing large binary and intermediate implementation files.

| Artifact | Description |
|---|---|
| `soc_top_sram_accel_write_decode_pdn_cut.odb` | OpenROAD database after PDN and row-cut implementation |
| `soc_top_sram_accel_write_decode_pdn_cut.def` | DEF representation after PDN and row-cut implementation |
| `soc_top_sram_accel_write_decode_placed.odb` | Retained placed OpenROAD database |
| `soc_top_sram_accel_write_decode_placed.def` | Retained placed DEF |

These files are local implementation outputs. They are not routed or signoff GDS deliverables.

## 2. Source-controlled physical-design scripts

The `physical_design/scripts/` directory contains the Tcl and Python scripts used for:

- Design inspection and macro discovery.
- SRAM macro floorplanning.
- PDN generation and connectivity checks.
- Standard-cell row cutting.
- Placement.
- Placement timing analysis.
- Macro power-pin checks.
- Physical-design diagnostics and candidate netlist conversion.

The scripts and compact reports are retained in the source repository.

## 3. Compact implementation reports

The following reports are retained:

- `physical_design/reports/01_inspect_design.log`
- `physical_design/reports/02_check_commands.log`
- `physical_design/reports/03_list_macro_names.log`
- `physical_design/reports/04_floorplan_macros.log`
- `physical_design/reports/05_macro_name_diagnostic.log`
- `physical_design/reports/06_power_grid.log`

## 4. Synthesis artifacts

The source release retains:

- `synthesis_reports/soc_top_sram_sky130_stat.txt`
- `synthesis_reports/soc_top_sram_sky130_yosys.log`
- `synthesis_reports/soc_top_sram_sky130_mapped.v`

## 5. Functional regression evidence

The final regression logs are retained:

- `simulation_logs/final_release_regression.log`
- `simulation_logs/final_release_sram_regression.log`

See `documentation/VALIDATION_RESULTS.md` for the recorded test results.

## 6. Placement result summary

The retained accelerator write-decode candidate reports:

| Metric | Result |
|---|---:|
| Standard-cell area | 225,984.24 um^2 |
| Fixed macro area | 9,105,231.17 um^2 |
| Placement utilization | 55.7% |
| WNS | -78.43 ns |
| TNS | -87,555.66 ns |
| Detailed-placement illegal cells | 0 |

Timing is placement-estimated. The candidate is not timing-closed.

## 7. Artifact policy

- Source RTL, Python, testbenches, implementation scripts and compact reports belong in Git.
- Large generated ODB and DEF files remain in the local project workspace.
- Experimental and diagnostic implementation outputs are preserved locally.
- Backups are preserved locally and excluded from the source release.
- No local artifact is deleted by this policy.

For a future reproducible physical-design handoff, archive the exact PDK revision, tool versions, constraints, source revision and selected implementation database together.
