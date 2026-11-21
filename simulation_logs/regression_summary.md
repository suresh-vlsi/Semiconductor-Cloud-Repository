| program | ISS | instructions | RTL | RTL cycles | kernel cycles |
|---|---|---|---|---|---|
| hello | PASS | 114 | PASS | 603 | 0 |
| alu_test | PASS | 2747 | PASS | 3519 | 0 |
| mem_hazard | PASS | 169 | PASS | 250 | 0 |
| matmul_sw | PASS | 855 | PASS | 1128 | 909 |
| matmul_accel | PASS | 294 | PASS | 456 | 241 |

Accelerator speed-up (4x4 INT8 matmul, copy-in + compute + copy-out): 3.8x (909 vs 241 cycles)
