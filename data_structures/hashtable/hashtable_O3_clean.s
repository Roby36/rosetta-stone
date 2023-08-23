
.text
	.globl	_hashtable_new                  ; -- Begin function hashtable_new
	.p2align	2
_hashtable_new:                         ; @hashtable_new
	stp	x20, x19, [sp, #-32]!           ; 16-byte Folded Spill
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16

	cmp	w0, #1
	b.lt	LBB0_4
	mov	x20, x0		// x20 = num_slots
	mov	w0, #16
	bl	_malloc
	cbz	x0, LBB0_3
	mov	x19, x0		// x19 = ht
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

                                        ; -- End function
	.globl	_hashtable_find                 ; -- Begin function hashtable_find
	.p2align	2
_hashtable_find:                        ; @hashtable_find
	stp	x22, x21, [sp, #-48]!           ; 16-byte Folded Spill
	stp	x20, x19, [sp, #16]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32

	mov	x20, x0
	mov	x0, #0
	cbz	x20, LBB1_7
	mov	x19, x1
	cbz	x1, LBB1_7
	ldr	w8, [x20]
	cmp	w8, #1
	b.lt	LBB1_8
	mov	x21, #0
LBB1_4:                                 ; =>This Inner Loop Header: Depth=1
	ldr	x8, [x20, #8]
	ldr	x0, [x8, x21, lsl #3]
	mov	x1, x19
	bl	_set_find
	cbnz	x0, LBB1_7
	add	x21, x21, #1
	ldrsw	x8, [x20]
	cmp	x21, x8
	b.lt	LBB1_4
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
                                        ; -- End function
	.globl	_hashtable_insert               ; -- Begin function hashtable_insert
	.p2align	2
_hashtable_insert:                      ; @hashtable_insert
	stp	x22, x21, [sp, #-48]!           ; 16-byte Folded Spill
	stp	x20, x19, [sp, #16]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32

	cbz	x0, LBB2_10
	mov	x20, x1
	cbz	x1, LBB2_10
	mov	x19, x2
	cbz	x2, LBB2_10
	mov	x21, x0
	ldr	w8, [x0]
	cmp	w8, #1
	b.lt	LBB2_8
	mov	x22, #0
LBB2_5:                                 ; =>This Inner Loop Header: Depth=1
	ldr	x8, [x21, #8]
	ldr	x0, [x8, x22, lsl #3]
	mov	x1, x20
	bl	_set_find
	cbnz	x0, LBB2_10
	add	x22, x22, #1
	ldrsw	x8, [x21]
	cmp	x22, x8
	b.lt	LBB2_5
                                        
LBB2_8:
	sxtw	x1, w8
	mov	x0, x20
	bl	_hash_jenkins
	mov	x8, x0
	ldr	x9, [x21, #8]
	sbfiz	x10, x0, #3, #32
	ldr	x0, [x9, x10]
	cbz	x0, LBB2_11
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
                                        ; -- End function
	.globl	_hashtable_iterate              ; -- Begin function hashtable_iterate
	.p2align	2
_hashtable_iterate:                     ; @hashtable_iterate
; %bb.0:
	stp	x22, x21, [sp, #-48]!           ; 16-byte Folded Spill
	stp	x20, x19, [sp, #16]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32

	cbz	x0, LBB3_5
	mov	x19, x2
	cbz	x2, LBB3_5
	mov	x21, x0
	ldr	w8, [x0]
	cmp	w8, #1
	b.lt	LBB3_5
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
                                        ; -- End function
	.globl	_hashtable_print                ; -- Begin function hashtable_print
	.p2align	2
_hashtable_print:                       ; @hashtable_print
	stp	x22, x21, [sp, #-48]!           ; 16-byte Folded Spill
	stp	x20, x19, [sp, #16]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32

	cbz	x1, LBB4_7
	mov	x19, x1
	mov	x21, x0
	cbz	x0, LBB4_8
	mov	x20, x2
	mov	w0, #123
	mov	x1, x19
	bl	_fputc
	cbz	x20, LBB4_6
	ldr	w8, [x21]
	cmp	w8, #1
	b.lt	LBB4_6
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

	.globl	_hashtable_delete               ; -- Begin function hashtable_delete
	.p2align	2
_hashtable_delete:                      ; @hashtable_delete
	cbz	x0, LBB5_5
	stp	x22, x21, [sp, #-48]!           ; 16-byte Folded Spill
	stp	x20, x19, [sp, #16]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32

	mov	x19, x0
	ldr	w8, [x0]
	cmp	w8, #1
	b.lt	LBB5_4
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
	ret
                                        ; -- End function
	.data
l_.str:                                 
	.asciz	"(null)"

