
.data
mystr:    .asciz  "Loop iteration # %d\n"

.include "../utils/macro_defs.s"
.equ MAXIT, 10

.equ PRETEST, 1 /* determine here if we want a pre-test or post-test */

.text
.globl _main
.p2align    2
_main:
    sub sp, sp, #32
    stp x29, x30, [sp, #16]
    mov x4, #0  
    str x4, [sp, #8] // int i = 0;
loop:      // enter pre-test loop
.ifdef PRETEST
    cmp x4, #MAXIT
    bge endloop  // if i >= 10, goto end of loop
.endif 
    str x4, [sp]
    LOAD_ADDR x0, mystr  // x0 = &mystr
    bl _printf
    ldr x4, [sp, #8] // load value back into register after function call
    add x4, x4, #1  // i++;
    str x4, [sp, #8]
.ifdef POSTTEST /* see how post-test loop MORE EFFICIENT, requiring one less label & branch instruction! */ 
    cmp x4, #MAXIT
    blt loop  // if i < 10, continue in loop, otherwise continue to rest of _main function
.endif
.ifdef PRETEST
    b loop
endloop:
.endif
    mov w0, #0
    ldp x29, x30, [sp, #16]
    add sp, sp, #32
    ret
