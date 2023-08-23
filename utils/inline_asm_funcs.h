
#include <stdio.h>

/** COMPILING: gcc -o inline_test inline_asm_funcs.c macro_defs.s */

extern void print_current_pc();

extern int64_t get_current_pc();

int64_t get_sp();

int32_t write_byte(int64_t address, int32_t content);

static void test1();