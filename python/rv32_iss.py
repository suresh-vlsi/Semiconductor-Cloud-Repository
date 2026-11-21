#!/usr/bin/env python3
"""Golden RV32IM instruction-set simulator with the same memory map as rtl/soc_top.v.

Memory map: RAM 0x0000_0000 (64 KiB) | UART 0x2000_0000 | GPIO 0x3000_0000
            SYSCON 0x4000_0000 (write: finish, +8 read: cycle counter) | ACCEL 0x5000_0000
"""
import os
import sys
import argparse
import numpy as np

M32 = 0xFFFFFFFF
RAM_SIZE = 1 << 16


def s32(x):
    x &= M32
    return x - (1 << 32) if x >> 31 else x


def sext(v, bits):
    v &= (1 << bits) - 1
    return v - (1 << bits) if v >> (bits - 1) else v


class AccelModel:
    """Functional model of rtl/accel_top.v (identical register map)."""

    def __init__(self, n=4):
        self.n = n
        self.a = np.zeros(n * n, dtype=np.int8)
        self.b = np.zeros(n * n, dtype=np.int8)
        self.c = np.zeros(n * n, dtype=np.int32)
        self.done = 0

    def write_byte(self, off, val):
        win, idx = off >> 8, off & 0xFF
        if win == 1 and idx < self.n * self.n:
            self.a[idx] = sext(val, 8)
        elif win == 2 and idx < self.n * self.n:
            self.b[idx] = sext(val, 8)

    def write_word(self, off, val):
        if off == 0 and (val & 1):
            A = self.a.reshape(self.n, self.n).astype(np.int64)
            B = self.b.reshape(self.n, self.n).astype(np.int64)
            self.c = (A @ B).astype(np.int32).reshape(-1)
            self.done = 1

    def read_word(self, off):
        if off == 4:
            return self.done << 1
        if off == 8:
            return self.n
        if (off >> 8) == 3:
            i = (off & 0xFF) >> 2
            if i < self.n * self.n:
                return int(self.c[i]) & M32
        return 0


class ISS:
    def __init__(self, image, accel_n=4):
        self.ram = bytearray(RAM_SIZE)
        self.ram[:len(image)] = image
        self.x = [0] * 32
        self.pc = 0
        self.instret = 0
        self.gpio = 0
        self.uart = bytearray()
        self.done = False
        self.code = None
        self.accel = AccelModel(accel_n)

    def load(self, addr, size):
        addr &= M32
        if addr < RAM_SIZE:
            return int.from_bytes(self.ram[addr:addr + size], "little")
        base = addr & ~3
        if (addr >> 12) == 0x50000:
            word = self.accel.read_word(addr & 0xFFF & ~3)
        else:
            word = {0x20000004: 0, 0x30000000: self.gpio, 0x40000008: self.instret & M32}.get(base, 0)
        return (word >> ((addr & 3) * 8)) & ((1 << (8 * size)) - 1)

    def store(self, addr, val, size):
        addr &= M32
        val &= (1 << (8 * size)) - 1
        if addr < RAM_SIZE:
            self.ram[addr:addr + size] = val.to_bytes(size, "little")
        elif addr == 0x20000000:
            self.uart.append(val & 0xFF)
        elif addr == 0x30000000:
            self.gpio = val
        elif addr == 0x40000000:
            self.done, self.code = True, val
        elif (addr >> 12) == 0x50000:
            off = addr & 0xFFF
            if (off >> 8) in (1, 2):
                for i in range(size):
                    self.accel.write_byte(off + i, (val >> (8 * i)) & 0xFF)
            else:
                self.accel.write_word(off & ~3, val)

    def step(self):
        ins = self.load(self.pc, 4)
        op = ins & 0x7F
        rd, f3 = (ins >> 7) & 31, (ins >> 12) & 7
        rs1, rs2, f7 = (ins >> 15) & 31, (ins >> 20) & 31, ins >> 25
        a, b = self.x[rs1], self.x[rs2]
        sa, sb = s32(a), s32(b)
        npc = (self.pc + 4) & M32
        res = None
        imm_i = sext(ins >> 20, 12)
        if op == 0x37:
            res = ins & 0xFFFFF000
        elif op == 0x17:
            res = (self.pc + (ins & 0xFFFFF000)) & M32
        elif op == 0x6F:
            imm = sext(((ins >> 31) << 20) | (((ins >> 12) & 0xFF) << 12) | (((ins >> 20) & 1) << 11) |
                       (((ins >> 21) & 0x3FF) << 1), 21)
            res, npc = (self.pc + 4) & M32, (self.pc + imm) & M32
        elif op == 0x67:
            res, npc = (self.pc + 4) & M32, (a + imm_i) & M32 & ~1
        elif op == 0x63:
            imm = sext(((ins >> 31) << 12) | (((ins >> 7) & 1) << 11) | (((ins >> 25) & 0x3F) << 5) |
                       (((ins >> 8) & 0xF) << 1), 13)
            take = {0: a == b, 1: a != b, 4: sa < sb, 5: sa >= sb, 6: a < b, 7: a >= b}.get(f3, False)
            if take:
                npc = (self.pc + imm) & M32
        elif op == 0x03:
            size = {0: 1, 1: 2, 2: 4, 4: 1, 5: 2}[f3]
            v = self.load(a + imm_i, size)
            res = (sext(v, 8 * size) & M32) if f3 in (0, 1) else v
        elif op == 0x23:
            imm = sext(((ins >> 25) << 5) | ((ins >> 7) & 31), 12)
            self.store(a + imm, b, {0: 1, 1: 2, 2: 4}[f3])
        elif op in (0x13, 0x33):
            y = b if op == 0x33 else imm_i & M32
            if op == 0x33 and f7 == 1:
                res = self.muldiv(f3, a, b)
            else:
                alt = (f7 == 0x20) and (op == 0x33 or f3 == 5)
                res = {0: (a - y if alt else a + y), 1: a << (y & 31),
                       2: int(sa < s32(y)), 3: int(a < y), 4: a ^ y,
                       5: (sa >> (y & 31)) if alt else (a >> (y & 31)), 6: a | y, 7: a & y}[f3] & M32
        # fence/system opcodes behave as NOP, matching the RTL
        if res is not None and rd:
            self.x[rd] = res & M32
        self.pc = npc
        self.instret += 1

    @staticmethod
    def muldiv(f3, a, b):
        sa, sb = s32(a), s32(b)
        if f3 == 0: return (a * b) & M32
        if f3 == 1: return ((sa * sb) >> 32) & M32
        if f3 == 2: return ((sa * b) >> 32) & M32
        if f3 == 3: return ((a * b) >> 32) & M32
        if f3 == 4:
            if b == 0: return M32
            if sa == -(1 << 31) and sb == -1: return 0x80000000
            q = abs(sa) // abs(sb)
            return (q if (sa < 0) == (sb < 0) else -q) & M32
        if f3 == 5: return M32 if b == 0 else a // b
        if f3 == 6:
            if b == 0: return a
            if sa == -(1 << 31) and sb == -1: return 0
            r = abs(sa) % abs(sb)
            return (-r if sa < 0 else r) & M32
        return a if b == 0 else a % b

    def run(self, max_instr=2_000_000):
        while not self.done and self.instret < max_instr:
            self.step()
        return {"done": self.done, "code": self.code, "instret": self.instret,
                "gpio": self.gpio, "uart": self.uart.decode(errors="replace")}


def load_image(path):
    if path.endswith(".hex"):
        words = [int(l, 16) for l in open(path) if l.strip()]
        return b"".join(w.to_bytes(4, "little") for w in words)
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    from rv32_asm import assemble
    return assemble(open(path).read())[0]


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("source", help=".S assembly or .hex file")
    ap.add_argument("--accel-n", type=int, default=4)
    ap.add_argument("--max", type=int, default=2_000_000)
    args = ap.parse_args()
    r = ISS(load_image(args.source), args.accel_n).run(args.max)
    if r["uart"]:
        print("UART:", r["uart"].rstrip())
    if not r["done"]:
        verdict = "TEST TIMEOUT"
    elif r["code"] == 1:
        verdict = "TEST PASSED"
    else:
        verdict = f"TEST FAILED code={r['code']}"
    print(f"{verdict}  instret={r['instret']}  gpio={r['gpio']}")
    sys.exit(0 if verdict == "TEST PASSED" else 1)


if __name__ == "__main__":
    main()
