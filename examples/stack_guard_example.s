
.include "../utils/macro_defs.s"

.data
str1:   .asciz  "Stored stack guard\n"
str2:   .asciz  "Checked stack guard successfully\n"

.text
.globl _main
.p2align 2
_main:
    stp x29, x30, [sp, #-16]!
    sub sp, sp, #16       // make space for stack guard
    add x20, sp, #8       // x20 (non-volatile) points to the stack guard location (just before x29)
    STORE_STACK_GUARD x20 // write stack guard value at memory location pointed to by x20
    LOAD_ADDR , str1      // log stack guard storage
    bl _printf

    /** function body here: do not use x20 (points to stack guard location) **/
    
    // Stack guard detects writing at any location between [x20], [x20, #8]
    // str xzr, [x20, #-4]
    // Writing past [x20, #8] -> Stack guard bypassed 
    // --> segmentation fault as x29, x30 registers overwritten: 
    // str wzr, [x20, #8]
   
    CHECK_STACK_GUARD x20 // retrieve and verify stack guard value
    LOAD_ADDR , str2      // log successful stack guard check
    bl _printf
    add sp, sp, #16       // delete stack guard
    mov w0, #0            // return value
    ldp x29, x30, [sp], #16
    ret
