
.include "../utils/macro_defs.s"

.data 
arr_str:    .asciz  "str_double_array[%d][%d]"
all_str:    .asciz  "Allocated %s\n"
fr_str:     .asciz  "Freeing %s\n"
x_size:     .word   4
y_size:     .word   4
str_len:    .word   32 

.text 
.globl _main 
.p2align 2
_main:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!

    LOAD_ADDR x19, x_size       // x19 = &x_size 
    LOAD_ADDR x22, y_size       // x22 = &y_size    
    LOAD_ADDR x25, str_len      // x25 = &str_len 
    ldr w19, [x19]              // w19 = x_size   
    ldr w22, [x22]              // w22 = y_size 
    ldr w25, [x25]              // w25 = str_len 

    mov w1, #8
    smull x0, w19, w1           // malloc(x_size * sizeof (char **))
    MWRP _malloc, mdbg0, mdbg1  // malloc(x_size * sizeof (char **))
    mov x20, x0                 // x20 = str_double_array

    mov w21, wzr                // w21 = i
loop1:
    cmp w21, w19 
    bge loop1_end
    mov w1, #8
    smull x0, w22, w1        
    MWRP _malloc, mdbg0, mdbg1  
    str x0, [x20, w21, sxtw #3] // str_double_array[i] = malloc(y_size * sizeof (char *))
    mov x24, x0                 // x24 = str_double_array[i]

    mov w23, wzr                // w23 = j 
loop2:
    cmp w23, w22 
    bge loop2_end 
    mov w1, #1
    smull x0, w25, w1
    MWRP _malloc, mdbg0, mdbg1  
    str x0, [x24, w23, sxtw #3]     // str_double_array[i][j] = malloc(str_len * sizeof(char))
    sxtw x1, w25
    LOAD_ADDR x2, arr_str
    sxtw x3, w21 
    sxtw x4, w23 
    stp x3, x4, [sp, #-16]!         // snprintf(str_double_array[i][j], str_len, "str_double_array[%d][%d]", i, j)
    bl _snprintf 
    add sp, sp, #16
    LOAD_ADDR x0, all_str
    ldr x1, [x24, w23, sxtw #3] 
    str x1, [sp, #-16]!             // printf("Allocated %s\n", str_double_array[i][j]);
    bl _printf 
    add sp, sp, #16
    add w23, w23, #1            // j++
    b loop2 
loop2_end:

    add w21, w21, #1            // i++
    b loop1 
loop1_end:

    mov w21, wzr                // w21 = i
loop3:
    cmp w21, w19 
    bge loop3_end 
    ldr x24, [x20, w21, sxtw #3]    // x24 = str_double_array[i]

    mov w23, wzr                    // w23 = j
loop4:
    cmp w23, w22 
    bge loop4_end 
    ldr x26, [x24, w23, sxtw #3]    // x26 = str_double_array[i][j]
    LOAD_ADDR x0, fr_str
    str x26, [sp, #-16]!            // printf("Freeing %s\n", str_double_array[i][j])
    bl _printf                      
    add sp, sp, #16
    mov x0, x26
    MWRP _free, fdbg0, fdbg1        // free (str_double_array[i][j])
    add w23, w23, #1            // j++
    b loop4 
loop4_end:

    mov x0, x24 
    MWRP _free, fdbg0, fdbg1        // free (str_double_array[i])
    add w21, w21, #1            // i++ 
    b loop3
loop3_end:

    mov x0, x20                     // free (str_double_array)
    MWRP _free, fdbg0, fdbg1 

    mov x0, xzr 
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

