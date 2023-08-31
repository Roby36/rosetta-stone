	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 13, 0	sdk_version 13, 3
	.globl	_parseArgs                      ; -- Begin function parseArgs
	.p2align	2
_parseArgs:                             ; @parseArgs
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #80
	.cfi_def_cfa_offset 80
	stp	x29, x30, [sp, #64]             ; 16-byte Folded Spill
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	adrp	x8, ___stderrp@GOTPAGE
	ldr	x8, [x8, ___stderrp@GOTPAGEOFF]
	str	x8, [sp, #16]                   ; 8-byte Folded Spill
	stur	w0, [x29, #-4]
	stur	x1, [x29, #-16]
	stur	x2, [x29, #-24]
	ldur	x8, [x29, #-16]
	ldr	x8, [x8]
	str	x8, [sp, #32]
	ldur	w8, [x29, #-4]
	subs	w8, w8, #3
	cset	w8, eq
	tbnz	w8, #0, LBB0_2
	b	LBB0_1
LBB0_1:
	ldr	x8, [sp, #16]                   ; 8-byte Folded Reload
	ldr	x0, [x8]
	ldr	x8, [sp, #32]
	mov	x9, sp
	str	x8, [x9]
	adrp	x1, l_.str@PAGE
	add	x1, x1, l_.str@PAGEOFF
	bl	_fprintf
	mov	w0, #1
	bl	_exit
LBB0_2:
	ldur	x8, [x29, #-16]
	ldr	x0, [x8, #8]
	adrp	x1, l_.str.1@PAGE
	add	x1, x1, l_.str.1@PAGEOFF
	bl	_pagedir_test
	tbz	w0, #0, LBB0_4
	b	LBB0_3
LBB0_3:
	ldur	x8, [x29, #-16]
	ldr	x0, [x8, #8]
	adrp	x1, l_.str.2@PAGE
	add	x1, x1, l_.str.2@PAGEOFF
	bl	_pagedir_test
	tbnz	w0, #0, LBB0_5
	b	LBB0_4
LBB0_4:
	ldr	x8, [sp, #16]                   ; 8-byte Folded Reload
	ldr	x0, [x8]
	ldr	x8, [sp, #32]
	mov	x9, sp
	str	x8, [x9]
	adrp	x1, l_.str.3@PAGE
	add	x1, x1, l_.str.3@PAGEOFF
	bl	_fprintf
	mov	w0, #2
	bl	_exit
LBB0_5:
	ldur	x8, [x29, #-16]
	ldr	x0, [x8, #8]
	bl	_strlen
	add	x0, x0, #1
	bl	_malloc
	ldur	x8, [x29, #-24]
	str	x0, [x8]
	ldur	x8, [x29, #-24]
	ldr	x0, [x8]
	ldur	x8, [x29, #-16]
	ldr	x1, [x8, #8]
	mov	x2, #-1
	bl	___strcpy_chk
	ldur	x8, [x29, #-16]
	ldr	x0, [x8, #16]
	bl	_loadIndex
	str	x0, [sp, #24]
	ldr	x8, [sp, #24]
	subs	x8, x8, #0
	cset	w8, ne
	tbnz	w8, #0, LBB0_7
	b	LBB0_6
LBB0_6:
	ldur	x8, [x29, #-24]
	ldr	x0, [x8]
	bl	_free
	ldr	x8, [sp, #16]                   ; 8-byte Folded Reload
	ldr	x0, [x8]
	ldr	x10, [sp, #32]
	ldur	x8, [x29, #-16]
	ldr	x8, [x8, #16]
	mov	x9, sp
	str	x10, [x9]
	str	x8, [x9, #8]
	adrp	x1, l_.str.4@PAGE
	add	x1, x1, l_.str.4@PAGEOFF
	bl	_fprintf
	mov	w0, #3
	bl	_exit
LBB0_7:
	ldr	x0, [sp, #24]
	ldp	x29, x30, [sp, #64]             ; 16-byte Folded Reload
	add	sp, sp, #80
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_newQuery                       ; -- Begin function newQuery
	.p2align	2
_newQuery:                              ; @newQuery
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #32
	.cfi_def_cfa_offset 32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	str	x0, [sp]
	bl	_prompt
	ldr	x0, [sp]
	adrp	x8, ___stdinp@GOTPAGE
	ldr	x8, [x8, ___stdinp@GOTPAGEOFF]
	ldr	x2, [x8]
	mov	w1, #1000
	bl	_fgets
	subs	x8, x0, #0
	cset	w8, ne
	tbnz	w8, #0, LBB1_2
	b	LBB1_1
LBB1_1:
	mov	w8, #0
	and	w8, w8, #0x1
	and	w8, w8, #0x1
	sturb	w8, [x29, #-1]
	b	LBB1_3
LBB1_2:
	mov	w8, #1
	and	w8, w8, #0x1
	and	w8, w8, #0x1
	sturb	w8, [x29, #-1]
	b	LBB1_3
LBB1_3:
	ldurb	w8, [x29, #-1]
	and	w0, w8, #0x1
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #32
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_prompt                         ; -- Begin function prompt
	.p2align	2
_prompt:                                ; @prompt
	.cfi_startproc
; %bb.0:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	adrp	x8, ___stdinp@GOTPAGE
	ldr	x8, [x8, ___stdinp@GOTPAGEOFF]
	ldr	x0, [x8]
	bl	_fileno
	bl	_isatty
	subs	w8, w0, #0
	cset	w8, eq
	tbnz	w8, #0, LBB2_2
	b	LBB2_1
LBB2_1:
	adrp	x0, l_.str.19@PAGE
	add	x0, x0, l_.str.19@PAGEOFF
	bl	_printf
	b	LBB2_2
LBB2_2:
	ldp	x29, x30, [sp], #16             ; 16-byte Folded Reload
	ret
	.cfi_endproc
                                        ; -- End function





	.globl	_tokenize                       ; -- Begin function tokenize
	.p2align	2
_tokenize:                              ; @tokenize
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #64
	.cfi_def_cfa_offset 64
	stp	x29, x30, [sp, #48]             ; 16-byte Folded Spill
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	stur	x0, [x29, #-16]
	str	x1, [sp, #24]
	ldur	x8, [x29, #-16]
	subs	x8, x8, #0
	cset	w8, ne
	tbnz	w8, #0, LBB3_2
	b	LBB3_1
LBB3_1:
	mov	w8, #-1
	stur	w8, [x29, #-4]
	b	LBB3_20
LBB3_2:
	str	wzr, [sp, #20]
	ldur	x8, [x29, #-16]
	str	x8, [sp, #8]
	b	LBB3_3
LBB3_3:                                 ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB3_4 Depth 2
                                        ;     Child Loop BB3_12 Depth 2
	b	LBB3_4
LBB3_4:                                 ;   Parent Loop BB3_3 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ldr	x8, [sp, #8]
	ldrsb	w0, [x8]
	bl	_isspace
	subs	w8, w0, #0
	cset	w8, eq
	tbnz	w8, #0, LBB3_6
	b	LBB3_5
LBB3_5:                                 ;   in Loop: Header=BB3_4 Depth=2
	ldr	x8, [sp, #8]
	add	x8, x8, #1
	str	x8, [sp, #8]
	b	LBB3_4
LBB3_6:                                 ;   in Loop: Header=BB3_3 Depth=1
	ldr	x8, [sp, #8]
	ldrsb	w8, [x8]
	subs	w8, w8, #0
	cset	w8, ne
	tbnz	w8, #0, LBB3_8
	b	LBB3_7
LBB3_7:
	ldr	x8, [sp, #8]
	ldr	x9, [sp, #24]
	ldrsw	x10, [sp, #20]
	str	x8, [x9, x10, lsl #3]
	ldr	w8, [sp, #20]
	stur	w8, [x29, #-4]
	b	LBB3_20
LBB3_8:                                 ;   in Loop: Header=BB3_3 Depth=1
	ldr	x8, [sp, #8]
	ldrsb	w0, [x8]
	bl	_isalpha
	subs	w8, w0, #0
	cset	w8, ne
	tbnz	w8, #0, LBB3_10
	b	LBB3_9
LBB3_9:
	adrp	x8, ___stderrp@GOTPAGE
	ldr	x8, [x8, ___stderrp@GOTPAGEOFF]
	ldr	x0, [x8]
	ldr	x8, [sp, #8]
	ldrsb	w10, [x8]
	mov	x9, sp
                                        ; implicit-def: $x8
	mov	x8, x10
	str	x8, [x9]
	adrp	x1, l_.str.5@PAGE
	add	x1, x1, l_.str.5@PAGEOFF
	bl	_fprintf
	mov	w8, #-1
	stur	w8, [x29, #-4]
	b	LBB3_20
LBB3_10:                                ;   in Loop: Header=BB3_3 Depth=1
	b	LBB3_11
LBB3_11:                                ;   in Loop: Header=BB3_3 Depth=1
	ldr	x8, [sp, #8]
	ldr	x9, [sp, #24]
	ldrsw	x10, [sp, #20]
	mov	x11, x10
	add	w11, w11, #1
	str	w11, [sp, #20]
	str	x8, [x9, x10, lsl #3]
	b	LBB3_12
LBB3_12:                                ;   Parent Loop BB3_3 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ldr	x8, [sp, #8]			// x8 = p
	ldrsb	w0, [x8]			// w0 = *p
	bl	_isalpha				// isalpha(*p)
	subs	w8, w0, #0
	cset	w8, eq
	tbnz	w8, #0, LBB3_14		// if isalpha(*p), b LBB3_13
	b	LBB3_13
LBB3_13:                                ;   in Loop: Header=BB3_12 Depth=2
	ldr	x8, [sp, #8]
	add	x8, x8, #1				// p++
	str	x8, [sp, #8]
	b	LBB3_12
LBB3_14:                                ;   in Loop: Header=BB3_3 Depth=1
	ldr	x8, [sp, #8]
	ldrsb	w8, [x8]
	subs	w8, w8, #0
	cset	w8, ne
	tbnz	w8, #0, LBB3_16
	b	LBB3_15
LBB3_15:
	ldr	x8, [sp, #8]
	ldr	x9, [sp, #24]
	ldrsw	x10, [sp, #20]
	str	x8, [x9, x10, lsl #3]
	ldr	w8, [sp, #20]
	stur	w8, [x29, #-4]
	b	LBB3_20
LBB3_16:                                ;   in Loop: Header=BB3_3 Depth=1
	ldr	x8, [sp, #8]
	ldrsb	w0, [x8]
	bl	_isspace
	subs	w8, w0, #0
	cset	w8, ne
	tbnz	w8, #0, LBB3_18
	b	LBB3_17
LBB3_17:
	adrp	x8, ___stderrp@GOTPAGE
	ldr	x8, [x8, ___stderrp@GOTPAGEOFF]
	ldr	x0, [x8]
	ldr	x8, [sp, #8]
	ldrsb	w10, [x8]
	mov	x9, sp
                                        ; implicit-def: $x8
	mov	x8, x10
	str	x8, [x9]
	adrp	x1, l_.str.5@PAGE
	add	x1, x1, l_.str.5@PAGEOFF
	bl	_fprintf
	mov	w8, #-1
	stur	w8, [x29, #-4]
	b	LBB3_20
LBB3_18:                                ;   in Loop: Header=BB3_3 Depth=1
	b	LBB3_19
LBB3_19:                                ;   in Loop: Header=BB3_3 Depth=1
	ldr	x8, [sp, #8]
	add	x9, x8, #1
	str	x9, [sp, #8]
	strb	wzr, [x8]
	b	LBB3_3
LBB3_20:
	ldur	w0, [x29, #-4]
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	add	sp, sp, #64
	ret
	.cfi_endproc
                                        ; -- End function









	.globl	_printQuery                     ; -- Begin function printQuery
	.p2align	2
_printQuery:                            ; @printQuery
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #48
	.cfi_def_cfa_offset 48
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	stur	x0, [x29, #-8]
	stur	w1, [x29, #-12]
	adrp	x0, l_.str.6@PAGE
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	str	wzr, [sp, #16]
	b	LBB4_1
LBB4_1:                                 ; =>This Inner Loop Header: Depth=1
	ldr	w8, [sp, #16]
	ldur	w9, [x29, #-12]
	subs	w9, w9, #1
	subs	w8, w8, w9
	cset	w8, ge
	tbnz	w8, #0, LBB4_4
	b	LBB4_2
LBB4_2:                                 ;   in Loop: Header=BB4_1 Depth=1
	ldur	x8, [x29, #-8]
	ldrsw	x9, [sp, #16]
	ldr	x8, [x8, x9, lsl #3]
	mov	x9, sp
	str	x8, [x9]
	adrp	x0, l_.str.7@PAGE
	add	x0, x0, l_.str.7@PAGEOFF
	bl	_printf
	b	LBB4_3
LBB4_3:                                 ;   in Loop: Header=BB4_1 Depth=1
	ldr	w8, [sp, #16]
	add	w8, w8, #1
	str	w8, [sp, #16]
	b	LBB4_1
LBB4_4:
	ldur	x8, [x29, #-8]
	ldur	w9, [x29, #-12]
	subs	w9, w9, #1
	ldr	x8, [x8, w9, sxtw #3]
	mov	x9, sp
	str	x8, [x9]
	adrp	x0, l_.str.8@PAGE
	add	x0, x0, l_.str.8@PAGEOFF
	bl	_printf
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_take_set_intersection          ; -- Begin function take_set_intersection
	.p2align	2
_take_set_intersection:                 ; @take_set_intersection
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #112
	.cfi_def_cfa_offset 112
	stp	x29, x30, [sp, #96]             ; 16-byte Folded Spill
	add	x29, sp, #96
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	stur	x0, [x29, #-8]
	stur	x1, [x29, #-16]
	stur	x2, [x29, #-24]
	stur	x3, [x29, #-32]
	stur	w4, [x29, #-36]
	stur	w5, [x29, #-40]
	bl	_set_new
	str	x0, [sp, #24]
	mov	w8, #1
	str	w8, [sp, #20]
	b	LBB5_1
LBB5_1:                                 ; =>This Inner Loop Header: Depth=1
	ldr	w8, [sp, #20]
	subs	w8, w8, #1000
	cset	w8, ge
	tbnz	w8, #0, LBB5_6
	b	LBB5_2
LBB5_2:                                 ;   in Loop: Header=BB5_1 Depth=1
	ldur	x0, [x29, #-16]
	ldur	x8, [x29, #-24]
	ldursw	x9, [x29, #-36]
	ldr	x1, [x8, x9, lsl #3]
	ldr	w2, [sp, #20]
	bl	_index_get
	stur	w0, [x29, #-44]
	subs	w8, w0, #0
	cset	w8, le
	tbnz	w8, #0, LBB5_4
	b	LBB5_3
LBB5_3:                                 ;   in Loop: Header=BB5_1 Depth=1
	ldur	x0, [x29, #-8]
	ldr	w1, [sp, #20]
	bl	_buildPath
	str	x0, [sp, #40]
	ldr	x8, [sp, #24]
	str	x8, [sp, #8]                    ; 8-byte Folded Spill
	ldr	x8, [sp, #40]
	str	x8, [sp]                        ; 8-byte Folded Spill
	ldur	w0, [x29, #-44]
	bl	_intsave
	ldr	x1, [sp]                        ; 8-byte Folded Reload
	mov	x2, x0
	ldr	x0, [sp, #8]                    ; 8-byte Folded Reload
	bl	_set_insert
	ldr	x0, [sp, #40]
	bl	_free
	b	LBB5_4
LBB5_4:                                 ;   in Loop: Header=BB5_1 Depth=1
	b	LBB5_5
LBB5_5:                                 ;   in Loop: Header=BB5_1 Depth=1
	ldr	w8, [sp, #20]
	add	w8, w8, #1
	str	w8, [sp, #20]
	b	LBB5_1
LBB5_6:
	ldur	w8, [x29, #-40]
	subs	w8, w8, #0
	cset	w8, ne
	tbnz	w8, #0, LBB5_8
	b	LBB5_7
LBB5_7:
	ldur	x8, [x29, #-32]
	ldr	x0, [x8]
	ldr	x1, [sp, #24]
	bl	_set_merge
	b	LBB5_9
LBB5_8:
	ldur	x8, [x29, #-32]
	ldr	x0, [x8]
	ldr	x1, [sp, #24]
	bl	_set_intersect
	str	x0, [sp, #32]
	ldur	x8, [x29, #-32]
	ldr	x0, [x8]
	adrp	x1, _itemdelete@PAGE
	add	x1, x1, _itemdelete@PAGEOFF
	bl	_set_delete
	ldr	x8, [sp, #32]
	ldur	x9, [x29, #-32]
	str	x8, [x9]
	b	LBB5_9
LBB5_9:
	ldr	x0, [sp, #24]
	adrp	x1, _itemdelete@PAGE
	add	x1, x1, _itemdelete@PAGEOFF
	bl	_set_delete
	ldp	x29, x30, [sp, #96]             ; 16-byte Folded Reload
	add	sp, sp, #112
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_intsave                        ; -- Begin function intsave
	.p2align	2
_intsave:                               ; @intsave
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #32
	.cfi_def_cfa_offset 32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	stur	w0, [x29, #-4]
	mov	x0, #4
	bl	_malloc
	str	x0, [sp]
	ldur	w8, [x29, #-4]
	ldr	x9, [sp]
	str	w8, [x9]
	ldr	x0, [sp]
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #32
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_itemdelete                     ; -- Begin function itemdelete
	.p2align	2
_itemdelete:                            ; @itemdelete
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #32
	.cfi_def_cfa_offset 32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	str	x0, [sp, #8]
	ldr	x8, [sp, #8]
	subs	x8, x8, #0
	cset	w8, eq
	tbnz	w8, #0, LBB7_2
	b	LBB7_1
LBB7_1:
	ldr	x0, [sp, #8]
	bl	_free
	b	LBB7_2
LBB7_2:
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #32
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_print_query_results            ; -- Begin function print_query_results
	.p2align	2
_print_query_results:                   ; @print_query_results
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #64
	.cfi_def_cfa_offset 64
	stp	x29, x30, [sp, #48]             ; 16-byte Folded Spill
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	stur	x0, [x29, #-8]
	sub	x1, x29, #12
	stur	wzr, [x29, #-12]
	sub	x8, x29, #16
	str	x8, [sp, #16]                   ; 8-byte Folded Spill
	stur	wzr, [x29, #-16]
	ldur	x0, [x29, #-8]
	adrp	x2, _findmax@PAGE
	add	x2, x2, _findmax@PAGEOFF
	bl	_set_iterate
	ldr	x1, [sp, #16]                   ; 8-byte Folded Reload
	ldur	x0, [x29, #-8]
	adrp	x2, _findsize@PAGE
	add	x2, x2, _findsize@PAGEOFF
	bl	_set_iterate
	ldur	w8, [x29, #-12]
	subs	w8, w8, #0
	cset	w8, ne
	tbnz	w8, #0, LBB8_2
	b	LBB8_1
LBB8_1:
	adrp	x0, l_.str.9@PAGE
	add	x0, x0, l_.str.9@PAGEOFF
	bl	_printf
	b	LBB8_7
LBB8_2:
	ldur	w9, [x29, #-16]
                                        ; implicit-def: $x8
	mov	x8, x9
	mov	x9, sp
	str	x8, [x9]
	adrp	x0, l_.str.10@PAGE
	add	x0, x0, l_.str.10@PAGEOFF
	bl	_printf
	stur	wzr, [x29, #-20]
	b	LBB8_3
LBB8_3:                                 ; =>This Inner Loop Header: Depth=1
	ldur	w8, [x29, #-20]
	ldur	w9, [x29, #-12]
	subs	w8, w8, w9
	cset	w8, ge
	tbnz	w8, #0, LBB8_6
	b	LBB8_4
LBB8_4:                                 ;   in Loop: Header=BB8_3 Depth=1
	ldur	w8, [x29, #-12]
	ldur	w9, [x29, #-20]
	subs	w8, w8, w9
	add	x1, sp, #24
	str	w8, [sp, #24]
	ldur	x0, [x29, #-8]
	adrp	x2, _printRanked@PAGE
	add	x2, x2, _printRanked@PAGEOFF
	bl	_set_iterate
	b	LBB8_5
LBB8_5:                                 ;   in Loop: Header=BB8_3 Depth=1
	ldur	w8, [x29, #-20]
	add	w8, w8, #1
	stur	w8, [x29, #-20]
	b	LBB8_3
LBB8_6:
	b	LBB8_7
LBB8_7:
	adrp	x0, l_.str.11@PAGE
	add	x0, x0, l_.str.11@PAGEOFF
	bl	_printf
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	add	sp, sp, #64
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_findmax                        ; -- Begin function findmax
	.p2align	2
_findmax:                               ; @findmax
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #48
	.cfi_def_cfa_offset 48
	str	x0, [sp, #40]
	str	x1, [sp, #32]
	str	x2, [sp, #24]
	ldr	x8, [sp, #40]
	str	x8, [sp, #16]
	ldr	x8, [sp, #24]
	str	x8, [sp, #8]
	ldr	x8, [sp, #8]
	ldr	w8, [x8]
	ldr	x9, [sp, #16]
	ldr	w9, [x9]
	subs	w8, w8, w9
	cset	w8, le
	tbnz	w8, #0, LBB9_2
	b	LBB9_1
LBB9_1:
	ldr	x8, [sp, #8]
	ldr	w8, [x8]
	str	w8, [sp, #4]                    ; 4-byte Folded Spill
	b	LBB9_3
LBB9_2:
	ldr	x8, [sp, #16]
	ldr	w8, [x8]
	str	w8, [sp, #4]                    ; 4-byte Folded Spill
	b	LBB9_3
LBB9_3:
	ldr	w8, [sp, #4]                    ; 4-byte Folded Reload
	ldr	x9, [sp, #16]
	str	w8, [x9]
	add	sp, sp, #48
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_findsize                       ; -- Begin function findsize
	.p2align	2
_findsize:                              ; @findsize
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #32
	.cfi_def_cfa_offset 32
	str	x0, [sp, #24]
	str	x1, [sp, #16]
	str	x2, [sp, #8]
	ldr	x8, [sp, #24]
	str	x8, [sp]
	ldr	x8, [sp]
	ldr	w8, [x8]
	add	w8, w8, #1
	ldr	x9, [sp]
	str	w8, [x9]
	add	sp, sp, #32
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_printRanked                    ; -- Begin function printRanked
	.p2align	2
_printRanked:                           ; @printRanked
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #112
	.cfi_def_cfa_offset 112
	stp	x29, x30, [sp, #96]             ; 16-byte Folded Spill
	add	x29, sp, #96
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	stur	x0, [x29, #-8]
	stur	x1, [x29, #-16]
	stur	x2, [x29, #-24]
	ldur	x8, [x29, #-8]
	stur	x8, [x29, #-32]
	ldur	x8, [x29, #-24]
	stur	x8, [x29, #-40]
	ldur	x8, [x29, #-40]
	ldr	w8, [x8]
	ldur	x9, [x29, #-32]
	ldr	w9, [x9]
	subs	w8, w8, w9
	cset	w8, eq
	tbnz	w8, #0, LBB11_2
	b	LBB11_1
LBB11_1:
	b	LBB11_3
LBB11_2:
	ldur	x0, [x29, #-16]
	adrp	x1, l_.str.17@PAGE
	add	x1, x1, l_.str.17@PAGEOFF
	bl	_fopen
	str	x0, [sp, #48]
	ldr	x0, [sp, #48]
	bl	_file_readLine
	str	x0, [sp, #40]
	ldur	x0, [x29, #-16]
	bl	_parseInt
	str	w0, [sp, #36]
	ldur	x8, [x29, #-40]
	ldr	w8, [x8]
                                        ; implicit-def: $x11
	mov	x11, x8
	ldr	w8, [sp, #36]
                                        ; implicit-def: $x10
	mov	x10, x8
	ldr	x8, [sp, #40]
	mov	x9, sp
	str	x11, [x9]
	str	x10, [x9, #8]
	str	x8, [x9, #16]
	adrp	x0, l_.str.18@PAGE
	add	x0, x0, l_.str.18@PAGEOFF
	bl	_printf
	ldr	x0, [sp, #40]
	bl	_free
	ldr	x0, [sp, #48]
	bl	_fclose
	b	LBB11_3
LBB11_3:
	ldp	x29, x30, [sp, #96]             ; 16-byte Folded Reload
	add	sp, sp, #112
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_validate_query                 ; -- Begin function validate_query
	.p2align	2
_validate_query:                        ; @validate_query
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #80
	.cfi_def_cfa_offset 80
	stp	x29, x30, [sp, #64]             ; 16-byte Folded Spill
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	adrp	x8, ___stderrp@GOTPAGE
	ldr	x8, [x8, ___stderrp@GOTPAGEOFF]
	str	x8, [sp, #16]                   ; 8-byte Folded Spill
	stur	x0, [x29, #-16]
	stur	x1, [x29, #-24]
	str	x2, [sp, #32]
	str	w3, [sp, #28]
	ldur	x8, [x29, #-16]
	subs	x8, x8, #0
	cset	w8, eq
	tbnz	w8, #0, LBB12_4
	b	LBB12_1
LBB12_1:
	ldur	x8, [x29, #-24]
	subs	x8, x8, #0
	cset	w8, eq
	tbnz	w8, #0, LBB12_4
	b	LBB12_2
LBB12_2:
	ldr	x8, [sp, #32]
	subs	x8, x8, #0
	cset	w8, eq
	tbnz	w8, #0, LBB12_4
	b	LBB12_3
LBB12_3:
	ldr	w8, [sp, #28]
	subs	w8, w8, #0
	cset	w8, ge
	tbnz	w8, #0, LBB12_5
	b	LBB12_4
LBB12_4:
	mov	w8, #0
	and	w8, w8, #0x1
	and	w8, w8, #0x1
	sturb	w8, [x29, #-1]
	b	LBB12_21
LBB12_5:
	ldr	x8, [sp, #32]
	ldr	x0, [x8]
	adrp	x1, l_.str.12@PAGE
	add	x1, x1, l_.str.12@PAGEOFF
	bl	_strcmp
	subs	w8, w0, #0
	cset	w8, eq
	tbnz	w8, #0, LBB12_7
	b	LBB12_6
LBB12_6:
	ldr	x8, [sp, #32]
	ldr	x0, [x8]
	adrp	x1, l_.str.13@PAGE
	add	x1, x1, l_.str.13@PAGEOFF
	bl	_strcmp
	subs	w8, w0, #0
	cset	w8, ne
	tbnz	w8, #0, LBB12_8
	b	LBB12_7
LBB12_7:
	ldr	x8, [sp, #16]                   ; 8-byte Folded Reload
	ldr	x0, [x8]
	ldr	x8, [sp, #32]
	ldr	x8, [x8]
	mov	x9, sp
	str	x8, [x9]
	adrp	x1, l_.str.14@PAGE
	add	x1, x1, l_.str.14@PAGEOFF
	bl	_fprintf
	mov	w8, #0
	and	w8, w8, #0x1
	and	w8, w8, #0x1
	sturb	w8, [x29, #-1]
	b	LBB12_21
LBB12_8:
	ldr	x8, [sp, #32]
	ldr	w9, [sp, #28]
	subs	w9, w9, #1
	ldr	x0, [x8, w9, sxtw #3]
	adrp	x1, l_.str.12@PAGE
	add	x1, x1, l_.str.12@PAGEOFF
	bl	_strcmp
	subs	w8, w0, #0
	cset	w8, eq
	tbnz	w8, #0, LBB12_10
	b	LBB12_9
LBB12_9:
	ldr	x8, [sp, #32]
	ldr	w9, [sp, #28]
	subs	w9, w9, #1
	ldr	x0, [x8, w9, sxtw #3]
	adrp	x1, l_.str.13@PAGE
	add	x1, x1, l_.str.13@PAGEOFF
	bl	_strcmp
	subs	w8, w0, #0
	cset	w8, ne
	tbnz	w8, #0, LBB12_11
	b	LBB12_10
LBB12_10:
	ldr	x8, [sp, #16]                   ; 8-byte Folded Reload
	ldr	x0, [x8]
	ldr	x8, [sp, #32]
	ldr	w9, [sp, #28]
	subs	w9, w9, #1
	ldr	x8, [x8, w9, sxtw #3]
	mov	x9, sp
	str	x8, [x9]
	adrp	x1, l_.str.15@PAGE
	add	x1, x1, l_.str.15@PAGEOFF
	bl	_fprintf
	mov	w8, #0
	and	w8, w8, #0x1
	and	w8, w8, #0x1
	sturb	w8, [x29, #-1]
	b	LBB12_21
LBB12_11:
	mov	w8, #1
	str	w8, [sp, #24]
	b	LBB12_12
LBB12_12:                               ; =>This Inner Loop Header: Depth=1
	ldr	w8, [sp, #24]
	ldr	w9, [sp, #28]
	subs	w9, w9, #1
	subs	w8, w8, w9
	cset	w8, ge
	tbnz	w8, #0, LBB12_20
	b	LBB12_13
LBB12_13:                               ;   in Loop: Header=BB12_12 Depth=1
	ldr	x8, [sp, #32]
	ldrsw	x9, [sp, #24]
	ldr	x0, [x8, x9, lsl #3]
	adrp	x1, l_.str.12@PAGE
	add	x1, x1, l_.str.12@PAGEOFF
	bl	_strcmp
	subs	w8, w0, #0
	cset	w8, eq
	tbnz	w8, #0, LBB12_15
	b	LBB12_14
LBB12_14:                               ;   in Loop: Header=BB12_12 Depth=1
	ldr	x8, [sp, #32]
	ldrsw	x9, [sp, #24]
	ldr	x0, [x8, x9, lsl #3]
	adrp	x1, l_.str.13@PAGE
	add	x1, x1, l_.str.13@PAGEOFF
	bl	_strcmp
	subs	w8, w0, #0
	cset	w8, ne
	tbnz	w8, #0, LBB12_18
	b	LBB12_15
LBB12_15:                               ;   in Loop: Header=BB12_12 Depth=1
	ldr	x8, [sp, #32]
	ldr	w9, [sp, #24]
	add	w9, w9, #1
	ldr	x0, [x8, w9, sxtw #3]
	adrp	x1, l_.str.12@PAGE
	add	x1, x1, l_.str.12@PAGEOFF
	bl	_strcmp
	subs	w8, w0, #0
	cset	w8, eq
	tbnz	w8, #0, LBB12_17
	b	LBB12_16
LBB12_16:                               ;   in Loop: Header=BB12_12 Depth=1
	ldr	x8, [sp, #32]
	ldr	w9, [sp, #24]
	add	w9, w9, #1
	ldr	x0, [x8, w9, sxtw #3]
	adrp	x1, l_.str.13@PAGE
	add	x1, x1, l_.str.13@PAGEOFF
	bl	_strcmp
	subs	w8, w0, #0
	cset	w8, ne
	tbnz	w8, #0, LBB12_18
	b	LBB12_17
LBB12_17:
	ldr	x8, [sp, #16]                   ; 8-byte Folded Reload
	ldr	x0, [x8]
	ldr	x8, [sp, #32]
	ldrsw	x9, [sp, #24]
	ldr	x10, [x8, x9, lsl #3]
	ldr	x8, [sp, #32]
	ldr	w9, [sp, #24]
	add	w9, w9, #1
	ldr	x8, [x8, w9, sxtw #3]
	mov	x9, sp
	str	x10, [x9]
	str	x8, [x9, #8]
	adrp	x1, l_.str.16@PAGE
	add	x1, x1, l_.str.16@PAGEOFF
	bl	_fprintf
	mov	w8, #0
	and	w8, w8, #0x1
	and	w8, w8, #0x1
	sturb	w8, [x29, #-1]
	b	LBB12_21
LBB12_18:                               ;   in Loop: Header=BB12_12 Depth=1
	b	LBB12_19
LBB12_19:                               ;   in Loop: Header=BB12_12 Depth=1
	ldr	w8, [sp, #24]
	add	w8, w8, #1
	str	w8, [sp, #24]
	b	LBB12_12
LBB12_20:
	mov	w8, #1
	and	w8, w8, #0x1
	and	w8, w8, #0x1
	sturb	w8, [x29, #-1]
	b	LBB12_21
LBB12_21:
	ldurb	w8, [x29, #-1]
	and	w0, w8, #0x1
	ldp	x29, x30, [sp, #64]             ; 16-byte Folded Reload
	add	sp, sp, #80
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_Query                          ; -- Begin function Query
	.p2align	2
_Query:                                 ; @Query
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #96
	.cfi_def_cfa_offset 96
	stp	x29, x30, [sp, #80]             ; 16-byte Folded Spill
	add	x29, sp, #80
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	stur	x0, [x29, #-16]
	stur	x1, [x29, #-24]
	stur	x2, [x29, #-32]
	stur	w3, [x29, #-36]
	ldur	x0, [x29, #-16]
	ldur	x1, [x29, #-24]
	ldur	x2, [x29, #-32]
	ldur	w3, [x29, #-36]
	bl	_validate_query
	tbnz	w0, #0, LBB13_2
	b	LBB13_1
LBB13_1:
	mov	w8, #0
	and	w8, w8, #0x1
	and	w8, w8, #0x1
	sturb	w8, [x29, #-1]
	b	LBB13_15
LBB13_2:
	ldur	w8, [x29, #-36]
	subs	w8, w8, #0
	cset	w8, ne
	tbnz	w8, #0, LBB13_4
	b	LBB13_3
LBB13_3:
	mov	w8, #1
	and	w8, w8, #0x1
	and	w8, w8, #0x1
	sturb	w8, [x29, #-1]
	b	LBB13_15
LBB13_4:
	ldur	x0, [x29, #-32]
	ldur	w1, [x29, #-36]
	bl	_printQuery
	bl	_set_new
	str	x0, [sp, #32]
	str	wzr, [sp, #20]
	str	wzr, [sp, #16]
	b	LBB13_5
LBB13_5:                                ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB13_7 Depth 2
	ldr	w8, [sp, #20]
	ldur	w9, [x29, #-36]
	subs	w8, w8, w9
	cset	w8, ge
	tbnz	w8, #0, LBB13_14
	b	LBB13_6
LBB13_6:                                ;   in Loop: Header=BB13_5 Depth=1
	bl	_set_new
	str	x0, [sp, #24]
	b	LBB13_7
LBB13_7:                                ;   Parent Loop BB13_5 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ldr	w8, [sp, #20]
	ldur	w9, [x29, #-36]
	subs	w8, w8, w9
	cset	w8, ge
	mov	w9, #0
	str	w9, [sp, #12]                   ; 4-byte Folded Spill
	tbnz	w8, #0, LBB13_9
	b	LBB13_8
LBB13_8:                                ;   in Loop: Header=BB13_7 Depth=2
	ldur	x8, [x29, #-32]
	ldrsw	x9, [sp, #20]
	ldr	x0, [x8, x9, lsl #3]
	adrp	x1, l_.str.13@PAGE
	add	x1, x1, l_.str.13@PAGEOFF
	bl	_strcmp
	subs	w8, w0, #0
	cset	w8, ne
	str	w8, [sp, #12]                   ; 4-byte Folded Spill
	b	LBB13_9
LBB13_9:                                ;   in Loop: Header=BB13_7 Depth=2
	ldr	w8, [sp, #12]                   ; 4-byte Folded Reload
	tbz	w8, #0, LBB13_13
	b	LBB13_10
LBB13_10:                               ;   in Loop: Header=BB13_7 Depth=2
	ldur	x8, [x29, #-32]
	ldrsw	x9, [sp, #20]
	ldr	x0, [x8, x9, lsl #3]
	adrp	x1, l_.str.12@PAGE
	add	x1, x1, l_.str.12@PAGEOFF
	bl	_strcmp
	subs	w8, w0, #0
	cset	w8, eq
	tbnz	w8, #0, LBB13_12
	b	LBB13_11
LBB13_11:                               ;   in Loop: Header=BB13_7 Depth=2
	ldur	x0, [x29, #-16]
	ldur	x1, [x29, #-24]
	ldur	x2, [x29, #-32]
	ldr	w4, [sp, #20]
	ldr	w5, [sp, #16]
	add	x3, sp, #24
	bl	_take_set_intersection
	b	LBB13_12
LBB13_12:                               ;   in Loop: Header=BB13_7 Depth=2
	ldr	w8, [sp, #20]
	add	w8, w8, #1
	str	w8, [sp, #20]
	ldr	w8, [sp, #16]
	add	w8, w8, #1
	str	w8, [sp, #16]
	b	LBB13_7
LBB13_13:                               ;   in Loop: Header=BB13_5 Depth=1
	ldr	x0, [sp, #32]
	ldr	x1, [sp, #24]
	bl	_set_merge
	ldr	x0, [sp, #24]
	adrp	x1, _itemdelete@PAGE
	add	x1, x1, _itemdelete@PAGEOFF
	bl	_set_delete
	str	wzr, [sp, #16]
	ldr	w8, [sp, #20]
	add	w8, w8, #1
	str	w8, [sp, #20]
	b	LBB13_5
LBB13_14:
	ldr	x0, [sp, #32]
	bl	_print_query_results
	ldr	x0, [sp, #32]
	adrp	x1, _itemdelete@PAGE
	add	x1, x1, _itemdelete@PAGEOFF
	bl	_set_delete
	mov	w8, #1
	and	w8, w8, #0x1
	and	w8, w8, #0x1
	sturb	w8, [x29, #-1]
	b	LBB13_15
LBB13_15:
	ldurb	w8, [x29, #-1]
	and	w0, w8, #0x1
	ldp	x29, x30, [sp, #80]             ; 16-byte Folded Reload
	add	sp, sp, #96
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_parseInt                       ; -- Begin function parseInt
	.p2align	2
_parseInt:                              ; @parseInt
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #80
	.cfi_def_cfa_offset 80
	stp	x29, x30, [sp, #64]             ; 16-byte Folded Spill
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	adrp	x8, ___stack_chk_guard@GOTPAGE
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
	ldr	x8, [x8]
	stur	x8, [x29, #-8]
	str	x0, [sp, #32]
	str	wzr, [sp, #28]
	str	wzr, [sp, #24]
	ldr	x8, [sp, #32]
	str	x8, [sp, #8]                    ; 8-byte Folded Spill
	ldr	x0, [sp, #32]
	bl	_strlen
	ldr	x8, [sp, #8]                    ; 8-byte Folded Reload
	add	x8, x8, x0
	str	x8, [sp, #16]
	b	LBB14_1
LBB14_1:                                ; =>This Inner Loop Header: Depth=1
	ldr	x8, [sp, #16]
	ldrsb	w8, [x8]
	subs	w8, w8, #47
	cset	w8, eq
	tbnz	w8, #0, LBB14_3
	b	LBB14_2
LBB14_2:                                ;   in Loop: Header=BB14_1 Depth=1
	ldr	x8, [sp, #16]
	subs	x8, x8, #1
	str	x8, [sp, #16]
	b	LBB14_1
LBB14_3:
	b	LBB14_4
LBB14_4:                                ; =>This Inner Loop Header: Depth=1
	ldr	x8, [sp, #16]
	ldrsb	w8, [x8]
	subs	w8, w8, #0
	cset	w8, eq
	tbnz	w8, #0, LBB14_6
	b	LBB14_5
LBB14_5:                                ;   in Loop: Header=BB14_4 Depth=1
	ldr	x8, [sp, #16]
	add	x8, x8, #1
	str	x8, [sp, #16]
	ldr	x8, [sp, #16]
	ldrb	w8, [x8]
	ldrsw	x10, [sp, #28]
	mov	x9, x10
	add	w9, w9, #1
	str	w9, [sp, #28]
	sub	x9, x29, #24
	add	x9, x9, x10
	strb	w8, [x9]
	b	LBB14_4
LBB14_6:
	sub	x0, x29, #24
	add	x1, sp, #24
	bl	_str2int
	ldr	w8, [sp, #24]
	str	w8, [sp, #4]                    ; 4-byte Folded Spill
	ldur	x9, [x29, #-8]
	adrp	x8, ___stack_chk_guard@GOTPAGE
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
	ldr	x8, [x8]
	subs	x8, x8, x9
	cset	w8, eq
	tbnz	w8, #0, LBB14_8
	b	LBB14_7
LBB14_7:
	bl	___stack_chk_fail
LBB14_8:
	ldr	w0, [sp, #4]                    ; 4-byte Folded Reload
	ldp	x29, x30, [sp, #64]             ; 16-byte Folded Reload
	add	sp, sp, #80
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_main                           ; -- Begin function main
	.p2align	2
_main:                                  ; @main
	.cfi_startproc
; %bb.0:
	stp	x20, x19, [sp, #-32]!           ; 16-byte Folded Spill
	.cfi_def_cfa_offset 32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	sub	sp, sp, #1104
	mov	x19, sp
	adrp	x8, ___stack_chk_guard@GOTPAGE
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
	ldr	x8, [x8]
	stur	x8, [x29, #-24]
	str	wzr, [x19, #92]
	str	w0, [x19, #88]
	str	x1, [x19, #80]
	ldr	w0, [x19, #88]
	ldr	x1, [x19, #80]
	add	x2, x19, #72
	bl	_parseArgs
	str	x0, [x19, #64]
	b	LBB15_1
LBB15_1:                                ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB15_5 Depth 2
	add	x0, x19, #96
	bl	_newQuery
	tbz	w0, #0, LBB15_14
	b	LBB15_2
LBB15_2:                                ;   in Loop: Header=BB15_1 Depth=1
	add	x0, x19, #96
	str	x0, [x19, #8]                   ; 8-byte Folded Spill
	bl	_strlen
	mov	x8, x0
	ldr	x0, [x19, #8]                   ; 8-byte Folded Reload
	mov	x9, #2
	udiv	x8, x8, x9
                                        ; kill: def $w8 killed $w8 killed $x8
	add	w8, w8, #1
                                        ; kill: def $x8 killed $w8
	mov	x9, sp
	str	x9, [x19, #56]
	lsl	x9, x8, #3
	add	x9, x9, #15
	and	x9, x9, #0xfffffffffffffff0
	str	x9, [x19, #16]                  ; 8-byte Folded Spill
	adrp	x16, ___chkstk_darwin@GOTPAGE
	ldr	x16, [x16, ___chkstk_darwin@GOTPAGEOFF]
	blr	x16
	ldr	x10, [x19, #16]                 ; 8-byte Folded Reload
	mov	x9, sp
	subs	x1, x9, x10
	mov	sp, x1
	str	x1, [x19, #24]                  ; 8-byte Folded Spill
	str	x8, [x19, #48]
	bl	_tokenize
	str	w0, [x19, #44]
	ldr	w8, [x19, #44]
	adds	w8, w8, #1
	cset	w8, ne
	tbnz	w8, #0, LBB15_4
	b	LBB15_3
LBB15_3:                                ;   in Loop: Header=BB15_1 Depth=1
	mov	w8, #2
	str	w8, [x19, #40]
	b	LBB15_11
LBB15_4:                                ;   in Loop: Header=BB15_1 Depth=1
	str	wzr, [x19, #36]
	b	LBB15_5
LBB15_5:                                ;   Parent Loop BB15_1 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ldr	w8, [x19, #36]
	ldr	w9, [x19, #44]
	subs	w8, w8, w9
	cset	w8, ge
	tbnz	w8, #0, LBB15_8
	b	LBB15_6
LBB15_6:                                ;   in Loop: Header=BB15_5 Depth=2
	ldr	x8, [x19, #24]                  ; 8-byte Folded Reload
	ldrsw	x9, [x19, #36]
	ldr	x0, [x8, x9, lsl #3]
	bl	_normalizeWord
	b	LBB15_7
LBB15_7:                                ;   in Loop: Header=BB15_5 Depth=2
	ldr	w8, [x19, #36]
	add	w8, w8, #1
	str	w8, [x19, #36]
	b	LBB15_5
LBB15_8:                                ;   in Loop: Header=BB15_1 Depth=1
	ldr	x2, [x19, #24]                  ; 8-byte Folded Reload
	ldr	x0, [x19, #72]
	ldr	x1, [x19, #64]
	ldr	w3, [x19, #44]
	bl	_Query
	tbnz	w0, #0, LBB15_10
	b	LBB15_9
LBB15_9:                                ;   in Loop: Header=BB15_1 Depth=1
	mov	w8, #2
	str	w8, [x19, #40]
	b	LBB15_11
LBB15_10:                               ;   in Loop: Header=BB15_1 Depth=1
	str	wzr, [x19, #40]
	b	LBB15_11
LBB15_11:                               ;   in Loop: Header=BB15_1 Depth=1
	ldr	x8, [x19, #56]
	mov	sp, x8
	ldr	w8, [x19, #40]
	subs	w8, w8, #0
	cset	w8, eq
	tbnz	w8, #0, LBB15_13
	b	LBB15_12
LBB15_12:                               ;   in Loop: Header=BB15_1 Depth=1
	b	LBB15_1
LBB15_13:                               ;   in Loop: Header=BB15_1 Depth=1
	b	LBB15_1
LBB15_14:
	adrp	x8, ___stdoutp@GOTPAGE
	ldr	x8, [x8, ___stdoutp@GOTPAGEOFF]
	ldr	x0, [x8]
	adrp	x1, l_.str.20@PAGE
	add	x1, x1, l_.str.20@PAGEOFF
	bl	_fprintf
	ldr	x0, [x19, #72]
	bl	_free
	ldr	x0, [x19, #64]
	bl	_index_delete
	ldur	x9, [x29, #-24]
	adrp	x8, ___stack_chk_guard@GOTPAGE
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
	ldr	x8, [x8]
	subs	x8, x8, x9
	cset	w8, eq
	tbnz	w8, #0, LBB15_16
	b	LBB15_15
LBB15_15:
	bl	___stack_chk_fail
LBB15_16:
	mov	w0, #0
	sub	sp, x29, #16
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp], #32             ; 16-byte Folded Reload
	ret
; %bb.17:
	.cfi_endproc
                                        ; -- End function
	.section	__TEXT,__const
	.globl	_QUERYMAXCHARACTERS             ; @QUERYMAXCHARACTERS
	.p2align	2
_QUERYMAXCHARACTERS:
	.long	1000                            ; 0x3e8

	.globl	_MAXDOCUMENTS                   ; @MAXDOCUMENTS
	.p2align	2
_MAXDOCUMENTS:
	.long	1000                            ; 0x3e8

	.section	__TEXT,__cstring,cstring_literals
l_.str:                                 ; @.str
	.asciz	"Usage: %s pageDirectory indexFilename\n"

l_.str.1:                               ; @.str.1
	.asciz	"/.crawler"

l_.str.2:                               ; @.str.2
	.asciz	"/1"

l_.str.3:                               ; @.str.3
	.asciz	"%s: Please enter a valid pageDirectory marked for crawling.\n"

l_.str.4:                               ; @.str.4
	.asciz	"%s: Error opening %s for reading.\n"

l_.str.5:                               ; @.str.5
	.asciz	"Bad character: %c\n"

l_.str.6:                               ; @.str.6
	.asciz	"Query: "

l_.str.7:                               ; @.str.7
	.asciz	"%s "

l_.str.8:                               ; @.str.8
	.asciz	"%s \n"

l_.str.9:                               ; @.str.9
	.asciz	"No documents match.\n"

l_.str.10:                              ; @.str.10
	.asciz	"Matches %d document(s) (ranked):\n"

l_.str.11:                              ; @.str.11
	.asciz	"-------------------------------------------------------------------\n"

l_.str.12:                              ; @.str.12
	.asciz	"and"

l_.str.13:                              ; @.str.13
	.asciz	"or"

l_.str.14:                              ; @.str.14
	.asciz	"Operator '%s' cannot be first.\n"

l_.str.15:                              ; @.str.15
	.asciz	"Operator '%s' cannot be last.\n"

l_.str.16:                              ; @.str.16
	.asciz	"Operators '%s'/'%s' cannot be adjacent.\n"

l_.str.17:                              ; @.str.17
	.asciz	"r"

l_.str.18:                              ; @.str.18
	.asciz	"score %d doc %d: %s\n"

l_.str.19:                              ; @.str.19
	.asciz	"Query? "

l_.str.20:                              ; @.str.20
	.asciz	"\n"

.subsections_via_symbols
