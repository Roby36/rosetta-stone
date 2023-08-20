
.data
fne:    .asciz  "Rob"
lne:    .asciz  "Brera"

.include "../utils/macro_defs.s"

.text
.globl _main
.p2align 2
_main:
    stp x29, x30, [sp, #-16]!
/* Allocate struct on stack: total bytes = 30 + 30 + 1 + 32 -> 96
                            word-aligned = 4 * 32 = 128 */
    sub sp, sp, #128
    mov x0, sp
    LOAD_ADDR x1, fne
    bl _strcpy
    add x1, sp, #32
    mov x0, x1 // keep word-alignment
    LOAD_ADDR x1, lne
    bl _strcpy
    mov w0, #2
    strb w0, [sp, #(2 * 32)] // keep word-alignment
    mov w0, #8
    str w0, [sp, #(3 * 32)] // keep word-alignment
/* Clean-up stack & return */
    add sp, sp, #128
    mov w0, #0
    ldp x29, x30, [sp], #16
    ret