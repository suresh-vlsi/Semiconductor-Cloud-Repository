#!/usr/bin/env python3
"""Minimal RV32IM assembler -> $readmemh hex (one 32-bit word per line).

Supported: RV32I integer ops (no fence/ecall), RV32M, common pseudo-ops
(li la mv not neg nop j jal jr ret beqz bnez bltz bgez blez bgtz bgt ble bgtu bleu seqz snez),
directives: .equ .word .byte .ascii .asciz .string .space .align
Comments start with '#' or '//'.
"""
import re
import sys
import argparse

ABI = ("zero ra sp gp tp t0 t1 t2 s0 s1 a0 a1 a2 a3 a4 a5 a6 a7 "
       "s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6").split()
REGS = {f"x{i}": i for i in range(32)}
REGS.update({n: i for i, n in enumerate(ABI)})
REGS["fp"] = 8
M32 = 0xFFFFFFFF

R_OPS = {"add": (0, 0), "sub": (0x20, 0), "sll": (0, 1), "slt": (0, 2), "sltu": (0, 3),
         "xor": (0, 4), "srl": (0, 5), "sra": (0x20, 5), "or": (0, 6), "and": (0, 7),
         "mul": (1, 0), "mulh": (1, 1), "mulhsu": (1, 2), "mulhu": (1, 3),
         "div": (1, 4), "divu": (1, 5), "rem": (1, 6), "remu": (1, 7)}
I_OPS = {"addi": 0, "slti": 2, "sltiu": 3, "xori": 4, "ori": 6, "andi": 7}
SH_OPS = {"slli": (0, 1), "srli": (0, 5), "srai": (0x20, 5)}
LOADS = {"lb": 0, "lh": 1, "lw": 2, "lbu": 4, "lhu": 5}
STORES = {"sb": 0, "sh": 1, "sw": 2}
BRANCHES = {"beq": 0, "bne": 1, "blt": 4, "bge": 5, "bltu": 6, "bgeu": 7}
BR_PSEUDO_Z = {"beqz": ("beq", False), "bnez": ("bne", False), "bltz": ("blt", False),
               "bgez": ("bge", False), "blez": ("bge", True), "bgtz": ("blt", True)}
BR_SWAP = {"bgt": "blt", "ble": "bge", "bgtu": "bltu", "bleu": "bgeu"}


class AsmError(Exception):
    pass


def sext(v, bits):
    v &= (1 << bits) - 1
    return v - (1 << bits) if v >> (bits - 1) else v


def enc_r(f7, rs2, rs1, f3, rd, op):
    return (f7 << 25) | (rs2 << 20) | (rs1 << 15) | (f3 << 12) | (rd << 7) | op


def enc_i(imm, rs1, f3, rd, op):
    if not -2048 <= imm <= 2047:
        raise AsmError(f"I-immediate out of range: {imm}")
    return ((imm & 0xFFF) << 20) | (rs1 << 15) | (f3 << 12) | (rd << 7) | op


def enc_s(imm, rs2, rs1, f3, op):
    if not -2048 <= imm <= 2047:
        raise AsmError(f"S-immediate out of range: {imm}")
    imm &= 0xFFF
    return ((imm >> 5) << 25) | (rs2 << 20) | (rs1 << 15) | (f3 << 12) | ((imm & 0x1F) << 7) | op


def enc_b(imm, rs2, rs1, f3, op):
    if imm % 2 or not -4096 <= imm <= 4094:
        raise AsmError(f"branch offset out of range: {imm}")
    imm &= 0x1FFF
    return (((imm >> 12) & 1) << 31) | (((imm >> 5) & 0x3F) << 25) | (rs2 << 20) | (rs1 << 15) | \
           (f3 << 12) | (((imm >> 1) & 0xF) << 8) | (((imm >> 11) & 1) << 7) | op


def enc_u(imm20, rd, op):
    return ((imm20 & 0xFFFFF) << 12) | (rd << 7) | op


def enc_j(imm, rd, op):
    if imm % 2 or not -(1 << 20) <= imm < (1 << 20):
        raise AsmError(f"jump offset out of range: {imm}")
    imm &= 0x1FFFFF
    return (((imm >> 20) & 1) << 31) | (((imm >> 1) & 0x3FF) << 21) | (((imm >> 11) & 1) << 20) | \
           (((imm >> 12) & 0xFF) << 12) | (rd << 7) | op


def reg(tok):
    t = tok.strip()
    if t not in REGS:
        raise AsmError(f"unknown register '{tok}'")
    return REGS[t]


def is_number(tok):
    try:
        int(tok.strip(), 0)
        return True
    except ValueError:
        return False


def strip_comment(line):
    out, in_str = [], False
    i = 0
    while i < len(line):
        c = line[i]
        if c == '"' and (i == 0 or line[i - 1] != '\\'):
            in_str = not in_str
        if not in_str and (c == '#' or line.startswith('//', i)):
            break
        out.append(c)
        i += 1
    return "".join(out).strip()


def parse_string(tok):
    tok = tok.strip()
    if not (tok.startswith('"') and tok.endswith('"')):
        raise AsmError(f"bad string literal {tok}")
    return tok[1:-1].encode().decode("unicode_escape").encode("latin-1")


def li_split(v):
    """Split a 32-bit constant into (hi20, lo12) for lui+addi."""
    v &= M32
    lo = sext(v & 0xFFF, 12)
    hi = ((v - lo) >> 12) & 0xFFFFF
    return hi, lo


def fits12(v):
    return -2048 <= sext(v & M32, 32) <= 2047


def assemble(text):
    syms = {}
    items = []          # (addr, kind, payload, lineno)
    addr = 0

    def eval_expr(tok, pc=None, lineno=0):
        tok = tok.strip()
        if is_number(tok):
            return int(tok, 0)
        m = re.fullmatch(r"([A-Za-z_.][\w.]*)\s*([+-])\s*(\w+)", tok)
        if m:
            base = eval_expr(m.group(1), pc, lineno)
            off = int(m.group(3), 0)
            return base + off if m.group(2) == "+" else base - off
        if tok in syms:
            return syms[tok]
        raise AsmError(f"line {lineno}: undefined symbol '{tok}'")

    # ---------------- pass 1: sizes and labels ----------------
    for lineno, raw in enumerate(text.splitlines(), 1):
        line = strip_comment(raw)
        while True:
            m = re.match(r"^([A-Za-z_.][\w.]*)\s*:\s*(.*)$", line)
            if not m:
                break
            if m.group(1) in syms:
                raise AsmError(f"line {lineno}: duplicate label {m.group(1)}")
            syms[m.group(1)] = addr
            line = m.group(2).strip()
        if not line:
            continue
        parts = line.split(None, 1)
        mn = parts[0].lower()
        rest = parts[1].strip() if len(parts) > 1 else ""
        if mn in (".text", ".data", ".globl", ".global", ".section"):
            continue
        if mn == ".equ":
            name, val = [x.strip() for x in rest.split(",", 1)]
            syms[name] = eval_expr(val, lineno=lineno)
            continue
        if mn == ".align":
            a = 1 << int(rest, 0)
            pad = (-addr) % a
            items.append((addr, "bytes", bytes(pad), lineno))
            addr += pad
            continue
        if mn == ".space":
            n = int(rest, 0)
            items.append((addr, "bytes", bytes(n), lineno))
            addr += n
            continue
        if mn in (".ascii", ".asciz", ".string"):
            b = parse_string(rest) + (b"\0" if mn != ".ascii" else b"")
            items.append((addr, "bytes", b, lineno))
            addr += len(b)
            continue
        if mn in (".word", ".byte"):
            vals = [v.strip() for v in rest.split(",") if v.strip()]
            items.append((addr, mn, vals, lineno))
            addr += len(vals) * (4 if mn == ".word" else 1)
            continue
        if addr % 4:
            raise AsmError(f"line {lineno}: instruction at unaligned address {addr:#x} (use .align 2)")
        ops = [o.strip() for o in rest.split(",")] if rest else []
        if mn in ("li", "la"):
            if mn == "li" and len(ops) == 2 and is_number(ops[1]):
                n = 1 if fits12(int(ops[1], 0)) else 2
            else:
                n = 2   # symbolic operand: value unknown in pass 1, always lui+addi
        else:
            n = 1
        items.append((addr, "insn", (mn, ops), lineno))
        addr += 4 * n

    # ---------------- pass 2: encode ----------------
    out = bytearray()
    for (a, kind, payload, lineno) in items:
        assert len(out) == a, "internal address mismatch"
        try:
            if kind == "bytes":
                out += payload
            elif kind == ".word":
                for v in payload:
                    out += (eval_expr(v, lineno=lineno) & M32).to_bytes(4, "little")
            elif kind == ".byte":
                for v in payload:
                    out += bytes([eval_expr(v, lineno=lineno) & 0xFF])
            else:
                for w in encode(payload[0], payload[1], a, eval_expr, lineno):
                    out += (w & M32).to_bytes(4, "little")
        except AsmError as e:
            raise AsmError(f"line {lineno}: {e}") from None
    while len(out) % 4:
        out.append(0)
    return bytes(out), syms


def mem_operand(tok, ev, lineno):
    m = re.fullmatch(r"(.*)\(\s*(\w+)\s*\)", tok.strip())
    if not m:
        raise AsmError(f"bad memory operand '{tok}'")
    off = m.group(1).strip()
    return (ev(off, lineno=lineno) if off else 0), reg(m.group(2))


def encode(mn, ops, pc, ev, lineno):
    def target(tok):
        return ev(tok, pc, lineno) - pc

    if mn in R_OPS:
        f7, f3 = R_OPS[mn]
        return [enc_r(f7, reg(ops[2]), reg(ops[1]), f3, reg(ops[0]), 0x33)]
    if mn in I_OPS:
        return [enc_i(ev(ops[2], lineno=lineno), reg(ops[1]), I_OPS[mn], reg(ops[0]), 0x13)]
    if mn in SH_OPS:
        f7, f3 = SH_OPS[mn]
        sh = ev(ops[2], lineno=lineno)
        if not 0 <= sh < 32:
            raise AsmError("shift amount out of range")
        return [enc_r(f7, sh, reg(ops[1]), f3, reg(ops[0]), 0x13)]
    if mn in LOADS:
        off, rs1 = mem_operand(ops[1], ev, lineno)
        return [enc_i(off, rs1, LOADS[mn], reg(ops[0]), 0x03)]
    if mn in STORES:
        off, rs1 = mem_operand(ops[1], ev, lineno)
        return [enc_s(off, reg(ops[0]), rs1, STORES[mn], 0x23)]
    if mn in BRANCHES:
        return [enc_b(target(ops[2]), reg(ops[1]), reg(ops[0]), BRANCHES[mn], 0x63)]
    if mn in BR_PSEUDO_Z:
        base, swap = BR_PSEUDO_Z[mn]
        rs = reg(ops[0])
        a, b = (0, rs) if swap else (rs, 0)
        return [enc_b(target(ops[1]), b, a, BRANCHES[base], 0x63)]
    if mn in BR_SWAP:
        return [enc_b(target(ops[2]), reg(ops[0]), reg(ops[1]), BRANCHES[BR_SWAP[mn]], 0x63)]
    if mn == "lui":
        return [enc_u(ev(ops[1], lineno=lineno), reg(ops[0]), 0x37)]
    if mn == "auipc":
        return [enc_u(ev(ops[1], lineno=lineno), reg(ops[0]), 0x17)]
    if mn == "jal":
        if len(ops) == 1:
            return [enc_j(target(ops[0]), 1, 0x6F)]
        return [enc_j(target(ops[1]), reg(ops[0]), 0x6F)]
    if mn == "j":
        return [enc_j(target(ops[0]), 0, 0x6F)]
    if mn == "jalr":
        if len(ops) == 1:
            return [enc_i(0, reg(ops[0]), 0, 1, 0x67)]
        if len(ops) == 2:
            off, rs1 = mem_operand(ops[1], ev, lineno)
            return [enc_i(off, rs1, 0, reg(ops[0]), 0x67)]
        return [enc_i(ev(ops[2], lineno=lineno), reg(ops[1]), 0, reg(ops[0]), 0x67)]
    if mn == "jr":
        return [enc_i(0, reg(ops[0]), 0, 0, 0x67)]
    if mn == "ret":
        return [enc_i(0, 1, 0, 0, 0x67)]
    if mn == "nop":
        return [enc_i(0, 0, 0, 0, 0x13)]
    if mn == "mv":
        return [enc_i(0, reg(ops[1]), 0, reg(ops[0]), 0x13)]
    if mn == "not":
        return [enc_i(-1, reg(ops[1]), 4, reg(ops[0]), 0x13)]
    if mn == "neg":
        return [enc_r(0x20, reg(ops[1]), 0, 0, reg(ops[0]), 0x33)]
    if mn == "seqz":
        return [enc_i(1, reg(ops[1]), 3, reg(ops[0]), 0x13)]
    if mn == "snez":
        return [enc_r(0, reg(ops[1]), 0, 3, reg(ops[0]), 0x33)]
    if mn in ("li", "la"):
        rd = reg(ops[0])
        v = ev(ops[1], pc, lineno) & M32
        literal = mn == "li" and is_number(ops[1])
        if literal and fits12(v):
            return [enc_i(sext(v, 32), 0, 0, rd, 0x13)]
        hi, lo = li_split(v)          # symbolic operands always use the 2 words reserved in pass 1
        return [enc_u(hi, rd, 0x37), enc_i(lo, rd, 0, rd, 0x13)]
    raise AsmError(f"unknown mnemonic '{mn}'")


def to_hex(binary):
    return "".join(f"{int.from_bytes(binary[i:i+4], 'little'):08x}\n" for i in range(0, len(binary), 4))


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("source")
    ap.add_argument("-o", "--output", required=True, help="output .hex file")
    args = ap.parse_args()
    with open(args.source) as f:
        try:
            binary, _ = assemble(f.read())
        except AsmError as e:
            sys.exit(f"{args.source}: {e}")
    with open(args.output, "w") as f:
        f.write(to_hex(binary))
    print(f"{args.source}: {len(binary)//4} words -> {args.output}")


if __name__ == "__main__":
    main()
