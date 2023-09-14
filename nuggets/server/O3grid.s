	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 13, 0	sdk_version 13, 3
	.globl	_grid_new                       ; -- Begin function grid_new
	.p2align	2
_grid_new:                              ; @grid_new
	.cfi_startproc
; %bb.0:
	stp	x24, x23, [sp, #-64]!           ; 16-byte Folded Spill
	stp	x22, x21, [sp, #16]             ; 16-byte Folded Spill
	stp	x20, x19, [sp, #32]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #48]             ; 16-byte Folded Spill
	add	x29, sp, #48

	cbz	x0, LBB0_11
; %bb.1:
	mov	x20, x0
	mov	w0, #10012
	bl	_malloc
	mov	x19, x0
	cbz	x0, LBB0_12
; %bb.2:
	mov	x21, x19
	str	wzr, [x21, #4]!
	str	wzr, [x19]
	str	wzr, [x19, #8]
	mov	w22, #167772160
	mov	w23, #-16777216
	b	LBB0_7
LBB0_3:                                 ;   in Loop: Header=BB0_7 Depth=1
	ldr	w8, [x19, #8]
LBB0_4:                                 ;   in Loop: Header=BB0_7 Depth=1
	ldr	w10, [x19]
	mov	x11, x19
	mov	x1, x8
LBB0_5:                                 ;   in Loop: Header=BB0_7 Depth=1
	add	w8, w10, #1
	str	w8, [x11]
	mov	x8, x1
LBB0_6:                                 ;   in Loop: Header=BB0_7 Depth=1
	add	w9, w8, #1
	str	w9, [x19, #8]
	add	x8, x19, w8, sxtw
	strb	w0, [x8, #12]
LBB0_7:                                 ; =>This Inner Loop Header: Depth=1
	mov	x0, x20
	bl	_getc
	lsl	w9, w0, #24
	cmp	w9, w22
	b.eq	LBB0_3
; %bb.8:                                ;   in Loop: Header=BB0_7 Depth=1
	cmp	w9, w23
	b.eq	LBB0_13
; %bb.9:                                ;   in Loop: Header=BB0_7 Depth=1
	ldp	w10, w8, [x19, #4]
	mov	x11, x21
	mov	x1, x10
	cmp	w10, w8
	b.eq	LBB0_5
; %bb.10:                               ;   in Loop: Header=BB0_7 Depth=1
	cmp	w9, w22
	b.eq	LBB0_4
	b	LBB0_6
LBB0_11:
	mov	x19, #0
LBB0_12:
	mov	x0, x19
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #32]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #16]             ; 16-byte Folded Reload
	ldp	x24, x23, [sp], #64             ; 16-byte Folded Reload
	ret
LBB0_13:
	ldrsw	x8, [x19, #8]
	add	x8, x19, x8
	strb	wzr, [x8, #12]
	mov	x0, x19
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #32]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #16]             ; 16-byte Folded Reload
	ldp	x24, x23, [sp], #64             ; 16-byte Folded Reload
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_getX                           ; -- Begin function getX
	.p2align	2
_getX:                                  ; @getX
	.cfi_startproc
; %bb.0:
	cbz	x0, LBB1_5
; %bb.1:
	mov	x8, x0
	mov	w0, #-1
	tbnz	w1, #31, LBB1_4
; %bb.2:
	ldr	w9, [x8, #8]
	cmp	w9, w1
	b.le	LBB1_4
; %bb.3:
	ldr	w8, [x8, #4]
	add	w8, w8, #1
	sdiv	w9, w1, w8
	msub	w0, w9, w8, w1
LBB1_4:
	ret
LBB1_5:
	mov	w0, #-1
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_getY                           ; -- Begin function getY
	.p2align	2
_getY:                                  ; @getY
	.cfi_startproc
; %bb.0:
	cbz	x0, LBB2_5
; %bb.1:
	mov	x8, x0
	mov	w0, #-1
	tbnz	w1, #31, LBB2_4
; %bb.2:
	ldr	w9, [x8, #8]
	cmp	w9, w1
	b.le	LBB2_4
; %bb.3:
	ldr	w8, [x8, #4]
	add	w8, w8, #1
	sdiv	w0, w1, w8
LBB2_4:
	ret
LBB2_5:
	mov	w0, #-1
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_getPos                         ; -- Begin function getPos
	.p2align	2
_getPos:                                ; @getPos
	.cfi_startproc
; %bb.0:
	mov	x8, x0
	mov	w0, #-1
	cbz	x8, LBB3_6
; %bb.1:
	tbnz	w1, #31, LBB3_6
; %bb.2:
	mov	w0, #-1
	tbnz	w2, #31, LBB3_6
; %bb.3:
	ldr	w9, [x8, #4]
	cmp	w9, w1
	b.lt	LBB3_6
; %bb.4:
	ldr	w8, [x8]
	cmp	w8, w2
	b.le	LBB3_7
; %bb.5:
	madd	w8, w2, w9, w2
	add	w0, w8, w1
LBB3_6:
	ret
LBB3_7:
	mov	w0, #-1
	ret
	.cfi_endproc
                                        ; -- End function



	.globl	_isVisible                      ; -- Begin function isVisible
	.p2align	2
_isVisible:                             ; @isVisible
	.cfi_startproc

	// Initial return checks: DOES NOT MOVE SP & SAVE REGS !!! 
	// would be useless to set up sp & callee-saved registers if there's an early return!
	mov	w10, #0
	cbz	x0, LBB4_38
	tbnz	w1, #31, LBB4_38
	mov	w10, #0
	tbnz	w2, #31, LBB4_38
	ldr	w8, [x0, #4]			// w8 = grid->NC
	cmp	w8, w1
	b.lt	LBB4_38
	mov	w10, #0
	tbnz	w3, #31, LBB4_38
	ldr	w9, [x0]				// w9 = grid->NR
	cmp	w9, w2
	b.le	LBB4_38
	mov	w10, #0
	tbnz	w4, #31, LBB4_38
	cmp	w8, w3
	b.lt	LBB4_38
	cmp	w9, w4
	b.le	LBB4_38


	subs	w13, w3, w1			// w13 = ox -px 
	csel	w14, w3, w1, lt		// w14 = xmin 
	csel	w11, w3, w1, gt		// w11 = xmax
	subs	w10, w4, w2			// w10 = oy - py
	csel	w12, w4, w2, lt		// w12 = ymin
	scvtf	s0, w10				// s0 = (float) oy - py
	csel	w10, w4, w2, gt		// w10 = ymax
	scvtf	s1, w13				// s1 = (float) ox - px 
	fdiv	s0, s0, s1			// s0 = m

	// for (int x = xmin + 1; x < xmax; x++)
	add	w13, w14, #1			// w13 = x			
	cmp	w13, w11				
	b.hs	LBB4_19				// if x > xmax,  goto loop end

	add	w14, w8, #1				// w14 = grid->NC + 1
	scvtf	s1, w2				// s1 = (float) py
	neg	w15, w1					// w15 = - px
	mov	w16, #1					// w16 = 1
	mov	x17, #4401911981670		// x17 = 4401911981670
	mov	w3, #-1					// w3 = -1

LBB4_11:                                ; =>This Inner Loop Header: Depth=1
	sub	w5, w13, #1				// w5 = x - 1
	cmn	w5, #1					// PSTATE <- (x - 1) + 1
	b.ge	LBB4_13				// if x >= 0, goto LBB4_13

// continue here if x < 0
	ldrb	w4, [x0, #11]
	mov	w5, #-1
	mov	w6, w4
	cmp	w4, #45
	lsl	x6, x16, x6
	and	x6, x6, x17
	ccmp	x6, #0, #4, ls
	b.ne	LBB4_15
	b	LBB4_14

// Case where x >= 0
LBB4_13:                                ;   in Loop: Header=BB4_11 Depth=1
	add	w4, w15, w13			
	scvtf	s2, w4				// s2 = (float) (x - px)
	fmadd	s2, s0, s2, s1		// s2 = y
	fcvtms	w4, s2				// w4 = floor(y)

//!	Inlined getPos
	cmp	w9, w4					// cmp grid->NR, floor(y)
	ccmp	w4, w3, #4, gt		// if (grid->NR > floor(y)), cmp floor(y), -1, else set Z = 1
	ccmp	w8, w5, #4, gt		// if (floor(y) > -1),       cmp (grid->NC, x - 1), else set Z = 1
					// Some checks already performed by isVisible!
	madd	w4, w14, w4, w13	
	sxtw	x4, w4				// x4 = (grid->NC + 1)(floor(y)) + x

	csinv	x4, x4, xzr, gt		// if (grid->NC - 1) > 0 [PASSED ALL CONDITIONS], x4 = (grid->NC + 1)(floor(y)) + x
		// else x4 = inv(xzr) = 111....1111 [64x] = -1	!!! DANGEROUS if getPos returns -1 !!!
	add	x4, x0, x4				// x4 = &grid + getPos
	ldrb	w4, [x4, #12]		// w4 = *(&grid + getPos + 12) = *(&grid->map[getPos]) = grid->map[getPos] (prevTile)

	fcvtps	w6, s2				// w6 = ceil(y)
	madd	w7, w14, w6, w13	// w7 = (grid->NC + 1)(ceil(y)) + x

//! Inlined getPos
	cmp	w9, w6					// cmp  grid->NR, ceil(y)
	csel	w7, w7, w3, gt		// if (grid->NR > ceil(y)), w7 = (grid->NC + 1)(ceil(y)) + x, else w7 = -1
	tst	w6, #0x80000000			// if ceil(y) negative, w6 & 0x80000000 != 0, hence Z = 0 (ne)
	csel	w6, w3, w7, ne		// if ceil(y) negative, w6 = -1 (bad result), else w6 = w7

	cmp	w8, w5					// cmp grid->NC, x - 1
	csel	w5, w3, w6, le		// if grid->NC <= x - 1, w5 = -1 (bad result), else w5 = w6
	mov	w6, w4					// w6 = prevTile

//! Start comparing ASCII characters for prevTile before fetching from memory nextTile !!!
	cmp	w4, #45					// cmp prevTile, horizontalBoundary (45)

	lsl	x6, x16, x6				// x6 = 1 << prevTile
	and	x6, x6, x17				// x6 = x6 AND #4401911981670
	ccmp	x6, #0, #4, ls		// if (prevTile <= 45), cmp x6, 0; else set Z = 1
	b.ne	LBB4_15				// branch to second comparison if (x6 & #4401911981670 != 0) (ne)

// Case where prevTile > 45, or comparison with lower tiles fails
LBB4_14:                                ;   in Loop: Header=BB4_11 Depth=1
	cmp	w4, #124				// cmp prevTile, verticalBoundary
	b.ne	LBB4_18				// if not equal, continue loop

// Second comparison (fetching nextTile)
LBB4_15:                                ;   in Loop: Header=BB4_11 Depth=1
	add	x4, x0, w5, sxtw		// x4 = &grid + getPos(grid, x, ceilf(y)) [could have returned -1!]
	ldrb	w4, [x4, #12]		// w4 = nextTile
	cmp	w4, #45
	b.hi	LBB4_17				// if nextTile > 45, branch to final comparison
		// if nextTile < horizontalBoudnary (45), continue here    
	lsl	x5, x16, x4				// x5 = 1 << nextTile
	tst	x5, x17					
	b.ne	LBB4_37				// if (x5 & #4401911981670) != 0, return false

// Since this branch assumes (nextTile > horizontalBoundary), we only need to check against verticalBoundary (124)
LBB4_17:                                ;   in Loop: Header=BB4_11 Depth=1
	cmp	w4, #124
	b.eq	LBB4_37				// if nextTile == verticalBoundary, return false

//! Loop condition check
LBB4_18:                                ;   in Loop: Header=BB4_11 Depth=1
	add	w13, w13, #1
	cmp	w11, w13
	b.ne	LBB4_11


// Loop end
LBB4_19:
	add	w11, w12, #1
	cmp	w11, w10
	b.ge	LBB4_39

; %bb.20:
	scvtf	s1, w1
	add	w12, w8, #1
	neg	w13, w2
	mul	w14, w12, w11
	mov	w15, #1
	mov	x17, #44019119816704
	mov	w16, #1
LBB4_21:                                ; =>This Inner Loop Header: Depth=1
	sub	w3, w11, #1
	add	w1, w13, w11
	scvtf	s2, w1
	fdiv	s2, s2, s0
	fadd	s2, s2, s1
	mov	w1, #-1
	fcvtms	w2, s2
	tbnz	w2, #31, LBB4_25
; %bb.22:                               ;   in Loop: Header=BB4_21 Depth=1
	cmn	w3, #1
	b.lt	LBB4_25
; %bb.23:                               ;   in Loop: Header=BB4_21 Depth=1
	cmp	w8, w2
	ccmp	w9, w11, #4, ge
	b.le	LBB4_25
; %bb.24:                               ;   in Loop: Header=BB4_21 Depth=1
	add	w1, w14, w2
LBB4_25:                                ;   in Loop: Header=BB4_21 Depth=1
	mov	w2, #-1
	fcvtps	w4, s2
	tbnz	w4, #31, LBB4_29
; %bb.26:                               ;   in Loop: Header=BB4_21 Depth=1
	cmn	w3, #1
	b.lt	LBB4_29
; %bb.27:                               ;   in Loop: Header=BB4_21 Depth=1
	cmp	w8, w4
	ccmp	w9, w11, #4, ge
	b.le	LBB4_29
; %bb.28:                               ;   in Loop: Header=BB4_21 Depth=1
	add	w2, w14, w4
LBB4_29:                                ;   in Loop: Header=BB4_21 Depth=1
	add	x1, x0, w1, sxtw
	ldrb	w1, [x1, #12]
	cmp	w1, #45
	b.hi	LBB4_31
; %bb.30:                               ;   in Loop: Header=BB4_21 Depth=1
	lsl	x3, x15, x1
	tst	x3, x17
	b.ne	LBB4_32
LBB4_31:                                ;   in Loop: Header=BB4_21 Depth=1
	cmp	w1, #124
	b.ne	LBB4_35
LBB4_32:                                ;   in Loop: Header=BB4_21 Depth=1
	add	x1, x0, w2, sxtw
	ldrb	w1, [x1, #12]
	cmp	w1, #45
	b.hi	LBB4_34
; %bb.33:                               ;   in Loop: Header=BB4_21 Depth=1
	lsl	x2, x15, x1
	tst	x2, x17
	b.ne	LBB4_36
LBB4_34:                                ;   in Loop: Header=BB4_21 Depth=1
	cmp	w1, #124
	b.eq	LBB4_36
LBB4_35:                                ;   in Loop: Header=BB4_21 Depth=1
	add	w11, w11, #1
	cmp	w11, w10
	cset	w16, lt
	add	w14, w14, w12
	cmp	w10, w11
	b.ne	LBB4_21
LBB4_36:
	eor	w10, w16, #0x1
	and	w0, w10, #0x1
	ret


//! false return 
LBB4_37:
	mov	w10, #0
LBB4_38:
	and	w0, w10, #0x1		// w0 = w10[0]
	ret
LBB4_39:
	eor	w10, wzr, #0x1
	and	w0, w10, #0x1
	ret
	.cfi_endproc
                                        ; -- End function



	.globl	_getVisibleGrid                 ; -- Begin function getVisibleGrid
	.p2align	2
_getVisibleGrid:                        ; @getVisibleGrid
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #128
	.cfi_def_cfa_offset 128
	stp	x28, x27, [sp, #32]             ; 16-byte Folded Spill
	stp	x26, x25, [sp, #48]             ; 16-byte Folded Spill
	stp	x24, x23, [sp, #64]             ; 16-byte Folded Spill
	stp	x22, x21, [sp, #80]             ; 16-byte Folded Spill
	stp	x20, x19, [sp, #96]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #112]            ; 16-byte Folded Spill
	add	x29, sp, #112
ì
	cbz	x0, LBB5_7
; %bb.1:
	mov	x20, x2
	tbnz	w2, #31, LBB5_7
; %bb.2:
	mov	x21, x3
	tbnz	w3, #31, LBB5_7
; %bb.3:
	mov	x22, x0
	ldr	w8, [x0, #4]
	cmp	w8, w20
	b.lt	LBB5_7
; %bb.4:
	ldr	w9, [x22]
	cmp	w9, w21
	b.le	LBB5_7
; %bb.5:
	madd	w9, w21, w8, w21
	add	w9, w9, w20
	add	x9, x22, w9, sxtw
	ldrb	w9, [x9, #12]
	cmp	w9, #45
	mov	w10, #1
	lsl	x10, x10, x9
	mov	x11, #1024
	movk	x11, #10241, lsl #32
	and	x10, x10, x11
	ccmp	x10, #0, #4, ls
	b.eq	LBB5_8
LBB5_6:
Lloh0:
	adrp	x8, ___stderrp@GOTPAGE
Lloh1:
	ldr	x8, [x8, ___stderrp@GOTPAGEOFF]
Lloh2:
	ldr	x0, [x8]
                                        ; kill: def $w9 killed $w9 killed $x9 def $x9
	stp	x21, x9, [sp, #8]
	str	x20, [sp]
Lloh3:
	adrp	x1, l_.str@PAGE
Lloh4:
	add	x1, x1, l_.str@PAGEOFF
	bl	_fprintf
LBB5_7:
	ldp	x29, x30, [sp, #112]            ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #96]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #80]             ; 16-byte Folded Reload
	ldp	x24, x23, [sp, #64]             ; 16-byte Folded Reload
	ldp	x26, x25, [sp, #48]             ; 16-byte Folded Reload
	ldp	x28, x27, [sp, #32]             ; 16-byte Folded Reload
	add	sp, sp, #128
	ret
LBB5_8:
	cmp	w9, #124
	b.eq	LBB5_6
; %bb.9:
	mov	x19, x1
	ldr	w9, [x22, #8]
	cmp	w9, #1
	b.lt	LBB5_19
; %bb.10:
	mov	x23, #0
	mov	w24, #10
	mov	w25, #32
	mov	w26, #64
	add	w8, w8, #1
	sdiv	w4, w23, w8
	msub	w3, w4, w8, w23
	cmp	w3, w20
	ccmp	w4, w21, #0, eq
	b.eq	LBB5_13
LBB5_11:
	add	x8, x22, x23
	ldrb	w27, [x8, #12]
	cmp	w27, #10
	b.ne	LBB5_14
; %bb.12:
	strb	w24, [x19, x23]
	b	LBB5_17
LBB5_13:
	strb	w26, [x19, x23]
	b	LBB5_17
LBB5_14:
	mov	x0, x22
	mov	x1, x20
	mov	x2, x21
	bl	_isVisible
	cbz	w0, LBB5_16
; %bb.15:
	strb	w27, [x19, x23]
	b	LBB5_17
LBB5_16:
	strb	w25, [x19, x23]
LBB5_17:
	add	x23, x23, #1
	ldrsw	x9, [x22, #8]
	cmp	x23, x9
	b.ge	LBB5_19
; %bb.18:
	ldr	w8, [x22, #4]
	add	w8, w8, #1
	sdiv	w4, w23, w8
	msub	w3, w4, w8, w23
	cmp	w3, w20
	ccmp	w4, w21, #0, eq
	b.eq	LBB5_13
	b	LBB5_11
LBB5_19:
	strb	wzr, [x19, w9, sxtw]
	b	LBB5_7
	.loh AdrpAdd	Lloh3, Lloh4
	.loh AdrpLdrGotLdr	Lloh0, Lloh1, Lloh2
	.cfi_endproc
                                        ; -- End function
	.globl	_grid_delete                    ; -- Begin function grid_delete
	.p2align	2
_grid_delete:                           ; @grid_delete
	.cfi_startproc
; %bb.0:
	cbz	x0, LBB6_2
; %bb.1:
	b	_free
LBB6_2:
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_get_gridPoint                  ; -- Begin function get_gridPoint
	.p2align	2
_get_gridPoint:                         ; @get_gridPoint
	.cfi_startproc
; %bb.0:
	mov	w8, #0
	cbz	x0, LBB7_4
; %bb.1:
	tbnz	w1, #31, LBB7_4
; %bb.2:
	ldr	w9, [x0, #8]
	cmp	w9, w1
	b.le	LBB7_4
; %bb.3:
	add	x8, x0, w1, uxtw
	ldrb	w8, [x8, #12]
LBB7_4:
	sxtb	w0, w8
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_get_TC                         ; -- Begin function get_TC
	.p2align	2
_get_TC:                                ; @get_TC
	.cfi_startproc
; %bb.0:
	cbz	x0, LBB8_2
; %bb.1:
	ldr	w0, [x0, #8]
	ret
LBB8_2:
	mov	w0, #-1
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_set_gridPoint                  ; -- Begin function set_gridPoint
	.p2align	2
_set_gridPoint:                         ; @set_gridPoint
	.cfi_startproc
; %bb.0:
	cbz	x0, LBB9_4
; %bb.1:
	mov	x8, x0
	mov	w0, #0
	tbnz	w1, #31, LBB9_4
; %bb.2:
	ldr	w9, [x8, #8]
	cmp	w9, w1
	b.le	LBB9_4
; %bb.3:
	add	x8, x8, w1, uxtw
	strb	w2, [x8, #12]
	mov	w0, #1
LBB9_4:
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_get_map                        ; -- Begin function get_map
	.p2align	2
_get_map:                               ; @get_map
	.cfi_startproc
; %bb.0:
	add	x8, x0, #12
	cmp	x0, #0
	csel	x0, xzr, x8, eq
	ret
	.cfi_endproc
                                        ; -- End function
	.section	__TEXT,__cstring,cstring_literals
l_.str:                                 ; @.str
	.asciz	"(%d, %d) position not allowed: %c\n"

.subsections_via_symbols
