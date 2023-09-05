
.include "../utils/macro_defs.s"

.text
/* float multiplications */
.equ f_mant, 0
.equ f_exp,  52
.equ f_sign, 63
.equ f_size, 64 

/* 64-bit float multiplication:
 * takes multiplicands in x0, x1
 * returns product in x0 
 */
.globl _mfmul64
.p2align 2
_mfmul64:
    /* extract sign bits (1 bit) */
    lsr x10, x0, #(f_sign)
    lsr x11, x1, #(f_sign)
    /* extract exponent values (12 bits) */
    ubfx x12, x0, #(f_exp), #(f_sign - f_exp)
    ubfx x13, x1, #(f_exp), #(f_sign - f_exp)
    /* clear sign and exponent sections of mantissa */
    bfi x0, xzr, #(f_exp), #(f_size - f_exp)
    bfi x1, xzr, #(f_exp), #(f_size - f_exp)
    /* insert leading 1's */
    mov x2, #1
    lsl x2, x2, #(f_exp)
    orr x0, x0, x2 
    orr x1, x1, x2
    /* reduce mantissa length by a factor of two */
    lsr x0, x0, #(f_exp / 2)
    lsr x1, x1, #(f_exp / 2)
    /* multiply reduced-length mantissas */
    mul x0, x0, x1 
    /* ensure we have (f_size - f_exp - 1) leading zeroes (leading 1 overwritten) */ 
    clz x1, x0 
    sub x1, x1, #(f_size - f_exp - 1)
    lsl x0, x0, x1 
    /* Add exponents and insert resulting exponent */
    add x12, x12, x13 
    mov x4, #1                          // subtract 1023 exponent offset
    lsl x4, x4, #(f_sign - f_exp - 1)
    sub x4, x4, #1 
    sub x12, x12, x4 
    bfi x0, x12, #(f_exp), #(f_sign - f_exp) // insert resulting exponent
    /* Compute and insert resulting sign bit */
    eor x10, x10, x11 
    bfi x0, x10, #(f_sign), #(f_size - f_sign)
    ret

.equ mul_test, 1
.ifdef mul_test
.data 
mfmul64_str:    .asciz  "mfmul64(%f, %f) = result %f, m_result %f\n"
mant_dbg:       .asciz  "mantissa; %lx\n"

f0:     .double     1.4141
f1:     .double     -1.4141

.text 
.p2align 2
_mfmul64_test:
    stp x29, x30, [sp, #-16]!
    LOAD_ADDR x0, f0 
    LOAD_ADDR x1, f1 
    ldr d0, [x0]
    ldr d1, [x1]
    fmul d2, d0, d1 
    stp d0, d1, [sp, #-32]!
    str d2, [sp, #16]

    /* MOVE to integer registers before performing float operations */
    fmov x0, d0
    fmov x1, d1
    bl _mfmul64
    str x0, [sp, #24]
    LOAD_ADDR x0, mfmul64_str
    bl _printf
    add sp, sp, #32
    ldp x29, x30, [sp], #16
    ret

.globl _main 
.p2align 2 
_main:
    stp x29, x30, [sp, #-16]!
    bl _mfmul64_test
    mov x0, xzr 
    ldp x29, x30, [sp], #16
    ret

.endif
