# INT8 Systolic Accelerator — SKY130 Synthesis Summary

## Technology
- PDK: SKY130A
- Standard-cell library: sky130_fd_sc_hd
- Process corner: TT, 25 C, 1.80 V
- Synthesis tool: Yosys 0.52
- Technology mapping: ABC fast mode

## Verified Results
- Mapped standard-cell instances: 26,127
- Total library area: 164520.288
- Sequential cell area: 25579.5328
- Sequential area fraction: 15.55%
- Sequential cells: 971
  - dfrtp_1: 715
  - edfxtp_1: 256
- Structural problems: 0
- Memories inferred: 0

## Artifacts
- accel_top_sky130.v: Technology-mapped Verilog netlist
- accel_top_mapping.rpt: Initial synthesis report
- accel_top_postcheck.rpt: Library-aware structural verification

## Scope and Limitations
This is a technology-mapped synthesis result, not a placed-and-routed
physical implementation. Area, timing, power, congestion, and routing
must be evaluated during physical design.
