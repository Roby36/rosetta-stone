
.include "../utils/macro_defs.s"
// .equ MALLOC_FAIL_TEST, 0

.data
errstr: .asciz  "Error: malloc() failed\n"
.equ width,  100
.equ height, 100

/* Define pixel struct relative locations */
/* NOTE: characters need not be word-aligned! */
.equ p_red, 0
.equ p_green, 1 
.equ p_blue, 2  
.equ p_size, 3

.text
.globl _main
.p2align 2
_main:
    stp x29, x30, [sp, #-16]!
    mov x0, #(width * height * p_size)
    bl _malloc
    cmp x0, #0
    beq malloc_fail
    .ifndef MALLOC_FAIL_TEST
    b malloc_success
    .endif
malloc_fail:
    LOAD_CONT_GOT x0, ___stderrp // load the standard error pointer into x0
    ldr x0, [x0]                 // load the content stored at the pointer into x0
    LOAD_ADDR x1, errstr         // load output string address into x1 (second argument for fprintf)
    bl _fprintf
    mov w0, #1               // return 1
    b endfunc
malloc_success:
    /* "pixel *" is an array of pixels (i.e. pixel[width * height]) */
    /* hence, we need to initialize each byte from x0 to x0 + (width * height * p_size) to zero */
    mov w1, #(width * height * p_size) // comparison variable
    mov w2, #0  // i = 0 (iterating variable)
init_loop:
    add x3, x0, x2          // x3 = image + i
    strb wzr, [x3, p_red]   // image[i].red = 0
    strb wzr, [x3, p_green] // image[i].green = 0
    strb wzr, [x3, p_blue]  // image[i].blue = 0
    add w2, w2, #p_size     // i += 3 
    cmp w2, w1              // if i < (width * height * p_size), iterate again
    blt init_loop        // end of loop

    bl _free            // image pointer already stored in x0
    mov w0, #0
endfunc:
    ldp x29, x30, [sp], #16
    ret
    