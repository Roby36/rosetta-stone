	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 13, 0	sdk_version 13, 3
	.globl	_hashtable_new                  ; -- Begin function hashtable_new
	.p2align	2
_hashtable_new:                         ; @hashtable_new
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
	cmp	w0, #1
	b.lt	LBB0_4
; %bb.1:
	mov	x20, x0
	mov	w0, #16
	bl	_malloc
	cbz	x0, LBB0_3
; %bb.2:
	mov	x19, x0
	str	w20, [x0]
	mov	w0, w20
	mov	w1, #8
	bl	_calloc
	str	x0, [x19, #8]
	cmp	x0, #0
	csel	x0, xzr, x19, eq
LBB0_3:
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp], #32             ; 16-byte Folded Reload
	ret
LBB0_4:
	mov	x0, #0
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp], #32             ; 16-byte Folded Reload
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_hashtable_find                 ; -- Begin function hashtable_find
	.p2align	2
_hashtable_find:                        ; @hashtable_find
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
	mov	x20, x0
	mov	x0, #0
	cbz	x20, LBB1_7
; %bb.1:
	mov	x19, x1
	cbz	x1, LBB1_7
; %bb.2:
	ldr	w8, [x20]
	cmp	w8, #1
	b.lt	LBB1_8
; %bb.3:
	mov	x21, #0
LBB1_4:                                 ; =>This Inner Loop Header: Depth=1
	ldr	x8, [x20, #8]
	ldr	x0, [x8, x21, lsl #3]
	mov	x1, x19
	bl	_set_find
	cbnz	x0, LBB1_7
; %bb.5:                                ;   in Loop: Header=BB1_4 Depth=1
	add	x21, x21, #1
	ldrsw	x8, [x20]
	cmp	x21, x8
	b.lt	LBB1_4
; %bb.6:
	mov	x0, #0
LBB1_7:
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp], #48             ; 16-byte Folded Reload
	ret
LBB1_8:
	mov	x0, #0
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp], #48             ; 16-byte Folded Reload
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_hashtable_insert               ; -- Begin function hashtable_insert
	.p2align	2
_hashtable_insert:                      ; @hashtable_insert
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
	cbz	x0, LBB2_10
; %bb.1:
	mov	x20, x1
	cbz	x1, LBB2_10
; %bb.2:
	mov	x19, x2
	cbz	x2, LBB2_10
; %bb.3:
	mov	x21, x0
	ldr	w8, [x0]
	cmp	w8, #1
	b.lt	LBB2_8
; %bb.4:
	mov	x22, #0
LBB2_5:                                 ; =>This Inner Loop Header: Depth=1
	ldr	x8, [x21, #8]
	ldr	x0, [x8, x22, lsl #3]
	mov	x1, x20
	bl	_set_find
	cbnz	x0, LBB2_10
; %bb.6:                                ;   in Loop: Header=BB2_5 Depth=1
	add	x22, x22, #1
	ldrsw	x8, [x21]
	cmp	x22, x8
	b.lt	LBB2_5
; %bb.7:
                                        ; kill: def $w8 killed $w8 killed $x8 def $x8
LBB2_8:
	sxtw	x1, w8
	mov	x0, x20
	bl	_hash_jenkins
	mov	x8, x0
	ldr	x9, [x21, #8]
	sbfiz	x10, x0, #3, #32
	ldr	x0, [x9, x10]
	cbz	x0, LBB2_11
; %bb.9:
	mov	x1, x20
	mov	x2, x19
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp], #48             ; 16-byte Folded Reload
	b	_set_insert
LBB2_10:
	mov	w0, #0
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp], #48             ; 16-byte Folded Reload
	ret
LBB2_11:
	sxtw	x22, w8
	bl	_set_new
	ldr	x8, [x21, #8]
	lsl	x9, x22, #3
	str	x0, [x8, x9]
	ldr	x8, [x21, #8]
	ldr	x0, [x8, x9]
	mov	x1, x20
	mov	x2, x19
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp], #48             ; 16-byte Folded Reload
	b	_set_insert
	.cfi_endproc
                                        ; -- End function
	.globl	_hashtable_iterate              ; -- Begin function hashtable_iterate
	.p2align	2
_hashtable_iterate:                     ; @hashtable_iterate
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
	cbz	x0, LBB3_5
; %bb.1:
	mov	x19, x2
	cbz	x2, LBB3_5
; %bb.2:
	mov	x21, x0
	ldr	w8, [x0]
	cmp	w8, #1
	b.lt	LBB3_5
; %bb.3:
	mov	x20, x1
	mov	x22, #0
LBB3_4:                                 ; =>This Inner Loop Header: Depth=1
	ldr	x8, [x21, #8]
	ldr	x0, [x8, x22, lsl #3]
	mov	x1, x20
	mov	x2, x19
	bl	_set_iterate
	add	x22, x22, #1
	ldrsw	x8, [x21]
	cmp	x22, x8
	b.lt	LBB3_4
LBB3_5:
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp], #48             ; 16-byte Folded Reload
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_hashtable_print                ; -- Begin function hashtable_print
	.p2align	2
_hashtable_print:                       ; @hashtable_print
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
	cbz	x1, LBB4_7
; %bb.1:
	mov	x19, x1
	mov	x21, x0
	cbz	x0, LBB4_8
; %bb.2:
	mov	x20, x2
	mov	w0, #123
	mov	x1, x19
	bl	_fputc
	cbz	x20, LBB4_6
; %bb.3:
	ldr	w8, [x21]
	cmp	w8, #1
	b.lt	LBB4_6
; %bb.4:
	mov	x22, #0
LBB4_5:                                 ; =>This Inner Loop Header: Depth=1
	ldr	x8, [x21, #8]
	ldr	x0, [x8, x22, lsl #3]
	mov	x1, x19
	mov	x2, x20
	bl	_set_iterate
	add	x22, x22, #1
	ldrsw	x8, [x21]
	cmp	x22, x8
	b.lt	LBB4_5
LBB4_6:
	mov	w0, #125
	mov	x1, x19
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp], #48             ; 16-byte Folded Reload
	b	_fputc
LBB4_7:
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp], #48             ; 16-byte Folded Reload
	ret
LBB4_8:
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
	.globl	_hashtable_delete               ; -- Begin function hashtable_delete
	.p2align	2
_hashtable_delete:                      ; @hashtable_delete
	.cfi_startproc
; %bb.0:
	cbz	x0, LBB5_5
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
	ldr	w8, [x0]
	cmp	w8, #1
	b.lt	LBB5_4
; %bb.2:
	mov	x20, x1
	mov	x21, #0
LBB5_3:                                 ; =>This Inner Loop Header: Depth=1
	ldr	x8, [x19, #8]
	ldr	x0, [x8, x21, lsl #3]
	mov	x1, x20
	bl	_set_delete
	add	x21, x21, #1
	ldrsw	x8, [x19]
	cmp	x21, x8
	b.lt	LBB5_3
LBB5_4:
	ldr	x0, [x19, #8]
	bl	_free
	mov	x0, x19
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp], #48             ; 16-byte Folded Reload
	b	_free
LBB5_5:
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
	.section	__TEXT,__cstring,cstring_literals
l_.str:                                 ; @.str
	.asciz	"(null)"

.subsections_via_symbols
