
/* load memory address of symbol s into register r */
.macro LOAD_ADDR r=x0, s
    adrp \r, \s@PAGE       ; load symbol's page address into register r
    add \r, \r, \s@PAGEOFF ; add symbol's page offset
.endm

/* load memory address of symbol s into register r */
.macro LOAD_ADDR_GOT r=x0, s
    adrp \r, \s@GOTPAGE       ; load symbol's page address into register r
    add \r, \r, \s@GOTPAGEOFF ; add symbol's page offset
.endm

/* load memory content of symbol s into register r */
.macro LOAD_CONT r=x0, s
    adrp \r, \s@PAGE         ; load symbol's page address into register r
    ldr \r, [\r, \s@PAGEOFF] ; add symbol's page offset and load content into register
.endm

/* load memory content of symbol s into register r */
.macro LOAD_CONT_GOT r=x0, s
    adrp \r, \s@GOTPAGE         ; load symbol's page address into register r
    ldr \r, [\r, \s@GOTPAGEOFF] ; add symbol's page offset and load content into register
.endm

/*** print current sp ***/

.data 
sp_str: .asciz  "Current sp; %llx\n"
.macro PRINT_CURRENT_SP
    mov x0, sp
    str x0, [sp, #-16]!
    LOAD_ADDR , sp_str
    bl _printf
    add sp, sp, #16
.endm

/*** get/print current pc ***/

.data
pc_str: .asciz  "Current pc; %llx\n"

.text
.globl _get_current_pc
.p2align 2
_get_current_pc: /* returns pc value, in x0 */
    sub x0, x30, #4  // x0 = x30 - 4 (x30 set to caller's instruction)
    ret

.globl _print_current_pc
.p2align 2
_print_current_pc:
    stp x29, x30, [sp, #-16]! // x29, x30 must be stored because we have function calls!
    sub x0, x30, #4         // x0 = x30 - 4 (x30 set to caller's instruction)
    
    str x0, [sp, #-16]! // print out previous instruction's program counter
    LOAD_ADDR , pc_str
    bl _printf
    add sp, sp, #16     

    ldp x29, x30, [sp], #16
    ret 

/* macro definition for simplicity */
.macro PRINT_CURRENT_PC
    bl _print_current_pc
.endm

/*** store & verify stack guard ***/

.macro STORE_STACK_GUARD lreg, r=x8
    LOAD_CONT_GOT \r, ___stack_chk_guard
    ldr \r, [\r]
    str \r, [\lreg]
.endm

.data
stck_fail_msg:  .asciz  "Stack guard check failed\n"  
    .macro CHECK_STACK_GUARD lreg, r=x8, c=x9
    ldr \c, [\lreg]
    LOAD_CONT_GOT \r, ___stack_chk_guard
    ldr \r, [\r]
    cmp \r, \c
    bne stack_fail
    b stack_success
stack_fail: 
    LOAD_ADDR , stck_fail_msg
    bl _printf 
    bl ___stack_chk_fail
stack_success:
    .endm

.data 
mdbg0:    .asciz  "\ncalling malloc() with %llx\n"
mdbg1:    .asciz  "\nmalloc() returned %llx"
fdbg0:    .asciz  "\ncalling free() with %llx\n"
fdbg1:    .asciz  "\nfree() returned\n"

// assume x0 already loaded for malloc call
.macro MWRAPPER f, s0, s1 
.ifdef MDBG
    str x0, [sp, #-16]!
    LOAD_ADDR x0, \s0
    bl _printf
    ldr x0, [sp]
.endif
    bl \f
.ifdef MDBG
    str x0, [sp]
    LOAD_ADDR x0, \s1
    bl _printf
    ldr x0, [sp] // restore x0 to return value
    add sp, sp, #16
.endif
.endm

.macro RWRAPPER s
.ifdef RDBG
    str x0, [sp, #-16]!
    LOAD_ADDR x0, \s
    bl _printf
    ldr x0, [sp] // restore x0 value
    add sp, sp, #16
.endif
.endm

.macro FPRINTF_STR fpr, s
    mov x0, \fpr          
    LOAD_ADDR x1, \s
    bl _fprintf      
.endm
