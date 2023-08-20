
.data
fne:    .asciz  "Rob"
lne:    .asciz  "Brera"

.include "../utils/macro_defs.s"

.text
/* Define relative LOCATION of each struct field: 
    struct must be 16-bytes aligned, storing data in word-aligned locations */
.equ s_first_name, 0
.equ s_last_name, 30
.equ s_class, 60
.equ s_grade, 64 /* KEEP ALL TYPES WORD-ALIGNED, EXCEPT CHAR STRINGS */
.equ s_end,   68
.equ s_end_aligned, 80

s_str:  .asciz "\tfirst_name = %s\n\tlast_name = %s\n\tclass = %d\n\tgrade = %d\n"

.p2align 2
_print_struct:
    stp x29, x30, [sp, #-16]!
    /* when this subroutine is called, x19 holds the pointer to the struct */
    add x0, x19, #s_first_name // x0 points to struct first_name location
    add x1, x19, #s_last_name  // x1 points to struct last_name location
    stp x0, x1, [sp, #-32]!    // push on stack for printf (4 arguments * 8 bytes = 32)
    ldrb w0, [x19, #s_class]   // load class value into w0,
    str x0, [sp, #16]          // and store it on stack for printf
    ldr w0, [x19, #s_grade]    // load grade value into w0,
    str x0, [sp, #24]          // and store it on stack for printf
    LOAD_ADDR , s_str          
    bl _printf                 // load string address & call printf
    /* push stack back & return */
    add sp, sp, #32
    ldp x29, x30, [sp], #16
    ret

.globl _main
.p2align 2
_main:
    stp x29, x30, [sp, #-32]!
    str x19, [sp, #16] /* save previous NON-VOLATILE x19 value since x19 now used as pointer to new struct */
/* Allocate struct on stack: total bytes = 65, 16-bytes alignment of 80 */
    sub sp, sp, s_end_aligned
/* Save pointer to struct in x19 */
    mov x19, sp
/* Initialize struct fields */
    add x0, x19, #s_first_name
    LOAD_ADDR x1, fne
    bl _strcpy
    add x0, x19, #s_last_name // x1 = x19 + s_last_name
    LOAD_ADDR x1, lne
    bl _strcpy
    mov w0, #2
    strb w0, [x19, #s_class]
    mov w0, #8
    str w0, [x19, #s_grade]
/* Use struct ... */
    bl _print_struct
/* Delete struct (x19 pointer not valid anymore) */
    add sp, sp, s_end_aligned
/* Return */
    mov w0, #0
    ldr x19, [sp, #16] /* restore previous x19 value (NON-VOLATILE) */
    ldp x29, x30, [sp], #32
    ret
