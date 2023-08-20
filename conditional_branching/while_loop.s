
; Standard assembler directives
.section    __TEXT,__text,regular,pure_instructions
.build_version macos, 13, 0 sdk_version 13, 3
.globl _main
.p2align    2

; Define main function
_main:
    .cfi_startproc
    ; process start (setting up stack, making space for all variables)
    sub sp, sp, #48          
    .cfi_def_cfa_offset 48   
    stp x29, x30, [sp, #32] 
    add x29, sp, #32      
    ; other assembler directives
    .cfi_def_cfa w29, 16
    .cfi_offset w30, -8     ; address in w30 register 8 bytes before sp
    .cfi_offset w29, -16    ; address in w29 register 16 bytes before sp

    ; initialize exit code
    str wzr, [x29, #-4]

    ; AIM: We want to execute the following C-code (inside main)
    ;   int32_t a = 10;
    ;   int32_t b = 5;
    ;   int32_t c = 2;
    ;   while (a > 0) {
    ;       printf("a = %d\n", a);
    ;       if (a > b) {
    ;           printf("a is greater than b\n");
    ;       } else if (a > c) {
    ;           printf("a is greater than c\n");
    ;       }
    ;       a--;
    ;   }

    ; store all the variables at cleanly mapped places in memory
    mov w2, #10       
    str w2, [sp, #16] ; a stored at [sp, #16]
    mov w2, #5 
    str w2, [sp, #12] ; b stored at [sp, #12]
    mov w2, #2
    str w2, [sp, #8]  ; c stored at [sp, #8]
    ; branch to the while-loop test condition
    b LBB0_TESTCOND

LBB0_TESTCOND:  ; test condition and determine whether to exit process  
    ldr w2, [sp, #16]; LOAD a back from memory
    cmp w2, #0       ; set flags
    cset w3, gt      ; w3 <- 1 if w2 > 0, else w3 <- 0
    cbnz w3, LBB0_1  ; branch to LBB0_1 (while-loop body) if w3 not zero 
    b LBB0_EXIT      ; otherwise branch unconditionally to process exit

LBB0_1:     ; while-loop body
    ;   printf("a = %d\n", a)
    ldr w2, [sp, #16]; LOAD a back from memory!
    str x2, [sp]     ; store a's value in the stack pointer address (first value used by printf)
    adrp	x0, l_.str@PAGE		; NOTE: l_.str label defined in literal pool
    add	x0, x0, l_.str@PAGEOFF
	bl	_printf     ; call printf
   
    ;   if (a > b) printf("a is greater than b\n");
    ldr w2, [sp, #16] ; load a back from memory
    ldr w3, [sp, #12] ; load b back from memory
    mov w13, #98
    str x13, [sp] ; load sp with b ascii code
    cmp w2, w3    ; a > b
    cset w5, gt   ; w5 <- 1 if a > b
    str w5, [sp, #4]  ; save comparison outcome to memory
    cbnz w5, LBB0_PRINT_B_OR_C ; proceed printing b if possible

    ; else if (a > c) printf("a is greater than c\n");
    ldr w2, [sp, #16] ; load a back from memory
    ldr w4, [sp, #8]  ; load c back from memory
    ldr w5, [sp, #4]  ; load outcome from previous comparison
    mov w13, #99
    str x13, [sp] ; load sp with c ascii code
    cmp w2, w4    ; a > c 
    cset w6, gt   ; w6 <- 1 if a > c
        ; in order to print c, we want w5 = 0, and w6 = 1
    mov w7, #1    ; initialize w7 to 1
    cmp w5, #0 
    csel w7, w7, wzr, eq ; if w5 = 0, w7 = 1, else w7 = 0
    cmp w6, #1
    csel w7, w7, wzr, eq ; if w6 = 1, w7 = 1, else w7 = 0
    cbnz w7, LBB0_PRINT_B_OR_C ; proceed printing c if possible
    b LBB0_WHILE_CONT ; branch to rest of while-loop

LBB0_PRINT_B_OR_C:
    adrp	x0, l1_.str@PAGE		
    add	x0, x0, l1_.str@PAGEOFF
	bl	_printf     ; call printf
    b LBB0_WHILE_CONT ; branch to rest of while-loop

LBB0_WHILE_CONT: ; rest of while-loop
    ; a--;
    ldr w2, [sp, #16] ; load a back from memory
    sub w2, w2, #1  ; w2 = w2 - 1 (decrement a)
    str w2, [sp, #16]; STORE a back to memory
    b LBB0_TESTCOND ; branch again to test condition

LBB0_EXIT:     ; process exit (cleaning up stack)
    ldr w0, [x29, #-4]      
    ldp x29, x30, [sp, #32] 
    add sp, sp, #48       
    ret
    .cfi_endproc

    ; literal pool
    .section	__TEXT,__cstring,cstring_literals
l_.str:                                 ; @.str
	.asciz	"a = %d\n" 
l1_.str:
    .asciz  "a is greater than %c\n"

.subsections_via_symbols
