
.include "../../utils/macro_defs.s"

// .equ MDBG, 1
// .equ RDBG, 1

/* struct element */
.equ el_key,  0
.equ el_item, 8
.equ el_next, 16
.equ el_size, 24

/* struct set */
.equ s_head, 0
.equ s_size, 8

.data
str0:   .asciz  "(null)"
str1:   .asciz  "{"
str2:   .asciz  "}"
// debugging strings
set_new_r:  .asciz  "\tset_new() returned %llx\n"
set_find_r: .asciz  "\tset_find() returned %llx\n"
key_find_c: .asciz  "\tkey_find() called with key = %s\n"
key_find_r: .asciz  "\tkey_find() returned %llx\n"
set_insert_r:   .asciz  "\tset_insert() returned %d\n"

.text
// set_t*  set_new(void) 
.globl _set_new      
.p2align 2
_set_new:
    stp x29, x30, [sp, #-16]!
    mov x0, #s_size             // set_t* new_set = malloc(sizeof(set_t))
    MWRP _malloc, mdbg0, mdbg1
    cbz x0, sn_end              // if (new_set == NULL) return
    str xzr, [x0, #s_head]      // new_set->head = NULL; 
sn_end:
    RWRP , set_new_r
    ldp x29, x30, [sp], #16
    ret

// element_t* key_find (set_t* set, const char* key)
.p2align 2
_key_find:
    stp x29, x30, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    str x23,      [sp, #-16]!
    RWRP x1, key_find_c

    cmp x0, xzr                 // if x0 != 0, set PSTATE to cmp x1, xzr
    ccmp x1, xzr, #0b0100, ne   // if x0 = 0, set Z = 1
    beq loop1_end               // this ensures we return NULL 
    mov x21, x1                 // x21 = key
    ldr x22, [x0, #s_head]      // x22 = it
loop1:
    cbz x22, loop1_end          // if (it == NULL), goto loop end
    ldr x23, [x22, el_key]      // x23 = it->key
    mov x0, x23
    bl _strlen
    add x2, x0, #1              // x2 = strlen(it->key) + 1
    mov x1, x21                 // x1 = key
    mov x0, x23                 // x0 = it->key
    bl _strncmp     
    cbz w0, if1
    b endif1
if1:    // if (strncmp(it->key, key, strlen(it->key) + 1) == 0) 
    mov x0, x22                 // return it
    b kf_end                    
endif1:
    ldr x22, [x22, #el_next]    // it = it->next
    b loop1
loop1_end:
    mov x0, xzr                 // return NULL

kf_end:
    RWRP , key_find_r
    ldr x23,      [sp], #16
    ldp x21, x22, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// bool set_insert(set_t* set, const char* key, void* item)
.globl _set_insert
.p2align 2
_set_insert:
    stp x29, x30, [sp, #-64]!   // move sp ONLY ONCE
    stp x20, x21, [sp, #16]
    stp x22, x23, [sp, #32]
    str x24,      [sp, #48]     

    mov x20, x0                 // x20 = set
    mov x21, x1                 // x21 = key
    mov x22, x2                 // x22 = item
    cmp x20, xzr
    ccmp x21, xzr, #0b0100, ne  // if set != NULL, compare key with NULL
    ccmp x22, xzr, #0b0100, ne  // if key != NULL, compare item with NULL
    beq false_ret               // return false if any argument is NULL
    mov x0, x20
    bl _key_find                // key_find(set, key)
    cbnz x0, false_ret          // if (key_find(set, key) != NULL) return false
    mov x0, x21
    bl _strlen                  // strlen(key)
    add x23, x0, #1             // x23 = key_length
    mov x0, x23
    MWRP _malloc, mdbg0, mdbg1  // malloc(key_length)
    cbz x0, false_ret           // if (key_copy == NULL) return false
    mov x24, x0                 // x24 = key_copy
    mov x1, x21
    mov x2, x23                 
    bl _strncpy                 // strncpy(key_copy, key, key_length);

    mov x0, #el_size
    MWRP _malloc, mdbg0, mdbg1  // malloc(sizeof(element_t))
    cbz x0, false_ret           // if (new_element == NULL) return false
    stp x24, x22, [x0, #el_key] // new_element->key = key_copy; new_element->item = item 
    ldr x1, [x20, #s_head]      // x1 = set->head
    str x1, [x0, #el_next]      // new_element->next = x1
    str x0, [x20, #s_head]      // set->head         = new_element
    mov w0, #1
    b si_end                    // return true

false_ret:
    mov w0, wzr
si_end:
    RWRP , set_insert_r
    ldr x24,      [sp, #48]
    ldp x22, x23, [sp, #32]
    ldp x20, x21, [sp, #16]
    ldp x29, x30, [sp], #64     // move sp ONLY ONCE
    ret


// void* set_find(set_t* set, const char* key)
.globl _set_find
.p2align 2
_set_find:
    stp x29, x30, [sp, #-16]!

    bl _key_find                // key_find(set, key) 
    cbz x0, sf_end              // if (el == NULL) return NULL
    ldr x0, [x0, #el_item]      // x0 = el->item
sf_end:
    RWRP , set_find_r
    ldp x29, x30, [sp], #16
    ret

// void set_iterate(set_t* set, void* arg,  void (*itemfunc)(void* arg, const char* key, void* item))
.globl _set_iterate
.p2align 2
_set_iterate:
    stp x29, x30, [sp, #-16]! 
    stp x20, x21, [sp, #-16]!
    stp x22, x23, [sp, #-16]! 
   
    cmp x0, xzr                       
    ccmp x2, xzr, 0b0100, ne    // if (x20 != 0), then cmp x2, xzr, else set Z=1
    beq sit_end 
    mov x20, x0                 // x20 = set
    mov x21, x1                 // x21 = arg
    mov x22, x2                 // x22 = itemfunc
    ldr x23, [x20, #s_head]     // x23 = it
loop2:
    cbz x23, loop2_end          // if (it == NULL), exit loop
    mov x0, x21
    ldr x1, [x23, #el_key]
    ldr x2, [x23, #el_item]
    blr x22                     // (*itemfunc)(arg, it->key, it->item)
    ldr x23, [x23, #el_next]    // it = it->next
    b loop2
loop2_end:

sit_end:
    ldp x22, x23, [sp], #16
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// void set_print(set_t* set, FILE* fp, void (*itemprint)(FILE* fp, const char* key, void* item) ) 
.globl _set_print
.p2align 2
_set_print:
    stp x29, x30, [sp, #-16]! 
    stp x20, x21, [sp, #-16]!
    str x22,      [sp, #-16]!

    cbz x1, sp_end              // if (fp == NULL) return
    mov x20, x0                 // x20 = set
    mov x21, x1                 // x21 = fp
    mov x22, x2                 // x22 = itemprint
    cbz x0, if2
    b endif2
if2:    // if (set == NULL)
    FPRINTF_STR x21, str0       // fprintf(fp, "(null)")
    b sp_end                    // return
endif2:
    FPRINTF_STR x21, str1       // fprintf(fp, "{");
    mov x0, x20
    mov x1, x21
    mov x2, x22
    bl _set_iterate             // set_iterate(set, fp, itemprint)
    FPRINTF_STR x21, str2       // fprintf(fp, "}");

sp_end:
    ldr x22,      [sp], #16
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// void set_delete(set_t* set, void (*itemdelete)(void* item) )
.globl _set_delete
.p2align 2
_set_delete:
    stp x29, x30, [sp, #-16]! 
    stp x20, x21, [sp, #-16]!
    str x22,      [sp, #-16]!

    cbz x0, sd_end              // if (set == NULL) return without free'ing the set
    mov x20, x0                 // x20 = set
    cbz x1, sd_free             // if (itemdelete == NULL), free set and return
    mov x21, x1                 // x21 = itemdelete
    ldr x22, [x20, #s_head]     // x22 = it
loop3:
    cbz x22, loop3_end          // if (it == NULL), terminate loop
    ldr x0, [x22, #el_item]     // x0 = it->item
    blr x21                     // (*itemdelete)(it->item)
    ldr x0, [x22, #el_key]      // x0 = it->key
    MWRP _free, fdbg0, fdbg1    // free(it->key)
    mov x0, x22
    MWRP _free, fdbg0, fdbg1    // free(it)
    ldr x22, [x22, #el_next]    // it = it->next
    b loop3
loop3_end:
sd_free:
    mov x0, x20
    MWRP _free, fdbg0, fdbg1    // free(set)
sd_end:
    ldr x22,      [sp], #16
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret
