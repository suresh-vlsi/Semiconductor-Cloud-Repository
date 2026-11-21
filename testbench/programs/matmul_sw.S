.equ SYSCON, 0x40000000
.equ UART, 0x20000000
.equ GPIO, 0x30000000
.equ ACCEL, 0x50000000
_start:
    la   s0, A
    la   s1, B
    la   s2, C
    li   s7, SYSCON
    lw   s8, 8(s7)            # start cycle
    li   t1, 4
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
    addi t3, t3, 4
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

    # ---- verify C against expected ----
    la   t0, C
    la   t1, EXP
    li   t2, 16
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
    .align 2
A:
    .byte -106, 70, 39, -16, -18, 91, -106, 50, -77, -104, 6, 121, 60, 66, 55, 73
    .align 2
B:
    .byte 3, -96, 86, -13, 0, -34, -82, 109, 72, 36, -25, 82, 11, -15, -13, -70
    .align 2
EXP:
    .word 2314, 9440, -15623, 13326, -7136, -5932, -7010, -2039, 1532, 9329, 183, -18313, 4943, -7119, -2576, 5814
C:
    .space 64
