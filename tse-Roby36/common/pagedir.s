
.include "../../utils/macro_defs.s"
.include "../../integer_math/division_algorithms.s"

.equ  MAX_CONC_CHAR, 16

.text
.globl _concatInt
.p2align 2
_concatInt: // char * concatInt(char* p, int n)
    stp x29, x30, [sp, #-16]!
    stp x20, x21, [sp, #-16]!
    stp x22, x23, [sp, #-16]!
    stp x24, x25, [sp, #-16]!
    str x26,      [sp, #-16]!

    mov x20, x0                 // x20 = p
    mov w21, w1                 // w21 = n
    sub sp, sp, #MAX_CONC_CHAR
    mov x22, sp                 // x22 = q
    mov w23, #1                 // w23 = i
ci_loop1:  // while (n % i != n)
    mov w0, w21                 
    mov w1, w23                 // mudiv64(n, i)
    bl _mudiv64
    cmp w1, w21                 // if (n % i) == n, exit loop
    beq ci_loop1_end   
    mov w2, #10             
    mul w23, w23, w2            // i *= 10
    b ci_loop1
ci_loop1_end:
    mov w24, #0                 // w24 = bw
ci_loop2:
    cmp w23, #1                 // if (i <= 1), terminate loop
    ble ci_loop2_end
    cmp w24, #MAX_CONC_CHAR     // if (bw >= MAX_CONC_CHAR), terminate loop
    bge ci_loop2_end

    mov w0, w23                 // divide i by 10, save result in w25
    CONST_DIV 10, 0x66666667, 34
    mov w25, w0                 // w25 = i/10
    mov w0, w21                 // mudiv64(n, i)
    mov w1, w23                 
    bl _mudiv64
    mov w26, w1                 // w26 = n % i
    mov w0, w21                 // mudiv64(n, i/10)
    mov w1, w25
    bl _mudiv64
    sub w0, w26, w1             // w0 = n % i - (n % (i/10))
    mov w1, w25                 // w1 = i/10
    bl _mudiv64                 
    add w0, w0, #'0'

    strb w0, [x22, x24]         // q[bw] = (((n % i) - (n % (i/10))) / (i/10)) + '0';
    add w24, w24, #1            // bw++
    mov w23, w25                // i = i/10             
    b ci_loop2
ci_loop2_end:
    mov x0, x20
    bl _strlen
    add w25, w0, #1             // w25 = strlen(p) + 1
    add x0, x25, x24            // x0 = strlen(p) + 1 + bw
    MWRP _malloc, mdbg0, mdbg1
    mov x26, x0                 // x26 = r
    mov x1, x20 
    mov x2, x25                 // strncpy(r, p, strlen(p) + 1)      
    bl _strncpy
    mov x0, x26
    mov x1, x22 
    mov x2, x24                 // strncat(r, q, bw)
    bl _strncat 
    mov x0, x20                 // free(p)
    MWRP _free, fdbg0, fdbg1        
    mov x0, x26                 // return r 

concatInt_end:
    add sp, sp, #MAX_CONC_CHAR  // pop temporary string array from stack
    ldr x26,      [sp], #16
    ldp x24, x25, [sp], #16
    ldp x22, x23, [sp], #16
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret


