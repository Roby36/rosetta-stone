
#include "inline_asm_funcs.h"

int64_t get_sp() {
    int64_t res = 0;
    asm volatile (
        "mov %x[result], sp"
        : [result] "=r" (res)
    );
    return res;
}

int32_t write_byte(int64_t address, int32_t content) {
    int32_t res = 0;
    asm volatile (
        "mov x3, %x[input_content]"   "\n"
        "str x3, [%x[input_address]]" "\n"
        "ldr %x[result], [%x[input_address]]"
        : [result] "=r" (res)
        : [input_address] "r" (address), [input_content] "r" (content)
        : "x3"
    );
    return res;
}

static void test1() {
    print_current_pc();
    print_current_pc();
    print_current_pc();
    int64_t prev_pc = get_current_pc();
    
    int32_t sp_offset = -16;
    int64_t address = get_sp() + sp_offset;
    int32_t byte = 0b111111;
    printf("Wrote %d at address %llx\n", write_byte(address, byte), address);
    
    int64_t curr_pc = get_current_pc();
    printf("\tprev_pc: %llx\n\tcurr_pc: %llx\n\tcurr_pc - prev_pc: %llu\n", 
            prev_pc, curr_pc, curr_pc - prev_pc);
}

