	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 13, 0	sdk_version 13, 3



	.globl	_linked_list_new                ; -- Begin function linked_list_new
	.p2align	2
_linked_list_new:                       ; @linked_list_new
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	mov	x29, sp
	mov	w0, #8
	bl	_malloc
	cbz	x0, LBB0_2
	str	xzr, [x0]
LBB0_2:
	ldp	x29, x30, [sp], #16             ; 16-byte Folded Reload
	ret


                                        ; -- End function
	.globl	_linked_list_insert             ; -- Begin function linked_list_insert
	.p2align	2
_linked_list_insert:                    ; @linked_list_insert
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
	mov	x21, x2
	mov	x20, x1
	mov	x19, x0
	mov	x22, #0
	cbz	x0, LBB1_6
; %bb.1:
	cmp	w21, #1
	b.lt	LBB1_6
; %bb.2:
	ldr	x22, [x19]
	sub	w8, w21, #1
	cbz	w8, LBB1_6
; %bb.3:
	cbz	x22, LBB1_6
; %bb.4:
	mov	w9, #1
LBB1_5:                                 ; =>This Inner Loop Header: Depth=1
	ldr	x22, [x22, #8]
	cmp	x22, #0
	ccmp	w9, w8, #0, ne
	add	w9, w9, #1
	b.lt	LBB1_5
LBB1_6:
	mov	x23, #0
	cbz	x19, LBB1_12
; %bb.7:
	tbnz	w21, #31, LBB1_12
; %bb.8:
	ldr	x23, [x19]
	cbz	w21, LBB1_12
; %bb.9:
	cbz	x23, LBB1_12
; %bb.10:
	mov	w8, #1
LBB1_11:                                ; =>This Inner Loop Header: Depth=1
	ldr	x23, [x23, #8]
	cmp	x23, #0
	ccmp	w8, w21, #0, ne
	add	w8, w8, #1
	b.lt	LBB1_11
LBB1_12:
	mov	w0, #16
	bl	_malloc
	cbz	x0, LBB1_16
; %bb.13:
	stp	x20, xzr, [x0]
	cmp	w21, #0
	ccmp	x22, #0, #0, ne
	cset	w8, eq
	cbz	x20, LBB1_16
; %bb.14:
	tbnz	w8, #0, LBB1_16
; %bb.15:
	str	x23, [x0, #8]
	add	x8, x22, #8
	cmp	x22, #0
	csel	x8, x19, x8, eq
	str	x0, [x8]
LBB1_16:
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #32]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #16]             ; 16-byte Folded Reload
	ldp	x24, x23, [sp], #64             ; 16-byte Folded Reload
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_linked_list_extract            ; -- Begin function linked_list_extract
	.p2align	2
_linked_list_extract:                   ; @linked_list_extract
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
	mov	x9, #0
	cbz	x0, LBB2_6
; %bb.1:
	cmp	w1, #1
	b.lt	LBB2_6
; %bb.2:
	ldr	x9, [x0]
	sub	w8, w1, #1
	cbz	w8, LBB2_6
; %bb.3:
	cbz	x9, LBB2_6
; %bb.4:
	mov	w10, #1
LBB2_5:                                 ; =>This Inner Loop Header: Depth=1
	ldr	x9, [x9, #8]
	cmp	x9, #0
	ccmp	w10, w8, #0, ne
	add	w10, w10, #1
	b.lt	LBB2_5
LBB2_6:
	mov	x19, #0
	cbz	x0, LBB2_14
; %bb.7:
	tbnz	w1, #31, LBB2_14
; %bb.8:
	ldr	x8, [x0]
	cbz	w1, LBB2_12
; %bb.9:
	cbz	x8, LBB2_12
; %bb.10:
	mov	w10, #1
LBB2_11:                                ; =>This Inner Loop Header: Depth=1
	ldr	x8, [x8, #8]
	cmp	x8, #0
	ccmp	w10, w1, #0, ne
	add	w10, w10, #1
	b.lt	LBB2_11
LBB2_12:
	cbz	x8, LBB2_15
; %bb.13:
	ldr	x10, [x8, #8]
	add	x11, x9, #8
	cmp	x9, #0
	csel	x9, x0, x11, eq
	str	x10, [x9]
	ldr	x19, [x8]
	mov	x0, x8
	bl	_free
LBB2_14:
	mov	x0, x19
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp], #32             ; 16-byte Folded Reload
	ret
LBB2_15:
	mov	x19, #0
	mov	x0, x19
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp], #32             ; 16-byte Folded Reload
	ret
	.cfi_endproc
                                        ; -- End function
	


	
	.globl	_linked_list_insert2            ; -- Begin function linked_list_insert2
	.p2align	2
_linked_list_insert2: 
    // move stack pointer only once!
	stp	x22, x21, [sp, #-48]!           ; 16-byte Folded Spill
	stp	x20, x19, [sp, #16]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32

	cbz	x0, LBB3_11  // check linked_list
	mov	x21, x1		 // x21 = item
	cbz	x1, LBB3_11  // check item

	mov	x19, x2      // x19 = item_index
	tbnz	w2, #31, LBB3_11 // check sign directly 

	mov	x20, x0		// x20 = linked_list

	// bl _linked_list_node_new (INLINED !!)
	mov	w0, #16
	bl	_malloc
	cbz	x0, LBB3_5

	stp	x21, xzr, [x0]	// faster initialization 
	// return from inlined _linked_list_node_new
LBB3_5: // loop pre-test
	ldr	x8, [x20]	// x8 = *next_it
	cbz	x8, LBB3_10

	cbz	w19, LBB3_10

	mov	w9, #1		// w9 = curr_index
LBB3_8:                                 ; =>This Inner Loop Header: Depth=1
	mov	x10, x8
	ldr	x8, [x8, #8]	// *next_it = (*next_it)->next
	cmp	x8, #0			//  *next_it != NULL
	ccmp	w9, w19, #0, ne	// CONDITIONAL COMPARE FOR SHORT CIRCUITING! 
		// if  *next_it != NULL, then curr_index < item_index
	add	w9, w9, #1		// curr_index++ (NOT setting flags!)
	b.lt	LBB3_8      // repeat loop iff both conditions met

	add	x20, x10, #8    // x20 =  &((*next_it)->next) [final iteration]
LBB3_10:
	str	x8, [x0, #8]	// new_node->next = *next_it
	str	x0, [x20]		// *next_it       = new_node
LBB3_11:
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	// move stack pointer only once!
	ldp	x22, x21, [sp], #48             ; 16-byte Folded Reload
	ret





                                        ; -- End function
	.globl	_linked_list_extract2           ; -- Begin function linked_list_extract2
	.p2align	2
_linked_list_extract2:                  ; @linked_list_extract2
	stp	x20, x19, [sp, #-32]!           ; 16-byte Folded Spill
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16

	mov	x19, #0
	cbz	x0, LBB4_6
	tbnz	w1, #31, LBB4_6
	ldr	x9, [x0]
	cbz	x9, LBB4_7
	mov	w11, #0
LBB4_4:                                 ; =>This Inner Loop Header: Depth=1
	mov	x10, x0
	mov	x8, x9
	mov	x0, x9
	ldr	x9, [x0, #8]!
	cmp	x9, #0
	ccmp	w11, w1, #0, ne
	add	w11, w11, #1
	b.lt	LBB4_4
; %bb.5:
	ldr	x19, [x8]
	str	x9, [x10]
	mov	x0, x8
	bl	_free
LBB4_6:
	mov	x0, x19
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp], #32             ; 16-byte Folded Reload
	ret
LBB4_7:
	mov	x19, #0
	mov	x0, x19
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp], #32             ; 16-byte Folded Reload
	ret
                                        ; -- End function
	.globl	_linked_list_print              ; -- Begin function linked_list_print
	.p2align	2
_linked_list_print:                     ; @linked_list_print
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
	cbz	x1, LBB5_7
; %bb.1:
	mov	x20, x2
	cbz	x2, LBB5_7
; %bb.2:
	mov	x19, x1
	mov	x21, x0
	cbz	x0, LBB5_8
; %bb.3:
	mov	w0, #91
	mov	x1, x19
	bl	_fputc
	ldr	x22, [x21]
	cbz	x22, LBB5_6
; %bb.4:
Lloh0:
	adrp	x21, l_.str.2@PAGE
Lloh1:
	add	x21, x21, l_.str.2@PAGEOFF
LBB5_5:                                 ; =>This Inner Loop Header: Depth=1
	ldr	x1, [x22]
	mov	x0, x19
	blr	x20
	mov	x0, x21
	mov	w1, #4
	mov	w2, #1
	mov	x3, x19
	bl	_fwrite
	ldr	x22, [x22, #8]
	cbnz	x22, LBB5_5
LBB5_6:
	mov	w0, #93
	mov	x1, x19
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp], #48             ; 16-byte Folded Reload
	b	_fputc
LBB5_7:
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp], #48             ; 16-byte Folded Reload
	ret
LBB5_8:
Lloh2:
	adrp	x0, l_.str@PAGE
Lloh3:
	add	x0, x0, l_.str@PAGEOFF
	mov	w1, #6
	mov	w2, #1
	mov	x3, x19
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp], #48             ; 16-byte Folded Reload
	b	_fwrite
	.loh AdrpAdd	Lloh0, Lloh1
	.loh AdrpAdd	Lloh2, Lloh3
	.cfi_endproc
                                        ; -- End function
	.globl	_linked_list_delete             ; -- Begin function linked_list_delete
	.p2align	2
_linked_list_delete:                    ; @linked_list_delete
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
	cbz	x0, LBB6_5
; %bb.1:
	mov	x20, x1
	cbz	x1, LBB6_5
; %bb.2:
	mov	x19, x0
	ldr	x21, [x0]
	cbz	x21, LBB6_4
LBB6_3:                                 ; =>This Inner Loop Header: Depth=1
	ldr	x0, [x21]
	blr	x20
	ldr	x22, [x21, #8]
	mov	x0, x21
	bl	_free
	mov	x21, x22
	cbnz	x22, LBB6_3
LBB6_4:
	mov	x0, x19
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp], #48             ; 16-byte Folded Reload
	b	_free
LBB6_5:
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp], #48             ; 16-byte Folded Reload
	ret
	.cfi_endproc
                                        ; -- End function
	.section	__TEXT,__cstring,cstring_literals
l_.str:                                 ; @.str
	.asciz	"(null)"

l_.str.2:                               ; @.str.2
	.asciz	" -> "

.subsections_via_symbols
