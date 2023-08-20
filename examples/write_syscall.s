
/** Source code:
4	AUE_NULL	ALL	{ user_ssize_t write(int fd, user_addr_t cbuf, user_size_t nbyte); }
*/ 

.include "../utils/macro_defs.s"
.data
str:    .asciz  "Write syscall!\n" // 16 bytes

.text
.globl _main
.p2align 2
_main:
    stp x29, x30, [sp, #-16]!
    mov x0, #1         // int fd = 1 (stdout)
    LOAD_ADDR x1, str  // user_addr_t cbuf (address of strign to write)
    mov x2, #16        // 16 bytes to write
/* doesn't work, just call _write directly instead
    ldr x8, =0x2000004 // 0×2000000 + syscall#
    svc #0             // invoke syscall
*/
    bl _write

    mov w0, #0          // return
    ldp x29, x30, [sp], #16
    ret
