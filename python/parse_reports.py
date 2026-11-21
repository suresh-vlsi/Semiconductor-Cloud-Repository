#!/usr/bin/env python3
"""Summarise synthesis / timing reports in a directory into a markdown table.

Understands:
  * Yosys `stat` output   (*.rpt / *.log containing 'Number of cells' and optionally 'Chip area')
  * OpenSTA / OpenROAD timing reports (lines 'slack (MET|VIOLATED)', 'wns', 'tns', 'worst slack')
  * Power lines 'Total  <internal> <switching> <leakage> <total>' from report_power
Usage: python3 python/parse_reports.py synthesis_reports [-o summary.md]
"""
import os
import re
import sys
import argparse


def parse_yosys(text):
    d = {}
    cells = re.findall(r"^\s*(\d+)\s+cells\s*$", text, re.M)
    if cells:
        d["cells"] = int(cells[-1])
    else:
        m2 = re.findall(r"Number of cells:?\s+(\d+)", text)
        if m2:
            d["cells"] = int(m2[-1])
    area = re.findall(r"Chip area for (?:top )?module '?\\?([\w$.]+)'?:\s*([\d.]+)", text)
    if area:
        d["area_um2"] = float(area[-1][1])
    ff = re.findall(r"^\s*\S*(?:DFF|dff|dfxtp|dfrtp)\S*\s+(\d+)\s*$", text, re.M)
    if ff:
        d["flip_flops"] = sum(int(x) for x in ff)
    return d


def parse_timing(text):
    d = {}
    slacks = [float(x) for x in re.findall(r"(-?\d+\.?\d*)\s+slack\s+\((?:MET|VIOLATED)\)", text)]
    if slacks:
        d["worst_slack_ns"] = min(slacks)
    for key, name in (("wns", "wns_ns"), ("tns", "tns_ns")):
        m = re.search(rf"^\s*{key}\s+(-?\d+\.?\d*)", text, re.M | re.I)
        if m:
            d[name] = float(m.group(1))
    m = re.search(r"worst slack\s+(-?\d+\.?\d*)", text, re.I)
    if m:
        d["worst_slack_ns"] = float(m.group(1))
    m = re.search(r"^\s*Total\s+([\d.eE+-]+)\s+([\d.eE+-]+)\s+([\d.eE+-]+)\s+([\d.eE+-]+)", text, re.M)
    if m:
        d["power_w"] = float(m.group(4))
    return d


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("directory")
    ap.add_argument("-o", "--output")
    args = ap.parse_args()
    rows = []
    for fn in sorted(os.listdir(args.directory)):
        if not fn.endswith((".rpt", ".log", ".txt")):
            continue
        text = open(os.path.join(args.directory, fn), errors="replace").read()
        info = {**parse_yosys(text), **parse_timing(text)}
        if info:
            rows.append((fn, info))
    cols = ["cells", "flip_flops", "area_um2", "worst_slack_ns", "wns_ns", "tns_ns", "power_w"]
    out = ["| report | " + " | ".join(cols) + " |", "|---|" + "---|" * len(cols)]
    for fn, info in rows:
        out.append(f"| {fn} | " + " | ".join(str(info.get(c, "-")) for c in cols) + " |")
    if not rows:
        out.append("| (no recognisable reports found) |" + " |" * len(cols))
    text = "\n".join(out)
    print(text)
    if args.output:
        open(args.output, "w").write(text + "\n")


if __name__ == "__main__":
    main()
