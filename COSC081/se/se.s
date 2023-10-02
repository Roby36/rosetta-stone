
.include "../../utils/macro_defs.s"

.equ CELLS, 4
.equ COMMANDS, 5

.data 

uSeq:                 .word   1, 1, 1, -1, -1
curr_probs:           .double 0.1, 0.1, 0.1, 0.1 
transition_probs_mat: .double 0.25, 0.5,  0.25, 0.0,    0.0,  0.25, 0.5,  0.25,     0.0,  0.0,  0.25, 0.75,     0.0,  0.0,  0.0,  1.0

str1:   .asciz  "State estimations for round %d: "
str2:   .asciz  "  %f"
str3:   .asciz  "\n"

.text 

.globl _uIND
.p2align 2 
_uIND:   // uIND(int x, int u)  ((u)*(x) + ((1 - (u))/2) * (CELLS - 1))
    stp x29, x30, [sp, #-16]!

    mul w2, w0, w1              // w2 = (u)*(x)
    mov w3, #(CELLS - 1)        // w3 = (CELLS - 1)
    mov w4, #1 
    mov w5, #2
    sub w4, w4, w1              // w4 = 1 - (u)
    sdiv w4, w4, w5             // w4 = ((1 - (u))/2)
    madd w0, w4, w3, w2         // w0 = ((1 - (u))/2) * (CELLS - 1) + (u)*(x)

    ldp x29, x30, [sp], #16
    ret

.globl _update_probs 
.p2align 2
_update_probs:  // void update_probs(double * curr_probs, int u)
    stp x29, x30, [sp, #-16]!
    stp x20, x21, [sp, #-16]!
    stp x22, x23, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    stp d11, d12, [sp, #-16]!
    stp d13, d14, [sp, #-16]!

    mov x20, x0                             // x20 = curr_probs 
    mov w21, w1                             // w21 = u
    LOAD_ADDR x25, transition_probs_mat     // x25 = transition_probs_mat

    mov x29, sp                             // save current stack pointer to frame pointer register 
    .equ updated_probs_off, -32
    add sp, sp, #updated_probs_off          // allocate space on stack for updated_probs 
    fmov d11, #0.0                          // d11 = sum 
    mov w22, wzr                            // w22 = x1 
loop1:  // turning into post-condition loop 
    fmov d12, #0.0                          // d12 = new_prob 
    mov w23, wzr                            // w23 = x0 
loop2:   // turning into post-condition loop 
    ldr d13, [x20, w23, sxtw #3]            // d13 = curr_probs[x0]
    mov w0, w23 
    mov w1, w21                             // uIND(x0, u)
    bl _uIND 
    mov w26, w0                             // w26 = UIND(x0, u)
    mov w0, w22 
    mov w1, w21                             // uIND(x1, u)
    bl _uIND 
    mov w1, #CELLS
    madd w2, w1, w26, w0                    // w2 = CELLS*(UIND(x0, u)) + uIND(x1, u)
    ldr d14, [x25, w2, sxtw #3]             // d14 = transition_probs_mat[UIND(x0, u)][UIND(x1, u)]
    fmadd d12, d13, d14, d12                // new_prob = curr_probs[x0] * transition_probs_mat[UIND(x0, u)][UIND(x1, u)] + new_prob

    add w23, w23, #1                        // x0++
    cmp w23, #CELLS
    blt loop2 
loop2_end:

    add x0, x29, #updated_probs_off         // x0 = &updated_probs
    str d12, [x0, w22, sxtw #3]             // updated_probs[x1] = new_prob
    fadd d11, d11, d12                      // sum = sum + new_prob

    add w22, w22, #1                        // x1++
    cmp w22, #CELLS
    blt loop1
loop1_end:
    sub sp, sp, #updated_probs_off          // pop updated_probs from stack 

    mov w22, wzr                            // w22 = i 
loop3:  // turning into a post-condition loop 
    ldr d1, [x0, w22, sxtw #3]              // d1 = updated_probs[i]
    fdiv d2, d1, d11                        // d2 = updated_probs[i] / sum 
    str d2, [x20, w22, sxtw #3]             // curr_probs[i] = d2 

    add w22, w22, #1                        // i++ 
    cmp w22, #CELLS 
    blt loop3 
loop3_end:

    ldp d13, d14, [sp], #16
    ldp d11, d12, [sp], #16
    ldp x25, x26, [sp], #16
    ldp x22, x23, [sp], #16
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.globl _execute_commands
.p2align 2 
_execute_commands:
    stp x29, x30, [sp, #-16]!
    stp x20, x21, [sp, #-16]!
    stp x22, x23, [sp, #-16]!
    stp x24, x25, [sp, #-16]!
    str x26, [sp, #-16]!

    LOAD_ADDR x21, str1
    LOAD_ADDR x22, str2 
    LOAD_ADDR x23, str3 
    LOAD_ADDR x24, curr_probs
    LOAD_ADDR x26, uSeq
    mov w20, wzr                // w20 = round 
loop4:
    mov x0, x21
    str x20, [sp, #-16]!        // printf("State estimations for round %d: ", round)
    bl _printf
    add sp, sp, #16
    mov w25, wzr                // w25 = i
loop5:  // turning into post-condition loop
    ldr d1, [x24, w25, sxtw #3] // d1 = curr_probs[i]
    str d1, [sp, #-16]!
    mov x0, x22                 // printf("  %f", curr_probs[i]);
    bl _printf 
    add sp, sp, #16
    add w25, w25, #1            // i++ 
    cmp w25, #CELLS 
    blt loop5
loop5_end:
    mov x0, x23 
    bl _printf 
    cmp x20, #COMMANDS 
    beq loop4_end
    mov x0, x24 
    lsl x2, x20, #2
    ldr x1, [x26, x2]           // x1 = uSeq[round]
    bl _update_probs            // update_probs(curr_probs, uSeq[round])
    add x20, x20, #1            // round++
    b loop4 
loop4_end:

    ldr x26, [sp], #16
    ldp x24, x25, [sp], #16
    ldp x22, x23, [sp], #16
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.globl _main 
.p2align 2
_main:
    stp x29, x30, [sp, #-16]!
    bl _execute_commands
    mov w0, wzr
    ldp x29, x30, [sp], #16
    ret 
