
/* This code shows a trick to compare a register to multiple positive values 
 * between 0 and 63, by doing a single comparison on a register 
*/

.include "../utils/macro_defs.s"

.data 
int_arr:    .word   3, 6, 9, 12, 15, 33, 63, -1 // terminator

str0:       .asciz  "Enter a number\n"
str1:       .asciz  "Number %d is in the list\n"
str2:       .asciz  "Number %d in NOT in the list\n"
str3:       .asciz  "%d"

.text
.p2align 2
_gen_comp_reg: /* Generates comparison register in x27, can be done statically */
    LOAD_ADDR x5, int_arr   // x5 = &int_arr
    mov x3, #1              // x3 = 1
    mov x27, xzr             // initialize comparison register x27
loop1:
    ldrsw x1, [x5], #4      // x1 = *(int_arr += 4)
    tbnz x1, #63, loop1_end // as soon as we find a negative integer, terminate loop
    lsl x2, x3, x1          // x2 = 1 << x1 
    orr x27, x27, x2          // set (x1)th bit of x27 to 1
    b loop1 
loop1_end:
    ret 

.p2align 2 
_compare_reg:   /* compares input register x0 with values in int_arr */    
    mov x3, #1              // x3 = 1 
    lsl x6, x3, x0          // set (x0)th bit of x6 to 1 
    tst x6, x27         
    csel x0, x3, xzr, ne    // if (x6 & x27) != 0, return true, else return false
    ret 

.globl _main 
.p2align 2 
_main:
    stp x29, x30, [sp, #-16]!
    str x27,      [sp, #-16]!
    // Generate comparison register (statically) in x27
    bl _gen_comp_reg
    // Start querying user for numbers, storing user input on sp 
    sub sp, sp, #16
loop2:
    LOAD_ADDR x0, str0 
    bl _printf
    LOAD_ADDR x0, str3 
    mov x1, sp          // &(user_input) = sp
//! _scanf needs its arguments on the stack
    str x1, [sp, #-16]! 
    bl _scanf 
    add sp, sp, #16
//! _scanf needs its arguments on the stack
    ldrsw x0, [sp]      // x0 = user_input 
    bl _compare_reg
    tst x0, #1          
    LOAD_ADDR x1, str1  // + result 
    LOAD_ADDR x2, str2  // - result 
    csel x0, x1, x2, ne // if (x0 & 1) != 0, x0 = x1, else x0 = x2 
    bl _printf 
    b loop2 
loop2_end:
    add sp, sp, #16
    ldr x27,      [sp], #16
    ldp x29, x30, [sp], #16
    ret 
