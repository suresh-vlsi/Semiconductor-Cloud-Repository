#!/usr/bin/env python3
"""Generate the test/benchmark assembly programs into testbench/programs/.

Expected values come from independent Python reference math (not from the ISS or the RTL).
Pass/fail protocol: write 1 to SYSCON (0x4000_0000) = PASS, any other value = FAIL code.
"""
import os
import random
import argparse
import numpy as np

M = 0xFFFFFFFF
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "testbench", "programs")

EPILOGUE = """
pass:
    li   t6, SYSCON
    li   t5, 1
    sw   t5, 0(t6)
halt_pass:
    j    halt_pass
fail:
    li   t6, SYSCON
    sw   a0, 0(t6)
halt_fail:
    j    halt_fail
"""
HEADER = ".equ SYSCON, 0x40000000\n.equ UART, 0x20000000\n.equ GPIO, 0x30000000\n.equ ACCEL, 0x50000000\n"


def s32(x):
    x &= M
    return x - (1 << 32) if x >> 31 else x


def ref(op, a, b):
    a &= M
    b &= M
    sa, sb = s32(a), s32(b)
    sh = b & 31
    if op in ("add", "addi"): return (a + b) & M
    if op == "sub": return (a - b) & M
    if op in ("sll", "slli"): return (a << sh) & M
    if op in ("srl", "srli"): return a >> sh
    if op in ("sra", "srai"): return (sa >> sh) & M
    if op in ("slt", "slti"): return int(sa < sb)
    if op in ("sltu", "sltiu"): return int(a < b)
    if op in ("xor", "xori"): return a ^ b
    if op in ("or", "ori"): return a | b
    if op in ("and", "andi"): return a & b
    if op == "mul": return (a * b) & M
    if op == "mulh": return ((sa * sb) >> 32) & M
    if op == "mulhsu": return ((sa * b) >> 32) & M
    if op == "mulhu": return ((a * b) >> 32) & M
    if op == "div":
        if b == 0: return M
        if sa == -(1 << 31) and sb == -1: return 0x80000000
        q = abs(sa) // abs(sb)
        return (q if (sa < 0) == (sb < 0) else -q) & M
    if op == "divu": return M if b == 0 else a // b
    if op == "rem":
        if b == 0: return a
        if sa == -(1 << 31) and sb == -1: return 0
        r = abs(sa) % abs(sb)
        return (-r if sa < 0 else r) & M
    if op == "remu": return a if b == 0 else a % b
    raise ValueError(op)


class Prog:
    def __init__(self):
        self.lines = [HEADER, "_start:"]
        self.n = 0

    def emit(self, *ls):
        self.lines.extend("    " + l if not l.endswith(":") else l for l in ls)

    def label(self, name):
        self.lines.append(name + ":")

    def check(self, reg, expected):
        """Fail with code (n+1) if reg != expected. Uses a0/a1. beq+j keeps branch range small."""
        self.n += 1
        i = self.n + 1
        self.emit(f"li   a0, {i}", f"li   a1, {expected & M}", f"beq  {reg}, a1, ok_{i}",
                  "j    fail")
        self.label(f"ok_{i}")

    def text(self):
        return "\n".join(self.lines) + "\n"


def gen_alu(seed=1234):
    rng = random.Random(seed)
    corners = [0, 1, M, 2, 0x7FFFFFFF, 0x80000000, 0x80000001, 0x12345678, 0xDEADBEEF, 31, 32, 0x0000FFFF]
    p = Prog()
    rr_ops = ["add", "sub", "sll", "srl", "sra", "slt", "sltu", "xor", "or", "and",
              "mul", "mulh", "mulhsu", "mulhu", "div", "divu", "rem", "remu"]
    for op in rr_ops:
        pairs = [(0x80000000, M), (M, 0), (7, 0), (0x80000000, 1), (M, M), (5, 3), (M - 4, 3)]
        pairs += [(rng.choice(corners), rng.choice(corners)) for _ in range(4)]
        pairs += [(rng.getrandbits(32), rng.getrandbits(32)) for _ in range(6)]
        for a, b in pairs:
            p.emit(f"li   t0, {a}", f"li   t1, {b}", f"{op}  t2, t0, t1")
            p.check("t2", ref(op, a, b))
    for op in ["addi", "slti", "sltiu", "xori", "ori", "andi"]:
        for _ in range(10):
            a, imm = rng.choice(corners + [rng.getrandbits(32)]), rng.randint(-2048, 2047)
            p.emit(f"li   t0, {a}", f"{op} t2, t0, {imm}")
            p.check("t2", ref(op, a, imm & M))
    for op in ["slli", "srli", "srai"]:
        for sh in (0, 1, 5, 15, 31):
            a = rng.choice([0x80000000, 0xF0F0F0F0, 0x12345678, M])
            p.emit(f"li   t0, {a}", f"{op} t2, t0, {sh}")
            p.check("t2", ref(op, a, sh))
    for imm in (0xABCDE, 0x00001, 0xFFFFF):
        p.emit(f"lui  t2, {imm}")
        p.check("t2", imm << 12)
    p.emit("j    pass")
    p.lines.append(EPILOGUE)
    return p.text()


def gen_mem_hazard():
    p = Prog()
    p.emit("li   s0, 0x8000            # scratch RAM")
    # byte/half loads with sign / zero extension
    p.emit("li   t0, 0x8091A2B3", "sw   t0, 0(s0)",
           "lbu  t1, 0(s0)", "lbu  t2, 1(s0)", "lb   t3, 2(s0)", "lb   t4, 3(s0)")
    for r, e in (("t1", 0xB3), ("t2", 0xA2), ("t3", 0xFFFFFF91), ("t4", 0xFFFFFF80)):
        p.check(r, e)
    p.emit("lhu  t1, 0(s0)", "lh   t2, 2(s0)", "lh   t3, 0(s0)", "lhu  t4, 2(s0)")
    for r, e in (("t1", 0xA2B3), ("t2", 0xFFFF8091), ("t3", 0xFFFFA2B3), ("t4", 0x8091)):
        p.check(r, e)
    # sub-word stores
    p.emit("li   t0, 0x11223344", "sw   t0, 4(s0)", "li   t1, 0xAA", "sb   t1, 5(s0)", "lw   t2, 4(s0)")
    p.check("t2", 0x1122AA44)
    p.emit("li   t1, 0xBEEF", "sh   t1, 6(s0)", "lw   t2, 4(s0)")
    p.check("t2", 0xBEEFAA44)
    # load-use hazard + forwarding from MEM and WB
    p.emit("li   t0, 100", "sw   t0, 8(s0)", "lw   t1, 8(s0)", "addi t2, t1, 1", "add  t3, t2, t1")
    p.check("t2", 101)
    p.check("t3", 201)
    # back-to-back dependent ALU ops
    p.emit("li   t0, 1", "add  t1, t0, t0", "add  t2, t1, t0", "add  t3, t2, t1", "add  t4, t3, t2")
    p.check("t4", 8)
    # store data forwarding
    p.emit("li   t0, 55", "addi t1, t0, 5", "sw   t1, 12(s0)", "lw   t2, 12(s0)")
    p.check("t2", 60)
    # taken branch must flush the two wrong-path instructions
    p.emit("li   t0, 5", "li   t1, 0", "beq  t0, t0, skip1", "addi t1, t1, 100", "addi t1, t1, 100")
    p.label("skip1")
    p.emit("addi t1, t1, 1")
    p.check("t1", 1)
    # not-taken branch
    p.emit("li   t2, 0", "bne  t0, t0, bad", "addi t2, t2, 7")
    p.check("t2", 7)
    # signed vs unsigned compares
    p.emit("li   t0, -1", "li   t1, 1", "li   t2, 0", "blt  t0, t1, l1", "j    fail")
    p.label("l1")
    p.emit("bltu t0, t1, bad", "bgeu t0, t1, l2", "j    fail")
    p.label("l2")
    p.emit("addi t2, t2, 1")
    p.check("t2", 1)
    # jal / ret (jalr) loop
    p.emit("li   t0, 0", "jal  ra, func_inc", "jal  ra, func_inc")
    p.check("t0", 20)
    # auipc + jal link value
    p.emit("auipc t0, 0", "jal  t1, after_jal")
    p.label("after_jal")
    p.emit("sub  t2, t1, t0")
    p.check("t2", 8)
    # x0 is hard-wired to zero
    p.emit("addi x0, x0, 5", "add  t0, x0, x0")
    p.check("t0", 0)
    # backward-branch countdown loop (branch + forwarding every iteration)
    p.emit("li   t0, 10", "li   t1, 0")
    p.label("cnt")
    p.emit("add  t1, t1, t0", "addi t0, t0, -1", "bnez t0, cnt")
    p.check("t1", 55)
    p.emit("j    pass")
    p.label("bad")
    p.emit("li   a0, 99", "j    fail")
    p.label("func_inc")
    p.emit("addi t0, t0, 10", "ret")
    p.lines.append(EPILOGUE)
    return p.text()


def gen_hello():
    return HEADER + """_start:
    la   s0, msg
    li   s1, UART
next_char:
    lbu  t0, 0(s0)
    beqz t0, pass
wait_tx:
    lw   t1, 4(s1)
    andi t1, t1, 1
    bnez t1, wait_tx
    sw   t0, 0(s1)
    addi s0, s0, 1
    j    next_char
""" + EPILOGUE + """
msg:
    .asciz "Hello, VLSI!\\n"
"""


def matmul_data(n, seed):
    rng = np.random.default_rng(seed)
    A = rng.integers(-128, 128, size=(n, n), dtype=np.int64)
    B = rng.integers(-128, 128, size=(n, n), dtype=np.int64)
    C = (A @ B).astype(np.int32)
    data = ["    .align 2", "A:", "    .byte " + ", ".join(str(int(v)) for v in A.reshape(-1)),
            "    .align 2", "B:", "    .byte " + ", ".join(str(int(v)) for v in B.reshape(-1)),
            "    .align 2", "EXP:", "    .word " + ", ".join(str(int(v)) for v in C.reshape(-1)),
            "C:", f"    .space {4 * n * n}"]
    return "\n".join(data) + "\n"


COMPARE = """
    # ---- verify C against expected ----
    la   t0, C
    la   t1, EXP
    li   t2, {nn}
    li   a0, 2
cmp_loop:
    lw   t3, 0(t0)
    lw   t4, 0(t1)
    beq  t3, t4, cmp_ok
    j    fail
cmp_ok:
    addi t0, t0, 4
    addi t1, t1, 4
    addi t2, t2, -1
    bnez t2, cmp_loop
    j    pass
"""


def gen_matmul_sw(n, seed):
    return HEADER + f"""_start:
    la   s0, A
    la   s1, B
    la   s2, C
    li   s7, SYSCON
    lw   s8, 8(s7)            # start cycle
    li   t1, {n}
    li   s3, 0
i_loop:
    li   s4, 0
j_loop:
    li   t0, 0                # accumulator
    li   s5, 0
    mul  t2, s3, t1
    add  t2, t2, s0           # &A[i][0]
    add  t3, s1, s4           # &B[0][j]
k_loop:
    lb   t4, 0(t2)
    lb   t5, 0(t3)
    mul  t4, t4, t5
    add  t0, t0, t4
    addi t2, t2, 1
    addi t3, t3, {n}
    addi s5, s5, 1
    blt  s5, t1, k_loop
    mul  t4, s3, t1
    add  t4, t4, s4
    slli t4, t4, 2
    add  t4, t4, s2
    sw   t0, 0(t4)
    addi s4, s4, 1
    blt  s4, t1, j_loop
    addi s3, s3, 1
    blt  s3, t1, i_loop
    lw   s9, 8(s7)
    sub  s9, s9, s8           # kernel cycles
    li   t6, GPIO
    sw   s9, 0(t6)
""" + COMPARE.format(nn=n * n) + EPILOGUE + matmul_data(n, seed)


def gen_matmul_accel(n, seed):
    words = n * n // 4
    return HEADER + f"""_start:
    li   s6, ACCEL
    li   s7, SYSCON
    lw   s8, 8(s7)            # start cycle
    # copy A, B into the accelerator buffers
    la   t0, A
    addi t1, s6, 0x100
    li   t2, {words}
cpa:
    lw   t3, 0(t0)
    sw   t3, 0(t1)
    addi t0, t0, 4
    addi t1, t1, 4
    addi t2, t2, -1
    bnez t2, cpa
    la   t0, B
    addi t1, s6, 0x200
    li   t2, {words}
cpb:
    lw   t3, 0(t0)
    sw   t3, 0(t1)
    addi t0, t0, 4
    addi t1, t1, 4
    addi t2, t2, -1
    bnez t2, cpb
    # start and poll DONE (status bit 1)
    li   t0, 1
    sw   t0, 0(s6)
poll:
    lw   t0, 4(s6)
    andi t0, t0, 2
    beqz t0, poll
    # copy C out of the accelerator into RAM
    la   t0, C
    addi t1, s6, 0x300
    li   t2, {n * n}
cpc:
    lw   t3, 0(t1)
    sw   t3, 0(t0)
    addi t0, t0, 4
    addi t1, t1, 4
    addi t2, t2, -1
    bnez t2, cpc
    lw   s9, 8(s7)
    sub  s9, s9, s8           # kernel cycles
    li   t6, GPIO
    sw   s9, 0(t6)
""" + COMPARE.format(nn=n * n) + EPILOGUE + matmul_data(n, seed)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--n", type=int, default=4, choices=(4, 8), help="systolic array size (must match ACCEL_N)")
    ap.add_argument("--seed", type=int, default=42)
    args = ap.parse_args()
    os.makedirs(OUT, exist_ok=True)
    progs = {"hello": gen_hello(), "alu_test": gen_alu(), "mem_hazard": gen_mem_hazard(),
             "matmul_sw": gen_matmul_sw(args.n, args.seed), "matmul_accel": gen_matmul_accel(args.n, args.seed)}
    for name, text in progs.items():
        with open(os.path.join(OUT, name + ".S"), "w") as f:
            f.write(text)
        print(f"generated testbench/programs/{name}.S")


if __name__ == "__main__":
    main()
