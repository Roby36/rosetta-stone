
    .section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 13, 0	sdk_version 13, 3

	.globl	_main                          
	.p2align	2
_main:   
	; setting up stack
	.cfi_startproc
	sub sp, sp, #32			
	.cfi_def_cfa_offset 32
	stp x29, x30, [sp, #16] ; store old fp and lr values at the end of the stack frame
	add x29, sp, #16		  ; update frame pointer
	.cfi_def_cfa w29, 16
	.cfi_offset  w30, -8
	.cfi_offset  w29, -16
    str wzr, [sp, #12] ; return value

	; float f = 238.543107
    ; mov w0,  #0b1000101100001101
    ; movk w0, #0b0100001101101110, lsl #16

    ; float f = -987.009760050
    mov w0,  #0b1100000010100000
    movk w0, #0b1100010001110110, lsl #16
    fmov s0, w0
    str s0, [sp, #8] ; 32 bits

    ; print float
    ldr s0, [sp, #8]
    fcvt d0, s0
    str d0, [sp]
    adrp	x0, l_.str@PAGE		
	add	x0, x0, l_.str@PAGEOFF
	bl	_printf

    ldr w0, [sp, #12] ; return value
	; clean up stack
	ldp x29, x30, [sp, #16]
	add sp, sp, #32
	ret
	.cfi_endproc	; main end

    .section	__TEXT,__cstring,cstring_literals
l_.str:                                
	.asciz	"Float value: %f\n" 

.subsections_via_symbols