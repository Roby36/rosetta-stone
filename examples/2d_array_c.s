	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 13, 0	sdk_version 13, 3
	.file	1 "/Users/roby/Desktop/23X/ASM/rosetta-stone/examples" "2d_array.c"
	.globl	_main                           ; -- Begin function main
	.p2align	2
_main:                                  ; @main
Lfunc_begin0:
	.loc	1 9 0                           ; 2d_array.c:9:0
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #80
	.cfi_def_cfa_offset 80
	stp	x29, x30, [sp, #64]             ; 16-byte Folded Spill
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	stur	wzr, [x29, #-4]
Ltmp0:
	.loc	1 0 0 is_stmt 0                 ; 2d_array.c:0:0
	adrp	x8, _x_size@PAGE
	.loc	1 14 31 prologue_end is_stmt 1  ; 2d_array.c:14:31
	ldrsw	x8, [x8, _x_size@PAGEOFF]
	.loc	1 14 38 is_stmt 0               ; 2d_array.c:14:38
	lsl	x0, x8, #3
	.loc	1 14 24                         ; 2d_array.c:14:24
	bl	_malloc
	.loc	1 14 22                         ; 2d_array.c:14:22
	stur	x0, [x29, #-16]
Ltmp1:
	.loc	1 15 14 is_stmt 1               ; 2d_array.c:15:14
	stur	wzr, [x29, #-20]
	.loc	1 15 10 is_stmt 0               ; 2d_array.c:15:10
	b	LBB0_1
LBB0_1:                                 ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB0_3 Depth 2
Ltmp2:
	.loc	1 15 21                         ; 2d_array.c:15:21
	ldur	w8, [x29, #-20]
Ltmp3:
	.loc	1 0 0                           ; 2d_array.c:0:0
	adrp	x9, _x_size@PAGE
Ltmp4:
	.loc	1 15 25                         ; 2d_array.c:15:25
	ldr	w9, [x9, _x_size@PAGEOFF]
	.loc	1 15 23                         ; 2d_array.c:15:23
	subs	w8, w8, w9
	cset	w8, ge
Ltmp5:
	.loc	1 15 5                          ; 2d_array.c:15:5
	tbnz	w8, #0, LBB0_8
	b	LBB0_2
Ltmp6:
LBB0_2:                                 ;   in Loop: Header=BB0_1 Depth=1
	.loc	1 0 0                           ; 2d_array.c:0:0
	adrp	x8, _y_size@PAGE
Ltmp7:
	.loc	1 17 38 is_stmt 1               ; 2d_array.c:17:38
	ldrsw	x8, [x8, _y_size@PAGEOFF]
	.loc	1 17 45 is_stmt 0               ; 2d_array.c:17:45
	lsl	x0, x8, #3
	.loc	1 17 31                         ; 2d_array.c:17:31
	bl	_malloc
	.loc	1 17 9                          ; 2d_array.c:17:9
	ldur	x8, [x29, #-16]
	.loc	1 17 26                         ; 2d_array.c:17:26
	ldursw	x9, [x29, #-20]
	.loc	1 17 29                         ; 2d_array.c:17:29
	str	x0, [x8, x9, lsl #3]
Ltmp8:
	.loc	1 18 18 is_stmt 1               ; 2d_array.c:18:18
	stur	wzr, [x29, #-24]
	.loc	1 18 14 is_stmt 0               ; 2d_array.c:18:14
	b	LBB0_3
LBB0_3:                                 ;   Parent Loop BB0_1 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
Ltmp9:
	.loc	1 18 25                         ; 2d_array.c:18:25
	ldur	w8, [x29, #-24]
Ltmp10:
	.loc	1 0 0                           ; 2d_array.c:0:0
	adrp	x9, _y_size@PAGE
Ltmp11:
	.loc	1 18 29                         ; 2d_array.c:18:29
	ldr	w9, [x9, _y_size@PAGEOFF]
	.loc	1 18 27                         ; 2d_array.c:18:27
	subs	w8, w8, w9
	cset	w8, ge
Ltmp12:
	.loc	1 18 9                          ; 2d_array.c:18:9
	tbnz	w8, #0, LBB0_6
	b	LBB0_4
LBB0_4:                                 ;   in Loop: Header=BB0_3 Depth=2
Ltmp13:
	.loc	1 0 0                           ; 2d_array.c:0:0
	adrp	x8, _str_len@PAGE
	str	x8, [sp, #24]                   ; 8-byte Folded Spill
	.loc	1 20 45 is_stmt 1               ; 2d_array.c:20:45
	ldrsw	x8, [x8, _str_len@PAGEOFF]
	.loc	1 20 53 is_stmt 0               ; 2d_array.c:20:53
	lsr	x0, x8, #0
	.loc	1 20 38                         ; 2d_array.c:20:38
	bl	_malloc
	ldr	x8, [sp, #24]                   ; 8-byte Folded Reload
	.loc	1 20 13                         ; 2d_array.c:20:13
	ldur	x9, [x29, #-16]
	.loc	1 20 30                         ; 2d_array.c:20:30
	ldursw	x10, [x29, #-20]
	.loc	1 20 13                         ; 2d_array.c:20:13
	ldr	x9, [x9, x10, lsl #3]
	.loc	1 20 33                         ; 2d_array.c:20:33
	ldursw	x10, [x29, #-24]
	.loc	1 20 36                         ; 2d_array.c:20:36
	str	x0, [x9, x10, lsl #3]
	.loc	1 21 13 is_stmt 1               ; 2d_array.c:21:13
	ldur	x9, [x29, #-16]
	ldursw	x10, [x29, #-20]
	ldr	x9, [x9, x10, lsl #3]
	ldursw	x10, [x29, #-24]
	ldr	x0, [x9, x10, lsl #3]
	ldrsw	x1, [x8, _str_len@PAGEOFF]
	ldur	w8, [x29, #-20]
                                        ; implicit-def: $x10
	mov	x10, x8
	ldur	w9, [x29, #-24]
                                        ; implicit-def: $x8
	mov	x8, x9
	mov	x9, sp
	str	x10, [x9]
	str	x8, [x9, #8]
	mov	w2, #0
	mov	x3, #-1
	.loc	1 0 0 is_stmt 0                 ; 2d_array.c:0:0
	adrp	x4, l_.str@PAGE
	add	x4, x4, l_.str@PAGEOFF
	.loc	1 21 13                         ; 2d_array.c:21:13
	bl	___snprintf_chk
	.loc	1 22 38 is_stmt 1               ; 2d_array.c:22:38
	ldur	x8, [x29, #-16]
	.loc	1 22 55 is_stmt 0               ; 2d_array.c:22:55
	ldursw	x9, [x29, #-20]
	.loc	1 22 38                         ; 2d_array.c:22:38
	ldr	x8, [x8, x9, lsl #3]
	.loc	1 22 58                         ; 2d_array.c:22:58
	ldursw	x9, [x29, #-24]
	.loc	1 22 38                         ; 2d_array.c:22:38
	ldr	x8, [x8, x9, lsl #3]
	.loc	1 22 13                         ; 2d_array.c:22:13
	mov	x9, sp
	str	x8, [x9]
	.loc	1 0 0                           ; 2d_array.c:0:0
	adrp	x0, l_.str.1@PAGE
	add	x0, x0, l_.str.1@PAGEOFF
	.loc	1 22 13                         ; 2d_array.c:22:13
	bl	_printf
	.loc	1 23 9 is_stmt 1                ; 2d_array.c:23:9
	b	LBB0_5
Ltmp14:
LBB0_5:                                 ;   in Loop: Header=BB0_3 Depth=2
	.loc	1 18 38                         ; 2d_array.c:18:38
	ldur	w8, [x29, #-24]
	add	w8, w8, #1
	stur	w8, [x29, #-24]
	.loc	1 18 9 is_stmt 0                ; 2d_array.c:18:9
	b	LBB0_3
Ltmp15:
LBB0_6:                                 ;   in Loop: Header=BB0_1 Depth=1
	.loc	1 24 5 is_stmt 1                ; 2d_array.c:24:5
	b	LBB0_7
Ltmp16:
LBB0_7:                                 ;   in Loop: Header=BB0_1 Depth=1
	.loc	1 15 34                         ; 2d_array.c:15:34
	ldur	w8, [x29, #-20]
	add	w8, w8, #1
	stur	w8, [x29, #-20]
	.loc	1 15 5 is_stmt 0                ; 2d_array.c:15:5
	b	LBB0_1
Ltmp17:
LBB0_8:
	.loc	1 27 14 is_stmt 1               ; 2d_array.c:27:14
	stur	wzr, [x29, #-28]
	.loc	1 27 10 is_stmt 0               ; 2d_array.c:27:10
	b	LBB0_9
LBB0_9:                                 ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB0_11 Depth 2
Ltmp18:
	.loc	1 27 21                         ; 2d_array.c:27:21
	ldur	w8, [x29, #-28]
Ltmp19:
	.loc	1 0 0                           ; 2d_array.c:0:0
	adrp	x9, _x_size@PAGE
Ltmp20:
	.loc	1 27 25                         ; 2d_array.c:27:25
	ldr	w9, [x9, _x_size@PAGEOFF]
	.loc	1 27 23                         ; 2d_array.c:27:23
	subs	w8, w8, w9
	cset	w8, ge
Ltmp21:
	.loc	1 27 5                          ; 2d_array.c:27:5
	tbnz	w8, #0, LBB0_16
	b	LBB0_10
LBB0_10:                                ;   in Loop: Header=BB0_9 Depth=1
Ltmp22:
	.loc	1 28 18 is_stmt 1               ; 2d_array.c:28:18
	str	wzr, [sp, #32]
	.loc	1 28 14 is_stmt 0               ; 2d_array.c:28:14
	b	LBB0_11
LBB0_11:                                ;   Parent Loop BB0_9 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
Ltmp23:
	.loc	1 28 25                         ; 2d_array.c:28:25
	ldr	w8, [sp, #32]
	.loc	1 0 0                           ; 2d_array.c:0:0
	adrp	x9, _y_size@PAGE
	.loc	1 28 29                         ; 2d_array.c:28:29
	ldr	w9, [x9, _y_size@PAGEOFF]
	.loc	1 28 27                         ; 2d_array.c:28:27
	subs	w8, w8, w9
	cset	w8, ge
Ltmp24:
	.loc	1 28 9                          ; 2d_array.c:28:9
	tbnz	w8, #0, LBB0_14
	b	LBB0_12
LBB0_12:                                ;   in Loop: Header=BB0_11 Depth=2
Ltmp25:
	.loc	1 29 36 is_stmt 1               ; 2d_array.c:29:36
	ldur	x8, [x29, #-16]
	.loc	1 29 53 is_stmt 0               ; 2d_array.c:29:53
	ldursw	x9, [x29, #-28]
	.loc	1 29 36                         ; 2d_array.c:29:36
	ldr	x8, [x8, x9, lsl #3]
	.loc	1 29 56                         ; 2d_array.c:29:56
	ldrsw	x9, [sp, #32]
	.loc	1 29 36                         ; 2d_array.c:29:36
	ldr	x8, [x8, x9, lsl #3]
	.loc	1 29 13                         ; 2d_array.c:29:13
	mov	x9, sp
	str	x8, [x9]
	.loc	1 0 0                           ; 2d_array.c:0:0
	adrp	x0, l_.str.2@PAGE
	add	x0, x0, l_.str.2@PAGEOFF
	.loc	1 29 13                         ; 2d_array.c:29:13
	bl	_printf
	.loc	1 31 19 is_stmt 1               ; 2d_array.c:31:19
	ldur	x8, [x29, #-16]
	.loc	1 31 36 is_stmt 0               ; 2d_array.c:31:36
	ldursw	x9, [x29, #-28]
	.loc	1 31 19                         ; 2d_array.c:31:19
	ldr	x8, [x8, x9, lsl #3]
	.loc	1 31 39                         ; 2d_array.c:31:39
	ldrsw	x9, [sp, #32]
	.loc	1 31 19                         ; 2d_array.c:31:19
	ldr	x0, [x8, x9, lsl #3]
	.loc	1 31 13                         ; 2d_array.c:31:13
	bl	_free
	.loc	1 32 9 is_stmt 1                ; 2d_array.c:32:9
	b	LBB0_13
Ltmp26:
LBB0_13:                                ;   in Loop: Header=BB0_11 Depth=2
	.loc	1 28 38                         ; 2d_array.c:28:38
	ldr	w8, [sp, #32]
	add	w8, w8, #1
	str	w8, [sp, #32]
	.loc	1 28 9 is_stmt 0                ; 2d_array.c:28:9
	b	LBB0_11
Ltmp27:
LBB0_14:                                ;   in Loop: Header=BB0_9 Depth=1
	.loc	1 34 15 is_stmt 1               ; 2d_array.c:34:15
	ldur	x8, [x29, #-16]
	.loc	1 34 32 is_stmt 0               ; 2d_array.c:34:32
	ldursw	x9, [x29, #-28]
	.loc	1 34 15                         ; 2d_array.c:34:15
	ldr	x0, [x8, x9, lsl #3]
	.loc	1 34 9                          ; 2d_array.c:34:9
	bl	_free
	.loc	1 35 5 is_stmt 1                ; 2d_array.c:35:5
	b	LBB0_15
Ltmp28:
LBB0_15:                                ;   in Loop: Header=BB0_9 Depth=1
	.loc	1 27 34                         ; 2d_array.c:27:34
	ldur	w8, [x29, #-28]
	add	w8, w8, #1
	stur	w8, [x29, #-28]
	.loc	1 27 5 is_stmt 0                ; 2d_array.c:27:5
	b	LBB0_9
Ltmp29:
LBB0_16:
	.loc	1 36 10 is_stmt 1               ; 2d_array.c:36:10
	ldur	x0, [x29, #-16]
	.loc	1 36 5 is_stmt 0                ; 2d_array.c:36:5
	bl	_free
	mov	w0, #0
	.loc	1 38 5 is_stmt 1                ; 2d_array.c:38:5
	ldp	x29, x30, [sp, #64]             ; 16-byte Folded Reload
	add	sp, sp, #80
	ret
Ltmp30:
Lfunc_end0:
	.cfi_endproc
                                        ; -- End function
	.section	__DATA,__data
	.p2align	2                               ; @x_size
_x_size:
	.long	4                               ; 0x4

	.p2align	2                               ; @y_size
_y_size:
	.long	4                               ; 0x4

	.p2align	2                               ; @str_len
_str_len:
	.long	32                              ; 0x20

	.section	__TEXT,__cstring,cstring_literals
l_.str:                                 ; @.str
	.asciz	"str_double_array[%d][%d]"

l_.str.1:                               ; @.str.1
	.asciz	"Allocated %s\n"

l_.str.2:                               ; @.str.2
	.asciz	"Freeing %s\n"

	.section	__DWARF,__debug_abbrev,regular,debug
Lsection_abbrev:
	.byte	1                               ; Abbreviation Code
	.byte	17                              ; DW_TAG_compile_unit
	.byte	1                               ; DW_CHILDREN_yes
	.byte	37                              ; DW_AT_producer
	.byte	14                              ; DW_FORM_strp
	.byte	19                              ; DW_AT_language
	.byte	5                               ; DW_FORM_data2
	.byte	3                               ; DW_AT_name
	.byte	14                              ; DW_FORM_strp
	.ascii	"\202|"                         ; DW_AT_LLVM_sysroot
	.byte	14                              ; DW_FORM_strp
	.ascii	"\357\177"                      ; DW_AT_APPLE_sdk
	.byte	14                              ; DW_FORM_strp
	.byte	16                              ; DW_AT_stmt_list
	.byte	23                              ; DW_FORM_sec_offset
	.byte	27                              ; DW_AT_comp_dir
	.byte	14                              ; DW_FORM_strp
	.byte	17                              ; DW_AT_low_pc
	.byte	1                               ; DW_FORM_addr
	.byte	18                              ; DW_AT_high_pc
	.byte	6                               ; DW_FORM_data4
	.byte	0                               ; EOM(1)
	.byte	0                               ; EOM(2)
	.byte	2                               ; Abbreviation Code
	.byte	52                              ; DW_TAG_variable
	.byte	0                               ; DW_CHILDREN_no
	.byte	3                               ; DW_AT_name
	.byte	14                              ; DW_FORM_strp
	.byte	73                              ; DW_AT_type
	.byte	19                              ; DW_FORM_ref4
	.byte	58                              ; DW_AT_decl_file
	.byte	11                              ; DW_FORM_data1
	.byte	59                              ; DW_AT_decl_line
	.byte	11                              ; DW_FORM_data1
	.byte	2                               ; DW_AT_location
	.byte	24                              ; DW_FORM_exprloc
	.byte	0                               ; EOM(1)
	.byte	0                               ; EOM(2)
	.byte	3                               ; Abbreviation Code
	.byte	36                              ; DW_TAG_base_type
	.byte	0                               ; DW_CHILDREN_no
	.byte	3                               ; DW_AT_name
	.byte	14                              ; DW_FORM_strp
	.byte	62                              ; DW_AT_encoding
	.byte	11                              ; DW_FORM_data1
	.byte	11                              ; DW_AT_byte_size
	.byte	11                              ; DW_FORM_data1
	.byte	0                               ; EOM(1)
	.byte	0                               ; EOM(2)
	.byte	4                               ; Abbreviation Code
	.byte	46                              ; DW_TAG_subprogram
	.byte	1                               ; DW_CHILDREN_yes
	.byte	17                              ; DW_AT_low_pc
	.byte	1                               ; DW_FORM_addr
	.byte	18                              ; DW_AT_high_pc
	.byte	6                               ; DW_FORM_data4
	.byte	64                              ; DW_AT_frame_base
	.byte	24                              ; DW_FORM_exprloc
	.byte	3                               ; DW_AT_name
	.byte	14                              ; DW_FORM_strp
	.byte	58                              ; DW_AT_decl_file
	.byte	11                              ; DW_FORM_data1
	.byte	59                              ; DW_AT_decl_line
	.byte	11                              ; DW_FORM_data1
	.byte	73                              ; DW_AT_type
	.byte	19                              ; DW_FORM_ref4
	.byte	63                              ; DW_AT_external
	.byte	25                              ; DW_FORM_flag_present
	.byte	0                               ; EOM(1)
	.byte	0                               ; EOM(2)
	.byte	5                               ; Abbreviation Code
	.byte	52                              ; DW_TAG_variable
	.byte	0                               ; DW_CHILDREN_no
	.byte	2                               ; DW_AT_location
	.byte	24                              ; DW_FORM_exprloc
	.byte	3                               ; DW_AT_name
	.byte	14                              ; DW_FORM_strp
	.byte	58                              ; DW_AT_decl_file
	.byte	11                              ; DW_FORM_data1
	.byte	59                              ; DW_AT_decl_line
	.byte	11                              ; DW_FORM_data1
	.byte	73                              ; DW_AT_type
	.byte	19                              ; DW_FORM_ref4
	.byte	0                               ; EOM(1)
	.byte	0                               ; EOM(2)
	.byte	6                               ; Abbreviation Code
	.byte	11                              ; DW_TAG_lexical_block
	.byte	1                               ; DW_CHILDREN_yes
	.byte	85                              ; DW_AT_ranges
	.byte	23                              ; DW_FORM_sec_offset
	.byte	0                               ; EOM(1)
	.byte	0                               ; EOM(2)
	.byte	7                               ; Abbreviation Code
	.byte	15                              ; DW_TAG_pointer_type
	.byte	0                               ; DW_CHILDREN_no
	.byte	73                              ; DW_AT_type
	.byte	19                              ; DW_FORM_ref4
	.byte	0                               ; EOM(1)
	.byte	0                               ; EOM(2)
	.byte	0                               ; EOM(3)
	.section	__DWARF,__debug_info,regular,debug
Lsection_info:
Lcu_begin0:
.set Lset0, Ldebug_info_end0-Ldebug_info_start0 ; Length of Unit
	.long	Lset0
Ldebug_info_start0:
	.short	4                               ; DWARF version number
.set Lset1, Lsection_abbrev-Lsection_abbrev ; Offset Into Abbrev. Section
	.long	Lset1
	.byte	8                               ; Address Size (in bytes)
	.byte	1                               ; Abbrev [1] 0xb:0xfc DW_TAG_compile_unit
	.long	0                               ; DW_AT_producer
	.short	12                              ; DW_AT_language
	.long	50                              ; DW_AT_name
	.long	61                              ; DW_AT_LLVM_sysroot
	.long	156                             ; DW_AT_APPLE_sdk
.set Lset2, Lline_table_start0-Lsection_line ; DW_AT_stmt_list
	.long	Lset2
	.long	167                             ; DW_AT_comp_dir
	.quad	Lfunc_begin0                    ; DW_AT_low_pc
.set Lset3, Lfunc_end0-Lfunc_begin0     ; DW_AT_high_pc
	.long	Lset3
	.byte	2                               ; Abbrev [2] 0x32:0x15 DW_TAG_variable
	.long	218                             ; DW_AT_name
	.long	71                              ; DW_AT_type
	.byte	1                               ; DW_AT_decl_file
	.byte	5                               ; DW_AT_decl_line
	.byte	9                               ; DW_AT_location
	.byte	3
	.quad	_x_size
	.byte	3                               ; Abbrev [3] 0x47:0x7 DW_TAG_base_type
	.long	225                             ; DW_AT_name
	.byte	5                               ; DW_AT_encoding
	.byte	4                               ; DW_AT_byte_size
	.byte	2                               ; Abbrev [2] 0x4e:0x15 DW_TAG_variable
	.long	229                             ; DW_AT_name
	.long	71                              ; DW_AT_type
	.byte	1                               ; DW_AT_decl_file
	.byte	6                               ; DW_AT_decl_line
	.byte	9                               ; DW_AT_location
	.byte	3
	.quad	_y_size
	.byte	2                               ; Abbrev [2] 0x63:0x15 DW_TAG_variable
	.long	236                             ; DW_AT_name
	.long	71                              ; DW_AT_type
	.byte	1                               ; DW_AT_decl_file
	.byte	7                               ; DW_AT_decl_line
	.byte	9                               ; DW_AT_location
	.byte	3
	.quad	_str_len
	.byte	4                               ; Abbrev [4] 0x78:0x78 DW_TAG_subprogram
	.quad	Lfunc_begin0                    ; DW_AT_low_pc
.set Lset4, Lfunc_end0-Lfunc_begin0     ; DW_AT_high_pc
	.long	Lset4
	.byte	1                               ; DW_AT_frame_base
	.byte	109
	.long	244                             ; DW_AT_name
	.byte	1                               ; DW_AT_decl_file
	.byte	9                               ; DW_AT_decl_line
	.long	71                              ; DW_AT_type
                                        ; DW_AT_external
	.byte	5                               ; Abbrev [5] 0x91:0xe DW_TAG_variable
	.byte	2                               ; DW_AT_location
	.byte	145
	.byte	112
	.long	249                             ; DW_AT_name
	.byte	1                               ; DW_AT_decl_file
	.byte	11                              ; DW_AT_decl_line
	.long	240                             ; DW_AT_type
	.byte	6                               ; Abbrev [6] 0x9f:0x28 DW_TAG_lexical_block
.set Lset5, Ldebug_ranges0-Ldebug_range ; DW_AT_ranges
	.long	Lset5
	.byte	5                               ; Abbrev [5] 0xa4:0xe DW_TAG_variable
	.byte	2                               ; DW_AT_location
	.byte	145
	.byte	108
	.long	271                             ; DW_AT_name
	.byte	1                               ; DW_AT_decl_file
	.byte	15                              ; DW_AT_decl_line
	.long	71                              ; DW_AT_type
	.byte	6                               ; Abbrev [6] 0xb2:0x14 DW_TAG_lexical_block
.set Lset6, Ldebug_ranges1-Ldebug_range ; DW_AT_ranges
	.long	Lset6
	.byte	5                               ; Abbrev [5] 0xb7:0xe DW_TAG_variable
	.byte	2                               ; DW_AT_location
	.byte	145
	.byte	104
	.long	273                             ; DW_AT_name
	.byte	1                               ; DW_AT_decl_file
	.byte	18                              ; DW_AT_decl_line
	.long	71                              ; DW_AT_type
	.byte	0                               ; End Of Children Mark
	.byte	0                               ; End Of Children Mark
	.byte	6                               ; Abbrev [6] 0xc7:0x28 DW_TAG_lexical_block
.set Lset7, Ldebug_ranges2-Ldebug_range ; DW_AT_ranges
	.long	Lset7
	.byte	5                               ; Abbrev [5] 0xcc:0xe DW_TAG_variable
	.byte	2                               ; DW_AT_location
	.byte	145
	.byte	100
	.long	271                             ; DW_AT_name
	.byte	1                               ; DW_AT_decl_file
	.byte	27                              ; DW_AT_decl_line
	.long	71                              ; DW_AT_type
	.byte	6                               ; Abbrev [6] 0xda:0x14 DW_TAG_lexical_block
.set Lset8, Ldebug_ranges3-Ldebug_range ; DW_AT_ranges
	.long	Lset8
	.byte	5                               ; Abbrev [5] 0xdf:0xe DW_TAG_variable
	.byte	2                               ; DW_AT_location
	.byte	143
	.byte	32
	.long	273                             ; DW_AT_name
	.byte	1                               ; DW_AT_decl_file
	.byte	28                              ; DW_AT_decl_line
	.long	71                              ; DW_AT_type
	.byte	0                               ; End Of Children Mark
	.byte	0                               ; End Of Children Mark
	.byte	0                               ; End Of Children Mark
	.byte	7                               ; Abbrev [7] 0xf0:0x5 DW_TAG_pointer_type
	.long	245                             ; DW_AT_type
	.byte	7                               ; Abbrev [7] 0xf5:0x5 DW_TAG_pointer_type
	.long	250                             ; DW_AT_type
	.byte	7                               ; Abbrev [7] 0xfa:0x5 DW_TAG_pointer_type
	.long	255                             ; DW_AT_type
	.byte	3                               ; Abbrev [3] 0xff:0x7 DW_TAG_base_type
	.long	266                             ; DW_AT_name
	.byte	6                               ; DW_AT_encoding
	.byte	1                               ; DW_AT_byte_size
	.byte	0                               ; End Of Children Mark
Ldebug_info_end0:
	.section	__DWARF,__debug_ranges,regular,debug
Ldebug_range:
Ldebug_ranges0:
.set Lset9, Ltmp1-Lfunc_begin0
	.quad	Lset9
.set Lset10, Ltmp3-Lfunc_begin0
	.quad	Lset10
.set Lset11, Ltmp4-Lfunc_begin0
	.quad	Lset11
.set Lset12, Ltmp6-Lfunc_begin0
	.quad	Lset12
.set Lset13, Ltmp7-Lfunc_begin0
	.quad	Lset13
.set Lset14, Ltmp10-Lfunc_begin0
	.quad	Lset14
.set Lset15, Ltmp11-Lfunc_begin0
	.quad	Lset15
.set Lset16, Ltmp17-Lfunc_begin0
	.quad	Lset16
	.quad	0
	.quad	0
Ldebug_ranges1:
.set Lset17, Ltmp8-Lfunc_begin0
	.quad	Lset17
.set Lset18, Ltmp10-Lfunc_begin0
	.quad	Lset18
.set Lset19, Ltmp11-Lfunc_begin0
	.quad	Lset19
.set Lset20, Ltmp15-Lfunc_begin0
	.quad	Lset20
	.quad	0
	.quad	0
Ldebug_ranges2:
.set Lset21, Ltmp6-Lfunc_begin0
	.quad	Lset21
.set Lset22, Ltmp7-Lfunc_begin0
	.quad	Lset22
.set Lset23, Ltmp10-Lfunc_begin0
	.quad	Lset23
.set Lset24, Ltmp11-Lfunc_begin0
	.quad	Lset24
.set Lset25, Ltmp17-Lfunc_begin0
	.quad	Lset25
.set Lset26, Ltmp19-Lfunc_begin0
	.quad	Lset26
.set Lset27, Ltmp20-Lfunc_begin0
	.quad	Lset27
.set Lset28, Ltmp29-Lfunc_begin0
	.quad	Lset28
	.quad	0
	.quad	0
Ldebug_ranges3:
.set Lset29, Ltmp6-Lfunc_begin0
	.quad	Lset29
.set Lset30, Ltmp7-Lfunc_begin0
	.quad	Lset30
.set Lset31, Ltmp10-Lfunc_begin0
	.quad	Lset31
.set Lset32, Ltmp11-Lfunc_begin0
	.quad	Lset32
.set Lset33, Ltmp22-Lfunc_begin0
	.quad	Lset33
.set Lset34, Ltmp27-Lfunc_begin0
	.quad	Lset34
	.quad	0
	.quad	0
	.section	__DWARF,__debug_str,regular,debug
Linfo_string:
	.asciz	"Apple clang version 14.0.3 (clang-1403.0.22.14.1)" ; string offset=0
	.asciz	"2d_array.c"                    ; string offset=50
	.asciz	"/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk" ; string offset=61
	.asciz	"MacOSX.sdk"                    ; string offset=156
	.asciz	"/Users/roby/Desktop/23X/ASM/rosetta-stone/examples" ; string offset=167
	.asciz	"x_size"                        ; string offset=218
	.asciz	"int"                           ; string offset=225
	.asciz	"y_size"                        ; string offset=229
	.asciz	"str_len"                       ; string offset=236
	.asciz	"main"                          ; string offset=244
	.asciz	"str_double_array"              ; string offset=249
	.asciz	"char"                          ; string offset=266
	.asciz	"i"                             ; string offset=271
	.asciz	"j"                             ; string offset=273
	.section	__DWARF,__apple_names,regular,debug
Lnames_begin:
	.long	1212240712                      ; Header Magic
	.short	1                               ; Header Version
	.short	0                               ; Header Hash Function
	.long	4                               ; Header Bucket Count
	.long	4                               ; Header Hash Count
	.long	12                              ; Header Data Length
	.long	0                               ; HeaderData Die Offset Base
	.long	1                               ; HeaderData Atom Count
	.short	1                               ; DW_ATOM_die_offset
	.short	6                               ; DW_FORM_data4
	.long	0                               ; Bucket 0
	.long	-1                              ; Bucket 1
	.long	2                               ; Bucket 2
	.long	3                               ; Bucket 3
	.long	689385240                       ; Hash in Bucket 0
	.long	-1358681252                     ; Hash in Bucket 0
	.long	2090499946                      ; Hash in Bucket 2
	.long	650249847                       ; Hash in Bucket 3
.set Lset35, LNames1-Lnames_begin       ; Offset in Bucket 0
	.long	Lset35
.set Lset36, LNames3-Lnames_begin       ; Offset in Bucket 0
	.long	Lset36
.set Lset37, LNames2-Lnames_begin       ; Offset in Bucket 2
	.long	Lset37
.set Lset38, LNames0-Lnames_begin       ; Offset in Bucket 3
	.long	Lset38
LNames1:
	.long	229                             ; y_size
	.long	1                               ; Num DIEs
	.long	78
	.long	0
LNames3:
	.long	236                             ; str_len
	.long	1                               ; Num DIEs
	.long	99
	.long	0
LNames2:
	.long	244                             ; main
	.long	1                               ; Num DIEs
	.long	120
	.long	0
LNames0:
	.long	218                             ; x_size
	.long	1                               ; Num DIEs
	.long	50
	.long	0
	.section	__DWARF,__apple_objc,regular,debug
Lobjc_begin:
	.long	1212240712                      ; Header Magic
	.short	1                               ; Header Version
	.short	0                               ; Header Hash Function
	.long	1                               ; Header Bucket Count
	.long	0                               ; Header Hash Count
	.long	12                              ; Header Data Length
	.long	0                               ; HeaderData Die Offset Base
	.long	1                               ; HeaderData Atom Count
	.short	1                               ; DW_ATOM_die_offset
	.short	6                               ; DW_FORM_data4
	.long	-1                              ; Bucket 0
	.section	__DWARF,__apple_namespac,regular,debug
Lnamespac_begin:
	.long	1212240712                      ; Header Magic
	.short	1                               ; Header Version
	.short	0                               ; Header Hash Function
	.long	1                               ; Header Bucket Count
	.long	0                               ; Header Hash Count
	.long	12                              ; Header Data Length
	.long	0                               ; HeaderData Die Offset Base
	.long	1                               ; HeaderData Atom Count
	.short	1                               ; DW_ATOM_die_offset
	.short	6                               ; DW_FORM_data4
	.long	-1                              ; Bucket 0
	.section	__DWARF,__apple_types,regular,debug
Ltypes_begin:
	.long	1212240712                      ; Header Magic
	.short	1                               ; Header Version
	.short	0                               ; Header Hash Function
	.long	2                               ; Header Bucket Count
	.long	2                               ; Header Hash Count
	.long	20                              ; Header Data Length
	.long	0                               ; HeaderData Die Offset Base
	.long	3                               ; HeaderData Atom Count
	.short	1                               ; DW_ATOM_die_offset
	.short	6                               ; DW_FORM_data4
	.short	3                               ; DW_ATOM_die_tag
	.short	5                               ; DW_FORM_data2
	.short	4                               ; DW_ATOM_type_flags
	.short	11                              ; DW_FORM_data1
	.long	0                               ; Bucket 0
	.long	1                               ; Bucket 1
	.long	193495088                       ; Hash in Bucket 0
	.long	2090147939                      ; Hash in Bucket 1
.set Lset39, Ltypes0-Ltypes_begin       ; Offset in Bucket 0
	.long	Lset39
.set Lset40, Ltypes1-Ltypes_begin       ; Offset in Bucket 1
	.long	Lset40
Ltypes0:
	.long	225                             ; int
	.long	1                               ; Num DIEs
	.long	71
	.short	36
	.byte	0
	.long	0
Ltypes1:
	.long	266                             ; char
	.long	1                               ; Num DIEs
	.long	255
	.short	36
	.byte	0
	.long	0
.subsections_via_symbols
	.section	__DWARF,__debug_line,regular,debug
Lsection_line:
Lline_table_start0:
