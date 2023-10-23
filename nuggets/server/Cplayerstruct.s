	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 13, 0	sdk_version 13, 3
	.globl	_player_new                     ; -- Begin function player_new
	.p2align	2

_player_new:                            ; @player_new
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
	stur	w1, [x29, #-20]
	stur	w2, [x29, #-24]
	stur	x3, [x29, #-32]
	str	x4, [sp, #40]
	ldur	x8, [x29, #-16]
	subs	x8, x8, #0
	cset	w8, eq
	tbnz	w8, #0, LBB0_5
	b	LBB0_1
LBB0_1:
	ldur	w8, [x29, #-20]
	subs	w8, w8, #0
	cset	w8, lt
	tbnz	w8, #0, LBB0_5
	b	LBB0_2
LBB0_2:
	ldur	x8, [x29, #-32]
	subs	x8, x8, #0
	cset	w8, eq
	tbnz	w8, #0, LBB0_5
	b	LBB0_3
LBB0_3:
	ldr	x8, [sp, #40]
	subs	x8, x8, #0
	cset	w8, eq
	tbnz	w8, #0, LBB0_5
	b	LBB0_4
LBB0_4:
	ldur	x0, [x29, #-32]
	ldur	w1, [x29, #-24]
	bl	_getX
	adds	w8, w0, #1
	cset	w8, ne
	tbnz	w8, #0, LBB0_6
	b	LBB0_5
LBB0_5:
                                        ; kill: def $x8 killed $xzr
	stur	xzr, [x29, #-8]
	b	LBB0_7
LBB0_6:
	mov	x0, #10040
	bl	_malloc
	str	x0, [sp, #32]
	ldur	x0, [x29, #-16]
	bl	_strlen
	add	x8, x0, #1
                                        ; kill: def $w8 killed $w8 killed $x8
	str	w8, [sp, #28]
	ldrsw	x0, [sp, #28]
	bl	_malloc
	ldr	x8, [sp, #32]			// sp + 32 holds *playerp 
	str	x0, [x8, #8]			// name offset: 8 
	ldr	x8, [sp, #32]
	ldr	x0, [x8, #8]
	ldur	x1, [x29, #-16]
	ldrsw	x2, [sp, #28]
	mov	x3, #-1
	bl	___strncpy_chk
	ldr	x9, [sp, #32]
	mov	w8, #1
	strb	w8, [x9]			// isActive offset: 0
	ldur	w8, [x29, #-20]
	ldr	x9, [sp, #32]
	str	w8, [x9, #16]			// playerNumber offset: 16
	ldur	w8, [x29, #-24]
	ldr	x9, [sp, #32]
	str	w8, [x9, #20]			// pos offset: 20
	ldr	x8, [sp, #32]
	str	wzr, [x8, #24]			// nuggets offset: 24 
	ldur	x8, [x29, #-32]		// x8 = spectatorGrid 
	str	x8, [sp, #16]                   ; 8-byte Folded Spill
	ldr	x8, [sp, #32]
	add	x8, x8, #40
	str	x8, [sp]                        ; 8-byte Folded Spill
	ldur	x0, [x29, #-32]
	ldur	w1, [x29, #-24]
	bl	_getX
	str	w0, [sp, #12]                   ; 4-byte Folded Spill
	ldur	x0, [x29, #-32]
	ldur	w1, [x29, #-24]
	bl	_getY
	ldr	x1, [sp]                        ; 8-byte Folded Reload
	ldr	w2, [sp, #12]                   ; 4-byte Folded Reload
	mov	x3, x0
	ldr	x0, [sp, #16]                   ; 8-byte Folded Reload
	bl	_getVisibleGrid
	ldr	x8, [sp, #40]			// retrieve *originalMap from sp, #40 
	ldr	x9, [sp, #32]
	str	x8, [x9, #32]			// originalMap offset: 32 
	ldr	x8, [sp, #32]
	stur	x8, [x29, #-8]
	b	LBB0_7
LBB0_7:
	ldur	x0, [x29, #-8]
	ldp	x29, x30, [sp, #80]             ; 16-byte Folded Reload
	add	sp, sp, #96
	ret
	.cfi_endproc
                                        ; -- End function
;

						
	.globl	_player_updateGrid              ; -- Begin function player_updateGrid
	.p2align	2
_player_updateGrid:                     ; @player_updateGrid
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #96
	.cfi_def_cfa_offset 96
	stp	x29, x30, [sp, #80]             ; 16-byte Folded Spill
	add	x29, sp, #80
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	stur	x0, [x29, #-8]
	stur	x1, [x29, #-16]
	stur	x2, [x29, #-24]
	ldur	x8, [x29, #-8]
	stur	x8, [x29, #-32]
	ldur	x8, [x29, #-24]
	str	x8, [sp, #40]
	ldr	x8, [sp, #40]
	subs	x8, x8, #0
	cset	w8, eq
	tbnz	w8, #0, LBB1_3
	b	LBB1_1
LBB1_1:
	ldur	x8, [x29, #-32]
	subs	x8, x8, #0
	cset	w8, eq
	tbnz	w8, #0, LBB1_3
	b	LBB1_2
LBB1_2:
	ldr	x8, [sp, #40]
	ldrb	w8, [x8]
	tbnz	w8, #0, LBB1_4
	b	LBB1_3
LBB1_3:
	b	LBB1_25
LBB1_4:
	str	wzr, [sp, #36]
	b	LBB1_5
LBB1_5:                                 ; =>This Inner Loop Header: Depth=1
	ldr	w8, [sp, #36]
	str	w8, [sp, #28]                   ; 4-byte Folded Spill
	ldur	x0, [x29, #-32]
	bl	_get_TC
	ldr	w8, [sp, #28]                   ; 4-byte Folded Reload
	subs	w8, w8, w0
	cset	w8, ge
	tbnz	w8, #0, LBB1_25
	b	LBB1_6
LBB1_6:                                 ;   in Loop: Header=BB1_5 Depth=1
	ldur	x0, [x29, #-32]
	ldr	w1, [sp, #36]
	bl	_get_gridPoint
	strb	w0, [sp, #35]
	ldr	x8, [sp, #40]
	ldr	x0, [x8, #32]
	ldr	w1, [sp, #36]
	bl	_get_gridPoint
	strb	w0, [sp, #34]
	ldr	w8, [sp, #36]
	ldr	x9, [sp, #40]
	ldr	w9, [x9, #20]
	subs	w8, w8, w9
	cset	w8, ne
	tbnz	w8, #0, LBB1_8
	b	LBB1_7
LBB1_7:                                 ;   in Loop: Header=BB1_5 Depth=1
	ldr	x8, [sp, #40]
	add	x8, x8, #40
	ldrsw	x9, [sp, #36]
	add	x9, x8, x9
	mov	w8, #64
	strb	w8, [x9]
	b	LBB1_23
LBB1_8:                                 ;   in Loop: Header=BB1_5 Depth=1
	ldr	x8, [sp, #40]
	add	x8, x8, #40
	ldrsw	x9, [sp, #36]
	ldrsb	w8, [x8, x9]
	subs	w8, w8, #64
	cset	w8, ne
	tbnz	w8, #0, LBB1_10
	b	LBB1_9
LBB1_9:                                 ;   in Loop: Header=BB1_5 Depth=1
	ldrb	w8, [sp, #35]
	ldr	x9, [sp, #40]
	add	x9, x9, #40
	ldrsw	x10, [sp, #36]
	add	x9, x9, x10
	strb	w8, [x9]
	b	LBB1_22
LBB1_10:                                ;   in Loop: Header=BB1_5 Depth=1
	ldur	x8, [x29, #-32]
	str	x8, [sp, #16]                   ; 8-byte Folded Spill
	ldur	x0, [x29, #-32]
	ldr	x8, [sp, #40]
	ldr	w1, [x8, #20]
	bl	_getX
	str	w0, [sp, #4]                    ; 4-byte Folded Spill
	ldur	x0, [x29, #-32]
	ldr	x8, [sp, #40]
	ldr	w1, [x8, #20]
	bl	_getY
	str	w0, [sp, #8]                    ; 4-byte Folded Spill
	ldur	x0, [x29, #-32]
	ldr	w1, [sp, #36]
	bl	_getX
	str	w0, [sp, #12]                   ; 4-byte Folded Spill
	ldur	x0, [x29, #-32]
	ldr	w1, [sp, #36]
	bl	_getY
	ldr	w1, [sp, #4]                    ; 4-byte Folded Reload
	ldr	w2, [sp, #8]                    ; 4-byte Folded Reload
	ldr	w3, [sp, #12]                   ; 4-byte Folded Reload
	mov	x4, x0
	ldr	x0, [sp, #16]                   ; 8-byte Folded Reload
	bl	_isVisible
	tbz	w0, #0, LBB1_12
	b	LBB1_11
LBB1_11:                                ;   in Loop: Header=BB1_5 Depth=1
	ldrb	w8, [sp, #35]
	ldr	x9, [sp, #40]
	add	x9, x9, #40
	ldrsw	x10, [sp, #36]
	add	x9, x9, x10
	strb	w8, [x9]
	b	LBB1_21
LBB1_12:                                ;   in Loop: Header=BB1_5 Depth=1
	ldr	x8, [sp, #40]
	add	x8, x8, #40
	ldrsw	x9, [sp, #36]
	ldrsb	w8, [x8, x9]
	adrp	x9, _solidRock@GOTPAGE
	ldr	x9, [x9, _solidRock@GOTPAGEOFF]
	ldrsb	w9, [x9]
	subs	w8, w8, w9
	cset	w8, eq
	tbnz	w8, #0, LBB1_18
	b	LBB1_13
LBB1_13:                                ;   in Loop: Header=BB1_5 Depth=1
	ldr	x8, [sp, #40]
	add	x8, x8, #40
	ldrsw	x9, [sp, #36]
	ldrsb	w8, [x8, x9]
	adrp	x9, _horizontalBoundary@GOTPAGE
	ldr	x9, [x9, _horizontalBoundary@GOTPAGEOFF]
	ldrsb	w9, [x9]
	subs	w8, w8, w9
	cset	w8, eq
	tbnz	w8, #0, LBB1_18
	b	LBB1_14
LBB1_14:                                ;   in Loop: Header=BB1_5 Depth=1
	ldr	x8, [sp, #40]
	add	x8, x8, #40
	ldrsw	x9, [sp, #36]
	ldrsb	w8, [x8, x9]
	adrp	x9, _verticalBoundary@GOTPAGE
	ldr	x9, [x9, _verticalBoundary@GOTPAGEOFF]
	ldrsb	w9, [x9]
	subs	w8, w8, w9
	cset	w8, eq
	tbnz	w8, #0, LBB1_18
	b	LBB1_15
LBB1_15:                                ;   in Loop: Header=BB1_5 Depth=1
	ldr	x8, [sp, #40]
	add	x8, x8, #40
	ldrsw	x9, [sp, #36]
	ldrsb	w8, [x8, x9]
	adrp	x9, _cornerBoundary@GOTPAGE
	ldr	x9, [x9, _cornerBoundary@GOTPAGEOFF]
	ldrsb	w9, [x9]
	subs	w8, w8, w9
	cset	w8, eq
	tbnz	w8, #0, LBB1_18
	b	LBB1_16
LBB1_16:                                ;   in Loop: Header=BB1_5 Depth=1
	ldr	x8, [sp, #40]
	add	x8, x8, #40
	ldrsw	x9, [sp, #36]
	ldrsb	w8, [x8, x9]
	adrp	x9, _roomSpot@GOTPAGE
	ldr	x9, [x9, _roomSpot@GOTPAGEOFF]
	ldrsb	w9, [x9]
	subs	w8, w8, w9
	cset	w8, eq
	tbnz	w8, #0, LBB1_18
	b	LBB1_17
LBB1_17:                                ;   in Loop: Header=BB1_5 Depth=1
	ldr	x8, [sp, #40]
	add	x8, x8, #40
	ldrsw	x9, [sp, #36]
	ldrsb	w8, [x8, x9]
	adrp	x9, _passageSpot@GOTPAGE
	ldr	x9, [x9, _passageSpot@GOTPAGEOFF]
	ldrsb	w9, [x9]
	subs	w8, w8, w9
	cset	w8, ne
	tbnz	w8, #0, LBB1_19
	b	LBB1_18
LBB1_18:                                ;   in Loop: Header=BB1_5 Depth=1
	b	LBB1_20
LBB1_19:                                ;   in Loop: Header=BB1_5 Depth=1
	ldrb	w8, [sp, #34]
	ldr	x9, [sp, #40]
	add	x9, x9, #40
	ldrsw	x10, [sp, #36]
	add	x9, x9, x10
	strb	w8, [x9]
	b	LBB1_20
LBB1_20:                                ;   in Loop: Header=BB1_5 Depth=1
	b	LBB1_21
LBB1_21:                                ;   in Loop: Header=BB1_5 Depth=1
	b	LBB1_22
LBB1_22:                                ;   in Loop: Header=BB1_5 Depth=1
	b	LBB1_23
LBB1_23:                                ;   in Loop: Header=BB1_5 Depth=1
	b	LBB1_24
LBB1_24:                                ;   in Loop: Header=BB1_5 Depth=1
	ldr	w8, [sp, #36]
	add	w8, w8, #1
	str	w8, [sp, #36]
	b	LBB1_5
LBB1_25:
	ldp	x29, x30, [sp, #80]             ; 16-byte Folded Reload
	add	sp, sp, #96
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_player_print                   ; -- Begin function player_print
	.p2align	2
_player_print:                          ; @player_print
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #224
	.cfi_def_cfa_offset 224
	stp	x29, x30, [sp, #208]            ; 16-byte Folded Spill
	add	x29, sp, #208
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	adrp	x8, ___stack_chk_guard@GOTPAGE
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
	ldr	x8, [x8]
	stur	x8, [x29, #-8]
	str	x0, [sp, #88]
	str	x1, [sp, #80]
	str	x2, [sp, #72]
	ldr	x8, [sp, #72]
	str	x8, [sp, #64]
	ldr	x8, [sp, #64]
	subs	x8, x8, #0
	cset	w8, ne
	tbnz	w8, #0, LBB2_2
	b	LBB2_1
LBB2_1:
	b	LBB2_3
LBB2_2:
	ldr	x11, [sp, #80]
	ldr	x8, [sp, #64]
	ldr	w8, [x8, #24]
                                        ; implicit-def: $x10
	mov	x10, x8
	ldr	x8, [sp, #64]
	ldr	x8, [x8, #8]
	mov	x9, sp
	str	x11, [x9]
	str	x10, [x9, #8]
	str	x8, [x9, #16]
	add	x0, sp, #100
	str	x0, [sp, #24]                   ; 8-byte Folded Spill
	mov	x3, #100
	str	x3, [sp, #32]                   ; 8-byte Folded Spill
	mov	x1, x3
	mov	w2, #0
	adrp	x4, l_.str@PAGE
	add	x4, x4, l_.str@PAGEOFF
	bl	___snprintf_chk
	ldr	x0, [sp, #88]
	bl	_strlen
	add	x8, x0, #1
                                        ; kill: def $w8 killed $w8 killed $x8
	str	w8, [sp, #60]
	ldr	w8, [sp, #60]
	add	w9, w8, #100
                                        ; implicit-def: $x8
	mov	x8, x9
	sxtw	x0, w8
	bl	_malloc
	str	x0, [sp, #48]
	ldr	x0, [sp, #48]
	ldr	x1, [sp, #88]
	ldrsw	x2, [sp, #60]
	mov	x3, #-1
	str	x3, [sp, #40]                   ; 8-byte Folded Spill
	bl	___strncpy_chk
	ldr	x1, [sp, #24]                   ; 8-byte Folded Reload
	ldr	x2, [sp, #32]                   ; 8-byte Folded Reload
	ldr	x3, [sp, #40]                   ; 8-byte Folded Reload
	ldr	x0, [sp, #48]
	bl	___strncat_chk
	ldr	x0, [sp, #48]
	bl	_puts
	ldr	x8, [sp, #64]
	add	x0, x8, #40
	bl	_puts
	ldr	x0, [sp, #48]
	bl	_free
	b	LBB2_3
LBB2_3:
	ldur	x9, [x29, #-8]
	adrp	x8, ___stack_chk_guard@GOTPAGE
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
	ldr	x8, [x8]
	subs	x8, x8, x9
	cset	w8, eq
	tbnz	w8, #0, LBB2_5
	b	LBB2_4
LBB2_4:
	bl	___stack_chk_fail
LBB2_5:
	ldp	x29, x30, [sp, #208]            ; 16-byte Folded Reload
	add	sp, sp, #224
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_player_delete                  ; -- Begin function player_delete
	.p2align	2
_player_delete:                         ; @player_delete
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
	str	x8, [sp]
	ldr	x8, [sp]
	subs	x8, x8, #0
	cset	w8, eq
	tbnz	w8, #0, LBB3_2
	b	LBB3_1
LBB3_1:
	ldr	x8, [sp]
	ldr	x0, [x8, #8]
	bl	_free
	ldr	x0, [sp]
	bl	_free
	b	LBB3_2
LBB3_2:
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #32
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_player_deactivate              ; -- Begin function player_deactivate
	.p2align	2
_player_deactivate:                     ; @player_deactivate
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #16
	.cfi_def_cfa_offset 16
	str	x0, [sp, #8]
	ldr	x8, [sp, #8]
	subs	x8, x8, #0
	cset	w8, ne
	tbnz	w8, #0, LBB4_2
	b	LBB4_1
LBB4_1:
	b	LBB4_3
LBB4_2:
	ldr	x8, [sp, #8]
	strb	wzr, [x8]
	b	LBB4_3
LBB4_3:
	add	sp, sp, #16
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_player_getPos                  ; -- Begin function player_getPos
	.p2align	2
_player_getPos:                         ; @player_getPos
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #16
	.cfi_def_cfa_offset 16
	str	x0, [sp]
	ldr	x8, [sp]
	subs	x8, x8, #0
	cset	w8, ne
	tbnz	w8, #0, LBB5_2
	b	LBB5_1
LBB5_1:
	mov	w8, #-1
	str	w8, [sp, #12]
	b	LBB5_3
LBB5_2:
	ldr	x8, [sp]
	ldr	w8, [x8, #20]
	str	w8, [sp, #12]
	b	LBB5_3
LBB5_3:
	ldr	w0, [sp, #12]
	add	sp, sp, #16
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_player_setPos                  ; -- Begin function player_setPos
	.p2align	2
_player_setPos:                         ; @player_setPos
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #48
	.cfi_def_cfa_offset 48
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	str	x0, [sp, #16]
	str	w1, [sp, #12]
	ldr	x8, [sp, #16]
	subs	x8, x8, #0
	cset	w8, eq
	tbnz	w8, #0, LBB6_3
	b	LBB6_1
LBB6_1:
	ldr	x8, [sp, #16]
	ldr	x0, [x8, #32]
	bl	_get_TC
	ldr	w8, [sp, #12]
	add	w8, w8, #1
	subs	w8, w0, w8
	cset	w8, lt
	tbnz	w8, #0, LBB6_3
	b	LBB6_2
LBB6_2:
	ldr	w8, [sp, #12]
	subs	w8, w8, #0
	cset	w8, ge
	tbnz	w8, #0, LBB6_4
	b	LBB6_3
LBB6_3:
	mov	w8, #0
	and	w8, w8, #0x1
	and	w8, w8, #0x1
	sturb	w8, [x29, #-1]
	b	LBB6_5
LBB6_4:
	ldr	w8, [sp, #12]
	ldr	x9, [sp, #16]
	str	w8, [x9, #20]
	mov	w8, #1
	and	w8, w8, #0x1
	and	w8, w8, #0x1
	sturb	w8, [x29, #-1]
	b	LBB6_5
LBB6_5:
	ldurb	w8, [x29, #-1]
	and	w0, w8, #0x1
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_player_isActive                ; -- Begin function player_isActive
	.p2align	2
_player_isActive:                       ; @player_isActive
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #16
	.cfi_def_cfa_offset 16
	str	x0, [sp]
	ldr	x8, [sp]
	subs	x8, x8, #0
	cset	w8, ne
	tbnz	w8, #0, LBB7_2
	b	LBB7_1
LBB7_1:
	mov	w8, #0
	and	w8, w8, #0x1
	and	w8, w8, #0x1
	strb	w8, [sp, #15]
	b	LBB7_3
LBB7_2:
	ldr	x8, [sp]
	ldrb	w8, [x8]
	and	w8, w8, #0x1
	and	w8, w8, #0x1
	strb	w8, [sp, #15]
	b	LBB7_3
LBB7_3:
	ldrb	w8, [sp, #15]
	and	w0, w8, #0x1
	add	sp, sp, #16
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_player_addNuggets              ; -- Begin function player_addNuggets
	.p2align	2
_player_addNuggets:                     ; @player_addNuggets
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #16
	.cfi_def_cfa_offset 16
	str	x0, [sp, #8]
	str	w1, [sp, #4]
	ldr	x8, [sp, #8]
	subs	x8, x8, #0
	cset	w8, ne
	tbnz	w8, #0, LBB8_2
	b	LBB8_1
LBB8_1:
	b	LBB8_3
LBB8_2:
	ldr	w10, [sp, #4]
	ldr	x9, [sp, #8]
	ldr	w8, [x9, #24]
	add	w8, w8, w10
	str	w8, [x9, #24]
	b	LBB8_3
LBB8_3:
	add	sp, sp, #16
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_player_getGrid                 ; -- Begin function player_getGrid
	.p2align	2
_player_getGrid:                        ; @player_getGrid
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #16
	.cfi_def_cfa_offset 16
	str	x0, [sp]
	ldr	x8, [sp]
	subs	x8, x8, #0
	cset	w8, ne
	tbnz	w8, #0, LBB9_2
	b	LBB9_1
LBB9_1:
                                        ; kill: def $x8 killed $xzr
	str	xzr, [sp, #8]
	b	LBB9_3
LBB9_2:
	ldr	x8, [sp]
	add	x8, x8, #40
	str	x8, [sp, #8]
	b	LBB9_3
LBB9_3:
	ldr	x0, [sp, #8]
	add	sp, sp, #16
	ret
	.cfi_endproc
                                        ; -- End function
	.section	__TEXT,__const
	.globl	_playerChar                     ; @playerChar
_playerChar:
	.byte	64                              ; 0x40

	.section	__TEXT,__cstring,cstring_literals
l_.str:                                 ; @.str
	.asciz	"%s %6d %s\n"

.subsections_via_symbols
