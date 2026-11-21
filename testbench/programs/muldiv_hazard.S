.equ SYSCON, 0x40000000
.equ UART, 0x20000000
.equ GPIO, 0x30000000
.equ ACCEL, 0x50000000

_start:
    li   s0, 0x8000
    li   t0, 123456
    sw   t0, 0(s0)
    li   t1, 4294967219
    sw   t1, 4(s0)
    lw   t2, 0(s0)
    lw   t3, 4(s0)
    mul  t4, t2, t3
    lw   t2, 0(s0)
    lw   t3, 4(s0)
    div  t5, t2, t3
    li   a0, 2
    li   a1, 4285461184
    beq  t4, a1, ok_2
    j    fail
ok_2:
    li   a0, 3
    li   a1, 4294965693
    beq  t5, a1, ok_3
    j    fail
ok_3:
    li   t0, 1000003
    li   t1, 12345
    mul  t2, t0, t1
    add  t3, t2, t0
    mulh t4, t2, t3
    li   a0, 4
    li   a1, 3756102446
    beq  t3, a1, ok_4
    j    fail
ok_4:
    li   a0, 5
    li   a1, 67733738
    beq  t4, a1, ok_5
    j    fail
ok_5:
    li   t0, 4294967291
    li   t1, 3
    mul    s1, t0, t1
    mulh   s2, t0, t1
    mulhu  s3, t0, t1
    mulhsu s4, t0, t1
    div    s5, t0, t1
    divu   s6, t0, t1
    rem    s7, t0, t1
    remu   s8, t0, t1
    li   a0, 6
    li   a1, 4294967281
    beq  s1, a1, ok_6
    j    fail
ok_6:
    li   a0, 7
    li   a1, 4294967295
    beq  s2, a1, ok_7
    j    fail
ok_7:
    li   a0, 8
    li   a1, 2
    beq  s3, a1, ok_8
    j    fail
ok_8:
    li   a0, 9
    li   a1, 4294967295
    beq  s4, a1, ok_9
    j    fail
ok_9:
    li   a0, 10
    li   a1, 4294967295
    beq  s5, a1, ok_10
    j    fail
ok_10:
    li   a0, 11
    li   a1, 1431655763
    beq  s6, a1, ok_11
    j    fail
ok_11:
    li   a0, 12
    li   a1, 4294967294
    beq  s7, a1, ok_12
    j    fail
ok_12:
    li   a0, 13
    li   a1, 2
    beq  s8, a1, ok_13
    j    fail
ok_13:
    li   t0, 2147483647
    li   t1, 2147483647
    mulhu t2, t0, t1
    sw   t2, 8(s0)
    lw   t3, 8(s0)
    li   a0, 14
    li   a1, 1073741823
    beq  t3, a1, ok_14
    j    fail
ok_14:
    li   t0, 6
    li   t1, 7
    mul  t2, t0, t1
    li   t3, 42
    beq  t2, t3, mb_ok
    j    bad
mb_ok:
    li   t4, 0
    bne  t2, t3, bad
    addi t4, t4, 1
    li   a0, 15
    li   a1, 1
    beq  t4, a1, ok_15
    j    fail
ok_15:
    li   t0, 9
    li   t1, 4
    add  t5, t0, t1
    mul  t2, t0, t1
    add  t6, t5, t2
    li   a0, 16
    li   a1, 49
    beq  t6, a1, ok_16
    j    fail
ok_16:
    li   t0, 3
    li   t1, 5
    mul  t2, t0, t1
    addi a2, t0, 100
    addi a3, t1, 200
    sub  a4, a3, a2
    li   a0, 17
    li   a1, 103
    beq  a2, a1, ok_17
    j    fail
ok_17:
    li   a0, 18
    li   a1, 205
    beq  a3, a1, ok_18
    j    fail
ok_18:
    li   a0, 19
    li   a1, 102
    beq  a4, a1, ok_19
    j    fail
ok_19:
    li   t0, 1
    li   t1, 1
    li   t2, 11
fact:
    mul  t0, t0, t1
    addi t1, t1, 1
    blt  t1, t2, fact
    li   a0, 20
    li   a1, 3628800
    beq  t0, a1, ok_20
    j    fail
ok_20:
    li   t0, 0x80000000
    li   t1, -1
    li   t2, 0
    div  t3, t0, t1
    rem  t4, t0, t1
    div  t5, t0, t2
    rem  t6, t0, t2
    li   a0, 21
    li   a1, 2147483648
    beq  t3, a1, ok_21
    j    fail
ok_21:
    li   a0, 22
    li   a1, 0
    beq  t4, a1, ok_22
    j    fail
ok_22:
    li   a0, 23
    li   a1, 4294967295
    beq  t5, a1, ok_23
    j    fail
ok_23:
    li   a0, 24
    li   a1, 2147483648
    beq  t6, a1, ok_24
    j    fail
ok_24:
    j    pass
bad:
    li   a0, 99
    j    fail

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
