
.include "../utils/macro_defs.s"

.equ DBG, 1

.data
str1:   .asciz  "Enter x: "
str2:   .asciz  "%d"
str3:   .asciz  "%d! = %lu\n"

.ifdef DBG
str4:   .asciz  "Exited loop\n"
str5:   .asciz  "Endif\n"
.endif

.text
.p2align 2
_factorial:
    stp x29, x30, [sp, #-16]!
    str w0, [sp, #-16]! // save x on the stack
    mov w0, #1          // prepare return value
    ldr w1, [sp]        // w1 = x
    cmp w1, #2          // if (x < 2) return 1
    blt endfact
    sub w1, w1, #1      // x -= 1
    mov w0, w1    
    bl _factorial       // factorial(x - 1)
    ldr w1, [sp]        // w1 = x
    mul w0, w0, w1      // w0 = x * factorial(x - 1)
endfact:
    add sp, sp, #16     // push stack back after saving x
    ldp x29, x30, [sp], #16
    ret

.globl _main
.p2align 2
_main:
    stp x29, x30, [sp, #-16]!
.ifdef DBG
    PRINT_CURRENT_SP
.endif
    sub sp, sp, #16     // x is stored at [sp] and goodval at [sp, #8]
loop:
    LOAD_ADDR , str1
    bl _printf
    mov x1, sp          // move stack back for call to scanf 
    str x1, [sp, #-16]! // save &x = sp to new stack pointer for scanf call
    LOAD_ADDR , str2
    bl _scanf
    add sp, sp, #16  // pop stack back after call to scanf 
    str w0, [sp, #8] // store goodval
if: 
    cmp w0, #1
    bne endif
    ldr w0, [sp]    // w0 = x
    bl _factorial   // w0 = factorial(x)
    ldr w1, [sp]    // w1 = x
    stp x1, x0, [sp, #-16]! // move stack back for call to printf 
    LOAD_ADDR , str3 
    bl _printf
    add sp, sp, #16         // pop stack back after call to printf 
endif:
    ldr w0, [sp, #8] // w0 = goodval
    cmp w0, #1
    beq loop         // end of loop
.ifdef DBG
    LOAD_ADDR , str4
    bl _printf
.endif

    add sp, sp, #16  // move stack back after allocating x, goodval
.ifdef DBG
    PRINT_CURRENT_SP
.endif
    mov w0, #0       // return routine
    ldp x29, x30, [sp], #16
    ret
