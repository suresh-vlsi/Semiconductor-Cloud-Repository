#!/usr/bin/env python3
"""Regression driver: for every program run (1) the Python ISS golden model and (2) the RTL
simulation (if iverilog is installed); report PASS/FAIL, cycle counts and accelerator speed-up.
Writes simulation_logs/regression_summary.md.
"""
import os
import re
import sys
import shutil
import argparse
import subprocess

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "python"))
from rv32_asm import assemble, to_hex          # noqa: E402
from rv32_iss import ISS                        # noqa: E402

PROGS = ["hello", "alu_test", "mem_hazard", "matmul_sw", "matmul_accel"]


def run_rtl(hexfile, accel_n):
    sim = os.path.join(ROOT, "simulation_logs", "soc_sim.vvp")
    cmd = ["make", "-s", "-C", ROOT, "simulation_logs/soc_sim.vvp", f"ACCEL_N={accel_n}"]
    subprocess.run(cmd, check=True, capture_output=True, text=True)
    out = subprocess.run(["vvp", sim, f"+HEX={hexfile}"], capture_output=True, text=True, timeout=600).stdout
    verdict = "PASS" if "TEST PASSED" in out else ("TIMEOUT" if "TEST TIMEOUT" in out else "FAIL")
    m = re.search(r"TOTAL_CYCLES=(\d+) KERNEL_CYCLES=(\d+)", out)
    return verdict, (int(m.group(1)), int(m.group(2))) if m else (None, None)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--accel-n", type=int, default=4)
    args = ap.parse_args()
    have_sim = shutil.which("iverilog") and shutil.which("vvp")
    rows, failures, kernel = [], 0, {}
    for name in PROGS:
        src = os.path.join(ROOT, "testbench", "programs", name + ".S")
        image, _ = assemble(open(src).read())
        iss = ISS(image, args.accel_n)
        r = iss.run()
        iss_v = "PASS" if r["done"] and r["code"] == 1 else "FAIL"
        rtl_v, cyc = ("n/a", (None, None))
        if have_sim:
            hexfile = os.path.join(ROOT, "testbench", "programs", name + ".hex")
            with open(hexfile, "w") as f:
                f.write(to_hex(image))
            rtl_v, cyc = run_rtl(hexfile, args.accel_n)
            kernel[name] = cyc[1]
        if iss_v != "PASS" or rtl_v in ("FAIL", "TIMEOUT"):
            failures += 1
        rows.append((name, iss_v, r["instret"], rtl_v, cyc[0], cyc[1]))
    lines = ["| program | ISS | instructions | RTL | RTL cycles | kernel cycles |", "|---|---|---|---|---|---|"]
    for n, iv, ins, rv, tc, kc in rows:
        lines.append(f"| {n} | {iv} | {ins} | {rv} | {tc if tc is not None else '-'} | {kc if kc is not None else '-'} |")
    if kernel.get("matmul_sw") and kernel.get("matmul_accel"):
        lines.append("")
        lines.append(f"Accelerator speed-up ({args.accel_n}x{args.accel_n} INT8 matmul, copy-in + compute + copy-out): "
                     f"{kernel['matmul_sw'] / kernel['matmul_accel']:.1f}x "
                     f"({kernel['matmul_sw']} vs {kernel['matmul_accel']} cycles)")
    if not have_sim:
        lines.append("")
        lines.append("_iverilog not found: only the Python golden model was run. Install iverilog and re-run `make test`._")
    text = "\n".join(lines)
    print(text)
    with open(os.path.join(ROOT, "simulation_logs", "regression_summary.md"), "w") as f:
        f.write(text + "\n")
    sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
