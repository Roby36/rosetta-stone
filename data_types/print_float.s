
.data
my_float:   .float  1.6965753
my_str:     .asciz  "my_float value: %f %d\n"

.include "../utils/macro_defs.s"

.text
.p2align 2
_print_myfloat:
    sub sp, sp, #32 ; make extra space in stack for float number to store
    stp x29, x30, [sp, #16]

    LOAD_ADDR x0, my_str   ; load string address into x0
    LOAD_ADDR x8, my_float ; load float's address into x8
    ldr s1, [x8] ; load float from address at x8 into register s1
    fcvt d1, s1  ; convert to 64-bit sized register
    str d1, [sp] ; store float value on stack
    ldr x1, =0x1234567812345678  ; pseudo-load test (up to 64 bits)
    mov x1, #0x1234  ; (up to 16 bits only!)
    str x1, [sp, #8]
    bl _printf

    ldp x29, x30, [sp, #16]
	add sp, sp, #32
	ret

.globl _main
.p2align 2
_main:
    stp x29, x30, [sp, #-16]!

    bl _print_myfloat

    mov w0, #0
    ldp x29, x30, [sp], #16
	ret
