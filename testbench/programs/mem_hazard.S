.equ SYSCON, 0x40000000
.equ UART, 0x20000000
.equ GPIO, 0x30000000
.equ ACCEL, 0x50000000

_start:
    li   s0, 0x8000            # scratch RAM
    li   t0, 0x8091A2B3
    sw   t0, 0(s0)
    lbu  t1, 0(s0)
    lbu  t2, 1(s0)
    lb   t3, 2(s0)
    lb   t4, 3(s0)
    li   a0, 2
    li   a1, 179
    beq  t1, a1, ok_2
    j    fail
ok_2:
    li   a0, 3
    li   a1, 162
    beq  t2, a1, ok_3
    j    fail
ok_3:
    li   a0, 4
    li   a1, 4294967185
    beq  t3, a1, ok_4
    j    fail
ok_4:
    li   a0, 5
    li   a1, 4294967168
    beq  t4, a1, ok_5
    j    fail
ok_5:
    lhu  t1, 0(s0)
    lh   t2, 2(s0)
    lh   t3, 0(s0)
    lhu  t4, 2(s0)
    li   a0, 6
    li   a1, 41651
    beq  t1, a1, ok_6
    j    fail
ok_6:
    li   a0, 7
    li   a1, 4294934673
    beq  t2, a1, ok_7
    j    fail
ok_7:
    li   a0, 8
    li   a1, 4294943411
    beq  t3, a1, ok_8
    j    fail
ok_8:
    li   a0, 9
    li   a1, 32913
    beq  t4, a1, ok_9
    j    fail
ok_9:
    li   t0, 0x11223344
    sw   t0, 4(s0)
    li   t1, 0xAA
    sb   t1, 5(s0)
    lw   t2, 4(s0)
    li   a0, 10
    li   a1, 287484484
    beq  t2, a1, ok_10
    j    fail
ok_10:
    li   t1, 0xBEEF
    sh   t1, 6(s0)
    lw   t2, 4(s0)
    li   a0, 11
    li   a1, 3203377732
    beq  t2, a1, ok_11
    j    fail
ok_11:
    li   t0, 100
    sw   t0, 8(s0)
    lw   t1, 8(s0)
    addi t2, t1, 1
    add  t3, t2, t1
    li   a0, 12
    li   a1, 101
    beq  t2, a1, ok_12
    j    fail
ok_12:
    li   a0, 13
    li   a1, 201
    beq  t3, a1, ok_13
    j    fail
ok_13:
    li   t0, 1
    add  t1, t0, t0
    add  t2, t1, t0
    add  t3, t2, t1
    add  t4, t3, t2
    li   a0, 14
    li   a1, 8
    beq  t4, a1, ok_14
    j    fail
ok_14:
    li   t0, 55
    addi t1, t0, 5
    sw   t1, 12(s0)
    lw   t2, 12(s0)
    li   a0, 15
    li   a1, 60
    beq  t2, a1, ok_15
    j    fail
ok_15:
    li   t0, 5
    li   t1, 0
    beq  t0, t0, skip1
    addi t1, t1, 100
    addi t1, t1, 100
skip1:
    addi t1, t1, 1
    li   a0, 16
    li   a1, 1
    beq  t1, a1, ok_16
    j    fail
ok_16:
    li   t2, 0
    bne  t0, t0, bad
    addi t2, t2, 7
    li   a0, 17
    li   a1, 7
    beq  t2, a1, ok_17
    j    fail
ok_17:
    li   t0, -1
    li   t1, 1
    li   t2, 0
    blt  t0, t1, l1
    j    fail
l1:
    bltu t0, t1, bad
    bgeu t0, t1, l2
    j    fail
l2:
    addi t2, t2, 1
    li   a0, 18
    li   a1, 1
    beq  t2, a1, ok_18
    j    fail
ok_18:
    li   t0, 0
    jal  ra, func_inc
    jal  ra, func_inc
    li   a0, 19
    li   a1, 20
    beq  t0, a1, ok_19
    j    fail
ok_19:
    auipc t0, 0
    jal  t1, after_jal
after_jal:
    sub  t2, t1, t0
    li   a0, 20
    li   a1, 8
    beq  t2, a1, ok_20
    j    fail
ok_20:
    addi x0, x0, 5
    add  t0, x0, x0
    li   a0, 21
    li   a1, 0
    beq  t0, a1, ok_21
    j    fail
ok_21:
    li   t0, 10
    li   t1, 0
cnt:
    add  t1, t1, t0
    addi t0, t0, -1
    bnez t0, cnt
    li   a0, 22
    li   a1, 55
    beq  t1, a1, ok_22
    j    fail
ok_22:
    j    pass
bad:
    li   a0, 99
    j    fail
func_inc:
    addi t0, t0, 10
    ret

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

