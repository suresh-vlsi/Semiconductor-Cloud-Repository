# Semiconductor-Cloud-Repository : RV32IM + INT8 systolic accelerator SoC
#   make test            assemble programs, run ISS golden model and RTL simulation for all programs
#   make sim PROG=hello  run a single program on the RTL (needs iverilog)
#   make iss             golden-model (Python) run only - no simulator needed
#   make accel_tb        standalone accelerator testbench
#   make muldiv_tb       standalone multiply/divide unit testbench
#   make wave PROG=...   same as sim, dumps simulation_logs/soc.vcd for GTKWave
#   make synth           Yosys generic synthesis + area report of core and accelerator
#   make report          parse synthesis_reports/*.rpt into a summary table
ACCEL_N ?= 4
PROG    ?= hello
PROGS = hello alu_test mem_hazard muldiv_hazard matmul_sw matmul_accel

IVERILOG ?= iverilog
VVP      ?= vvp
YOSYS    ?= yosys
PY       ?= python3

RTL = rtl/regfile.v rtl/muldiv_unit.v rtl/rv32im_core.v rtl/pe.v rtl/systolic_array.v rtl/accel_top.v \
      rtl/uart_tx.v rtl/soc_top.v
PROGDIR = testbench/programs

.PHONY: all programs test iss sim wave accel_tb muldiv_tb synth report selftest clean
all: test

programs: $(foreach p,$(PROGS),$(PROGDIR)/$(p).hex)

$(PROGDIR)/%.S:
	$(PY) python/gen_programs.py --n $(ACCEL_N)

$(PROGDIR)/%.hex: $(PROGDIR)/%.S python/rv32_asm.py
	$(PY) python/rv32_asm.py $< -o $@

selftest:
	$(PY) python/test_toolchain.py
	$(PY) python/test_muldiv_model.py
	$(PY) python/golden_systolic.py

iss: programs selftest
	@for p in $(PROGS); do echo "== ISS: $$p"; $(PY) python/rv32_iss.py $(PROGDIR)/$$p.hex --accel-n $(ACCEL_N) || exit 1; done

simulation_logs/soc_sim.vvp: $(RTL) testbench/tb_soc.v
	$(IVERILOG) -g2012 -Wall -DACCEL_N=$(ACCEL_N) -o $@ testbench/tb_soc.v $(RTL)

simulation_logs/soc_sim_dump.vvp: $(RTL) testbench/tb_soc.v
	$(IVERILOG) -g2012 -DDUMP -DACCEL_N=$(ACCEL_N) -o $@ testbench/tb_soc.v $(RTL)

sim: simulation_logs/soc_sim.vvp $(PROGDIR)/$(PROG).hex
	$(VVP) $< +HEX=$(PROGDIR)/$(PROG).hex | tee simulation_logs/$(PROG).log

wave: simulation_logs/soc_sim_dump.vvp $(PROGDIR)/$(PROG).hex
	$(VVP) $< +HEX=$(PROGDIR)/$(PROG).hex | tee simulation_logs/$(PROG).log

muldiv_tb: rtl/muldiv_unit.v testbench/tb_muldiv.v
	$(IVERILOG) -g2012 -Wall -o simulation_logs/muldiv_sim.vvp $^
	$(VVP) simulation_logs/muldiv_sim.vvp | tee simulation_logs/muldiv_tb.log

accel_tb: rtl/pe.v rtl/systolic_array.v rtl/accel_top.v testbench/tb_accel.v
	$(IVERILOG) -g2012 -Wall -DACCEL_N=$(ACCEL_N) -o simulation_logs/accel_sim.vvp $^
	$(VVP) simulation_logs/accel_sim.vvp | tee simulation_logs/accel_tb.log

test: iss
	$(PY) python/run_regression.py --accel-n $(ACCEL_N)

synth:
	$(YOSYS) -q -p "read_verilog -sv rtl/regfile.v rtl/muldiv_unit.v rtl/rv32im_core.v; synth -top rv32im_core -flatten; stat" \
	    | tee synthesis_reports/rv32im_core_yosys.rpt
	$(YOSYS) -q -p "read_verilog -sv rtl/pe.v rtl/systolic_array.v rtl/accel_top.v; chparam -set N $(ACCEL_N) accel_top; synth -top accel_top -flatten; stat" \
	    | tee synthesis_reports/accel_top_yosys.rpt

report:
	$(PY) python/parse_reports.py synthesis_reports

clean:
	rm -f simulation_logs/*.vvp simulation_logs/*.vcd simulation_logs/*.log $(PROGDIR)/*.hex


# SKY130 synchronous SRAM-backed SoC (set PDK_DIR to the installed sky130A root).
SRAM_MACRO ?= $(PDK_DIR)/libs.ref/sky130_sram_macros/verilog/sky130_sram_2kbyte_1rw1r_32x512_8.v
SRAM_RTL = rtl/regfile.v rtl/muldiv_unit.v rtl/rv32im_core_sram.v rtl/pe.v rtl/systolic_array.v \
           rtl/accel_top.v rtl/uart_tx.v rtl/sky130_sram_64kb.v rtl/soc_top_sram.v

.PHONY: sram_compile sram_sim sram_test
simulation_logs/soc_sram_sim.vvp: $(SRAM_RTL) testbench/tb_soc_sram.v $(SRAM_MACRO)
	@mkdir -p simulation_logs
	$(IVERILOG) -g2012 -Wall -DACCEL_N=$(ACCEL_N) -s tb_soc_sram -o $@ \
	  testbench/tb_soc_sram.v $(SRAM_RTL) $(SRAM_MACRO)

sram_compile: simulation_logs/soc_sram_sim.vvp

sram_sim: simulation_logs/soc_sram_sim.vvp $(PROGDIR)/$(PROG).hex
	$(VVP) $< +HEX=$(PROGDIR)/$(PROG).hex +TIMEOUT=1000000 | tee simulation_logs/$(PROG)_sram.log

sram_test: simulation_logs/soc_sram_sim.vvp programs
	ACCEL_N=$(ACCEL_N) $(PY) python/run_sram_regression.py
