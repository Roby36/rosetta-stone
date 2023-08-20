
/*
#include <stdio.h>
int main(void)
{
do
    {} 
while (getchar() != ’A’)
return 0; 
}
*/

.equ char, 'A'

.text
.globl _main
.p2align 2
_main:
    stp x29, x30, [sp, #-16]!
loop:
    bl _getchar // result stored in w0
    mov w1, #char
    cmp w0, w1
    bne loop
// end of loop here:
    mov w0, #0
    ldp x29, x30, [sp], #16
    ret
