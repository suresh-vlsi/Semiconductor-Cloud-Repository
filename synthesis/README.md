`make synth` runs Yosys on the core and the accelerator and writes `synthesis_reports/*_yosys.rpt`.
For sky130 mapping add, after `synth`:  `dfflibmap -liberty $LIB; abc -liberty $LIB; stat -liberty $LIB`.
OpenLane configs live in `openlane/<block>/config.json`.
