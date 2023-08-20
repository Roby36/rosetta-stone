
    .section    __TEXT,__text,regular,pure_instructions
    .build_version macos, 13, 0 sdk_version 13, 3

    .globl _main
    .p2align    2
_main:
    .cfi_startproc
    sub sp, sp, #64
    .cfi_def_cfa_offset 64
    stp x29, x30, [sp, #48]
    add x29, sp, #48
    .cfi_def_cfa w29, 16
    .cfi_offset  w30, -8
    .cfi_offset  w29, -16

    ; testing the two's complement integer representation:
    ; positive integers
    ; int i = 1089 (= 0b10001000001)
    mov x1, #0b10001000001
    str x1, [sp]
    ; int i = 1839207 (= 0b111000001000001100111)
    mov x1, #0b0001000001100111
    movk x1, #0b11100, lsl #16
    str x1, [sp, #8]
    ; negative integers
    ; int i = -55577
    ; -55577 = -(0b1101100100011001)
    ;        = 1... + 1's complement(1101100100011001) + 1
    ;        = 1... 0010011011100111
    mov w1, #0b0010011011100111
    movk w1, #0b1111111111111111, lsl #16
    sxtw x1, w1
    str x1, [sp, #16]
    ; int i = -66743257
    ;       = -(0b11111110100110101111011001)
    ;       = 1... + 1's complement(11111110100110101111011001) + 1
    ;       = 1... 00000001011001010000100110 + 1
    ;       = 1... 00000001011001010000100111
    mov w1, #0b1001010000100111
    movk w1, #0b1111110000000101, lsl #16   ; 6x 1s "padding"
    sxtw x1, w1     ; sign-extend w-register to x-register to pad with 1s
    str x1, [sp, #24]
    ; int i = -87944
    mov w1, #0b1010100001111000
    movk w1, #0b1111111111111110, lsl #16
    sxtw x1, w1
    str x1, [sp, #32]

    ; printf() call:
	adrp	x0, l_.str@PAGE		
	add	x0, x0, l_.str@PAGEOFF
	bl	_printf

    mov w0, #0 ; return code

    ldp x29, x30, [sp, #48] ; cleaning up stack
    add sp, sp, #64
    ret 
    .cfi_endproc

    .section	__TEXT,__cstring,cstring_literals
l_.str:                                
	.asciz	"Integers:\n %d\n %d\n %d\n %d\n %d\n" 

.subsections_via_symbols

