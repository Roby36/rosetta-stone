
.include "../../utils/macro_defs.s"
.equ MDBG, 1

.data 
/* Use .equ defintions instead of static constants
   to avoid memory accesses */ 
.equ numColumns,    3
.equ numRows,       2 
.equ termState_x,   2
.equ termState_y,   1
.equ NORTH,         0
.equ EAST,          1 
.equ SOUTH,         2
.equ WEST,          3
.equ STILL,         4
.equ NUMACTIONS,    5

// static const double 
desired:    .double     0.9
left:       .double     0.05
right:      .double     0.05
discount:   .double     0.9
ivalues:    .double     0.0, 0.0, 0.0, 0.0, 0.0, 0.0
R:          .double     -0.1, -0.1, -0.05, -0.1, -0.1, 1.0

// strings 
str1:   .asciz  "\t%f"
str2:   .asciz  "\n\n"
str3:   .asciz  "State_equal returned %d\n"
str4:   .asciz  "State_is_inside returned %d\n"
str5:   .asciz  "T returned %f\n"
str6:   .asciz  "Iteration terminated\n"
str7:   .asciz  "Round %d:\n"

// struct State 
.equ s_x, 0
.equ s_y, 4
.equ s_size, 8

.text 
.globl _allocate_matrix
.p2align 2
_allocate_matrix: // double ** allocate_matrix(double m[numRows][numColumns])
    stp x29, x30, [sp, #-16]!
    stp x20, x21, [sp, #-16]!
    stp x22, x23, [sp, #-16]!
    stp x24, x25, [sp, #-16]!
    mov x20, x0                 // x20 = m 
    mov w21, #numRows           // w21 = numRows 
    mov w22, #numColumns        // w22 = numColumns 
    // double ** res = (double **) malloc (sizeof(double *) * sizeof(numRows))
    add x0, xzr, x21, lsl #3    // x0 = 0 + (numRows << 3)
    MWRP _malloc, mdbg0, mdbg1 
    mov x24, x0                 // x24 = res 
    mov w23, wzr                // w23 = row 
loop1: 
    cmp w23, w21
    bhs loop1_end
    // res[row] = (double *) malloc (sizeof(double) * sizeof(numColumns));
    add x0, xzr, x22, lsl #3
    MWRP _malloc, mdbg0, mdbg1 
    str x0, [x24, w23, sxtw #3] // res + (sxtw(row) << 3)
    mov x6, x0                  // x6 = res[row]
    mov w5, wzr                 // w5 = col 
loop2:
    cmp w5, w22 
    bhs loop2_end 
    smaddl x0, w23, w22, x5     // x0 = row * numColumns + col
    ldr x0, [x20, x0, lsl #3]   // x0 = m[row][col]
    str x0, [x6, w5, sxtw #3]   // res[row][col] = m[row][col]
    add w5, w5, #1              // col++
    b loop2
loop2_end:
    add w23, w23, #1            // row++
    b loop1
loop1_end:
    mov x0, x24                 // return res 
    ldp x24, x25, [sp], #16
    ldp x22, x23, [sp], #16
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret 

.globl _update_matrix
.p2align 2
_update_matrix: // update_matrix(double ** res, double m[numRows][numColumns])
    stp x29, x30, [sp, #-16]!
    mov w2, wzr                 // w2 = row 
    mov w3, wzr                 // w3 = col 
    mov w4, #numColumns         // w4 = numColumns 
    mov w5, #numRows            // w5 = numRows
loop9:  // Turning into a post-condition loop
    madd w6, w2, w4, w3         // w6 = (row * numColumns) + col 
    ldr d1, [x1, w6, sxtw #3]   // d1 = m[row][col]
    ldr x8, [x0, w2, sxtw #3]   // x8 = res[row]    (double *)
    str d1, [x8, w3, sxtw #3]   // res[row][col] = d1 

    add w3, w3, #1              // col++ 
    cmp w3, #numColumns
    csel w3, wzr, w3, eq 
    cinc w2, w2, eq             // if col == numColumns, col = 0 and row++
    cmp w2, #numRows
    blo loop9                   // if row < numRows, repeat loop 
loop9_end:
    ldp x29, x30, [sp], #16
    ret

.globl _free_matrix
.p2align 2
_free_matrix:
    stp x29, x30, [sp, #-16]!
    stp x20, x21, [sp, #-16]!
    stp x22, x23, [sp, #-16]!
    mov x20, x0                 // x20 = res 
    mov w21, #numRows           // w21 = numRows 
    mov w22, wzr                // w22 = row 
loop5:
    cmp w22, w21 
    bhs loop5_end
    ldr x0, [x20, w22, sxtw #3] // x0 = res[row]
    MWRP _free, fdbg0, fdbg1 
    add w22, w22, #1            // row++
    b loop5
loop5_end:
    mov x0, x20 
    MWRP _free, fdbg0, fdbg1 
    ldp x22, x23, [sp], #16
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.globl _printArray 
.p2align 2
_printArray:
    stp x29, x30, [sp, #-16]!
    stp x20, x21, [sp, #-16]!
    stp x22, x23, [sp, #-16]!
    stp x24, x25, [sp, #-16]!
    stp x26, x27, [sp, #-16]!

    LOAD_ADDR x26, str1
    LOAD_ADDR x27, str2
    mov x20, x0                 // x20 = values 
    mov w21, #numRows           // w21 = numRows 
    mov w22, #numColumns        // w22 = numColumns 
    mov w23, wzr                // w23 = y 
loop3:
    cmp w23, w21 
    bhs loop3_end
    mov w24, wzr                // w24 = x 
loop4:
    cmp w24, w22 
    bhs loop4_end 
    ldr x0, [x20, w23, sxtw #3] // x0 = values[y]
    ldr x0, [x0,  w24, sxtw #3] // x0 = values[y][x]
    str x0, [sp, #-16]!
    mov x0, x26 
    bl _printf                  // printf("\t%f", values[y][x]);
    add sp, sp, #16
    add w24, w24, #1            // x++
    b loop4 
loop4_end:
    mov x0, x27 
    bl _printf                  // printf("\n\n");
    add w23, w23, #1            // y++
    b loop3
loop3_end:
    ldp x26, x27, [sp], #16
    ldp x24, x25, [sp], #16
    ldp x22, x23, [sp], #16
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret 

.globl _State_equal
.p2align 2
_State_equal:   // bool State_equal(const State_t * s1, const State_t * s2)
    mov x2, x0  // x2 = s1, x1 = s2
    mov w0, wzr 
    cbz x2, State_equal_end
    cbz x1, State_equal_end
    ldr x3, [x1]    // x3 = s2->x|s2->y
    ldr x4, [x2]    // x4 = s1->x|s1->y 
    cmp x3, x4 
    cset x0, eq     // return ((s1->x == s2->x) && (s1->y == s2->y))
State_equal_end:
    ret

.globl _State_is_inside
.p2align 2
_State_is_inside:
    mov x1, x0                          // x1 = s
    mov w0, wzr 
    cbz x1, State_is_inside_end
    ldp w2, w3, [x1]                    // w2 = s->x, w3 = s->y
    tbnz w2, #31, State_is_inside_end   // s->x < 0
    tbnz w3, #31, State_is_inside_end   // s->y < 0
    mov w4, #numRows                    // w4 = numRows 
    cmp w3, w4 
    bhs State_is_inside_end
    mov w5, #numColumns                 // w5 = numColumns 
    cmp w2, w5 
    bhs State_is_inside_end
    mov w0, #1                          // return true 
State_is_inside_end:
    ret 

.globl _T
.p2align 2
.equ N_bit_pos, 0
.equ S_bit_pos, 1
.equ E_bit_pos, 2
.equ W_bit_pos, 3
.macro COMP_A s, pos
    // Use register w25 to hold bits N,S,E,W 
    mov w1, #\s
    cmp w21, w1             // cmp a, NORTH/SOUTH/EAST/WEST    
    cset w1, eq
    bfi w25, w1, #\pos, #1
.endm
.macro CONSTR_STATE p1, p2, p3, p4, op5
    // Extract N,S,E,W  bits from w25 to generate new states
    ubfx w2, w25, #\p1, #1
    ubfx w3, w25, #\p2, #1
    sub w4, w2, w3
    add w4, w4, w23 
    ubfx w2, w25, #\p3, #1
    ubfx w3, w25, #\p4, #1
    sub w1, w2, w3
    add w1, w1, w24 
//! State_new stack inline 
    stp w4, w1, [sp, #-16]!     // Push state on stack and save pointer
    mov \op5, sp
.endm
.macro CHECK_SUP sreg, dreg, supreg 
    mov x0, \sreg 
    bl _State_is_inside
    cmp w0, wzr 
    fcsel \supreg, \dreg, d11, eq 
.endm
.macro SET_RET_VAL sreg, dreg, supreg, l 
    mov x0, x22
    mov x1, \sreg
    bl _State_equal
    cbz w0, \l 
    fcmp \supreg, #0.0
    fcsel d15, \dreg, d11, eq 
    b endif1
.endm
_T: // double T( State_t * si, const int a, State_t * sf)
    stp x29, x30, [sp, #-16]!
    stp x20, x21, [sp, #-16]!
    stp x22, x23, [sp, #-16]!
    stp x24, x25, [sp, #-16]!
    stp x26, x27, [sp, #-16]!
    str x28, [sp, #-16]!
    stp d8, d9, [sp, #-16]!
    stp d10, d11, [sp, #-16]!
    stp d12, d13, [sp, #-16]!
    stp d14, d15, [sp, #-16]!

    mov x20, x0                 // x20 = si 
    mov w21, w1                 // w21 = a
    mov x22, x2                 // x22 = sf
    fmov d0, #0.0
    bl _State_is_inside
    cbz w0, T_end
    ldp w23, w24, [x20]         // w23 = si->x, w24 = si->y              
    mov w3, #termState_x        // w3 = termState_x, w4 = termState_y
    mov w4, #termState_y
    cmp w3, w23 
    ccmp w4, w24, #0b0000, eq   // if (w3 = w23), cmp w4, w24, else set Z = 0 (ne)
    beq T_end
                            
    COMP_A NORTH, N_bit_pos     // Use register w25 to hold bits N, S, E, W 
    COMP_A SOUTH, S_bit_pos
    COMP_A EAST,  E_bit_pos
    COMP_A WEST,  W_bit_pos

    CONSTR_STATE E_bit_pos, W_bit_pos, N_bit_pos, S_bit_pos, x26    // x26 = s_desired 
    CONSTR_STATE N_bit_pos, S_bit_pos, W_bit_pos, E_bit_pos, x27    // x27 = s_right 
    CONSTR_STATE S_bit_pos, N_bit_pos, E_bit_pos, W_bit_pos, x28    // x28 = s_left 

    LOAD_ADDR x1, desired
    ldr d8, [x1]                // d8 = desired
    LOAD_ADDR x1, right 
    ldr d9, [x1]                // d9 = right 
    LOAD_ADDR x1, left 
    ldr d10, [x1]               // d10 = left 
    fmov d11, #0.0              // d11 = dzr     
    CHECK_SUP x26, d8, d12      // d12 = sup_desired
    CHECK_SUP x27, d9, d13      // d13 = sup_right 
    CHECK_SUP x28, d10, d14     // d14 = sup_left 
   
    mov x0, x22 
    mov x1, x20 
    bl _State_equal             
    cbz w0, elseif1 
if1:    // if (State_equal(sf, si))
    mov w1, #STILL              // w1 = STILL 
    fmov d1, #1.0               // d1 = 1.0
    fadd d2, d12, d13 
    fadd d2, d2, d14            // d2 = sup_desired + sup_left + sup_right
    cmp w21, w1 
    fcsel d15, d1, d2, eq 
    b endif1 
elseif1:
    SET_RET_VAL x26, d8, d12, elseif2
elseif2:
    SET_RET_VAL x27, d9, d13, elseif3 
elseif3:
    SET_RET_VAL x28, d10, d14, else1
else1:
    fmov d15, d11 
endif1:
    // Pop s_desired, s_right, and s_left from the stack 
    add sp, sp, #(3*16)
    fmov d0, d15 

T_end:
    ldp d14, d15, [sp], #16
    ldp d12, d13, [sp], #16
    ldp d10, d11, [sp], #16
    ldp d8, d9, [sp], #16
    ldr x28, [sp], #16
    ldp x26, x27, [sp], #16
    ldp x24, x25, [sp], #16
    ldp x22, x23, [sp], #16
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.globl _update_values
.p2align 2
_update_values:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    stp x27, x28, [sp, #-16]!
    stp d8, d9, [sp, #-16]!
    stp d10, d11, [sp, #-16]!

    // Load static constants and save argument 
    mov x20, x0                 // x20 = values 
    mov w21, #numRows           // w21 = numRows 
    mov w22, #numColumns        // w22 = numColumns 
    LOAD_ADDR x1, discount
    ldr d10, [x1]               // d10 = discount 
    LOAD_ADDR x26, R            // x26 = &R
    mov w19, #NUMACTIONS        // w19 = NUMACTIONS

    // Make space on stack for next_values matrix 
    mul w0, w21, w22            // w0 = numRows * numColumns
    tst w0, #1               
    cinc w23, w0, ne            // increment if NOT divisible by 2, and save to w23 register
    sub sp, sp, w23, sxtw #3    // Push stack back to make space for next_values 
    mov x24, sp                 // x24 = &next_values 
    mov x29, sp                 // set frame pointer to stack pointer AFTER pushing next_values matrix 

    mov w5, wzr                 // w5 = xi
    mov w6, wzr                 // w6 = yi
    sub sp, sp, #16             // Push xi, yi, stored at (x29 - 16)
    .equ xi_fp_off, -16          // Keep track of xi's offset from frame pointer x29
loop6:  // Turning this into a POST-CONDITION CHECK LOOP
    stp w5, w6, [sp]
    mov x27, sp                 // x27 = si 

/* !!! ERROR: This leads to d8 = -nan!!!
    mvn x0, xzr    
    fmov d8, x0 
*/             
    fmov d8, #-10.0             // d8 = maximum 

    // Push a on stack 
    mov w8, wzr                 // w8 = a
    str w8, [sp, #-16]!         // Push a on stack at position x29 - 32
    .equ a_fp_off, -32           // Keep track of a's offset from frame pointer x29
loop7:
    cmp w8, w19 
    bhs loop7_end
    fmov d9, #0.0               // d9 = sum 

    mov w5, wzr                 // w5 = xt
    mov w6, wzr                 // w6 = yt  
    sub sp, sp, #16             // Push xt, yt on stack at position (x29 - 48)
    .equ xt_fp_off, -48          // Keep track of xt's offset from frame pointer x29
loop8:  // Turning this into a POST-CONDITION CHECK LOOP
    stp w5, w6, [sp]
    mov x25, sp                 // x25 = st

    ldp w5, w6, [x29, #xt_fp_off] // w5 = xt, w6 = yt
    ldr x4, [x20]               // x4 = *values           (double **)
    ldr x3, [x4, w6, sxtw #3]   // x3 = (*values)[yt]     (double *)
    ldr d2, [x3, w5, sxtw #3]   // d2 = (*values)[yt][xt] (double)
    madd w1, w22, w6, w5        // w1 = (numColumns * yt) + xt 
    ldr d3, [x26, w1, sxtw #3]  // d3 = R[yt][xt]
    fmadd d11, d10, d2, d3      // d11 = discount * ((*values)[yt][xt]) + R[yt][xt]
    mov x0, x27
    ldr w1, [x29, #a_fp_off]    // w1 = a
    mov x2, x25                 
    bl _T
    fmadd d9, d0, d11, d9       // sum = sum + (T(si, a, st) * (R[yt][xt] + discount * ((*values)[yt][xt])))

    ldp w5, w6, [x29, #xt_fp_off]
    add w6, w6, #1              // yt++
    cmp w6, w21    
    csel w6, wzr, w6, eq 
    cinc w5, w5, eq 
    stp w5, w6, [x29, #xt_fp_off]
    cmp w5, w22 
    blo loop8
loop8_end:
    add sp, sp, #16             // pop xt, yt (hence st) from the stack 
    fcmp d9, d8 
    fcsel d8, d9, d8, ge        // maximum = (sum > maximum) ? sum : maximum;
    ldr w8, [x29, #a_fp_off]
    add w8, w8, #1              // a++
    str w8, [x29, #a_fp_off]
    b loop7 
loop7_end:
    add sp, sp, #16             // pop a from stack 
    ldp w5, w6, [x29, #xi_fp_off]     // w5 = xi, w6 = yi 
    madd w1, w22, w6, w5 
    str d8, [x24, w1, sxtw #3]  // next_values[yi][xi] = maximum

    add w6, w6, #1              // yi++
    cmp w6, w21 
    csel w6, wzr, w6, eq        // if (yi == numRows), set yi = 0
    cinc w5, w5, eq             // if (yi == numRows), xi++
    stp w5, w6, [x29, #xi_fp_off]     // Store xi and yi back with updated values 
    cmp w5, w22 
    blo loop6                   // if (xi < numColumns), execute another loop iteration
loop6_end:
    add sp, sp, #16             // pop xi, yi (hence si) from the stack 
    ldr x0, [x20]               // x0 = *values (double **)

/* Avoid allocating & free'ing whole matrix at every iteration!
    bl _free_matrix
    mov x0, x24                 // allocate_matrix(next_values)
    bl _allocate_matrix     
    str x0, [x20]               // *values = allocate_matrix(next_values)
*/
    mov x1, x24
    bl _update_matrix           // update_matrix(*values, next_values)

    add sp, sp, w23, sxtw #3     // pop next_values from stack 

    ldp d10, d11, [sp], #16
    ldp d8, d9, [sp], #16
    ldp x27, x28, [sp], #16
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.globl _value_iteration 
.p2align 2 
_value_iteration:
    stp x29, x30, [sp, #-16]!
    stp x20, x21, [sp, #-16]!
    stp x22, x23, [sp, #-16]!

    mov x20, x0         // x20 = values 
    mov w21, w1         // w21 = totRounds 
    mov w22, w2         // w22 = round 
    mov w23, wzr        // w23 = r 
loop10: // pre-condition loop 
    cmp w23, w21 
    beq loop10_end

/* Do not print current result at each iteration
    LOAD_ADDR x0, str7 
    str x22, [sp, #-16]!
    bl _printf
    add sp, sp, #16
    ldr x0, [x20]       // x0 = *values 
    bl _printArray
*/

    mov x0, x20 
    bl _update_values 
    add w23, w23, #1    // r++  
    b loop10
loop10_end:
/* Print final array only after reaching base case */ 
    LOAD_ADDR x0, str7 
    str x23, [sp, #-16]!
    bl _printf
    add sp, sp, #16
    ldr x0, [x20]       // x0 = *values 
    bl _printArray
    LOAD_ADDR x0, str6
    bl _printf

/* Do not use recursion
    mov x0, x20 
    mov w1, w21 
    add w2, w22, #1
    bl _value_iteration 
*/

value_iteration_end:
    ldp x22, x23, [sp], #16
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret


// Test function (=Q1.2.s)
.p2align 2
.globl _value_iteration_test
_value_iteration_test: // void value_iteration_test(const int tot_rounds)
    stp x29, x30, [sp, #-16]!
    str w0, [sp, #-16]!         // save tot_rounds on the stack
    LOAD_ADDR x0, ivalues       // double ** values = allocate_matrix(ivalues);
    bl _allocate_matrix     
    str x0, [sp, #-16]!
    mov x0, sp                  // x0 = &values
    ldr w1, [sp, #16]           // w1 = tot_rounds
    mov w2, wzr                 // w2 = 0
    bl _value_iteration         // value_iteration(&values, tot_rounds, 0)
    ldr x0, [sp]                // x0 = *values_ptr 
    bl _free_matrix             // free_matrix(*values_ptr)
    add sp, sp, #16     
    add sp, sp, #16        
    ldp x29, x30, [sp], #16
    ret
