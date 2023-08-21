
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
    cbz x0, llnn_end
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

    mov x3, x0             // x3 = linked_list
    // if (linked_list == NULL || item_index < 0)  return NULL;
    mov x0, xzr
    cbz x3, llgi_end        // linked_list == NULL
    tbnz w1, #31, llgi_end  // item_index < 0 

    mov w2, #0             // w2 = curr_index, w1 = item_index
    ldr x0, [x3, #ll_head] // x0 = curr_node (return value) = linked_list->head
loop1:                     // pre-test loop 
    cbz x0, llgi_end       // if (curr_node == NULL), end loop (short-circuiting)
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

/** void linked_list_insert2(linked_list_t* linked_list, void* item, int item_index) **/
.globl _linked_list_insert2
.p2align 2
_linked_list_insert2:
    stp x29, x30, [sp, #-16]!
    stp x20, x21, [sp, #-16]!
    stp x22, x23, [sp, #-16]!
    // save in non-volatile registers before function call
    mov x20, x0             // x20 = linked_list
    mov x21, x1             // x21 = item
    mov w22, w2             // w22 = item_index
    // if (linked_list == NULL || item == NULL || item_index < 0) return
    cbz x20, lli2_end       
    cbz x21, lli2_end
    tbnz w22, #31, lli2_end // check sign bit of item_index (if 1, then negative, hence branch to end)

    mov x0, x21
    bl _linked_list_node_new
    cbz x0, lli2_end        // check NULL return
    mov x23, x0             // x23 = new_node
    // if no function call left can use volatile registers!              
    mov w4, #0             // w4 = curr_index
    add x5, x20, #ll_head  // x5 = next_it
loop5: // while (*next_it != NULL && curr_index < item_index)
    ldr x0, [x5]           // x0 = *next_it
    cmp x0, xzr            // *next_it != NULL
    ccmp w4, w22, #0, ne   // if *next_it != NULL,
    bge loop5_end          // then compare w4, w22, and set N flag

    add x5, x0, #n_next    // next_it = &((*next_it)->next)
    add w4, w4, #1         // curr_index++
    b loop5
loop5_end:
    str x0, [x23, #n_next]  // new_node->next = *next_it
    str x23, [x5]          // *next_it        = new_node
lli2_end:
    ldp x22, x23, [sp], #16
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret

/** void * linked_list_extract2(linked_list_t* linked_list, int item_index)**/
.globl _linked_list_extract2
.p2align 2
_linked_list_extract2:
    stp x29, x30, [sp, #-16]!
    str x24,      [sp, #-16]!

    mov x2, x0          // w1 = item_index, x2 = linked_list
    mov x0, xzr         // if (linked_list == NULL || item_index < 0 || linked_list->head == NULL) return NULL;
    cbz x2, lle2_end
    tbnz w1, #31, lle2_end
    ldr x3, [x20, #ll_head]
    cbz x3, lle2_end

    mov w3, #0              // w3 = curr_index
    add x4, x2, #ll_head    // x4 = next_it
loop4:  // while ((*next_it)->next != NULL && curr_index < item_index)
    ldr x0, [x4]             // x0 =  *next_it
    ldr x6, [x0, #n_next]    // x6 = (*next_it)->next
    cbz x6, loop4_end        // (*next_it)->next != NULL
    cmp w3, w1               // curr_index < item_index
    bge loop4_end

    add x4, x0, #n_next     // next_it = &((*next_it)->next)
    add w3, w3, #1          // curr_index++
    b loop4

loop4_end:
    ldr x24, [x0, #n_item]   // x24 = item
    str x6,  [x4]            // *next_it = (*next_it)->next
    MWRP _free, fdbg0, fdbg1 // free(*next_it)
    mov x0, x24              // only x24 needs to be saved in non-volatile register!          
lle2_end:
    ldr x24,      [sp], #16
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
    cbz x21, llp_end          // return (void) if fp == NULL
    cbz x22, llp_end          // return (void) if *itemprint == NULL          
    cbz x20, if3
    b endif3
if3: // if (linked_list == NULL)
    FPRINTF_STR x21, str1       // fprintf(fp, "(null)")
    b llp_end                   // return
endif3:
    FPRINTF_STR x21, str2       // fprintf(fp, "[")
    ldr x23, [x20, #ll_head]    // x23 = iterator_node = linked_list->head
loop2: // while (iterator_node != NULL)
    cbz x23, loop2_end       
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

    cbz x0, lld_end             // check if linked_list == NULL
    cbz x1, lld_end             // check if itemdelete == NULL

    mov x20, x0             // x20 = linked_list
    mov x21, x1             // x21 = itemdelete
    ldr x22, [x20, #ll_head]// x22 = iterator_node
loop3:  // while (iterator_node != NULL)
    cbz x22, loop3_end
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
