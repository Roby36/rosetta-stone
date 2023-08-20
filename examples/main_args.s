
.include "./utils/macro_defs.s"

.data
str:    .asciz  "argv[%d] = %s\n"

.text
.globl _main
.p2align 2
_main:
    stp x29, x30, [sp, #-16]!
    mov w22, w0    // w22 = argc (in NON-VOLATILE REGISTER)
    mov x23, x1   // x23 = argv (in NON-VOLATILE REGISTER)
    mov w21, #0  // int i = 0 (in NON-VOLATILE REGISTER)
loop: /* post-test loop, since argc >= 0 */
    ldr x4, [x23, x21, lsl #3]   // x4 = argv[i] (array of 8-byte pointers)
    stp x21, x4, [sp, #-16]!    // store i at [sp] and argv[i] at [sp, #8]
    LOAD_ADDR , str            // x0 = &str
    bl _printf
    add sp, sp, #16          // restore stack pointer
    add w21, w21, #1         // i++
    cmp w21, w22             // if i < argc, goto loop
    blt loop                 // loop end

    mov w0, #0
    ldp x29, x30, [sp], #16
    ret
