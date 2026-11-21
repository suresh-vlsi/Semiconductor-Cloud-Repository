#!/usr/bin/env python3
"""Run the five existing ISS programs against the SKY130 SRAM-backed SoC."""
import os, re, sys, subprocess
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "python"))
from rv32_asm import assemble, to_hex
from rv32_iss import ISS
PROGS = ["hello", "alu_test", "mem_hazard", "muldiv_hazard", "matmul_sw", "matmul_accel"]
ACCEL_N = int(os.environ.get("ACCEL_N", "4"))

def main():
    os.makedirs(os.path.join(ROOT, "simulation_logs"), exist_ok=True)
    rows, failed = [], 0
    for name in PROGS:
        src = os.path.join(ROOT, "testbench", "programs", name + ".S")
        image, _ = assemble(open(src).read())
        iss = ISS(image, ACCEL_N).run()
        iss_ok = iss["done"] and iss["code"] == 1
        hexfile = os.path.join(ROOT, "testbench", "programs", name + ".hex")
        with open(hexfile, "w") as f: f.write(to_hex(image))
        out = subprocess.run(["vvp", os.path.join(ROOT, "simulation_logs", "soc_sram_sim.vvp"),
                              f"+HEX={hexfile}", "+TIMEOUT=1000000"],
                             cwd=ROOT, capture_output=True, text=True, timeout=600).stdout
        rtl_ok = "TEST PASSED" in out
        m = re.search(r"TOTAL_CYCLES=(\d+) KERNEL_CYCLES=(\d+)", out)
        cycles = m.groups() if m else ("-", "-")
        rows.append((name, "PASS" if iss_ok else "FAIL", "PASS" if rtl_ok else "FAIL", *cycles))
        if not iss_ok or not rtl_ok: failed += 1
        print(f"{name:14s} ISS={'PASS' if iss_ok else 'FAIL':4s} RTL={'PASS' if rtl_ok else 'FAIL':4s} cycles={cycles[0]}")
        if not rtl_ok: print(out)
    print("\n| Program | ISS | SRAM RTL | Cycles |\n|---|---:|---:|---:|")
    for r in rows: print(f"| {r[0]} | {r[1]} | {r[2]} | {r[3]} |")
    sys.exit(1 if failed else 0)
if __name__ == "__main__": main()
