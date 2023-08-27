
/* Unsigned 64-bit division: 
 * takes dividend in x0 and divisor in x1
 * returns quotient in x0 and remainder in x1 
 */
.text
.globl _mudiv64
.p2align 2
_mudiv64:   // no function calls, hence no need to store x29, x30 registers...
    mov x2, xzr                 // x2 = count, intialized to zero
loop1:  // while divisor (x1) < dividend (x0)
    cmp x1, x0
    bhs loop1_end
    add x2, x2, #1              // count++
    lsl x1, x1, #1              // shift divisor left by one bit
    b loop1
loop1_end:
    mov x3, #0                  // x3 = quotient, initialze to zero
loop2:  // while count >= 0
    tbnz x2, #63, loop2_end
    lsl x3, x3, #1              // shift quotient left by 1 bit
    sub x4, x0, x1              // x4 = dividend - divisor
    cmp x1, x0
    cinc x3, x3, ls             // if divisor <= dividend, quotient++, else unchanged
    csel x0, x0, x4, hi         // if divisor <= dividend, dividend = dividend - divisor
    sub x2, x2, #1              // count --
    lsr x1, x1, #1              // shift divisor right by 1 bit
    b loop2
loop2_end:
    mov x1, x0                  // x1 = remainder (dividend)
    mov x0, x3                  // x0 = quotient 
    ret

/* Signed divide */
.globl _msdiv64
.p2align 2
_msdiv64:
    stp x29, x30, [sp, #-16]!
    str x20,      [sp, #-16]!   // x20 stores result sign bit
    
    cmp x0, xzr                 // compare dividend to zero
    cneg x0, x0, lt             // complement dividend if negative to 2's complement (i.e. invert all digits & add 1)
    cset x20, lt                // if dividend negative, set result's sign bit

    cmp x1, xzr                 // compare divisor to zero
    cneg x1, x1, lt             // if divisor negative, take 2's complement (i.e. invert all digits & add 1)
    eor x9, x20, #1             // set x9 to complement of sign bit
    csel x20, x9, x20, lt       // take sign bit complement if divisor negative
    /* perform unsiged division with relative magnitudes of divisor and dividend */     
    bl _mudiv64              
    cmp x20, #1                 // if sign bit was set, complement quotient & remainder
    cneg x0, x0, eq
    cneg x1, x1, eq 

msdiv64_end:
    ldr x20,      [sp], #16
    ldp x29, x30, [sp], #16
    ret


/* Testing */
.equ div_test, 1

.ifdef div_test

.include "../utils/macro_defs.s"
.data
udiv64_str: .asciz  "udiv64(%d, %d) = (%d, %d)\n"
sdiv64_str: .asciz  "sdiv64(%d, %d) = (%d, %d)\n"

.equ dividend,  0xface
.equ divisor,   -0xcab

.text
.globl _main
.p2align 2
_main:
    stp x29, x30, [sp, #-16]!

    mov x0, #dividend
    mov x1, #divisor
    stp x0, x1, [sp, #-32]!
    bl _msdiv64
    stp x0, x1, [sp, #16]
    LOAD_ADDR , sdiv64_str
    bl _printf
    add sp, sp, #32

main_end:
    mov x0, xzr
    ldp x29, x30, [sp], #16
    ret

.endif
