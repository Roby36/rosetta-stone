
.data 
str:    .asciz  "\nRoberto\n"

.include "../utils/macro_defs.s"

.text
.p2align 2
_reverse:   /* x0 = char * a, x1 = left, x2 = right */
    stp x29, x30, [sp, #-16]!
    cmp x1, x2
    bge endfunc
    /* ONLY STORE / LOAD INDIVIDUAL BYTES, SINCE THAT'S CHAR SIZE, 
        ELSE WILL BE OVERWRITTEN ON 4-BYTE REGISTERS!! */
    ldrb w3, [x0, x1] // w3 = a[left] 
    ldrb w4, [x0, x2] // w4 = a[right]
    strb w4, [x0, x1] // a[left]  = w4
    strb w3, [x0, x2] // a[right] = w3
    /* now perform subroutine call (w0 already in) */
    add w1, w1, #1 // left  + 1
    sub w2, w2, #1 // right - 1
    bl _reverse    
endfunc:
    ldp x29, x30, [sp], #16
    ret

.p2align 2
_print_n_rev:
    stp x29, x30, [sp, #-16]!
    LOAD_ADDR , str
    bl _printf
    LOAD_ADDR , str
    bl _strlen
    sub w0, w0, #1
    mov w2, w0      // x2 = strlen(str) - 1
    mov w1, #0      // x1 = 0
    LOAD_ADDR , str // x0 set to address of the string
    bl _reverse
    ldp x29, x30, [sp], #16
    ret

.globl _main
.p2align 2
_main: 
    stp x29, x30, [sp, #-16]!
    bl _print_n_rev
    bl _print_n_rev
    LOAD_ADDR , str 
    bl _printf
    mov w0, #0
    ldp x29, x30, [sp], #16
    ret
