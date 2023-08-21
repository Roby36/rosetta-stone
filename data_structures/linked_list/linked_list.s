
.include "../../utils/macro_defs.s"

// .equ MDBG, 1
// .equ RDBG, 1

/* struct linked_list_node memory locations */
.equ n_item, 0
.equ n_next, 8
.equ n_size, 16

/* struct linked_list memory locations */
.equ ll_head, 0
.equ ll_size, 8

.data
str1:    .asciz  "(null)"
str2:    .asciz  "["
str3:    .asciz  " --> "
str4:    .asciz  "]"

llnn_c:   .asciz  "\nlinked_list_node_new called with %llx\n"
llnn_r:   .asciz  "\nlinked_list_node_new returned %llx\n"
llgi_c:   .asciz  "\nlinked_list_get_item called with %llx\n"
llgi_r:   .asciz  "\nlinked_list_get_item returned %llx\n"
lln_c:    .asciz  "\nlinked_list_new called with %llx\n"
lln_r:    .asciz  "\nlinked_list_new returned %llx\n"
lli_c:    .asciz  "\nlinked_list_insert called with %llx\n"
lli_r:    .asciz  "\nlinked_list_insert returned %llx\n"
lle_c:    .asciz  "\nlinked_list_extract called with %llx\n"
lle_r:    .asciz  "\nlinked_list_extract returned %llx\n"

.text
/** static linked_list_node_t * linked_list_node_new (void* item) **/ 
.p2align 2
_linked_list_node_new: 
    stp x29, x30, [sp, #-16]!
    str x26,      [sp, #-16]!
    RWRP , llnn_c
    mov x26, x0     // save item to non-volatile register x26 (NOT USED BY OTHER FUNCTIONS)
    // linked_list_node_t* node = malloc (sizeof(linked_list_node_t));
    mov x0, #n_size
    MWRP _malloc, mdbg0, mdbg1
    // if node == NULL, go to end of function
    cmp x0, #0
    beq llnn_end
    // if (node != NULL)
    str x26, [x0, #n_item]   // node->item = item
    str xzr, [x0, #n_next]   // node->next = NULL
llnn_end:                    // node pointer already stored in x0
    RWRP , llnn_r
    ldr x26,      [sp], #16
    ldp x29, x30, [sp], #16
    ret

/** static linked_list_node_t * linked_list_get_item(linked_list_t * linked_list, int item_index) **/
.p2align 2
_linked_list_get_item: 
    stp x29, x30, [sp, #-16]!

    cmp x0, #0            // keep input parameters in registers
    beq llgi_end          // short-circuit --> x0 = 0 already
    cmp w1, #0
    csel x0, xzr, x0, lt  // if (item_index < 0), x0 = 0, else unchanged
    cmp w1, #0            // reset flag (for safety)
    blt llgi_end          // if (item_index < 0)  --> llgi_end (short-circuit) 

    mov w2, #0             // w2 = curr_index, w1 = item_index
    mov x3, x0             // x3 = *linked_list
    ldr x0, [x3, #ll_head] // x0 = curr_node (return value) = linked_list->head
loop1:                     // pre-test loop 
    cmp x0, #0
    beq llgi_end           // if (curr_node == NULL), end loop (short-circuiting)
    cmp w2, w1
    bge llgi_end           // if (curr_index >= item_index), end loop (short-circuiting)       

    ldr x0, [x0, #n_next]  // curr_node = curr_node->next
    add w2, w2, #1         // curr_index++
    b loop1                // loop1 end
llgi_end:
    RWRP , llgi_r
    ldp x29, x30, [sp], #16
    ret

/** linked_list_t * linked_list_new(void) **/
.globl _linked_list_new
.p2align 2
_linked_list_new:
    stp x29, x30, [sp, #-16]!
    // linked_list_t* linked_list = malloc (sizeof(linked_list_t))
    mov x0, #ll_size
    MWRP _malloc, mdbg0, mdbg1
    cbz x0, lln_end         // if x0 = 0, then linked_list = NULL, hence return NULL
    str xzr, [x0, #ll_head] // linked_list->head = NULL;
lln_end:
    RWRP , lln_r
    ldp x29, x30, [sp], #16
    ret

/** linked_list_insert(linked_list_t* linked_list, void* item, int item_index) **/
.globl _linked_list_insert
.p2align 2
_linked_list_insert: 
    stp x29, x30, [sp, #-16]!  // save non-volatile registers on stack
    stp x20, x21, [sp, #-16]!
    stp x22, x23, [sp, #-16]!
    stp x24, x25, [sp, #-16]!

    mov x20, x0              // x20 = linked_list
    mov x21, x1              // x21 = item
    mov w22, w2              // w22 = item_index
    sub w1, w2, #1           // w1  = item_index - 1
    bl _linked_list_get_item // prev_node = linked_list_get_item(linked_list, item_index - 1)
    mov x23, x0              // x23 = prev_node
    mov x0, x20              // x0 = linked_list
    mov w1, w22              // w1 = item_index
    bl _linked_list_get_item // curr_node = linked_list_get_item(linked_list, item_index)
    mov x24, x0              // x24 = curr_node
    mov x0, x21              // x0 = item
    bl _linked_list_node_new // new_node  = linked_list_node_new(item);
    mov x25, x0              // x25 = new_node

    cmp x22, #0
    cset x0, ne             // x0 = (item_index != 0)
    cmp x23, #0
    cset x1, eq             // x1 = (prev_node == NULL)
    and x1, x0, x1          // x1 = (prev_node == NULL) && (item_index != 0)
    tbnz x1, #0, lli_end    // if x1 != 0 --> lli_end (short-circuiting)
    cmp x21, #0
    beq lli_end             // if (item == NULL) --> lli_end (short-circuiting)
    cmp x25, #0
    beq lli_end             // if (new_node == NULL)--> lli_end (short-circuiting)

    str x24, [x25, #n_next] // new_node->next = curr_node

    cmp x23, #0             
    beq else1              
if1:   // if (prev_node != NULL)
    str x25, [x23, #n_next] // prev_node->next = new_node
    b endif1                // remember to skip else clause!
else1: // else
    str x25, [x20, ll_head] // linked_list->head = new_node
endif1:

lli_end:
    ldp x24, x25, [sp], #16 // restore non-volatile registers from stack
    ldp x22, x23, [sp], #16
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret

/** void * linked_list_extract(linked_list_t* linked_list, int item_index) **/
.globl _linked_list_extract
.p2align 2
_linked_list_extract:
    stp x29, x30, [sp, #-16]!  // save non-volatile registers on stack
    stp x20, x21, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    str x27,      [sp, #-16]!

    mov x20, x0                 // x20 = linked_list
    mov w21, w1                 // w21 = item_index
    bl _linked_list_get_item    // curr_node = linked_list_get_item(linked_list, item_index)
    mov x23, x0                 // x23 = curr_node
    mov x0, x20                 // x0 = linked_list
    sub w1, w21, #1             // w1 = item_index - 1
    bl _linked_list_get_item    // prev_node = linked_list_get_item(linked_list, item_index - 1)
    mov x24, x0                 // x24 = prev_node

    mov x0, #0                  // prepare default return value
    cmp x23, #0
    beq lle_end                 // if curr_node == NULL, return NULL

    ldr x1, [x23, #n_next]      // x1 = curr_node->next  
    cmp x24, #0            
    beq else2              
if2:   // if (prev_node != NULL)
    str x1, [x24, #n_next]      // prev_node->next = curr_node->next
    b endif2                    // remember to skip else clause!
else2: // else
    str x1, [x20, #ll_head]     // linked_list->head = curr_node->next
endif2: 
    ldr x27, [x23, #n_item]     // !! USE NON-VOLATILE REGISTER x27, ELSE ITEM LOST !!!!!
    mov x0, x23                 // x0 = curr_node
    MWRP _free, fdbg0, fdbg1// free(curr_node)
    mov x0, x27                 // x0 = item (ready for return)
lle_end:
    RWRP , lle_r
    ldr x27,      [sp], #16     // restore non-volatile registers from stack
    ldp x23, x24, [sp], #16
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret

/** void linked_list_insert2(linked_list_t* linked_list, void* item, int item_index) **/
.globl _linked_list_insert2
.p2align 2
_linked_list_insert2:
    stp x29, x30, [sp, #-16]!
    stp x20, x21, [sp, #-16]!
    stp x22, x23, [sp, #-16]!
    stp x24, x25,  [sp, #-16]!

    mov x20, x0         // x20 = linked_list
    mov x21, x1         // x21 = item
    mov w22, w2         // w22 = item_index
    cmp x20, #0         // if (linked_list == NULL || item == NULL || item_index < 0) return
    beq lli2_end
    cmp x21, #0
    beq lli2_end
    cmp w22, #0
    blt lli2_end

    mov x0, x21
    bl _linked_list_node_new
    cmp x0, #0
    beq lli2_end        // check NULL return
    mov x23, x0         // x23 = new_node

    mov w24, #0             // w24 = curr_index
    add x25, x20, #ll_head  // x25 = next_it
loop5: // while (*next_it != NULL && curr_index < item_index)
    ldr x0, [x25]           // x0 = *next_it
    cmp x0, #0              // *next_it != NULL
    beq loop5_end
    cmp w24, w22            // curr_index < item_index
    bge loop5_end
    add x25, x0, #n_next    // next_it = &((*next_it)->next)
    add w24, w24, #1        // curr_index++
    b loop5
loop5_end:
    str x0, [x23, #n_next]  // new_node->next = *next_it
    str x23, [x25]          // *next_it       = new_node
lli2_end:
    ldp x24, x25, [sp], #16
    ldp x22, x23, [sp], #16
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret

/** void * linked_list_extract2(linked_list_t* linked_list, int item_index)**/
.globl _linked_list_extract2
.p2align 2
_linked_list_extract2:
    stp x29, x30, [sp, #-16]!
    stp x20, x21, [sp, #-16]!
    stp x22, x23, [sp, #-16]!
    str x24,      [sp, #-16]!

    mov x20, x0         // x20 = linked_list
    mov w21, w1         // w21 = item_index
    mov x0, #0          // if (linked_list == NULL || item_index < 0 || linked_list->head == NULL) return NULL;
    cmp x20, #0
    beq lle2_end
    cmp w21, #0
    blt lle2_end
    ldr x1, [x20, #ll_head]
    cmp x1, #0
    beq lle2_end

    mov w22, #0             // w22 = curr_index
    add x23, x20, #ll_head  // x23 = next_it
loop4:  // while ((*next_it)->next != NULL && curr_index < item_index)
    ldr x0, [x23]            // x0 =  *next_it
    ldr x1, [x0, #n_next]    // x1 = (*next_it)->next
    cmp x1, #0
    beq loop4_end
    cmp w22, w21             // curr_index < item_index
    bge loop4_end
    add x23, x0, #n_next     // next_it = &((*next_it)->next)
    add w22, w22, #1         // curr_index++
    b loop4
loop4_end:
    ldr x24, [x0, #n_item]   // x24 = item
    str x1,  [x23]           // *next_it = (*next_it)->next
    MWRP _free, fdbg0, fdbg1 // free(*next_it)
    mov x0, x24             
lle2_end:
    ldr x24,      [sp], #16
    ldp x22, x23, [sp], #16
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret


/** void linked_list_print(linked_list_t* linked_list, FILE* fp, void (*itemprint)(FILE* fp, void* item)) **/
.globl _linked_list_print
.p2align 2
_linked_list_print:
    stp x29, x30, [sp, #-16]! 
    stp x20, x21, [sp, #-16]!
    stp x22, x23, [sp, #-16]!

    mov x20, x0               // x20 = linked_list
    mov x21, x1               // x21 = fp
    mov x22, x2               // x22 = itemprint
    cmp x21, #0
    beq llp_end               // return (void) if fp == NULL
    cmp x22, #0
    beq llp_end               // return (void) if *itemprint == NULL
    cmp x20, #0 
    beq if3
    b endif3
if3: // if (linked_list == NULL)
    FPRINTF_STR x21, str1       // fprintf(fp, "(null)")
    b llp_end                   // return
endif3:
    FPRINTF_STR x21, str2       // fprintf(fp, "[")
    ldr x23, [x20, #ll_head]    // x23 = iterator_node = linked_list->head
loop2: // while (iterator_node != NULL)
    cmp x23, #0         
    beq loop2_end
    mov x0, x21             // x0 = fp
    ldr x1, [x23, #n_item]  // x1 = iterator_node->item
    blr x22                 // branch to itemprint address, and store current pc in x30
    FPRINTF_STR x21, str3   // fprintf(fp, " -> ")
    ldr x23, [x23, #n_next] // iterator_node = iterator_node->next
    b loop2                 // loop2 end
loop2_end:
    FPRINTF_STR x21, str4   // fprintf(fp, "]")
llp_end:
    ldp x22, x23, [sp], #16
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret

/** void linked_list_delete(linked_list_t* linked_list, void (*itemdelete)(void* item) ) **/
.globl _linked_list_delete
.p2align 2
_linked_list_delete:
    stp x29, x30, [sp, #-16]!
    stp x20, x21, [sp, #-16]!
    stp x22, x23, [sp, #-16]!

    cmp x0, #0              // check if linked_list == NULL
    beq lld_end
    cmp x1, #0              // check if itemdelete == NULL
    beq lld_end

    mov x20, x0             // x20 = linked_list
    mov x21, x1             // x21 = itemdelete
    ldr x22, [x20, #ll_head]// x22 = iterator_node
loop3:  // while (iterator_node != NULL)
    cmp x22, #0
    beq loop3_end
    ldr x0, [x22, #n_item]  // x0 = iterator_node->item
    blr x21                 // (*itemdelete)(iterator_node->item)
    ldr x23,[x22, #n_next]  // x23 = next = iterator_node->next
    mov x0, x22
    MWRP _free, fdbg0, fdbg1    // free(iterator_node)
    mov x22, x23           // iterator_node = next
    b loop3                // loop3 end
loop3_end:
    mov x0, x20
    MWRP _free, fdbg0, fdbg1    // free(linked_list)
lld_end:
    ldp x22, x23, [sp], #16
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret
