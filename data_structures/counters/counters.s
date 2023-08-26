
.include "../../utils/macro_defs.s"

// .equ MDBG, 1
// .equ RDBG, 1

/* struct counter */
.equ ctr_key,   0
.equ ctr_count, 4
.equ ctr_next,  8
.equ ctr_size,  16

/* struct counters */
.equ ctrs_head, 0
.equ ctrs_size, 8

.data
/* debug strings */
counter_new_c:  .asciz  "counter_new() called with key = %d\n"
counter_new_r:  .asciz  "counter_new() returned %llx\n"
key_find_c:     .asciz  "key_find() called with key = %d\n"
key_find_r:     .asciz  "key_find() returned %llx\n"
counters_new_r: .asciz  "counters_new() returned %llx\n"
counters_add_c: .asciz  "counters_add() called with key = %d\n"
counters_add_r: .asciz  "counters_add() returned %d\n"
counters_get_r: .asciz  "counters_get() returned %d\n"
counters_set_r: .asciz  "counters_set() returned %d\n"
print_counter_c:    .asciz  "called print_counter with key = %d\n"
print_counter_r:    .asciz  "print_counter returned\n"

str0:           .asciz  "%d=%d, "
str1:           .asciz  "(null)"
str2:           .asciz  "{"
str3:           .asciz  "}"

.text
.p2align 2
_counter_new:   // static counter_t* counter_new(int key)
    stp x29, x30, [sp, #-16]!
    str x20,      [sp, #-16]!

    RWRP , counter_new_c
    mov w20, w0                 // w20 = key
    mov x0, #ctr_size
    MWRP _malloc, mdbg0, mdbg1  // counter_t* ctr = malloc(sizeof(counter_t))
    cbz x0, counter_new_end     // if (ctr == NULL) return NULL;
    stp w20, wzr, [x0, #ctr_key] // ctr -> key = key; ctr -> count = 0;
    str xzr, [x0, #ctr_next]    // ctr -> next  = NULL;
counter_new_end:
    RWRP , counter_new_r
    ldr x20,      [sp], #16
    ldp x29, x30, [sp], #16
    ret

.globl _counters_new
.p2align 2
_counters_new:  // counters_t* counters_new(void)
    stp x29, x30, [sp, #-16]!

    mov x0, #ctrs_size
    MWRP _malloc, mdbg0, mdbg1  // counters_t* ctrs = malloc(sizeof(counters_t))
    cbz x0, counters_new_end    // if (ctrs == NULL) return NULL;
    str xzr, [x0, #ctrs_head]   // ctrs->head = NULL;
counters_new_end:
    RWRP , counters_new_r
    ldp x29, x30, [sp], #16
    ret

.p2align 2
_key_find:  // static counter_t* key_find(counters_t* ctrs, const int key)
    stp x29, x30, [sp, #-16]!

    RWRP x1, key_find_c
    cbz x0, key_find_end        // if (ctrs == NULL) return NULL
    ldr x2, [x0, #ctrs_head]    // x2 = ctr
loop1:
    cbz x2, key_find_end        // if ctr == NULL exit loop
    ldr w3, [x2, #ctr_key]      // w3 = ctr->key
    cmp w3, w1                  // if ((ctr -> key) == key), exit loop
    beq key_find_end            
    ldr x2, [x2, #ctr_next]     // ctr = ctr -> next
    b loop1
key_find_end:
    mov x0, x2                  // set ctr as return value
    RWRP , key_find_r
    ldp x29, x30, [sp], #16
    ret

.p2align 2              
.globl _counters_add            
_counters_add:          // int counters_add(counters_t* ctrs, const int key)
    stp x29, x30, [sp, #-16]!
    stp x20, x21, [sp, #-16]!

    RWRP x1, counters_add_c
    mov x20, x0                     // x20 = ctrs
    mov w21, w1                     // w21 = key
    mov w0, wzr
    cbz x20, counters_add_end        // if (ctrs == NULL || key < 0) return
    tbnz w1, #31, counters_add_end
    mov x0, x20                     // counter_t* ctr = key_find(ctrs, key)
    bl _key_find
    cbz x0, if1
    b endif1
if1:    // if (ctr == NULL)
    mov w0, w21                     // ctr = counter_new(key)
    bl _counter_new 
    cbz x0, counters_add_end        // if (ctr == NULL) return 0
    ldr x2, [x20, #ctrs_head]       // x2 = ctrs->head
    str x2, [x0, #ctr_next]         // ctr->next = x2
    str x0, [x20, #ctrs_head]       // ctrs->head = x0 (ctr)
endif1: // assumes x0 = ctr
    ldr w2, [x0, #ctr_count]        // w2 = ctr->count
    add w2, w2, #1                  // w2 = w2 + 1
    str w2, [x0, #ctr_count]        // ctr->count = w2
    mov w0, w2                      // w0 = w2
counters_add_end:
    RWRP , counters_add_r
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.p2align 2
.globl _counters_get
_counters_get:
    stp x29, x30, [sp, #-16]!
    str x20,      [sp, #-16]!

    cbz x0, counters_get_end        // if (ctrs == NULL ) return 0
    mov x20, x0                     // x20 = ctrs
    mov w0, wzr
    tbnz w1, #31, counters_get_end  // if (key < 0) return 0
    mov x0, x20                     // counter_t* ctr = key_find(ctrs, key);
    bl _key_find
    cbz x0, counters_get_end        // if (ctr == NULL) return 0
    ldr w0, [x0, #ctr_count]        // return (ctr->count)
counters_get_end:
    RWRP , counters_get_r
    ldr x20,      [sp], #16
    ldp x29, x30, [sp], #16
    ret

.p2align 2
.globl _counters_set
_counters_set:
    stp x29, x30, [sp, #-16]!
    stp x20, x21, [sp, #-16]!
    str x22,      [sp, #-16]!

    mov x20, x0                     // x20 = ctrs
    mov w21, w1                     // w21 = key
    mov w22, w2                     // w22 = count
    mov w0, wzr
    cbz x20, counters_set_end
    tbnz w21, #31, counters_set_end
    tbnz w22, #31, counters_set_end
    mov x0, x20
    mov w1, w21                     // counter * ctr = key_find(ctrs, key)
    bl _key_find
    cbz x0, if2
    b endif2
if2:    // if (ctr == NULL)
    mov w0, w21                     // ctr = counter_new(key)
    bl _counter_new
    cbz x0, counters_set_end
    ldr x2, [x20, #ctrs_head]       // x2 = ctrs->head
    str x2, [x0, #ctr_next]         // ctr->next = x2
    str x0, [x20, #ctrs_head]       // ctrs->head = ctr
endif2:
    str w22, [x0, #ctr_count]       // ctr->count = count
    mov w0, #1                      // return true
counters_set_end:
    RWRP , counters_set_r
    ldr x22,      [sp], #16
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret


.p2align 2
_print_counter: // static void print_counter(void * fp, const int key, const int count)
    stp x29, x30, [sp, #-16]!

    RWRP x1, print_counter_c
    stp x1, x2, [sp, #-16]!
    LOAD_ADDR x1, str0
    bl _fprintf
    add sp, sp, #16
print_counter_end:
    RWRP , print_counter_r
    ldp x29, x30, [sp], #16
    ret


.p2align 2
.globl _counters_iterate   
_counters_iterate:  // void counters_iterate(counters_t* ctrs, void* arg, void (*itemfunc)(void* arg, const int key, const int count))
    stp x29, x30, [sp, #-16]!
    stp x20, x21, [sp, #-16]!
    str x23,      [sp, #-16]!

    cbz x0, counters_iterate_end
    cbz x2, counters_iterate_end
    mov x20, x1                     // x20 = arg
    mov x21, x2                     // x21 = itemfunc
    ldr x23, [x0, #ctrs_head]       // x23 = ctr
loop2:
    cbz x23, counters_iterate_end   // if ctr == NULL, exit function
    mov x0, x20                     // x0 = arg
    ldr w1, [x23, #ctr_key]         // w1 = ctr->key
    ldr w2, [x23, #ctr_count]       // w2 = ctr->count
    blr x21                         // (*itemfunc)(arg, ctr->key, ctr->count)
    ldr x23, [x23, #ctr_next]       // ctr = ctr -> next
    b loop2
counters_iterate_end:
    ldr x23,      [sp], #16
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.p2align 2
.globl _counters_print
_counters_print: // void counters_print(counters_t* ctrs, FILE* fp)
    stp x29, x30, [sp, #-16]!
    stp x20, x21, [sp, #-16]!

    mov x20, x0                 // x20 = ctrs
    mov x21, x1                 // x21 = fp
    cbz x21, counters_print_end // if (fp == NULL) return
    cbz x20, if3
    b endif3
if3:    // if (ctrs == NULL)
    FPRINTF_STR x21, str1       // fprintf(fp, "(null)"); return;
    b counters_print_end        
endif3:
    FPRINTF_STR x21, str2       // fprintf(fp, "{");
    mov x0, x20
    mov x1, x21
    LOAD_ADDR x2, _print_counter// x2 = &_print_counter
    bl _counters_iterate        
    FPRINTF_STR x21, str3       // fprintf(fp, "}");
counters_print_end:
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.p2align 2
.globl _counters_delete
_counters_delete:   // void counters_delete(counters_t* ctrs)
    stp x29, x30, [sp, #-16]!
    stp x20, x21, [sp, #-16]!

    mov x20, x0                     // x20 = ctrs
    cbz x0, counters_delete_end     // if (ctrs == NULL) return
    ldr x21, [x20, #ctrs_head]      // x21 = ctr = ctrs->head
loop3:
    cbz x21, loop3_end              // if (ctr == NULL), exit loop
    mov x0, x21
    MWRP _free, fdbg0, fdbg1        // free(ctr)
    ldr x21, [x21, #ctr_next]       // ctr = next
    b loop3
loop3_end:
    mov x0, x20
    MWRP _free, fdbg0, fdbg1        // free(ctrs)
counters_delete_end:
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret

