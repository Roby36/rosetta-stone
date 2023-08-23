
.include "../../utils/macro_defs.s"

// .equ MDBG, 1
// .equ RDBG, 1

/* struct hashtable */
.equ ht_capacity, 0
.equ ht_setArray, 4
.equ ht_size,     12

.data
ht_new_r:   .asciz  "\thashtable_new() returned %llx\n"
ht_find_c:  .asciz  "\thashtable_find() called with key = %s\n"
ht_find_r:  .asciz  "\thashtable_find() returned %llx\n"
ht_insert_r:    .asciz  "\thashtable_insert() returned %d\n"
ht_iterate_l:   .asciz  "\thashtable_iterate() looping with i = %d\n"
ht_sA:          .asciz  "\tsetArray = %llx\n"

str0:   .asciz  "(null)"
str1:   .asciz  "{"
str2:   .asciz  "}"

.text
// hashtable_t* hashtable_new(const int num_slots)
.globl _hashtable_new
.p2align 2
_hashtable_new:
    stp x29, x30, [sp, #-16]!
    stp x20, x21, [sp, #-16]!

    mov w20, w0                 // w20 = num_slots
    mov x0, xzr
    cmp w20, wzr
    ble ht_new_end              // if (num_slots <= 0) return NULL
    mov x0, #ht_size
    MWRP _malloc, mdbg0, mdbg1  // hashtable_t* ht = malloc(sizeof(hashtable_t));
    cbz x0, ht_new_end          // if (ht == NULL) return NULL
    mov x21, x0                 // x21 = ht
    str w20, [x21, #ht_capacity]// ht->CAPACITY = num_slots;
    mov w0, w20
    mov w1, #8
    bl _calloc                  // calloc(num_slots, 8)
    cbz x0, ht_new_end          // if (ht->setArray == NULL) return NULL
    str x0, [x21, #ht_setArray] // ht->setArray = calloc(num_slots, 8), DON'T FORGET TO ACTUALLY STORE THE DATA MEMBER!
    cmp x0, xzr
    csel x0, xzr, x21, eq       // if calloc returns NULL, return NULL, else return ht
/** Null initializations can be skipped!
    mov w1, wzr                 // int i = 0
loop1:
    cmp w1, w20
    bge loop1_end               // if i >= (ht->CAPACITY), exit loop
    str xzr, [x0, x1, lsl #3]   // (ht->setArray)[i] = NULL
    add w1, w1, #1              // i++
    b loop1
loop1_end:
    mov x0, x21                 // return ht
**/
ht_new_end:
    RWRP , ht_new_r
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// void* hashtable_find(hashtable_t* ht, const char* key)
.globl _hashtable_find
.p2align 2
_hashtable_find:
    stp x29, x30, [sp, #-16]!
    stp x20, x21, [sp, #-16]!
    stp x22, x23, [sp, #-16]! 
    str x24,      [sp, #-16]!
    RWRP x1, ht_find_c

    mov x20, x0                 // x20 = ht
    mov x0, xzr
    cbz x20, ht_find_end        // if (ht == NULL) return NULL
    cbz x1, ht_find_end         // if (key == NULL) return NULL
    mov x21, x1                 // x21 = key
    ldr w22, [x20, #ht_capacity]// w22 = ht->CAPACITY
    ldr x24, [x20, #ht_setArray]// x24 = ht->setArray
    mov w23, wzr                // int i = 0
loop2:
    cmp w23, w22                // if (i >= ht->CAPACITY), go to loop end
    bge loop2_end
    ldr x0, [x24, x23, lsl #3]  // x0 = (ht->setArray)[i]
    mov x1, x21
    bl _set_find                // set_find((ht->setArray)[i], key)
    cbnz x0, ht_find_end        // if (item != NULL) return item
    add w23, w23, #1            // i++
    b loop2
loop2_end:
    mov x0, xzr                 // return NULL
ht_find_end:
    RWRP , ht_find_r
    ldr x24,      [sp], #16
    ldp x22, x23, [sp], #16
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// bool hashtable_insert(hashtable_t* ht, const char* key, void* item)
.globl _hashtable_insert
.p2align 2
_hashtable_insert:
    stp x29, x30, [sp, #-16]!
    stp x20, x21, [sp, #-16]!
    stp x22, x23, [sp, #-16]!

    mov x20, x0                 // x20 = ht
    mov w0, wzr
    cbz x20, ht_insert_end
    cbz x1, ht_insert_end
    cbz x2, ht_insert_end
    mov x21, x1                 // x21 = key
    mov x22, x2                 // x22 = item

    mov x0, x20
    bl _hashtable_find          // hashtable_find(ht,key)
    mov x1, x0
    mov w0, wzr
    cbnz x1, ht_insert_end      // if (hashtable_find(ht,key) != NULL) return false

    mov x0, x21
    ldr w1, [x20, #ht_capacity] // w1 = ht->CAPACITY (int32)
    bl _hash_jenkins            // hash_jenkins(key, ht->CAPACITY)

    ldr x2, [x20, #ht_setArray] // x2  = (ht->setArray)
    add x23, x2, x0, lsl #3     // x23 = &((ht->setArray)[setn])
    ldr x3, [x23]               // x3 = (ht->setArray)[setn]
    cbz x3, if1
    b endif1
if1:    // if (ht->setArray)[setn] == NULL
    bl _set_new
    str x0, [x23]               // (ht->setArray)[setn] = set_new();
endif1:
    ldr x0, [x23]               // x0 = (ht->setArray)[setn]
    mov x1, x21
    mov x2, x22
    bl _set_insert              // return set_insert((ht->setArray)[setn], key, item)
ht_insert_end:
    RWRP , ht_insert_r
    ldp x22, x23, [sp], #16
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// void hashtable_iterate(hashtable_t* ht, void* arg, void (*itemfunc)(void* arg, const char* key, void* item) )
.globl _hashtable_iterate
.p2align 2
_hashtable_iterate:
    stp x29, x30, [sp, #-16]!
    stp x20, x21, [sp, #-16]!
    stp x22, x23, [sp, #-16]! 
    str x24,      [sp, #-16]!

    cbz x0, ht_iterate_end
    cbz x2, ht_iterate_end
    ldrsw x20, [x0, #ht_capacity] // x20 = ht->capacity
    ldr x23, [x0, #ht_setArray] // x23 = ht->setArray
    // RWRP x23, ht_sA          
    mov x21, x1                 // x21 = arg
    mov x22, x2                 // x22 = itemfunc
    mov x24, xzr                // int i = 0
loop3:
    cmp x24, x20
    bge loop3_end               // if i >= ht->capacity, goto loop end
    // RWRP x24, ht_iterate_l   
    ldr x0, [x23, x24, lsl #3]  // x0 = (ht->setArray)[i]
    mov x1, x21
    mov x2, x22
    bl _set_iterate             // set_iterate((ht->setArray)[i], arg, itemfunc)
    add x24, x24, #1            // i++
    b loop3
loop3_end:

ht_iterate_end:
    ldr x24,      [sp], #16
    ldp x22, x23, [sp], #16
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// void hashtable_print(hashtable_t* ht, FILE* fp, void (*itemprint)(FILE* fp, const char* key, void* item))
.globl _hashtable_print
.p2align 2
_hashtable_print:
    stp x29, x30, [sp, #-16]!
    stp x20, x21, [sp, #-16]!
    str x22,      [sp, #-16]!

    cbz x1, ht_print_end    // if (fp == NULL) return
    mov x20, x0             // x20 = ht
    mov x21, x1             // x21 = fp
    mov x22, x2             // x22 = itemprint
    cbz x20, if2
    b endif2
if2:    // if (ht == NULL)
    FPRINTF_STR x21, str0   // fprintf(fp, "(null)")
    b ht_print_end          // return
endif2:
    FPRINTF_STR x21, str1   // fprintf(fp, "{")
    mov x0, x20
    mov x1, x21
    mov x2, x22
    bl _hashtable_iterate  // hashtable_iterate(ht, fp, itemprint)
    FPRINTF_STR x21, str2   // fprintf(fp, "}")

ht_print_end:
    ldr x22,      [sp], #16
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// void hashtable_delete(hashtable_t* ht, void (*itemdelete)(void* item))
.globl _hashtable_delete
.p2align 2
_hashtable_delete:
    stp x29, x30, [sp, #-16]!
    stp x20, x21, [sp, #-16]!
    stp x22, x23, [sp, #-16]! 
    str x24,      [sp, #-16]!

    cbz x0, ht_delete_end       // if (ht == NULL) return NULL
    mov x20, x0                 // x20 = ht
    mov x21, x1                 // x21 = itemdelete
    ldr x22, [x20, #ht_setArray]// x22 = ht->setArray
    ldr w23, [x20, #ht_capacity]// w23 = ht->capacity
    mov w24, wzr                // int i = 0
loop4:
    cmp w24, w23
    bge loop4_end               // if (i >= ht->capacity), goto loop end
    ldr x0, [x22, x24, lsl #3]  // x0 = (ht->setArray)[i]
    mov x1, x21
    bl _set_delete              // set_delete((ht -> setArray)[i], itemdelete)
    add w24, w24, #1            // i++
    b loop4
loop4_end:
    mov x0, x22
    MWRP _free, fdbg0, fdbg1    // free(ht->setArray)
    mov x0, x20
    MWRP _free, fdbg0, fdbg1    // free(ht)

ht_delete_end:
    ldr x24,      [sp], #16
    ldp x22, x23, [sp], #16
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret
    
