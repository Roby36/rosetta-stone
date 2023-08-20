	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 13, 0	sdk_version 13, 3
	.globl	_main                           ; -- Begin function main
	.p2align	2
_main:                                  ; @main
	.cfi_startproc
; %bb.0:
	; process start
	sub	sp, sp, #32			; decrement sp by 32
	.cfi_def_cfa_offset 32  ; mark 32-byte offset
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16	

	; set-up return code
	str	wzr, [x29, #-4]					; STORE RETURN CODE AT [x29, #-4]

	mov	w8, #10			; int32_t a = 10;
	str	w8, [sp, #8]	; store a at current stack pointer + 8 bytes
	subs	w8, w8, #5  ; w8 = w8 - 5 (w8 = a - 5)
	cset	w8, ge		; if w8 >= 0 (a - 5 >= 0), set w8 = 1
					    ; else if w8 <= 0 (a - 5 < 0), set w8 = 0
	tbnz	w8, #0, LBB0_2 ; if w8[0] != 0 (a >= 5), branch to LBB0_2 -> a--
	b	LBB0_1			; branch unconditionally to LBB0_1 -> a++

LBB0_1:
	ldr	w8, [sp, #8]	; set w8 <- a
	add	w8, w8, #1		; w8 = w8 + 1
	str	w8, [sp, #8]    ; a <- w8
	b	LBB0_3			; branch unconditionally to LBB0_3 (program termination)

LBB0_2:					; similar to LBB0_1
	ldr	w8, [sp, #8]
	subs	w8, w8, #1
	str	w8, [sp, #8]
	b	LBB0_3

LBB0_3:
	ldr	w9, [sp, #8]	; w9 <- a
                                        ; implicit-def: $x8
	mov	x8, x9	 ; x8 = x9
	mov	x9, sp	 ; set x9 to stack pointer address
	str	x8, [x9] ; write a-value to address pointed to by x9 (sp)

	; NOTE: printf() prints value at memory address [sp] !
	mov x7, #19
	str x7, [sp]

	; printf call
	adrp	x0, l_.str@PAGE
	add	x0, x0, l_.str@PAGEOFF
	bl	_printf		; branch to _printf symbol (defined elsewhere...) and save return to X30 register
	
	; return code
	ldr	w0, [x29, #-4]	; LOAD RETURN CODE INTO w0 FROM [x29, #-4] (previously stored)

	; process exit
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #32
	ret						; return from main

	.cfi_endproc
                                        ; -- End function
	
	; literal pool
	.section	__TEXT,__cstring,cstring_literals
l_.str:                                 ; @.str
	.asciz	"a: %d\n"

.subsections_via_symbols
