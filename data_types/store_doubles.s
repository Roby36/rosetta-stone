
    .section    __TEXT,__text,regular,pure_instructions
    .build_version macos, 13, 0 sdk_version 13, 3

    .globl _main
    .p2align 2
_main:
    .cfi_startproc
    sub sp, sp, #64
    .cfi_def_cfa_offset 64
    stp x29, x30, [sp, #48]
    add x29, sp, #48
    .cfi_def_cfa w29, 16
    .cfi_offset  w30, -8
    .cfi_offset  w29, -16
    str wzr, [sp, #44]

    ; double d = -0.04
    mov  x0, #0b0001010001111011
    movk x0, #0b0100011110101110, lsl #16
    movk x0, #0b0111101011100001, lsl #32
    movk x0, #0b1011111110100100, lsl #48
    fmov d0, x0
    str d0, [sp, #36]  ; double = 64 bits = 8 bytes

    ; print
    ldr d0, [sp, #36]
    str d0, [sp]
    adrp    x0, l_.str@PAGE ; load the address (64-bit pointer) of the string in the literal pool
    add x0, x0, l_.str@PAGEOFF
    bl _printf

    ldr w0, [sp, #44]
    ldp x29, x30, [sp, #48]
    add sp, sp, #64
    ret
    .cfi_endproc

    .section    __TEXT,__cstring,cstring_literals
l_.str:
    .asciz  "Double value: %f\n"

.subsections_via_symbols
