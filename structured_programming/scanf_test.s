
.data
str1:    .asciz "%d"
str2:    .asciz "You entered %d, %d arguments successfully written by scanf\n"
n:       .long  0

.include "../utils/macro_defs.s"

.text
.globl _main
.p2align    2
_main:
    sub sp, sp, #48
    stp x29, x30, [sp, #32]
    /* _scanf, like print_f, expects format string address in x0,
        and successive 64-bit arguments at [sp], [sp, #8], [sp, #16], ... */
    LOAD_ADDR x1, n    // x1 = &n
    str x1, [sp]       // store address of n, &n, on sp
    LOAD_ADDR x0, str1
    bl _scanf

    /* _scanf automatically updates the given pointer,
       and returns the number of items successfully written to memory */ 
    LOAD_ADDR x1, n    // x1 = &n
    ldr w2, [x1]       // load new n value (already inserted by _scanf!) to 32-bit register
    str x2, [sp]       // store n value on sp as 64-bit value
    str x0, [sp, #8]
    LOAD_ADDR x0, str2
    bl _printf

    mov w0, #0
    ldp x29, x30, [sp, #32]
    add sp, sp, #48
    ret
    