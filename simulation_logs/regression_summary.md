| program | ISS | instructions | RTL | RTL cycles | kernel cycles |
|---|---|---|---|---|---|
| hello | PASS | 114 | PASS | 603 | 0 |
| alu_test | PASS | 2747 | PASS | 8143 | 0 |
| mem_hazard | PASS | 169 | PASS | 250 | 0 |
| muldiv_hazard | PASS | 179 | PASS | 1271 | 0 |
| matmul_sw | PASS | 855 | PASS | 4392 | 4173 |
| matmul_accel | PASS | 294 | PASS | 456 | 241 |

Accelerator speed-up (4x4 INT8 matmul, copy-in + compute + copy-out): 17.3x (4173 vs 241 cycles)
