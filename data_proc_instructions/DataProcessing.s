	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 13, 0	sdk_version 13, 3
	.globl	_main                           ; -- Begin function main
	.p2align	2
_main:                                  ; @main
	.cfi_startproc

; %bb.0:
	sub	sp, sp, #32
	.cfi_def_cfa_offset 32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16

; TEST INSTRUCTIONS START

	; assigning value to 32-bit register (byte extension tests HERE)
	mov	w8, #256			; testing instructions on w8 register

	; DATA-PROCESSING INSTRUCTIONS

		; addition and subtraction
	mov w7, #8 				; w7 = 8
	adds w8, w8, w7, lsl #2	; w8 = w8 + (w7 <<  2)
	mov w8, #256			; reset w8 to initial value
	subs w8, w8, w8, asr #4 ; w8 = w8 - (w8 >> 4)

		; logical instructions
	and w8, w7, w8;			; w8 = w7 AND w8
	mov w8, #16				; w8 = 16
	orr w8, w7, w8          ; w8 = w7 OR w8
	eor w8, w7, w8			; w8 = w7 EOR w8
	eon w8, w7, w8			; w8 = w7 EON w8

		; arithmetic with carry conditions
	adc w8, w8, wzr			; check is underflow occurred
	sbc w8, w8, wzr			; carry flag is set back to zero
	neg w8, w8				; invert sign

		; set arbitrary bit to zero using bic operator, and new register
	mov w6, #8				; bit[3] of w8 will be set to zero
	bic w8, w8, w6			; w8 = w8 AND (w6')

		; multiplication and division
	mov w7, #8
	mov w8, #-15
	sdiv w8, w8, w7			; w8 = w8 / w7 ; INTEGER DIVISION!
	mul w8, w7, w8			; w8 = w7 * w8 ; NO original integer!
	sdiv w6, w8, wzr		; integer division by zero returns zero
	mov w8, w6

		; shift operations
	mov w8, #4096
	lsl w8, w8, #1			; increment by some power of 2
	lsr w8, w8, #8			; decrement by some power of 2
	lsr w8, w8, #6			; rightmost bits will get lost
	mov w8, #16			
	mov w7, #0	
	ror w8, w8, #5			; bitwise rotation -> underflow!
	adc w7, w7, wzr			; use w7 as underflow indicator (if w7 = 1, then underflow occurred)
	mov w8, w7

		; byte extensions
	mov w7, #0
	mov w8, #128
	add w8, w8, #64
	sxtb x8, w8				; sign-extend the leftmost byte of w8 to entire x8 register -> underflow!
	;adc w7, w7, wzr			
	;mov w8, w7					; check underflow
	;sxth w8, w8				; extending half-word leaves number unchanged since bit[15] = 0

		; bitfield instructions
	mov w8, #0
	mov w7, #7				; 7 = 0b111
	bfi w8, w7, #5, #6		; w8 = 0b00011100000 = 224
	bfi w8, w7, #1, #3		; w8 = 0b00011101110 = 238 ; insertion does NOT zero out other bits in destination register
	ubfx w8, w8, #1, #3		; w8 = 0b00000000111 = 7
	ubfx w8, w7, #2, #7		; w8 = 0b00000000001 = 1   ; extraction DOES zero out other bits and allocates extracted bits at the start of destination register
	mov w8, #2147483647		; 2^31 - 1 is the maximum integer we can store without affecting the sign bit thus causing an underflow !
	; bfc w8, wzr, #1, #2	; this instruction is not recognized ...
	mov w8, #65536			; 2^16
	clz w8, w8				; 15 leading zeroes in w8
	sub w8, w8, #1
	rbit w8, w8				; reversing all bits in w8 -> NO underflow since bit[31] not set to 1 = NEGATIVE!

		; underflow & overflow testing
	mov w7, #2147483647
	mov w8, #2147483647		; 2^31 - 1, biggest integer letting bit[31] to zero -> biggest integer that we can store with NO underflow
	adds w8, w8, #1    	    ; (2^31 - 1) + 1 -> - 2^31 (underflow; adds only sets overflow, C-flag remains 0)
	adds w8, w8, w7   		; (- 2^31) + (2^31 - 1) -> -1 (no overflow / underflow, C-flag remains 0 )
	adds w8, w8, #1    		; -1 + 1 -> 0, but since 1111111.... -> 00000000.... there is an overflow, 
							; thus C-flag set to 1 to signal overflow during addition operation
	adc w8, wzr, wzr		; overflow?

		; comparison & checking flag
	mov w8, #0				; w0 outputs cmp result, w7 and w6 are compared
	mov w7, #7
	mov w6, #6
	cmp w7, w6				; w7 > w6
	adc w8, w8, wzr			; check carry flag: w7 > w6 -> w7 - w6 same sign as w7 -> NO underflow for w7 - w6 -> C-flag set to 1

		; conditional selects and sets
	; e.g: compile following switch-statement in assembly (NO BRANCHING STATEMENTS!)
	;	switch (k) {
	;		case 0: f=i+j; break; 
	;		case 1: f=g+h; break;
	;		case 2: f=g–h; break;
	;		case 3: f=i–j; break;
	;	}
			   ; assign some starting values to the variables
	mov w8, #2 ; f (final output)
	mov w3, #3 ; g
	mov w4, #4 ; h
	mov w5, #5 ; i
	mov w6, #6 ; j
	mov w7, #0 ; k
			   ; test individually each branch of the switch statement
	add w10, w5, w6      ; case 0: f=i+j;
	cmp w7, #0 			 ; check if k == 0
	csel w8, w10, w8, EQ ; if k == 0, f <- i+j, else f <- f
						 ; repeat for all the other clauses, using always w10 register to store candidate value
		; case 1: f=g+h;
	add w10, w3, w4  
	cmp w7, #1
	csel w8, w10, w8, EQ
		; case 2: f=g–h;
	sub w10, w3, w4  
	cmp w7, #2
	csel w8, w10, w8, EQ
		; case 3: f=i–j;
	sub w10, w5, w6  
	cmp w7, #3
	csel w8, w10, w8, EQ

	; DATA PROCESSING INSTRUCTIONS END


	; memory access operations 
	stur	w8, [x29, #-4] 
	ldur	w9, [x29, #-4] 
                                        ; implicit-def: $x8
	mov	x8, x9
	mov	x9, sp
	str	x8, [x9]

	; printf call
	adrp	x0, l_.str@PAGE
	add	x0, x0, l_.str@PAGEOFF
	bl	_printf

; TEST INSTRUCTIONS END

	adrp	x0, l_.str.1@PAGE
	add	x0, x0, l_.str.1@PAGEOFF
	bl	_puts
	mov	w0, #0
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload

	add	sp, sp, #32

	ret
	.cfi_endproc
                                        ; -- End function
	.section	__TEXT,__cstring,cstring_literals
l_.str:                                 ; @.str
	.asciz	"Resulting integer is: %d\n"

l_.str.1:                               ; @.str.1
	.asciz	"Done!"

.subsections_via_symbols
