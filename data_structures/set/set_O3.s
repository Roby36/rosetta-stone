	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 13, 0	sdk_version 13, 3
	.globl	_set_new                        ; -- Begin function set_new
	.p2align	2
_set_new:                               ; @set_new
	.cfi_startproc
; %bb.0:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	mov	w0, #8
	bl	_malloc
	cbz	x0, LBB0_2
; %bb.1:
	str	xzr, [x0]
LBB0_2:
	ldp	x29, x30, [sp], #16             ; 16-byte Folded Reload
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_set_insert                     ; -- Begin function set_insert
	.p2align	2
_set_insert:                            ; @set_insert
	.cfi_startproc
; %bb.0:
	stp	x24, x23, [sp, #-64]!           ; 16-byte Folded Spill
	.cfi_def_cfa_offset 64
	stp	x22, x21, [sp, #16]             ; 16-byte Folded Spill
	stp	x20, x19, [sp, #32]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #48]             ; 16-byte Folded Spill
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	mov	x19, x0
	mov	w0, #0
	cbz	x19, LBB1_5
; %bb.1:
	mov	x21, x1
	cbz	x1, LBB1_5
; %bb.2:
	mov	x20, x2
	cbz	x2, LBB1_5
; %bb.3:
	mov	x0, x19
	mov	x1, x21
	bl	_key_find
	cbz	x0, LBB1_6
; %bb.4:
	mov	w0, #0
LBB1_5:
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #32]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #16]             ; 16-byte Folded Reload
	ldp	x24, x23, [sp], #64             ; 16-byte Folded Reload
	ret
LBB1_6:
	mov	x0, x21
	bl	_strlen
	add	w8, w0, #1
	sxtw	x23, w8
	mov	x0, x23
	bl	_malloc
	cbz	x0, LBB1_5
; %bb.7:
	mov	x22, x0
	mov	x1, x21
	mov	x2, x23
	bl	_strncpy
	mov	w0, #24
	bl	_malloc
	cbz	x0, LBB1_9
; %bb.8:
	stp	x22, x20, [x0]
	ldr	x8, [x19]
	str	x8, [x0, #16]
	str	x0, [x19]
LBB1_9:
	cmp	x0, #0
	cset	w0, ne
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #32]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #16]             ; 16-byte Folded Reload
	ldp	x24, x23, [sp], #64             ; 16-byte Folded Reload
	ret
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function key_find
_key_find:                              ; @key_find
	.cfi_startproc
; %bb.0:
	stp	x22, x21, [sp, #-48]!           ; 16-byte Folded Spill
	.cfi_def_cfa_offset 48
	stp	x20, x19, [sp, #16]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	mov	x19, #0
	cbz	x0, LBB2_5
; %bb.1:
	mov	x20, x1
	cbz	x1, LBB2_5
; %bb.2:
	ldr	x19, [x0]
	cbz	x19, LBB2_5
LBB2_3:                                 ; =>This Inner Loop Header: Depth=1
	ldr	x21, [x19]
	mov	x0, x21
	bl	_strlen
	add	x2, x0, #1
	mov	x0, x21
	mov	x1, x20
	bl	_strncmp
	cbz	w0, LBB2_5
; %bb.4:                                ;   in Loop: Header=BB2_3 Depth=1
	ldr	x19, [x19, #16]
	cbnz	x19, LBB2_3
LBB2_5:
	mov	x0, x19
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp], #48             ; 16-byte Folded Reload
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_set_find                       ; -- Begin function set_find
	.p2align	2
_set_find:                              ; @set_find
	.cfi_startproc
; %bb.0:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	bl	_key_find
	cbz	x0, LBB3_2
; %bb.1:
	ldr	x0, [x0, #8]
LBB3_2:
	ldp	x29, x30, [sp], #16             ; 16-byte Folded Reload
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_set_iterate                    ; -- Begin function set_iterate
	.p2align	2
_set_iterate:                           ; @set_iterate
	.cfi_startproc
; %bb.0:
	stp	x22, x21, [sp, #-48]!           ; 16-byte Folded Spill
	.cfi_def_cfa_offset 48
	stp	x20, x19, [sp, #16]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	cbz	x0, LBB4_5
; %bb.1:
	mov	x19, x2
	cbz	x2, LBB4_5
; %bb.2:
	ldr	x21, [x0]
	cbz	x21, LBB4_5
; %bb.3:
	mov	x20, x1
LBB4_4:                                 ; =>This Inner Loop Header: Depth=1
	ldp	x1, x2, [x21]
	mov	x0, x20
	blr	x19
	ldr	x21, [x21, #16]
	cbnz	x21, LBB4_4
LBB4_5:
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp], #48             ; 16-byte Folded Reload
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_set_print                      ; -- Begin function set_print
	.p2align	2
_set_print:                             ; @set_print
	.cfi_startproc
; %bb.0:
	stp	x22, x21, [sp, #-48]!           ; 16-byte Folded Spill
	.cfi_def_cfa_offset 48
	stp	x20, x19, [sp, #16]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	cbz	x1, LBB5_3
; %bb.1:
	mov	x19, x1
	mov	x21, x0
	cbz	x0, LBB5_4
; %bb.2:
	mov	x20, x2
	mov	w0, #123
	mov	x1, x19
	bl	_fputc
	mov	x0, x21
	mov	x1, x19
	mov	x2, x20
	bl	_set_iterate
	mov	w0, #125
	mov	x1, x19
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp], #48             ; 16-byte Folded Reload
	b	_fputc
LBB5_3:
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp], #48             ; 16-byte Folded Reload
	ret
LBB5_4:
Lloh0:
	adrp	x0, l_.str@PAGE
Lloh1:
	add	x0, x0, l_.str@PAGEOFF
	mov	w1, #6
	mov	w2, #1
	mov	x3, x19
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp], #48             ; 16-byte Folded Reload
	b	_fwrite
	.loh AdrpAdd	Lloh0, Lloh1
	.cfi_endproc
                                        ; -- End function
	.globl	_set_delete                     ; -- Begin function set_delete
	.p2align	2
_set_delete:                            ; @set_delete
	.cfi_startproc
; %bb.0:
	cbz	x0, LBB6_6
; %bb.1:
	stp	x22, x21, [sp, #-48]!           ; 16-byte Folded Spill
	.cfi_def_cfa_offset 48
	stp	x20, x19, [sp, #16]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	mov	x19, x0
	ldr	x20, [x0]
	cbz	x20, LBB6_5
; %bb.2:
	mov	x21, x1
	cbz	x1, LBB6_4
LBB6_3:                                 ; =>This Inner Loop Header: Depth=1
	ldr	x0, [x20, #8]
	blr	x21
	ldr	x0, [x20]
	bl	_free
	ldr	x22, [x20, #16]
	mov	x0, x20
	bl	_free
	mov	x20, x22
	cbnz	x22, LBB6_3
	b	LBB6_5
LBB6_4:                                 ; =>This Inner Loop Header: Depth=1
	ldr	x0, [x20]
	bl	_free
	ldr	x21, [x20, #16]
	mov	x0, x20
	bl	_free
	mov	x20, x21
	cbnz	x21, LBB6_4
LBB6_5:
	mov	x0, x19
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp], #48             ; 16-byte Folded Reload
	b	_free
LBB6_6:
	.cfi_def_cfa wsp, 0
	.cfi_same_value w30
	.cfi_same_value w29
	.cfi_same_value w19
	.cfi_same_value w20
	.cfi_same_value w21
	.cfi_same_value w22
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_set_merge                      ; -- Begin function set_merge
	.p2align	2
_set_merge:                             ; @set_merge
	.cfi_startproc
; %bb.0:
	mov	x8, x0
Lloh2:
	adrp	x2, _set_merge_helper@PAGE
Lloh3:
	add	x2, x2, _set_merge_helper@PAGEOFF
	mov	x0, x1
	mov	x1, x8
	b	_set_iterate
	.loh AdrpAdd	Lloh2, Lloh3
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function set_merge_helper
_set_merge_helper:                      ; @set_merge_helper
	.cfi_startproc
; %bb.0:
	stp	x22, x21, [sp, #-48]!           ; 16-byte Folded Spill
	.cfi_def_cfa_offset 48
	stp	x20, x19, [sp, #16]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	mov	x19, x2
	mov	x20, x1
	mov	x21, x0
	bl	_key_find
	cbz	x0, LBB8_3
; %bb.1:
	ldr	x8, [x0, #8]
	cbz	x8, LBB8_3
; %bb.2:
	ldr	w9, [x19]
	ldr	w10, [x8]
	add	w9, w10, w9
	str	w9, [x8]
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp], #48             ; 16-byte Folded Reload
	ret
LBB8_3:
	mov	w0, #4
	bl	_malloc
	mov	x2, x0
	ldr	w8, [x19]
	str	w8, [x0]
	mov	x0, x21
	mov	x1, x20
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp], #48             ; 16-byte Folded Reload
	b	_set_insert
	.cfi_endproc
                                        ; -- End function
	.globl	_set_intersect                  ; -- Begin function set_intersect
	.p2align	2
_set_intersect:                         ; @set_intersect
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #48
	.cfi_def_cfa_offset 48
	stp	x20, x19, [sp, #16]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	mov	x19, x1
	mov	x20, x0
	mov	w0, #8
	bl	_malloc
	cbz	x0, LBB9_2
; %bb.1:
	str	xzr, [x0]
LBB9_2:
	stp	x20, x0, [sp]
Lloh4:
	adrp	x2, _set_intersect_helper@PAGE
Lloh5:
	add	x2, x2, _set_intersect_helper@PAGEOFF
	mov	x1, sp
	mov	x0, x19
	bl	_set_iterate
	ldr	x0, [sp, #8]
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
	.loh AdrpAdd	Lloh4, Lloh5
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function set_intersect_helper
_set_intersect_helper:                  ; @set_intersect_helper
	.cfi_startproc
; %bb.0:
	stp	x22, x21, [sp, #-48]!           ; 16-byte Folded Spill
	.cfi_def_cfa_offset 48
	stp	x20, x19, [sp, #16]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	mov	x21, x2
	mov	x19, x1
	ldp	x8, x20, [x0]
	mov	x0, x8
	bl	_key_find
	cbz	x0, LBB10_3
; %bb.1:
	ldr	x22, [x0, #8]
	cbz	x22, LBB10_3
; %bb.2:
	mov	w0, #4
	bl	_malloc
	mov	x2, x0
	ldr	w8, [x22]
	ldr	w9, [x21]
	cmp	w8, w9
	csel	w8, w8, w9, lt
	str	w8, [x0]
	mov	x0, x20
	mov	x1, x19
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp], #48             ; 16-byte Folded Reload
	b	_set_insert
LBB10_3:
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp], #48             ; 16-byte Folded Reload
	ret
	.cfi_endproc
                                        ; -- End function
	.section	__TEXT,__cstring,cstring_literals
l_.str:                                 ; @.str
	.asciz	"(null)"

.subsections_via_symbols
