#!/usr/bin/env python3
"""Self-tests for the assembler (known encodings) and the ISS. Run: python3 python/test_toolchain.py"""
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rv32_asm import assemble
from rv32_iss import ISS

KNOWN = {  # hand-verified encodings
    "addi x1, x0, 1": 0x00100093, "add x3, x1, x2": 0x002081B3, "lw x5, 8(x2)": 0x00812283,
    "sw x5, 8(x2)": 0x00512423, "beq x1, x2, t\nnop\nt: nop": 0x00208463,
    "jal x1, t\nnop\nt: nop": 0x008000EF, "lui x1, 0x12345": 0x123450B7,
    "mul x3, x1, x2": 0x022081B3, "srai x1, x2, 3": 0x40315093, "nop": 0x00000013,
    "ret": 0x00008067,
}


def first_word(src):
    return int.from_bytes(assemble(src)[0][:4], "little")


def main():
    for src, want in KNOWN.items():
        got = first_word(src)
        assert got == want, f"{src!r}: got {got:#010x}, want {want:#010x}"
    # li expansion round-trips through the ISS for tricky constants (bit 11 set -> carry into lui)
    for v in (0, 1, 2047, 2048, -2048, -2049, 0x7FF, 0x800, 0xFFF, 0x12345FFF, 0x80000000, 0xFFFFFFFF, 0xDEADBEEF):
        img, _ = assemble(f"li t0, {v}\nli t1, 0x40000000\nsw t0, 0(t1)\nloop: j loop")
        iss = ISS(img)
        iss.run(100)
        assert iss.code == v & 0xFFFFFFFF, f"li {v:#x} -> {iss.code:#x}"
    print("toolchain self-test OK")


if __name__ == "__main__":
    main()
