.equ SYSCON, 0x40000000
.equ UART, 0x20000000
.equ GPIO, 0x30000000
.equ ACCEL, 0x50000000
_start:
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

msg:
    .asciz "Hello, VLSI!\n"
