.equ SYSCON, 0x40000000
.equ UART, 0x20000000
.equ GPIO, 0x30000000
.equ ACCEL, 0x50000000

_start:
    li   t0, 2147483648
    li   t1, 4294967295
    add  t2, t0, t1
    li   a0, 2
    li   a1, 2147483647
    beq  t2, a1, ok_2
    j    fail
ok_2:
    li   t0, 4294967295
    li   t1, 0
    add  t2, t0, t1
    li   a0, 3
    li   a1, 4294967295
    beq  t2, a1, ok_3
    j    fail
ok_3:
    li   t0, 7
    li   t1, 0
    add  t2, t0, t1
    li   a0, 4
    li   a1, 7
    beq  t2, a1, ok_4
    j    fail
ok_4:
    li   t0, 2147483648
    li   t1, 1
    add  t2, t0, t1
    li   a0, 5
    li   a1, 2147483649
    beq  t2, a1, ok_5
    j    fail
ok_5:
    li   t0, 4294967295
    li   t1, 4294967295
    add  t2, t0, t1
    li   a0, 6
    li   a1, 4294967294
    beq  t2, a1, ok_6
    j    fail
ok_6:
    li   t0, 5
    li   t1, 3
    add  t2, t0, t1
    li   a0, 7
    li   a1, 8
    beq  t2, a1, ok_7
    j    fail
ok_7:
    li   t0, 4294967291
    li   t1, 3
    add  t2, t0, t1
    li   a0, 8
    li   a1, 4294967294
    beq  t2, a1, ok_8
    j    fail
ok_8:
    li   t0, 305419896
    li   t1, 1
    add  t2, t0, t1
    li   a0, 9
    li   a1, 305419897
    beq  t2, a1, ok_9
    j    fail
ok_9:
    li   t0, 0
    li   t1, 1
    add  t2, t0, t1
    li   a0, 10
    li   a1, 1
    beq  t2, a1, ok_10
    j    fail
ok_10:
    li   t0, 31
    li   t1, 0
    add  t2, t0, t1
    li   a0, 11
    li   a1, 31
    beq  t2, a1, ok_11
    j    fail
ok_11:
    li   t0, 32
    li   t1, 65535
    add  t2, t0, t1
    li   a0, 12
    li   a1, 65567
    beq  t2, a1, ok_12
    j    fail
ok_12:
    li   t0, 360511942
    li   t1, 422719469
    add  t2, t0, t1
    li   a0, 13
    li   a1, 783231411
    beq  t2, a1, ok_13
    j    fail
ok_13:
    li   t0, 3292010550
    li   t1, 1523148328
    add  t2, t0, t1
    li   a0, 14
    li   a1, 520191582
    beq  t2, a1, ok_14
    j    fail
ok_14:
    li   t0, 1017090249
    li   t1, 74852898
    add  t2, t0, t1
    li   a0, 15
    li   a1, 1091943147
    beq  t2, a1, ok_15
    j    fail
ok_15:
    li   t0, 132345184
    li   t1, 4237793703
    add  t2, t0, t1
    li   a0, 16
    li   a1, 75171591
    beq  t2, a1, ok_16
    j    fail
ok_16:
    li   t0, 3387753032
    li   t1, 68034096
    add  t2, t0, t1
    li   a0, 17
    li   a1, 3455787128
    beq  t2, a1, ok_17
    j    fail
ok_17:
    li   t0, 1486440787
    li   t1, 2784496138
    add  t2, t0, t1
    li   a0, 18
    li   a1, 4270936925
    beq  t2, a1, ok_18
    j    fail
ok_18:
    li   t0, 2147483648
    li   t1, 4294967295
    sub  t2, t0, t1
    li   a0, 19
    li   a1, 2147483649
    beq  t2, a1, ok_19
    j    fail
ok_19:
    li   t0, 4294967295
    li   t1, 0
    sub  t2, t0, t1
    li   a0, 20
    li   a1, 4294967295
    beq  t2, a1, ok_20
    j    fail
ok_20:
    li   t0, 7
    li   t1, 0
    sub  t2, t0, t1
    li   a0, 21
    li   a1, 7
    beq  t2, a1, ok_21
    j    fail
ok_21:
    li   t0, 2147483648
    li   t1, 1
    sub  t2, t0, t1
    li   a0, 22
    li   a1, 2147483647
    beq  t2, a1, ok_22
    j    fail
ok_22:
    li   t0, 4294967295
    li   t1, 4294967295
    sub  t2, t0, t1
    li   a0, 23
    li   a1, 0
    beq  t2, a1, ok_23
    j    fail
ok_23:
    li   t0, 5
    li   t1, 3
    sub  t2, t0, t1
    li   a0, 24
    li   a1, 2
    beq  t2, a1, ok_24
    j    fail
ok_24:
    li   t0, 4294967291
    li   t1, 3
    sub  t2, t0, t1
    li   a0, 25
    li   a1, 4294967288
    beq  t2, a1, ok_25
    j    fail
ok_25:
    li   t0, 31
    li   t1, 305419896
    sub  t2, t0, t1
    li   a0, 26
    li   a1, 3989547431
    beq  t2, a1, ok_26
    j    fail
ok_26:
    li   t0, 31
    li   t1, 305419896
    sub  t2, t0, t1
    li   a0, 27
    li   a1, 3989547431
    beq  t2, a1, ok_27
    j    fail
ok_27:
    li   t0, 4294967295
    li   t1, 1
    sub  t2, t0, t1
    li   a0, 28
    li   a1, 4294967294
    beq  t2, a1, ok_28
    j    fail
ok_28:
    li   t0, 4294967295
    li   t1, 65535
    sub  t2, t0, t1
    li   a0, 29
    li   a1, 4294901760
    beq  t2, a1, ok_29
    j    fail
ok_29:
    li   t0, 491399954
    li   t1, 3630744271
    sub  t2, t0, t1
    li   a0, 30
    li   a1, 1155622979
    beq  t2, a1, ok_30
    j    fail
ok_30:
    li   t0, 62787174
    li   t1, 2160727991
    sub  t2, t0, t1
    li   a0, 31
    li   a1, 2197026479
    beq  t2, a1, ok_31
    j    fail
ok_31:
    li   t0, 2090581934
    li   t1, 3781591665
    sub  t2, t0, t1
    li   a0, 32
    li   a1, 2603957565
    beq  t2, a1, ok_32
    j    fail
ok_32:
    li   t0, 4144220671
    li   t1, 1073003404
    sub  t2, t0, t1
    li   a0, 33
    li   a1, 3071217267
    beq  t2, a1, ok_33
    j    fail
ok_33:
    li   t0, 277292886
    li   t1, 2865840744
    sub  t2, t0, t1
    li   a0, 34
    li   a1, 1706419438
    beq  t2, a1, ok_34
    j    fail
ok_34:
    li   t0, 2323956060
    li   t1, 3918363701
    sub  t2, t0, t1
    li   a0, 35
    li   a1, 2700559655
    beq  t2, a1, ok_35
    j    fail
ok_35:
    li   t0, 2147483648
    li   t1, 4294967295
    sll  t2, t0, t1
    li   a0, 36
    li   a1, 0
    beq  t2, a1, ok_36
    j    fail
ok_36:
    li   t0, 4294967295
    li   t1, 0
    sll  t2, t0, t1
    li   a0, 37
    li   a1, 4294967295
    beq  t2, a1, ok_37
    j    fail
ok_37:
    li   t0, 7
    li   t1, 0
    sll  t2, t0, t1
    li   a0, 38
    li   a1, 7
    beq  t2, a1, ok_38
    j    fail
ok_38:
    li   t0, 2147483648
    li   t1, 1
    sll  t2, t0, t1
    li   a0, 39
    li   a1, 0
    beq  t2, a1, ok_39
    j    fail
ok_39:
    li   t0, 4294967295
    li   t1, 4294967295
    sll  t2, t0, t1
    li   a0, 40
    li   a1, 2147483648
    beq  t2, a1, ok_40
    j    fail
ok_40:
    li   t0, 5
    li   t1, 3
    sll  t2, t0, t1
    li   a0, 41
    li   a1, 40
    beq  t2, a1, ok_41
    j    fail
ok_41:
    li   t0, 4294967291
    li   t1, 3
    sll  t2, t0, t1
    li   a0, 42
    li   a1, 4294967256
    beq  t2, a1, ok_42
    j    fail
ok_42:
    li   t0, 305419896
    li   t1, 1
    sll  t2, t0, t1
    li   a0, 43
    li   a1, 610839792
    beq  t2, a1, ok_43
    j    fail
ok_43:
    li   t0, 31
    li   t1, 32
    sll  t2, t0, t1
    li   a0, 44
    li   a1, 31
    beq  t2, a1, ok_44
    j    fail
ok_44:
    li   t0, 1
    li   t1, 3735928559
    sll  t2, t0, t1
    li   a0, 45
    li   a1, 32768
    beq  t2, a1, ok_45
    j    fail
ok_45:
    li   t0, 31
    li   t1, 0
    sll  t2, t0, t1
    li   a0, 46
    li   a1, 31
    beq  t2, a1, ok_46
    j    fail
ok_46:
    li   t0, 1157860898
    li   t1, 3540692299
    sll  t2, t0, t1
    li   a0, 47
    li   a1, 477171712
    beq  t2, a1, ok_47
    j    fail
ok_47:
    li   t0, 2389859671
    li   t1, 270916581
    sll  t2, t0, t1
    li   a0, 48
    li   a1, 3461065440
    beq  t2, a1, ok_48
    j    fail
ok_48:
    li   t0, 2768682949
    li   t1, 1298922895
    sll  t2, t0, t1
    li   a0, 49
    li   a1, 1608679424
    beq  t2, a1, ok_49
    j    fail
ok_49:
    li   t0, 2066035487
    li   t1, 3651488269
    sll  t2, t0, t1
    li   a0, 50
    li   a1, 2791563264
    beq  t2, a1, ok_50
    j    fail
ok_50:
    li   t0, 1525740512
    li   t1, 1144412258
    sll  t2, t0, t1
    li   a0, 51
    li   a1, 1807994752
    beq  t2, a1, ok_51
    j    fail
ok_51:
    li   t0, 1070100198
    li   t1, 2815272642
    sll  t2, t0, t1
    li   a0, 52
    li   a1, 4280400792
    beq  t2, a1, ok_52
    j    fail
ok_52:
    li   t0, 2147483648
    li   t1, 4294967295
    srl  t2, t0, t1
    li   a0, 53
    li   a1, 1
    beq  t2, a1, ok_53
    j    fail
ok_53:
    li   t0, 4294967295
    li   t1, 0
    srl  t2, t0, t1
    li   a0, 54
    li   a1, 4294967295
    beq  t2, a1, ok_54
    j    fail
ok_54:
    li   t0, 7
    li   t1, 0
    srl  t2, t0, t1
    li   a0, 55
    li   a1, 7
    beq  t2, a1, ok_55
    j    fail
ok_55:
    li   t0, 2147483648
    li   t1, 1
    srl  t2, t0, t1
    li   a0, 56
    li   a1, 1073741824
    beq  t2, a1, ok_56
    j    fail
ok_56:
    li   t0, 4294967295
    li   t1, 4294967295
    srl  t2, t0, t1
    li   a0, 57
    li   a1, 1
    beq  t2, a1, ok_57
    j    fail
ok_57:
    li   t0, 5
    li   t1, 3
    srl  t2, t0, t1
    li   a0, 58
    li   a1, 0
    beq  t2, a1, ok_58
    j    fail
ok_58:
    li   t0, 4294967291
    li   t1, 3
    srl  t2, t0, t1
    li   a0, 59
    li   a1, 536870911
    beq  t2, a1, ok_59
    j    fail
ok_59:
    li   t0, 2
    li   t1, 305419896
    srl  t2, t0, t1
    li   a0, 60
    li   a1, 0
    beq  t2, a1, ok_60
    j    fail
ok_60:
    li   t0, 3735928559
    li   t1, 32
    srl  t2, t0, t1
    li   a0, 61
    li   a1, 3735928559
    beq  t2, a1, ok_61
    j    fail
ok_61:
    li   t0, 0
    li   t1, 3735928559
    srl  t2, t0, t1
    li   a0, 62
    li   a1, 0
    beq  t2, a1, ok_62
    j    fail
ok_62:
    li   t0, 1
    li   t1, 0
    srl  t2, t0, t1
    li   a0, 63
    li   a1, 1
    beq  t2, a1, ok_63
    j    fail
ok_63:
    li   t0, 1432414906
    li   t1, 617480673
    srl  t2, t0, t1
    li   a0, 64
    li   a1, 716207453
    beq  t2, a1, ok_64
    j    fail
ok_64:
    li   t0, 3049483969
    li   t1, 2030776188
    srl  t2, t0, t1
    li   a0, 65
    li   a1, 11
    beq  t2, a1, ok_65
    j    fail
ok_65:
    li   t0, 2823316065
    li   t1, 1620694933
    srl  t2, t0, t1
    li   a0, 66
    li   a1, 1346
    beq  t2, a1, ok_66
    j    fail
ok_66:
    li   t0, 717742554
    li   t1, 232680712
    srl  t2, t0, t1
    li   a0, 67
    li   a1, 2803681
    beq  t2, a1, ok_67
    j    fail
ok_67:
    li   t0, 327422443
    li   t1, 2523415722
    srl  t2, t0, t1
    li   a0, 68
    li   a1, 319748
    beq  t2, a1, ok_68
    j    fail
ok_68:
    li   t0, 2132802046
    li   t1, 704388509
    srl  t2, t0, t1
    li   a0, 69
    li   a1, 3
    beq  t2, a1, ok_69
    j    fail
ok_69:
    li   t0, 2147483648
    li   t1, 4294967295
    sra  t2, t0, t1
    li   a0, 70
    li   a1, 4294967295
    beq  t2, a1, ok_70
    j    fail
ok_70:
    li   t0, 4294967295
    li   t1, 0
    sra  t2, t0, t1
    li   a0, 71
    li   a1, 4294967295
    beq  t2, a1, ok_71
    j    fail
ok_71:
    li   t0, 7
    li   t1, 0
    sra  t2, t0, t1
    li   a0, 72
    li   a1, 7
    beq  t2, a1, ok_72
    j    fail
ok_72:
    li   t0, 2147483648
    li   t1, 1
    sra  t2, t0, t1
    li   a0, 73
    li   a1, 3221225472
    beq  t2, a1, ok_73
    j    fail
ok_73:
    li   t0, 4294967295
    li   t1, 4294967295
    sra  t2, t0, t1
    li   a0, 74
    li   a1, 4294967295
    beq  t2, a1, ok_74
    j    fail
ok_74:
    li   t0, 5
    li   t1, 3
    sra  t2, t0, t1
    li   a0, 75
    li   a1, 0
    beq  t2, a1, ok_75
    j    fail
ok_75:
    li   t0, 4294967291
    li   t1, 3
    sra  t2, t0, t1
    li   a0, 76
    li   a1, 4294967295
    beq  t2, a1, ok_76
    j    fail
ok_76:
    li   t0, 1
    li   t1, 3735928559
    sra  t2, t0, t1
    li   a0, 77
    li   a1, 0
    beq  t2, a1, ok_77
    j    fail
ok_77:
    li   t0, 2
    li   t1, 4294967295
    sra  t2, t0, t1
    li   a0, 78
    li   a1, 0
    beq  t2, a1, ok_78
    j    fail
ok_78:
    li   t0, 0
    li   t1, 2147483648
    sra  t2, t0, t1
    li   a0, 79
    li   a1, 0
    beq  t2, a1, ok_79
    j    fail
ok_79:
    li   t0, 1
    li   t1, 3735928559
    sra  t2, t0, t1
    li   a0, 80
    li   a1, 0
    beq  t2, a1, ok_80
    j    fail
ok_80:
    li   t0, 606568618
    li   t1, 2879783370
    sra  t2, t0, t1
    li   a0, 81
    li   a1, 592352
    beq  t2, a1, ok_81
    j    fail
ok_81:
    li   t0, 1311651681
    li   t1, 1950523684
    sra  t2, t0, t1
    li   a0, 82
    li   a1, 81978230
    beq  t2, a1, ok_82
    j    fail
ok_82:
    li   t0, 170036136
    li   t1, 1787783462
    sra  t2, t0, t1
    li   a0, 83
    li   a1, 2656814
    beq  t2, a1, ok_83
    j    fail
ok_83:
    li   t0, 1188776900
    li   t1, 2844927732
    sra  t2, t0, t1
    li   a0, 84
    li   a1, 1133
    beq  t2, a1, ok_84
    j    fail
ok_84:
    li   t0, 3463944851
    li   t1, 172677953
    sra  t2, t0, t1
    li   a0, 85
    li   a1, 3879456073
    beq  t2, a1, ok_85
    j    fail
ok_85:
    li   t0, 761682555
    li   t1, 1166818523
    sra  t2, t0, t1
    li   a0, 86
    li   a1, 5
    beq  t2, a1, ok_86
    j    fail
ok_86:
    li   t0, 2147483648
    li   t1, 4294967295
    slt  t2, t0, t1
    li   a0, 87
    li   a1, 1
    beq  t2, a1, ok_87
    j    fail
ok_87:
    li   t0, 4294967295
    li   t1, 0
    slt  t2, t0, t1
    li   a0, 88
    li   a1, 1
    beq  t2, a1, ok_88
    j    fail
ok_88:
    li   t0, 7
    li   t1, 0
    slt  t2, t0, t1
    li   a0, 89
    li   a1, 0
    beq  t2, a1, ok_89
    j    fail
ok_89:
    li   t0, 2147483648
    li   t1, 1
    slt  t2, t0, t1
    li   a0, 90
    li   a1, 1
    beq  t2, a1, ok_90
    j    fail
ok_90:
    li   t0, 4294967295
    li   t1, 4294967295
    slt  t2, t0, t1
    li   a0, 91
    li   a1, 0
    beq  t2, a1, ok_91
    j    fail
ok_91:
    li   t0, 5
    li   t1, 3
    slt  t2, t0, t1
    li   a0, 92
    li   a1, 0
    beq  t2, a1, ok_92
    j    fail
ok_92:
    li   t0, 4294967291
    li   t1, 3
    slt  t2, t0, t1
    li   a0, 93
    li   a1, 1
    beq  t2, a1, ok_93
    j    fail
ok_93:
    li   t0, 4294967295
    li   t1, 2147483647
    slt  t2, t0, t1
    li   a0, 94
    li   a1, 1
    beq  t2, a1, ok_94
    j    fail
ok_94:
    li   t0, 4294967295
    li   t1, 305419896
    slt  t2, t0, t1
    li   a0, 95
    li   a1, 1
    beq  t2, a1, ok_95
    j    fail
ok_95:
    li   t0, 0
    li   t1, 31
    slt  t2, t0, t1
    li   a0, 96
    li   a1, 1
    beq  t2, a1, ok_96
    j    fail
ok_96:
    li   t0, 2147483649
    li   t1, 2147483648
    slt  t2, t0, t1
    li   a0, 97
    li   a1, 0
    beq  t2, a1, ok_97
    j    fail
ok_97:
    li   t0, 2129688544
    li   t1, 1467623790
    slt  t2, t0, t1
    li   a0, 98
    li   a1, 0
    beq  t2, a1, ok_98
    j    fail
ok_98:
    li   t0, 2503368040
    li   t1, 3506682143
    slt  t2, t0, t1
    li   a0, 99
    li   a1, 1
    beq  t2, a1, ok_99
    j    fail
ok_99:
    li   t0, 2010556464
    li   t1, 2044124891
    slt  t2, t0, t1
    li   a0, 100
    li   a1, 1
    beq  t2, a1, ok_100
    j    fail
ok_100:
    li   t0, 194687846
    li   t1, 3362488191
    slt  t2, t0, t1
    li   a0, 101
    li   a1, 0
    beq  t2, a1, ok_101
    j    fail
ok_101:
    li   t0, 4007029338
    li   t1, 2022242938
    slt  t2, t0, t1
    li   a0, 102
    li   a1, 1
    beq  t2, a1, ok_102
    j    fail
ok_102:
    li   t0, 3737431110
    li   t1, 3510465779
    slt  t2, t0, t1
    li   a0, 103
    li   a1, 0
    beq  t2, a1, ok_103
    j    fail
ok_103:
    li   t0, 2147483648
    li   t1, 4294967295
    sltu  t2, t0, t1
    li   a0, 104
    li   a1, 1
    beq  t2, a1, ok_104
    j    fail
ok_104:
    li   t0, 4294967295
    li   t1, 0
    sltu  t2, t0, t1
    li   a0, 105
    li   a1, 0
    beq  t2, a1, ok_105
    j    fail
ok_105:
    li   t0, 7
    li   t1, 0
    sltu  t2, t0, t1
    li   a0, 106
    li   a1, 0
    beq  t2, a1, ok_106
    j    fail
ok_106:
    li   t0, 2147483648
    li   t1, 1
    sltu  t2, t0, t1
    li   a0, 107
    li   a1, 0
    beq  t2, a1, ok_107
    j    fail
ok_107:
    li   t0, 4294967295
    li   t1, 4294967295
    sltu  t2, t0, t1
    li   a0, 108
    li   a1, 0
    beq  t2, a1, ok_108
    j    fail
ok_108:
    li   t0, 5
    li   t1, 3
    sltu  t2, t0, t1
    li   a0, 109
    li   a1, 0
    beq  t2, a1, ok_109
    j    fail
ok_109:
    li   t0, 4294967291
    li   t1, 3
    sltu  t2, t0, t1
    li   a0, 110
    li   a1, 0
    beq  t2, a1, ok_110
    j    fail
ok_110:
    li   t0, 31
    li   t1, 4294967295
    sltu  t2, t0, t1
    li   a0, 111
    li   a1, 1
    beq  t2, a1, ok_111
    j    fail
ok_111:
    li   t0, 305419896
    li   t1, 65535
    sltu  t2, t0, t1
    li   a0, 112
    li   a1, 0
    beq  t2, a1, ok_112
    j    fail
ok_112:
    li   t0, 3735928559
    li   t1, 305419896
    sltu  t2, t0, t1
    li   a0, 113
    li   a1, 0
    beq  t2, a1, ok_113
    j    fail
ok_113:
    li   t0, 2147483647
    li   t1, 2147483647
    sltu  t2, t0, t1
    li   a0, 114
    li   a1, 0
    beq  t2, a1, ok_114
    j    fail
ok_114:
    li   t0, 532046260
    li   t1, 3340062503
    sltu  t2, t0, t1
    li   a0, 115
    li   a1, 1
    beq  t2, a1, ok_115
    j    fail
ok_115:
    li   t0, 797239823
    li   t1, 1788101245
    sltu  t2, t0, t1
    li   a0, 116
    li   a1, 1
    beq  t2, a1, ok_116
    j    fail
ok_116:
    li   t0, 1872862534
    li   t1, 3303097737
    sltu  t2, t0, t1
    li   a0, 117
    li   a1, 1
    beq  t2, a1, ok_117
    j    fail
ok_117:
    li   t0, 513108605
    li   t1, 4033387233
    sltu  t2, t0, t1
    li   a0, 118
    li   a1, 1
    beq  t2, a1, ok_118
    j    fail
ok_118:
    li   t0, 2275470015
    li   t1, 442781074
    sltu  t2, t0, t1
    li   a0, 119
    li   a1, 0
    beq  t2, a1, ok_119
    j    fail
ok_119:
    li   t0, 3562336744
    li   t1, 3610222285
    sltu  t2, t0, t1
    li   a0, 120
    li   a1, 1
    beq  t2, a1, ok_120
    j    fail
ok_120:
    li   t0, 2147483648
    li   t1, 4294967295
    xor  t2, t0, t1
    li   a0, 121
    li   a1, 2147483647
    beq  t2, a1, ok_121
    j    fail
ok_121:
    li   t0, 4294967295
    li   t1, 0
    xor  t2, t0, t1
    li   a0, 122
    li   a1, 4294967295
    beq  t2, a1, ok_122
    j    fail
ok_122:
    li   t0, 7
    li   t1, 0
    xor  t2, t0, t1
    li   a0, 123
    li   a1, 7
    beq  t2, a1, ok_123
    j    fail
ok_123:
    li   t0, 2147483648
    li   t1, 1
    xor  t2, t0, t1
    li   a0, 124
    li   a1, 2147483649
    beq  t2, a1, ok_124
    j    fail
ok_124:
    li   t0, 4294967295
    li   t1, 4294967295
    xor  t2, t0, t1
    li   a0, 125
    li   a1, 0
    beq  t2, a1, ok_125
    j    fail
ok_125:
    li   t0, 5
    li   t1, 3
    xor  t2, t0, t1
    li   a0, 126
    li   a1, 6
    beq  t2, a1, ok_126
    j    fail
ok_126:
    li   t0, 4294967291
    li   t1, 3
    xor  t2, t0, t1
    li   a0, 127
    li   a1, 4294967288
    beq  t2, a1, ok_127
    j    fail
ok_127:
    li   t0, 305419896
    li   t1, 2147483649
    xor  t2, t0, t1
    li   a0, 128
    li   a1, 2452903545
    beq  t2, a1, ok_128
    j    fail
ok_128:
    li   t0, 32
    li   t1, 2147483647
    xor  t2, t0, t1
    li   a0, 129
    li   a1, 2147483615
    beq  t2, a1, ok_129
    j    fail
ok_129:
    li   t0, 32
    li   t1, 2
    xor  t2, t0, t1
    li   a0, 130
    li   a1, 34
    beq  t2, a1, ok_130
    j    fail
ok_130:
    li   t0, 2147483648
    li   t1, 1
    xor  t2, t0, t1
    li   a0, 131
    li   a1, 2147483649
    beq  t2, a1, ok_131
    j    fail
ok_131:
    li   t0, 3017897195
    li   t1, 3007052337
    xor  t2, t0, t1
    li   a0, 132
    li   a1, 14323418
    beq  t2, a1, ok_132
    j    fail
ok_132:
    li   t0, 3478668300
    li   t1, 4137753490
    xor  t2, t0, t1
    li   a0, 133
    li   a1, 972644254
    beq  t2, a1, ok_133
    j    fail
ok_133:
    li   t0, 675038226
    li   t1, 2492860083
    xor  t2, t0, t1
    li   a0, 134
    li   a1, 3165274785
    beq  t2, a1, ok_134
    j    fail
ok_134:
    li   t0, 3899790000
    li   t1, 4050165343
    xor  t2, t0, t1
    li   a0, 135
    li   a1, 421170415
    beq  t2, a1, ok_135
    j    fail
ok_135:
    li   t0, 1156765092
    li   t1, 4174413472
    xor  t2, t0, t1
    li   a0, 136
    li   a1, 3156388612
    beq  t2, a1, ok_136
    j    fail
ok_136:
    li   t0, 665060610
    li   t1, 3641815260
    xor  t2, t0, t1
    li   a0, 137
    li   a1, 4273321438
    beq  t2, a1, ok_137
    j    fail
ok_137:
    li   t0, 2147483648
    li   t1, 4294967295
    or  t2, t0, t1
    li   a0, 138
    li   a1, 4294967295
    beq  t2, a1, ok_138
    j    fail
ok_138:
    li   t0, 4294967295
    li   t1, 0
    or  t2, t0, t1
    li   a0, 139
    li   a1, 4294967295
    beq  t2, a1, ok_139
    j    fail
ok_139:
    li   t0, 7
    li   t1, 0
    or  t2, t0, t1
    li   a0, 140
    li   a1, 7
    beq  t2, a1, ok_140
    j    fail
ok_140:
    li   t0, 2147483648
    li   t1, 1
    or  t2, t0, t1
    li   a0, 141
    li   a1, 2147483649
    beq  t2, a1, ok_141
    j    fail
ok_141:
    li   t0, 4294967295
    li   t1, 4294967295
    or  t2, t0, t1
    li   a0, 142
    li   a1, 4294967295
    beq  t2, a1, ok_142
    j    fail
ok_142:
    li   t0, 5
    li   t1, 3
    or  t2, t0, t1
    li   a0, 143
    li   a1, 7
    beq  t2, a1, ok_143
    j    fail
ok_143:
    li   t0, 4294967291
    li   t1, 3
    or  t2, t0, t1
    li   a0, 144
    li   a1, 4294967291
    beq  t2, a1, ok_144
    j    fail
ok_144:
    li   t0, 65535
    li   t1, 2147483648
    or  t2, t0, t1
    li   a0, 145
    li   a1, 2147549183
    beq  t2, a1, ok_145
    j    fail
ok_145:
    li   t0, 305419896
    li   t1, 65535
    or  t2, t0, t1
    li   a0, 146
    li   a1, 305463295
    beq  t2, a1, ok_146
    j    fail
ok_146:
    li   t0, 1
    li   t1, 1
    or  t2, t0, t1
    li   a0, 147
    li   a1, 1
    beq  t2, a1, ok_147
    j    fail
ok_147:
    li   t0, 2147483649
    li   t1, 2
    or  t2, t0, t1
    li   a0, 148
    li   a1, 2147483651
    beq  t2, a1, ok_148
    j    fail
ok_148:
    li   t0, 205021508
    li   t1, 3841984728
    or  t2, t0, t1
    li   a0, 149
    li   a1, 3979897308
    beq  t2, a1, ok_149
    j    fail
ok_149:
    li   t0, 1228934017
    li   t1, 3450586090
    or  t2, t0, t1
    li   a0, 150
    li   a1, 3454782443
    beq  t2, a1, ok_150
    j    fail
ok_150:
    li   t0, 163185562
    li   t1, 942279725
    or  t2, t0, t1
    li   a0, 151
    li   a1, 968495039
    beq  t2, a1, ok_151
    j    fail
ok_151:
    li   t0, 2176323648
    li   t1, 3563199940
    or  t2, t0, t1
    li   a0, 152
    li   a1, 3589938628
    beq  t2, a1, ok_152
    j    fail
ok_152:
    li   t0, 376530307
    li   t1, 3405030049
    or  t2, t0, t1
    li   a0, 153
    li   a1, 3740657571
    beq  t2, a1, ok_153
    j    fail
ok_153:
    li   t0, 4006455623
    li   t1, 4032840983
    or  t2, t0, t1
    li   a0, 154
    li   a1, 4277005655
    beq  t2, a1, ok_154
    j    fail
ok_154:
    li   t0, 2147483648
    li   t1, 4294967295
    and  t2, t0, t1
    li   a0, 155
    li   a1, 2147483648
    beq  t2, a1, ok_155
    j    fail
ok_155:
    li   t0, 4294967295
    li   t1, 0
    and  t2, t0, t1
    li   a0, 156
    li   a1, 0
    beq  t2, a1, ok_156
    j    fail
ok_156:
    li   t0, 7
    li   t1, 0
    and  t2, t0, t1
    li   a0, 157
    li   a1, 0
    beq  t2, a1, ok_157
    j    fail
ok_157:
    li   t0, 2147483648
    li   t1, 1
    and  t2, t0, t1
    li   a0, 158
    li   a1, 0
    beq  t2, a1, ok_158
    j    fail
ok_158:
    li   t0, 4294967295
    li   t1, 4294967295
    and  t2, t0, t1
    li   a0, 159
    li   a1, 4294967295
    beq  t2, a1, ok_159
    j    fail
ok_159:
    li   t0, 5
    li   t1, 3
    and  t2, t0, t1
    li   a0, 160
    li   a1, 1
    beq  t2, a1, ok_160
    j    fail
ok_160:
    li   t0, 4294967291
    li   t1, 3
    and  t2, t0, t1
    li   a0, 161
    li   a1, 3
    beq  t2, a1, ok_161
    j    fail
ok_161:
    li   t0, 65535
    li   t1, 2147483648
    and  t2, t0, t1
    li   a0, 162
    li   a1, 0
    beq  t2, a1, ok_162
    j    fail
ok_162:
    li   t0, 2147483647
    li   t1, 305419896
    and  t2, t0, t1
    li   a0, 163
    li   a1, 305419896
    beq  t2, a1, ok_163
    j    fail
ok_163:
    li   t0, 1
    li   t1, 31
    and  t2, t0, t1
    li   a0, 164
    li   a1, 1
    beq  t2, a1, ok_164
    j    fail
ok_164:
    li   t0, 2147483647
    li   t1, 1
    and  t2, t0, t1
    li   a0, 165
    li   a1, 1
    beq  t2, a1, ok_165
    j    fail
ok_165:
    li   t0, 2958515895
    li   t1, 1830962845
    and  t2, t0, t1
    li   a0, 166
    li   a1, 537020053
    beq  t2, a1, ok_166
    j    fail
ok_166:
    li   t0, 4078094644
    li   t1, 867140057
    and  t2, t0, t1
    li   a0, 167
    li   a1, 855802128
    beq  t2, a1, ok_167
    j    fail
ok_167:
    li   t0, 435048644
    li   t1, 1703584349
    and  t2, t0, t1
    li   a0, 168
    li   a1, 25821252
    beq  t2, a1, ok_168
    j    fail
ok_168:
    li   t0, 835809654
    li   t1, 3027350246
    and  t2, t0, t1
    li   a0, 169
    li   a1, 810627174
    beq  t2, a1, ok_169
    j    fail
ok_169:
    li   t0, 3807257242
    li   t1, 3811153588
    and  t2, t0, t1
    li   a0, 170
    li   a1, 3794272912
    beq  t2, a1, ok_170
    j    fail
ok_170:
    li   t0, 1973840922
    li   t1, 2149707570
    and  t2, t0, t1
    li   a0, 171
    li   a1, 2124818
    beq  t2, a1, ok_171
    j    fail
ok_171:
    li   t0, 2147483648
    li   t1, 4294967295
    mul  t2, t0, t1
    li   a0, 172
    li   a1, 2147483648
    beq  t2, a1, ok_172
    j    fail
ok_172:
    li   t0, 4294967295
    li   t1, 0
    mul  t2, t0, t1
    li   a0, 173
    li   a1, 0
    beq  t2, a1, ok_173
    j    fail
ok_173:
    li   t0, 7
    li   t1, 0
    mul  t2, t0, t1
    li   a0, 174
    li   a1, 0
    beq  t2, a1, ok_174
    j    fail
ok_174:
    li   t0, 2147483648
    li   t1, 1
    mul  t2, t0, t1
    li   a0, 175
    li   a1, 2147483648
    beq  t2, a1, ok_175
    j    fail
ok_175:
    li   t0, 4294967295
    li   t1, 4294967295
    mul  t2, t0, t1
    li   a0, 176
    li   a1, 1
    beq  t2, a1, ok_176
    j    fail
ok_176:
    li   t0, 5
    li   t1, 3
    mul  t2, t0, t1
    li   a0, 177
    li   a1, 15
    beq  t2, a1, ok_177
    j    fail
ok_177:
    li   t0, 4294967291
    li   t1, 3
    mul  t2, t0, t1
    li   a0, 178
    li   a1, 4294967281
    beq  t2, a1, ok_178
    j    fail
ok_178:
    li   t0, 2
    li   t1, 2147483648
    mul  t2, t0, t1
    li   a0, 179
    li   a1, 0
    beq  t2, a1, ok_179
    j    fail
ok_179:
    li   t0, 2
    li   t1, 3735928559
    mul  t2, t0, t1
    li   a0, 180
    li   a1, 3176889822
    beq  t2, a1, ok_180
    j    fail
ok_180:
    li   t0, 65535
    li   t1, 2147483649
    mul  t2, t0, t1
    li   a0, 181
    li   a1, 2147549183
    beq  t2, a1, ok_181
    j    fail
ok_181:
    li   t0, 4294967295
    li   t1, 31
    mul  t2, t0, t1
    li   a0, 182
    li   a1, 4294967265
    beq  t2, a1, ok_182
    j    fail
ok_182:
    li   t0, 872994431
    li   t1, 1296122616
    mul  t2, t0, t1
    li   a0, 183
    li   a1, 1494976776
    beq  t2, a1, ok_183
    j    fail
ok_183:
    li   t0, 259032919
    li   t1, 3491170168
    mul  t2, t0, t1
    li   a0, 184
    li   a1, 692310472
    beq  t2, a1, ok_184
    j    fail
ok_184:
    li   t0, 1513914884
    li   t1, 2294976060
    mul  t2, t0, t1
    li   a0, 185
    li   a1, 1836364016
    beq  t2, a1, ok_185
    j    fail
ok_185:
    li   t0, 657389733
    li   t1, 2145711126
    mul  t2, t0, t1
    li   a0, 186
    li   a1, 1895473710
    beq  t2, a1, ok_186
    j    fail
ok_186:
    li   t0, 3893218329
    li   t1, 3321406450
    mul  t2, t0, t1
    li   a0, 187
    li   a1, 456579746
    beq  t2, a1, ok_187
    j    fail
ok_187:
    li   t0, 4084019688
    li   t1, 2358068784
    mul  t2, t0, t1
    li   a0, 188
    li   a1, 3706112896
    beq  t2, a1, ok_188
    j    fail
ok_188:
    li   t0, 2147483648
    li   t1, 4294967295
    mulh  t2, t0, t1
    li   a0, 189
    li   a1, 0
    beq  t2, a1, ok_189
    j    fail
ok_189:
    li   t0, 4294967295
    li   t1, 0
    mulh  t2, t0, t1
    li   a0, 190
    li   a1, 0
    beq  t2, a1, ok_190
    j    fail
ok_190:
    li   t0, 7
    li   t1, 0
    mulh  t2, t0, t1
    li   a0, 191
    li   a1, 0
    beq  t2, a1, ok_191
    j    fail
ok_191:
    li   t0, 2147483648
    li   t1, 1
    mulh  t2, t0, t1
    li   a0, 192
    li   a1, 4294967295
    beq  t2, a1, ok_192
    j    fail
ok_192:
    li   t0, 4294967295
    li   t1, 4294967295
    mulh  t2, t0, t1
    li   a0, 193
    li   a1, 0
    beq  t2, a1, ok_193
    j    fail
ok_193:
    li   t0, 5
    li   t1, 3
    mulh  t2, t0, t1
    li   a0, 194
    li   a1, 0
    beq  t2, a1, ok_194
    j    fail
ok_194:
    li   t0, 4294967291
    li   t1, 3
    mulh  t2, t0, t1
    li   a0, 195
    li   a1, 4294967295
    beq  t2, a1, ok_195
    j    fail
ok_195:
    li   t0, 305419896
    li   t1, 2147483648
    mulh  t2, t0, t1
    li   a0, 196
    li   a1, 4142257348
    beq  t2, a1, ok_196
    j    fail
ok_196:
    li   t0, 4294967295
    li   t1, 4294967295
    mulh  t2, t0, t1
    li   a0, 197
    li   a1, 0
    beq  t2, a1, ok_197
    j    fail
ok_197:
    li   t0, 0
    li   t1, 31
    mulh  t2, t0, t1
    li   a0, 198
    li   a1, 0
    beq  t2, a1, ok_198
    j    fail
ok_198:
    li   t0, 4294967295
    li   t1, 4294967295
    mulh  t2, t0, t1
    li   a0, 199
    li   a1, 0
    beq  t2, a1, ok_199
    j    fail
ok_199:
    li   t0, 3617817834
    li   t1, 2345329810
    mulh  t2, t0, t1
    li   a0, 200
    li   a1, 307382078
    beq  t2, a1, ok_200
    j    fail
ok_200:
    li   t0, 299573040
    li   t1, 3065742335
    mulh  t2, t0, t1
    li   a0, 201
    li   a1, 4209229120
    beq  t2, a1, ok_201
    j    fail
ok_201:
    li   t0, 1397089319
    li   t1, 734541227
    mulh  t2, t0, t1
    li   a0, 202
    li   a1, 238935393
    beq  t2, a1, ok_202
    j    fail
ok_202:
    li   t0, 7328804
    li   t1, 2870068750
    mulh  t2, t0, t1
    li   a0, 203
    li   a1, 4292535891
    beq  t2, a1, ok_203
    j    fail
ok_203:
    li   t0, 2897802415
    li   t1, 261239845
    mulh  t2, t0, t1
    li   a0, 204
    li   a1, 4209985243
    beq  t2, a1, ok_204
    j    fail
ok_204:
    li   t0, 2741392227
    li   t1, 376327143
    mulh  t2, t0, t1
    li   a0, 205
    li   a1, 4158842285
    beq  t2, a1, ok_205
    j    fail
ok_205:
    li   t0, 2147483648
    li   t1, 4294967295
    mulhsu  t2, t0, t1
    li   a0, 206
    li   a1, 2147483648
    beq  t2, a1, ok_206
    j    fail
ok_206:
    li   t0, 4294967295
    li   t1, 0
    mulhsu  t2, t0, t1
    li   a0, 207
    li   a1, 0
    beq  t2, a1, ok_207
    j    fail
ok_207:
    li   t0, 7
    li   t1, 0
    mulhsu  t2, t0, t1
    li   a0, 208
    li   a1, 0
    beq  t2, a1, ok_208
    j    fail
ok_208:
    li   t0, 2147483648
    li   t1, 1
    mulhsu  t2, t0, t1
    li   a0, 209
    li   a1, 4294967295
    beq  t2, a1, ok_209
    j    fail
ok_209:
    li   t0, 4294967295
    li   t1, 4294967295
    mulhsu  t2, t0, t1
    li   a0, 210
    li   a1, 4294967295
    beq  t2, a1, ok_210
    j    fail
ok_210:
    li   t0, 5
    li   t1, 3
    mulhsu  t2, t0, t1
    li   a0, 211
    li   a1, 0
    beq  t2, a1, ok_211
    j    fail
ok_211:
    li   t0, 4294967291
    li   t1, 3
    mulhsu  t2, t0, t1
    li   a0, 212
    li   a1, 4294967295
    beq  t2, a1, ok_212
    j    fail
ok_212:
    li   t0, 4294967295
    li   t1, 2
    mulhsu  t2, t0, t1
    li   a0, 213
    li   a1, 4294967295
    beq  t2, a1, ok_213
    j    fail
ok_213:
    li   t0, 0
    li   t1, 2147483649
    mulhsu  t2, t0, t1
    li   a0, 214
    li   a1, 0
    beq  t2, a1, ok_214
    j    fail
ok_214:
    li   t0, 2147483649
    li   t1, 65535
    mulhsu  t2, t0, t1
    li   a0, 215
    li   a1, 4294934528
    beq  t2, a1, ok_215
    j    fail
ok_215:
    li   t0, 2147483648
    li   t1, 2
    mulhsu  t2, t0, t1
    li   a0, 216
    li   a1, 4294967295
    beq  t2, a1, ok_216
    j    fail
ok_216:
    li   t0, 4173448101
    li   t1, 3534057694
    mulhsu  t2, t0, t1
    li   a0, 217
    li   a1, 4194976814
    beq  t2, a1, ok_217
    j    fail
ok_217:
    li   t0, 2897858463
    li   t1, 1637246195
    mulhsu  t2, t0, t1
    li   a0, 218
    li   a1, 3762387892
    beq  t2, a1, ok_218
    j    fail
ok_218:
    li   t0, 4021757389
    li   t1, 3755028816
    mulhsu  t2, t0, t1
    li   a0, 219
    li   a1, 4056103760
    beq  t2, a1, ok_219
    j    fail
ok_219:
    li   t0, 3930845718
    li   t1, 4123274558
    mulhsu  t2, t0, t1
    li   a0, 220
    li   a1, 3945401598
    beq  t2, a1, ok_220
    j    fail
ok_220:
    li   t0, 1202795502
    li   t1, 2308492160
    mulhsu  t2, t0, t1
    li   a0, 221
    li   a1, 646487806
    beq  t2, a1, ok_221
    j    fail
ok_221:
    li   t0, 2713755043
    li   t1, 3955954176
    mulhsu  t2, t0, t1
    li   a0, 222
    li   a1, 2838564305
    beq  t2, a1, ok_222
    j    fail
ok_222:
    li   t0, 2147483648
    li   t1, 4294967295
    mulhu  t2, t0, t1
    li   a0, 223
    li   a1, 2147483647
    beq  t2, a1, ok_223
    j    fail
ok_223:
    li   t0, 4294967295
    li   t1, 0
    mulhu  t2, t0, t1
    li   a0, 224
    li   a1, 0
    beq  t2, a1, ok_224
    j    fail
ok_224:
    li   t0, 7
    li   t1, 0
    mulhu  t2, t0, t1
    li   a0, 225
    li   a1, 0
    beq  t2, a1, ok_225
    j    fail
ok_225:
    li   t0, 2147483648
    li   t1, 1
    mulhu  t2, t0, t1
    li   a0, 226
    li   a1, 0
    beq  t2, a1, ok_226
    j    fail
ok_226:
    li   t0, 4294967295
    li   t1, 4294967295
    mulhu  t2, t0, t1
    li   a0, 227
    li   a1, 4294967294
    beq  t2, a1, ok_227
    j    fail
ok_227:
    li   t0, 5
    li   t1, 3
    mulhu  t2, t0, t1
    li   a0, 228
    li   a1, 0
    beq  t2, a1, ok_228
    j    fail
ok_228:
    li   t0, 4294967291
    li   t1, 3
    mulhu  t2, t0, t1
    li   a0, 229
    li   a1, 2
    beq  t2, a1, ok_229
    j    fail
ok_229:
    li   t0, 2147483647
    li   t1, 2147483649
    mulhu  t2, t0, t1
    li   a0, 230
    li   a1, 1073741823
    beq  t2, a1, ok_230
    j    fail
ok_230:
    li   t0, 2147483648
    li   t1, 32
    mulhu  t2, t0, t1
    li   a0, 231
    li   a1, 16
    beq  t2, a1, ok_231
    j    fail
ok_231:
    li   t0, 31
    li   t1, 4294967295
    mulhu  t2, t0, t1
    li   a0, 232
    li   a1, 30
    beq  t2, a1, ok_232
    j    fail
ok_232:
    li   t0, 3735928559
    li   t1, 1
    mulhu  t2, t0, t1
    li   a0, 233
    li   a1, 0
    beq  t2, a1, ok_233
    j    fail
ok_233:
    li   t0, 3282831501
    li   t1, 1118047688
    mulhu  t2, t0, t1
    li   a0, 234
    li   a1, 854572786
    beq  t2, a1, ok_234
    j    fail
ok_234:
    li   t0, 1194088304
    li   t1, 1762044776
    mulhu  t2, t0, t1
    li   a0, 235
    li   a1, 489884302
    beq  t2, a1, ok_235
    j    fail
ok_235:
    li   t0, 1718274186
    li   t1, 3684327570
    mulhu  t2, t0, t1
    li   a0, 236
    li   a1, 1473977453
    beq  t2, a1, ok_236
    j    fail
ok_236:
    li   t0, 2426411365
    li   t1, 1188600110
    mulhu  t2, t0, t1
    li   a0, 237
    li   a1, 671491216
    beq  t2, a1, ok_237
    j    fail
ok_237:
    li   t0, 2258296047
    li   t1, 488504905
    mulhu  t2, t0, t1
    li   a0, 238
    li   a1, 256856134
    beq  t2, a1, ok_238
    j    fail
ok_238:
    li   t0, 3013600653
    li   t1, 1612109326
    mulhu  t2, t0, t1
    li   a0, 239
    li   a1, 1131150340
    beq  t2, a1, ok_239
    j    fail
ok_239:
    li   t0, 2147483648
    li   t1, 4294967295
    div  t2, t0, t1
    li   a0, 240
    li   a1, 2147483648
    beq  t2, a1, ok_240
    j    fail
ok_240:
    li   t0, 4294967295
    li   t1, 0
    div  t2, t0, t1
    li   a0, 241
    li   a1, 4294967295
    beq  t2, a1, ok_241
    j    fail
ok_241:
    li   t0, 7
    li   t1, 0
    div  t2, t0, t1
    li   a0, 242
    li   a1, 4294967295
    beq  t2, a1, ok_242
    j    fail
ok_242:
    li   t0, 2147483648
    li   t1, 1
    div  t2, t0, t1
    li   a0, 243
    li   a1, 2147483648
    beq  t2, a1, ok_243
    j    fail
ok_243:
    li   t0, 4294967295
    li   t1, 4294967295
    div  t2, t0, t1
    li   a0, 244
    li   a1, 1
    beq  t2, a1, ok_244
    j    fail
ok_244:
    li   t0, 5
    li   t1, 3
    div  t2, t0, t1
    li   a0, 245
    li   a1, 1
    beq  t2, a1, ok_245
    j    fail
ok_245:
    li   t0, 4294967291
    li   t1, 3
    div  t2, t0, t1
    li   a0, 246
    li   a1, 4294967295
    beq  t2, a1, ok_246
    j    fail
ok_246:
    li   t0, 2147483647
    li   t1, 2
    div  t2, t0, t1
    li   a0, 247
    li   a1, 1073741823
    beq  t2, a1, ok_247
    j    fail
ok_247:
    li   t0, 2147483647
    li   t1, 65535
    div  t2, t0, t1
    li   a0, 248
    li   a1, 32768
    beq  t2, a1, ok_248
    j    fail
ok_248:
    li   t0, 31
    li   t1, 2147483649
    div  t2, t0, t1
    li   a0, 249
    li   a1, 0
    beq  t2, a1, ok_249
    j    fail
ok_249:
    li   t0, 0
    li   t1, 2147483648
    div  t2, t0, t1
    li   a0, 250
    li   a1, 0
    beq  t2, a1, ok_250
    j    fail
ok_250:
    li   t0, 3768534763
    li   t1, 3584193253
    div  t2, t0, t1
    li   a0, 251
    li   a1, 0
    beq  t2, a1, ok_251
    j    fail
ok_251:
    li   t0, 1892169706
    li   t1, 998567415
    div  t2, t0, t1
    li   a0, 252
    li   a1, 1
    beq  t2, a1, ok_252
    j    fail
ok_252:
    li   t0, 3336704416
    li   t1, 2106687355
    div  t2, t0, t1
    li   a0, 253
    li   a1, 0
    beq  t2, a1, ok_253
    j    fail
ok_253:
    li   t0, 710047009
    li   t1, 1634414006
    div  t2, t0, t1
    li   a0, 254
    li   a1, 0
    beq  t2, a1, ok_254
    j    fail
ok_254:
    li   t0, 1322494161
    li   t1, 10515695
    div  t2, t0, t1
    li   a0, 255
    li   a1, 125
    beq  t2, a1, ok_255
    j    fail
ok_255:
    li   t0, 314934025
    li   t1, 2062472879
    div  t2, t0, t1
    li   a0, 256
    li   a1, 0
    beq  t2, a1, ok_256
    j    fail
ok_256:
    li   t0, 2147483648
    li   t1, 4294967295
    divu  t2, t0, t1
    li   a0, 257
    li   a1, 0
    beq  t2, a1, ok_257
    j    fail
ok_257:
    li   t0, 4294967295
    li   t1, 0
    divu  t2, t0, t1
    li   a0, 258
    li   a1, 4294967295
    beq  t2, a1, ok_258
    j    fail
ok_258:
    li   t0, 7
    li   t1, 0
    divu  t2, t0, t1
    li   a0, 259
    li   a1, 4294967295
    beq  t2, a1, ok_259
    j    fail
ok_259:
    li   t0, 2147483648
    li   t1, 1
    divu  t2, t0, t1
    li   a0, 260
    li   a1, 2147483648
    beq  t2, a1, ok_260
    j    fail
ok_260:
    li   t0, 4294967295
    li   t1, 4294967295
    divu  t2, t0, t1
    li   a0, 261
    li   a1, 1
    beq  t2, a1, ok_261
    j    fail
ok_261:
    li   t0, 5
    li   t1, 3
    divu  t2, t0, t1
    li   a0, 262
    li   a1, 1
    beq  t2, a1, ok_262
    j    fail
ok_262:
    li   t0, 4294967291
    li   t1, 3
    divu  t2, t0, t1
    li   a0, 263
    li   a1, 1431655763
    beq  t2, a1, ok_263
    j    fail
ok_263:
    li   t0, 2147483649
    li   t1, 2147483647
    divu  t2, t0, t1
    li   a0, 264
    li   a1, 1
    beq  t2, a1, ok_264
    j    fail
ok_264:
    li   t0, 2147483649
    li   t1, 32
    divu  t2, t0, t1
    li   a0, 265
    li   a1, 67108864
    beq  t2, a1, ok_265
    j    fail
ok_265:
    li   t0, 305419896
    li   t1, 4294967295
    divu  t2, t0, t1
    li   a0, 266
    li   a1, 0
    beq  t2, a1, ok_266
    j    fail
ok_266:
    li   t0, 2147483649
    li   t1, 32
    divu  t2, t0, t1
    li   a0, 267
    li   a1, 67108864
    beq  t2, a1, ok_267
    j    fail
ok_267:
    li   t0, 2052831094
    li   t1, 675128003
    divu  t2, t0, t1
    li   a0, 268
    li   a1, 3
    beq  t2, a1, ok_268
    j    fail
ok_268:
    li   t0, 1208004254
    li   t1, 2540484686
    divu  t2, t0, t1
    li   a0, 269
    li   a1, 0
    beq  t2, a1, ok_269
    j    fail
ok_269:
    li   t0, 1587099665
    li   t1, 2814176927
    divu  t2, t0, t1
    li   a0, 270
    li   a1, 0
    beq  t2, a1, ok_270
    j    fail
ok_270:
    li   t0, 2579101015
    li   t1, 1488128396
    divu  t2, t0, t1
    li   a0, 271
    li   a1, 1
    beq  t2, a1, ok_271
    j    fail
ok_271:
    li   t0, 885055256
    li   t1, 725770522
    divu  t2, t0, t1
    li   a0, 272
    li   a1, 1
    beq  t2, a1, ok_272
    j    fail
ok_272:
    li   t0, 2228505284
    li   t1, 4278668069
    divu  t2, t0, t1
    li   a0, 273
    li   a1, 0
    beq  t2, a1, ok_273
    j    fail
ok_273:
    li   t0, 2147483648
    li   t1, 4294967295
    rem  t2, t0, t1
    li   a0, 274
    li   a1, 0
    beq  t2, a1, ok_274
    j    fail
ok_274:
    li   t0, 4294967295
    li   t1, 0
    rem  t2, t0, t1
    li   a0, 275
    li   a1, 4294967295
    beq  t2, a1, ok_275
    j    fail
ok_275:
    li   t0, 7
    li   t1, 0
    rem  t2, t0, t1
    li   a0, 276
    li   a1, 7
    beq  t2, a1, ok_276
    j    fail
ok_276:
    li   t0, 2147483648
    li   t1, 1
    rem  t2, t0, t1
    li   a0, 277
    li   a1, 0
    beq  t2, a1, ok_277
    j    fail
ok_277:
    li   t0, 4294967295
    li   t1, 4294967295
    rem  t2, t0, t1
    li   a0, 278
    li   a1, 0
    beq  t2, a1, ok_278
    j    fail
ok_278:
    li   t0, 5
    li   t1, 3
    rem  t2, t0, t1
    li   a0, 279
    li   a1, 2
    beq  t2, a1, ok_279
    j    fail
ok_279:
    li   t0, 4294967291
    li   t1, 3
    rem  t2, t0, t1
    li   a0, 280
    li   a1, 4294967294
    beq  t2, a1, ok_280
    j    fail
ok_280:
    li   t0, 31
    li   t1, 305419896
    rem  t2, t0, t1
    li   a0, 281
    li   a1, 31
    beq  t2, a1, ok_281
    j    fail
ok_281:
    li   t0, 32
    li   t1, 305419896
    rem  t2, t0, t1
    li   a0, 282
    li   a1, 32
    beq  t2, a1, ok_282
    j    fail
ok_282:
    li   t0, 32
    li   t1, 0
    rem  t2, t0, t1
    li   a0, 283
    li   a1, 32
    beq  t2, a1, ok_283
    j    fail
ok_283:
    li   t0, 65535
    li   t1, 305419896
    rem  t2, t0, t1
    li   a0, 284
    li   a1, 65535
    beq  t2, a1, ok_284
    j    fail
ok_284:
    li   t0, 2837715077
    li   t1, 3433224784
    rem  t2, t0, t1
    li   a0, 285
    li   a1, 3699457589
    beq  t2, a1, ok_285
    j    fail
ok_285:
    li   t0, 445434616
    li   t1, 115584179
    rem  t2, t0, t1
    li   a0, 286
    li   a1, 98682079
    beq  t2, a1, ok_286
    j    fail
ok_286:
    li   t0, 1574679945
    li   t1, 4161897721
    rem  t2, t0, t1
    li   a0, 287
    li   a1, 110914620
    beq  t2, a1, ok_287
    j    fail
ok_287:
    li   t0, 3410463404
    li   t1, 2043610631
    rem  t2, t0, t1
    li   a0, 288
    li   a1, 3410463404
    beq  t2, a1, ok_288
    j    fail
ok_288:
    li   t0, 280000657
    li   t1, 3934548606
    rem  t2, t0, t1
    li   a0, 289
    li   a1, 280000657
    beq  t2, a1, ok_289
    j    fail
ok_289:
    li   t0, 601371235
    li   t1, 3814963929
    rem  t2, t0, t1
    li   a0, 290
    li   a1, 121367868
    beq  t2, a1, ok_290
    j    fail
ok_290:
    li   t0, 2147483648
    li   t1, 4294967295
    remu  t2, t0, t1
    li   a0, 291
    li   a1, 2147483648
    beq  t2, a1, ok_291
    j    fail
ok_291:
    li   t0, 4294967295
    li   t1, 0
    remu  t2, t0, t1
    li   a0, 292
    li   a1, 4294967295
    beq  t2, a1, ok_292
    j    fail
ok_292:
    li   t0, 7
    li   t1, 0
    remu  t2, t0, t1
    li   a0, 293
    li   a1, 7
    beq  t2, a1, ok_293
    j    fail
ok_293:
    li   t0, 2147483648
    li   t1, 1
    remu  t2, t0, t1
    li   a0, 294
    li   a1, 0
    beq  t2, a1, ok_294
    j    fail
ok_294:
    li   t0, 4294967295
    li   t1, 4294967295
    remu  t2, t0, t1
    li   a0, 295
    li   a1, 0
    beq  t2, a1, ok_295
    j    fail
ok_295:
    li   t0, 5
    li   t1, 3
    remu  t2, t0, t1
    li   a0, 296
    li   a1, 2
    beq  t2, a1, ok_296
    j    fail
ok_296:
    li   t0, 4294967291
    li   t1, 3
    remu  t2, t0, t1
    li   a0, 297
    li   a1, 2
    beq  t2, a1, ok_297
    j    fail
ok_297:
    li   t0, 31
    li   t1, 2147483648
    remu  t2, t0, t1
    li   a0, 298
    li   a1, 31
    beq  t2, a1, ok_298
    j    fail
ok_298:
    li   t0, 2147483648
    li   t1, 2147483647
    remu  t2, t0, t1
    li   a0, 299
    li   a1, 1
    beq  t2, a1, ok_299
    j    fail
ok_299:
    li   t0, 2147483647
    li   t1, 32
    remu  t2, t0, t1
    li   a0, 300
    li   a1, 31
    beq  t2, a1, ok_300
    j    fail
ok_300:
    li   t0, 32
    li   t1, 31
    remu  t2, t0, t1
    li   a0, 301
    li   a1, 1
    beq  t2, a1, ok_301
    j    fail
ok_301:
    li   t0, 1419859244
    li   t1, 2417431971
    remu  t2, t0, t1
    li   a0, 302
    li   a1, 1419859244
    beq  t2, a1, ok_302
    j    fail
ok_302:
    li   t0, 4062910640
    li   t1, 4086952925
    remu  t2, t0, t1
    li   a0, 303
    li   a1, 4062910640
    beq  t2, a1, ok_303
    j    fail
ok_303:
    li   t0, 1261781192
    li   t1, 2416048393
    remu  t2, t0, t1
    li   a0, 304
    li   a1, 1261781192
    beq  t2, a1, ok_304
    j    fail
ok_304:
    li   t0, 835656013
    li   t1, 2186831815
    remu  t2, t0, t1
    li   a0, 305
    li   a1, 835656013
    beq  t2, a1, ok_305
    j    fail
ok_305:
    li   t0, 3497324672
    li   t1, 3219360163
    remu  t2, t0, t1
    li   a0, 306
    li   a1, 277964509
    beq  t2, a1, ok_306
    j    fail
ok_306:
    li   t0, 1198444753
    li   t1, 311318775
    remu  t2, t0, t1
    li   a0, 307
    li   a1, 264488428
    beq  t2, a1, ok_307
    j    fail
ok_307:
    li   t0, 65535
    addi t2, t0, -377
    li   a0, 308
    li   a1, 65158
    beq  t2, a1, ok_308
    j    fail
ok_308:
    li   t0, 3735928559
    addi t2, t0, 690
    li   a0, 309
    li   a1, 3735929249
    beq  t2, a1, ok_309
    j    fail
ok_309:
    li   t0, 2147483648
    addi t2, t0, 1704
    li   a0, 310
    li   a1, 2147485352
    beq  t2, a1, ok_310
    j    fail
ok_310:
    li   t0, 1
    addi t2, t0, -1069
    li   a0, 311
    li   a1, 4294966228
    beq  t2, a1, ok_311
    j    fail
ok_311:
    li   t0, 2
    addi t2, t0, 58
    li   a0, 312
    li   a1, 60
    beq  t2, a1, ok_312
    j    fail
ok_312:
    li   t0, 4294967295
    addi t2, t0, -1816
    li   a0, 313
    li   a1, 4294965479
    beq  t2, a1, ok_313
    j    fail
ok_313:
    li   t0, 0
    addi t2, t0, -1687
    li   a0, 314
    li   a1, 4294965609
    beq  t2, a1, ok_314
    j    fail
ok_314:
    li   t0, 2
    addi t2, t0, -780
    li   a0, 315
    li   a1, 4294966518
    beq  t2, a1, ok_315
    j    fail
ok_315:
    li   t0, 2147483648
    addi t2, t0, 863
    li   a0, 316
    li   a1, 2147484511
    beq  t2, a1, ok_316
    j    fail
ok_316:
    li   t0, 3735928559
    addi t2, t0, -1483
    li   a0, 317
    li   a1, 3735927076
    beq  t2, a1, ok_317
    j    fail
ok_317:
    li   t0, 3625233423
    slti t2, t0, 451
    li   a0, 318
    li   a1, 1
    beq  t2, a1, ok_318
    j    fail
ok_318:
    li   t0, 65535
    slti t2, t0, 1929
    li   a0, 319
    li   a1, 0
    beq  t2, a1, ok_319
    j    fail
ok_319:
    li   t0, 31
    slti t2, t0, -250
    li   a0, 320
    li   a1, 0
    beq  t2, a1, ok_320
    j    fail
ok_320:
    li   t0, 3735928559
    slti t2, t0, -1370
    li   a0, 321
    li   a1, 1
    beq  t2, a1, ok_321
    j    fail
ok_321:
    li   t0, 2805222665
    slti t2, t0, -1900
    li   a0, 322
    li   a1, 1
    beq  t2, a1, ok_322
    j    fail
ok_322:
    li   t0, 31
    slti t2, t0, 664
    li   a0, 323
    li   a1, 1
    beq  t2, a1, ok_323
    j    fail
ok_323:
    li   t0, 31
    slti t2, t0, -168
    li   a0, 324
    li   a1, 0
    beq  t2, a1, ok_324
    j    fail
ok_324:
    li   t0, 305419896
    slti t2, t0, 2043
    li   a0, 325
    li   a1, 0
    beq  t2, a1, ok_325
    j    fail
ok_325:
    li   t0, 32
    slti t2, t0, -902
    li   a0, 326
    li   a1, 0
    beq  t2, a1, ok_326
    j    fail
ok_326:
    li   t0, 3735928559
    slti t2, t0, -1490
    li   a0, 327
    li   a1, 1
    beq  t2, a1, ok_327
    j    fail
ok_327:
    li   t0, 3735928559
    sltiu t2, t0, -56
    li   a0, 328
    li   a1, 1
    beq  t2, a1, ok_328
    j    fail
ok_328:
    li   t0, 4294967295
    sltiu t2, t0, 1172
    li   a0, 329
    li   a1, 0
    beq  t2, a1, ok_329
    j    fail
ok_329:
    li   t0, 2147483648
    sltiu t2, t0, -992
    li   a0, 330
    li   a1, 1
    beq  t2, a1, ok_330
    j    fail
ok_330:
    li   t0, 3735928559
    sltiu t2, t0, 1608
    li   a0, 331
    li   a1, 0
    beq  t2, a1, ok_331
    j    fail
ok_331:
    li   t0, 2147483648
    sltiu t2, t0, -1486
    li   a0, 332
    li   a1, 1
    beq  t2, a1, ok_332
    j    fail
ok_332:
    li   t0, 2147483648
    sltiu t2, t0, 1297
    li   a0, 333
    li   a1, 0
    beq  t2, a1, ok_333
    j    fail
ok_333:
    li   t0, 0
    sltiu t2, t0, -1468
    li   a0, 334
    li   a1, 1
    beq  t2, a1, ok_334
    j    fail
ok_334:
    li   t0, 2
    sltiu t2, t0, -425
    li   a0, 335
    li   a1, 1
    beq  t2, a1, ok_335
    j    fail
ok_335:
    li   t0, 3735928559
    sltiu t2, t0, 1063
    li   a0, 336
    li   a1, 0
    beq  t2, a1, ok_336
    j    fail
ok_336:
    li   t0, 305419896
    sltiu t2, t0, -1619
    li   a0, 337
    li   a1, 1
    beq  t2, a1, ok_337
    j    fail
ok_337:
    li   t0, 305419896
    xori t2, t0, -1392
    li   a0, 338
    li   a1, 3989548264
    beq  t2, a1, ok_338
    j    fail
ok_338:
    li   t0, 2147483647
    xori t2, t0, 1445
    li   a0, 339
    li   a1, 2147482202
    beq  t2, a1, ok_339
    j    fail
ok_339:
    li   t0, 2147483648
    xori t2, t0, -837
    li   a0, 340
    li   a1, 2147482811
    beq  t2, a1, ok_340
    j    fail
ok_340:
    li   t0, 32
    xori t2, t0, -66
    li   a0, 341
    li   a1, 4294967198
    beq  t2, a1, ok_341
    j    fail
ok_341:
    li   t0, 2976703215
    xori t2, t0, -1804
    li   a0, 342
    li   a1, 1318263323
    beq  t2, a1, ok_342
    j    fail
ok_342:
    li   t0, 65535
    xori t2, t0, 873
    li   a0, 343
    li   a1, 64662
    beq  t2, a1, ok_343
    j    fail
ok_343:
    li   t0, 2147483648
    xori t2, t0, 1351
    li   a0, 344
    li   a1, 2147484999
    beq  t2, a1, ok_344
    j    fail
ok_344:
    li   t0, 1
    xori t2, t0, -1903
    li   a0, 345
    li   a1, 4294965392
    beq  t2, a1, ok_345
    j    fail
ok_345:
    li   t0, 911695795
    xori t2, t0, -439
    li   a0, 346
    li   a1, 3383271930
    beq  t2, a1, ok_346
    j    fail
ok_346:
    li   t0, 31
    xori t2, t0, -890
    li   a0, 347
    li   a1, 4294966425
    beq  t2, a1, ok_347
    j    fail
ok_347:
    li   t0, 4294967295
    ori t2, t0, 38
    li   a0, 348
    li   a1, 4294967295
    beq  t2, a1, ok_348
    j    fail
ok_348:
    li   t0, 65535
    ori t2, t0, -1643
    li   a0, 349
    li   a1, 4294967295
    beq  t2, a1, ok_349
    j    fail
ok_349:
    li   t0, 31
    ori t2, t0, 1786
    li   a0, 350
    li   a1, 1791
    beq  t2, a1, ok_350
    j    fail
ok_350:
    li   t0, 31
    ori t2, t0, 997
    li   a0, 351
    li   a1, 1023
    beq  t2, a1, ok_351
    j    fail
ok_351:
    li   t0, 2147483649
    ori t2, t0, 1295
    li   a0, 352
    li   a1, 2147484943
    beq  t2, a1, ok_352
    j    fail
ok_352:
    li   t0, 2147483648
    ori t2, t0, -130
    li   a0, 353
    li   a1, 4294967166
    beq  t2, a1, ok_353
    j    fail
ok_353:
    li   t0, 0
    ori t2, t0, 514
    li   a0, 354
    li   a1, 514
    beq  t2, a1, ok_354
    j    fail
ok_354:
    li   t0, 2147483647
    ori t2, t0, -1062
    li   a0, 355
    li   a1, 4294967295
    beq  t2, a1, ok_355
    j    fail
ok_355:
    li   t0, 31
    ori t2, t0, -1758
    li   a0, 356
    li   a1, 4294965567
    beq  t2, a1, ok_356
    j    fail
ok_356:
    li   t0, 2
    ori t2, t0, 978
    li   a0, 357
    li   a1, 978
    beq  t2, a1, ok_357
    j    fail
ok_357:
    li   t0, 4294967295
    andi t2, t0, 591
    li   a0, 358
    li   a1, 591
    beq  t2, a1, ok_358
    j    fail
ok_358:
    li   t0, 2147483648
    andi t2, t0, 187
    li   a0, 359
    li   a1, 0
    beq  t2, a1, ok_359
    j    fail
ok_359:
    li   t0, 65535
    andi t2, t0, -604
    li   a0, 360
    li   a1, 64932
    beq  t2, a1, ok_360
    j    fail
ok_360:
    li   t0, 4294967295
    andi t2, t0, -2022
    li   a0, 361
    li   a1, 4294965274
    beq  t2, a1, ok_361
    j    fail
ok_361:
    li   t0, 3735928559
    andi t2, t0, 1299
    li   a0, 362
    li   a1, 1027
    beq  t2, a1, ok_362
    j    fail
ok_362:
    li   t0, 2
    andi t2, t0, 1587
    li   a0, 363
    li   a1, 2
    beq  t2, a1, ok_363
    j    fail
ok_363:
    li   t0, 65535
    andi t2, t0, -621
    li   a0, 364
    li   a1, 64915
    beq  t2, a1, ok_364
    j    fail
ok_364:
    li   t0, 65535
    andi t2, t0, 1305
    li   a0, 365
    li   a1, 1305
    beq  t2, a1, ok_365
    j    fail
ok_365:
    li   t0, 305419896
    andi t2, t0, 1893
    li   a0, 366
    li   a1, 1632
    beq  t2, a1, ok_366
    j    fail
ok_366:
    li   t0, 305419896
    andi t2, t0, 1599
    li   a0, 367
    li   a1, 1592
    beq  t2, a1, ok_367
    j    fail
ok_367:
    li   t0, 305419896
    slli t2, t0, 0
    li   a0, 368
    li   a1, 305419896
    beq  t2, a1, ok_368
    j    fail
ok_368:
    li   t0, 2147483648
    slli t2, t0, 1
    li   a0, 369
    li   a1, 0
    beq  t2, a1, ok_369
    j    fail
ok_369:
    li   t0, 4294967295
    slli t2, t0, 5
    li   a0, 370
    li   a1, 4294967264
    beq  t2, a1, ok_370
    j    fail
ok_370:
    li   t0, 4042322160
    slli t2, t0, 15
    li   a0, 371
    li   a1, 2021130240
    beq  t2, a1, ok_371
    j    fail
ok_371:
    li   t0, 2147483648
    slli t2, t0, 31
    li   a0, 372
    li   a1, 0
    beq  t2, a1, ok_372
    j    fail
ok_372:
    li   t0, 4294967295
    srli t2, t0, 0
    li   a0, 373
    li   a1, 4294967295
    beq  t2, a1, ok_373
    j    fail
ok_373:
    li   t0, 4294967295
    srli t2, t0, 1
    li   a0, 374
    li   a1, 2147483647
    beq  t2, a1, ok_374
    j    fail
ok_374:
    li   t0, 2147483648
    srli t2, t0, 5
    li   a0, 375
    li   a1, 67108864
    beq  t2, a1, ok_375
    j    fail
ok_375:
    li   t0, 4042322160
    srli t2, t0, 15
    li   a0, 376
    li   a1, 123361
    beq  t2, a1, ok_376
    j    fail
ok_376:
    li   t0, 305419896
    srli t2, t0, 31
    li   a0, 377
    li   a1, 0
    beq  t2, a1, ok_377
    j    fail
ok_377:
    li   t0, 4042322160
    srai t2, t0, 0
    li   a0, 378
    li   a1, 4042322160
    beq  t2, a1, ok_378
    j    fail
ok_378:
    li   t0, 2147483648
    srai t2, t0, 1
    li   a0, 379
    li   a1, 3221225472
    beq  t2, a1, ok_379
    j    fail
ok_379:
    li   t0, 305419896
    srai t2, t0, 5
    li   a0, 380
    li   a1, 9544371
    beq  t2, a1, ok_380
    j    fail
ok_380:
    li   t0, 4294967295
    srai t2, t0, 15
    li   a0, 381
    li   a1, 4294967295
    beq  t2, a1, ok_381
    j    fail
ok_381:
    li   t0, 305419896
    srai t2, t0, 31
    li   a0, 382
    li   a1, 0
    beq  t2, a1, ok_382
    j    fail
ok_382:
    lui  t2, 703710
    li   a0, 383
    li   a1, 2882396160
    beq  t2, a1, ok_383
    j    fail
ok_383:
    lui  t2, 1
    li   a0, 384
    li   a1, 4096
    beq  t2, a1, ok_384
    j    fail
ok_384:
    lui  t2, 1048575
    li   a0, 385
    li   a1, 4294963200
    beq  t2, a1, ok_385
    j    fail
ok_385:
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

