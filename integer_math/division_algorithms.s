
.include "../utils/macro_defs.s"

// .equ RDBG, 1

/* Unsigned 64-bit division: 
 * takes dividend in x0 and divisor in x1
 * returns quotient in x0 and remainder in x1 
 */
.text
.globl _mudiv64
.p2align 2
_mudiv64:   // no function calls, hence no need to store x29, x30 registers...
    cbz x0, mudiv64_zero_ret    // return zero if zero divisor or dividend
    cbz x1, mudiv64_zero_ret           
    b mudiv64_start
mudiv64_zero_ret:
    mov x0, xzr
    ret
mudiv64_start:
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

/* Constant division macro 
 * takes dividend in x0
 * returns quotient in x0 and remainder in x1  
 */
.macro CONST_DIV d, m, n
    mov x1, #\d                 // x1 = constant divisor; x2 = m
    ldr x2, =\m
    smull x3, w0, w2            // x3 = m * dividend
    asr x3, x3, #\n             // x3 >> n -> resulting quotient
    mul x4, x3, x1              // x4 = quotient * divisor
    sub x1, x0, x4              // x1 (remainder) = dividend - quotient * divisor
    mov x0, x3                  // x0 = quotient
.endm

/* Divides by constant 193, 
 * takes dividend in x0
 * returns quotient in x0 and remainder in x1  
 * n = 38; m = 0x54e42524   
 */
.p2align 2
_div193:                        
    CONST_DIV 193, 0x54e42524, 38
    ret

/* Division by constant 10, 32 bits of precision
 * takes dividend in x0
 * returns quotient in x0 and remainder in x1
 *  n = 34; m = 0x 6666 6667
 */    
.p2align 2
_div10:
    CONST_DIV 10, 0x66666667, 34
    ret

/* Testing */
// .equ div_test, 1

/* Float divisions */
.equ f_mant, 0
.equ f_exp,  52
.equ f_sign, 63
.equ f_size, 64

.equ l_prec, 8
.equ r_prec, 16

/* Floating-point 64-bit division: 
 * takes dividend in x0 and divisor in x1
 * returns quotient in x0
 */
.globl _mfdiv64
.p2align 2
_mfdiv64:
    stp x29, x30, [sp, #-16]!

    /* extract sign bits;  w22 = sign(x0), w23 = sign(x1) */
    ubfx x22, x0, #(f_sign), #(f_size - f_sign)     
    ubfx x23, x1, #(f_sign), #(f_size - f_sign)    
    /* extract exponent bits; w24 = exp(x0), w25 = exp(x1) */
    ubfx x24, x0, #(f_exp), #(f_sign - f_exp)
    ubfx x25, x1, #(f_exp), #(f_sign - f_exp)
    /* clear bits to zero until mantissa */
    bfi x0, xzr, #(f_exp), #(f_size - f_exp)
    bfi x1, xzr, #(f_exp), #(f_size - f_exp)
    /* insert leading 1's */
    mov x2, #1
    lsl x2, x2, #(f_exp)    
    orr x0, x0, x2
    orr x1, x1, x2
    /* shift dividend left & divisor right to increment level of precision  */
    lsl x0, x0, #(l_prec)
    lsr x1, x1, #(r_prec)
    /* perform unsigned integer division on mantissa values; x0 = quotient */
    bl _mudiv64
    /* count the leading zeroes in the quotient */
    clz x2, x0
    /* Shift left until we have (f_size - f_exp - 1) leading zeroes */
    sub x2, x2, #(f_size - f_exp - 1)
    lsl x0, x0, x2
    /* Subtract the exponents and add the exponent's offset */
    sub x3, x24, x25
    mov x4, #1                              // add 1023 offset 
    lsl x4, x4, #(f_sign - f_exp - 1)
    sub x4, x4, #1
    add x3, x3, x4  
    bfi x0, x3, #(f_exp), #(f_sign - f_exp) // insert resulting exponent bit
    /* Complement the sign bits to compute the resulting sign */
    eor x4, x22, x23
    bfi x0, x4, #(f_sign), #(f_size - f_sign) // insert resulting sign bit

    ldp x29, x30, [sp], #16
    ret


// .equ div_test, 1
.ifdef div_test

.data
udiv64_str: .asciz  "udiv64(%d, %d) = (%d, %d)\n"
sdiv64_str: .asciz  "sdiv64(%d, %d) = (%d, %d)\n"
div193_str: .asciz  "div193(%d, %d) = (%d, %d)\n"
rdbg_str:   .asciz  "reg = %lx\n"
mfdiv64_str:    .asciz  "mfdiv64(%f, %f) = result %f; m_result %f\n"

f0:     .double  1545.6965753345676666234567
f1:     .double  -1345678.4141413345678333345678

.equ dividend,  0xface
.equ divisor,   -0xcab

.text

.p2align 2
_intdiv_test:
    stp x29, x30, [sp, #-16]!

    mov x0, #dividend
    mov x1, #divisor
    stp x0, x1, [sp, #-32]!
    bl _msdiv64
    stp x0, x1, [sp, #16]
    LOAD_ADDR , sdiv64_str
    bl _printf
    add sp, sp, #32

    ldp x29, x30, [sp], #16
    ret

.p2align 2
_float_div_test:
    stp x29, x30, [sp, #-16]!

    LOAD_ADDR x0, f0
    LOAD_ADDR x1, f1
    ldr d0, [x0]
    ldr d1, [x1]
    fdiv d2, d0, d1
    stp d0, d1, [sp, #-32]!
    str d2, [sp, #16]
    /* !!! MOVE to integer registers before performing float operations !!! */
    fmov x0, d0
    fmov x1, d1
    bl _mfdiv64
/* If 32 bits; must first
    fmov s0, w0
    fcvt d0, s0
   so that we can pass properly formatted 64-bit value to _printf on stack:
    str d0, [sp, #24]
*/
    str x0, [sp, #24]
    LOAD_ADDR , mfdiv64_str
    bl _printf
    add sp, sp, #32

    ldp x29, x30, [sp], #16
    ret

.globl _main
.p2align 2
_main:
    stp x29, x30, [sp, #-16]!

    bl _intdiv_test
    bl _float_div_test

main_end:
    mov x0, xzr
    ldp x29, x30, [sp], #16
    ret

.endif
