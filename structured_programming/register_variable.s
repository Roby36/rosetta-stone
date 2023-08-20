
.data 
msg:    .asciz  "doit() returned %d\n"

.equ ARR_SIZE, 20
.include "../utils/macro_defs.s"

.text
.p2align 2

_doit:
    sub sp, sp, #(ARR_SIZE * 4) // only works because 80 divisible by 16!
    mov w1, #0  /* register int i */
 loop: 
    cmp w1, ARR_SIZE /* pre-testing condition */
    bge endloop
    str w1, [sp, x1, lsl #2] /* sp + (x1 << 2) */
    add w1, w1, #1  /* i++ */
    b loop
 endloop:
    mov w0, w1 /* return i */
    add sp, sp, #(ARR_SIZE * 4)
    ret

.globl _main
.p2align 2
_main:
    stp x29, x30, [sp, #-16]!
    bl _doit /* void requires no argument-passing in registers */
    str x0, [sp, #-16]! /* store return value on sp and print it out */
    LOAD_ADDR , msg
    bl _printf
    add sp, sp, #16 /* push stack back */
    mov w0, #0
    ldp x29, x30, [sp], #16
    ret
