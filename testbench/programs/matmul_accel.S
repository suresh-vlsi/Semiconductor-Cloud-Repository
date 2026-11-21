.equ SYSCON, 0x40000000
.equ UART, 0x20000000
.equ GPIO, 0x30000000
.equ ACCEL, 0x50000000
_start:
    li   s6, ACCEL
    li   s7, SYSCON
    lw   s8, 8(s7)            # start cycle
    # copy A, B into the accelerator buffers
    la   t0, A
    addi t1, s6, 0x100
    li   t2, 4
cpa:
    lw   t3, 0(t0)
    sw   t3, 0(t1)
    addi t0, t0, 4
    addi t1, t1, 4
    addi t2, t2, -1
    bnez t2, cpa
    la   t0, B
    addi t1, s6, 0x200
    li   t2, 4
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
    li   t2, 16
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
