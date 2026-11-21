#!/usr/bin/env python3
"""Cycle-accurate Python model of rtl/systolic_array.v + accel_top.v control timing.

Checks (a) the skewed-feed schedule produces A@B exactly and (b) the latency is 3N-2 RUN cycles.
Run:  python3 python/golden_systolic.py
"""
import numpy as np


def systolic_matmul(A, B):
    n = A.shape[0]
    acc = np.zeros((n, n), dtype=np.int64)
    a_reg = np.zeros((n, n), dtype=np.int64)    # a_out registers of each PE (flows right)
    b_reg = np.zeros((n, n), dtype=np.int64)    # b_out registers of each PE (flows down)
    cycles = 0
    for t in range(3 * n - 2):                  # RUN state: t = 0 .. 3N-3
        a_edge = [int(A[i, t - i]) if 0 <= t - i < n else 0 for i in range(n)]
        b_edge = [int(B[t - j, j]) if 0 <= t - j < n else 0 for j in range(n)]
        a_in = np.zeros((n, n), dtype=np.int64)
        b_in = np.zeros((n, n), dtype=np.int64)
        for i in range(n):
            for j in range(n):
                a_in[i, j] = a_edge[i] if j == 0 else a_reg[i, j - 1]
                b_in[i, j] = b_edge[j] if i == 0 else b_reg[i - 1, j]
        acc += a_in * b_in                      # all registers update on the same clock edge
        a_reg, b_reg = a_in.copy(), b_in.copy()
        cycles += 1
    return acc, cycles


def main():
    rng = np.random.default_rng(7)
    for n in (2, 4, 8):
        for _ in range(200):
            A = rng.integers(-128, 128, (n, n))
            B = rng.integers(-128, 128, (n, n))
            C, cyc = systolic_matmul(A, B)
            assert np.array_equal(C, A @ B), f"mismatch for N={n}"
            assert cyc == 3 * n - 2
        print(f"N={n}: 200 random INT8 matmuls match numpy, RUN latency = {3*n-2} cycles")
    print("systolic timing model OK")


if __name__ == "__main__":
    main()
