#!/usr/bin/env python3
"""Bit-accurate Python mirror of rtl/muldiv_unit.v, checked against independent RV32M reference math.

It mirrors the register-transfer behaviour cycle by cycle (same registers, same widths, same state
sequence), so a pass here validates the *algorithm and sign handling* used in the RTL.
It does not check Verilog syntax - run `make muldiv_tb` (iverilog) for that.
Run: python3 python/test_muldiv_model.py
"""
import random

M32, M64 = 0xFFFFFFFF, (1 << 64) - 1


def s32(x):
    x &= M32
    return x - (1 << 32) if x >> 31 else x


def ref(f3, a, b):
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


def unit(f3, a, b):
    """Returns (result, cycles from start to done)."""
    div_op = (f3 >> 2) & 1
    if div_op:
        sgn_a = sgn_b = 1 - (f3 & 1)
    else:
        sgn_a = int((f3 & 3) in (1, 2))
        sgn_b = int((f3 & 3) == 1)
    a_neg, b_neg = sgn_a & (a >> 31), sgn_b & (b >> 31)
    mag_a = (-a) & M32 if a_neg else a
    mag_b = (-b) & M32 if b_neg else b
    want_rem, want_hi = (f3 >> 1) & 1, int((f3 & 3) != 0)
    cycles = 1                                            # S_IDLE: latch
    if div_op:
        mcand, quo, rem = mag_b, mag_a, 0
        neg = int((a_neg ^ b_neg) and b != 0)
        neg_rem = a_neg
    else:
        mcand, acc = mag_a, mag_b
        neg, neg_rem = a_neg ^ b_neg, 0
    for _ in range(32):                                   # S_RUN
        if div_op:
            rem_sh = ((rem << 1) | (quo >> 31)) & ((1 << 33) - 1)
            if rem_sh >= mcand:
                rem, quo = (rem_sh - mcand) & M32, ((quo << 1) | 1) & M32
            else:
                rem, quo = rem_sh & M32, (quo << 1) & M32
        else:
            s = (acc >> 32) + (mcand if acc & 1 else 0)   # 33-bit sum
            acc = ((s << 31) | (acc & M32) >> 1) & M64
        cycles += 1
    if div_op:                                            # S_FIX
        if neg: quo = (-quo) & M32
        if neg_rem: rem = (-rem) & M32
    elif neg:
        acc = (-acc) & M64
    cycles += 1
    if div_op:
        res = rem if want_rem else quo
    else:
        res = (acc >> 32) if want_hi else (acc & M32)
    return res & M32, cycles


def main():
    rng = random.Random(2026)
    corners = [0, 1, 2, 3, 7, 0xFF, 0xFFFF, 0x7FFFFFFF, 0x80000000, 0x80000001, M32, M32 - 1,
               0x12345678, 0xDEADBEEF, 0x55555555, 0xAAAAAAAA]
    n = 0
    for f3 in range(8):
        pairs = [(a, b) for a in corners for b in corners]
        pairs += [(rng.getrandbits(32), rng.getrandbits(32)) for _ in range(3000)]
        pairs += [(rng.getrandbits(32), rng.getrandbits(rng.randint(1, 31))) for _ in range(1000)]
        for a, b in pairs:
            got, cyc = unit(f3, a, b)
            want = ref(f3, a, b)
            assert got == want, f"f3={f3} a={a:#x} b={b:#x}: got {got:#x}, want {want:#x}"
            assert cyc == 34
            n += 1
    print(f"muldiv model OK: {n} operations over all 8 funct3 values (34 cycles each, incl. latch+fix)")


if __name__ == "__main__":
    main()
