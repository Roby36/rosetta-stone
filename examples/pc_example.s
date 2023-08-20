
.include "../utils/macro_defs.s"

.data
logstr:  .asciz  "Returning to label1\n"

.text
.globl _main
.p2align 2
_main:
    stp x29, x30, [sp, #-16]!
label1:
    PRINT_CURRENT_PC
    PRINT_CURRENT_PC
    PRINT_CURRENT_PC
    PRINT_CURRENT_PC
    nop
    nop
    nop
    nop
    PRINT_CURRENT_PC
    PRINT_CURRENT_PC
    PRINT_CURRENT_PC
    PRINT_CURRENT_PC
    LOAD_ADDR , logstr
    bl _printf
    b label1

    mov w0, wzr     // returning
    ldp x29, x30, [sp], #16
    ret