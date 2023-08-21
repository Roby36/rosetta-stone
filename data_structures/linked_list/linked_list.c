
#include "linked_list.h"

/**************** local types ****************/
typedef struct linked_list_node {
    void * item;                    // pointer to data for this item
    struct linked_list_node * next; // pointer to next node
} linked_list_node_t;

/**************** global types ****************/
typedef struct linked_list {
    struct linked_list_node * head; // head of the linked_list
} linked_list_t;

/**************** local functions ****************/
/* not visible outside this file */

/**************** linked_listnode_new ****************/
/* Allocate and initialize a linked_list_node */

static linked_list_node_t * linked_list_node_new(void* item)
{
    linked_list_node_t* node = malloc (sizeof(linked_list_node_t));

    if (node != NULL) {
        node->item = item;
        node->next = NULL;
    }

    return node;
}

/**************** linked_list_get_item ****************/
/* Extract the item at a given index of the linked list, or NULL */
static linked_list_node_t * linked_list_get_item(linked_list_t * linked_list, int item_index)
{
    if (linked_list == NULL || item_index < 0)
        return NULL;

    register int curr_index        = 0;
    linked_list_node_t * curr_node = linked_list->head;

    while (curr_node != NULL && curr_index < item_index) {
        curr_node = curr_node->next;
        curr_index++;
    }
    
    return curr_node;
}

/**************** global functions ****************/
/* that is, visible outside this file */
/* see linked_list.h for comments about exported functions */

/**************** linked_list_new() ****************/
/* see linked_list.h for description */
linked_list_t * linked_list_new(void)
{
    linked_list_t* linked_list = malloc (sizeof(linked_list_t));

    if (linked_list != NULL) 
        linked_list->head = NULL; // linked list initialized empty, if successfully allocated 
    return linked_list;
}

/**************** linked_list_insert() ****************/
/* see linked_list.h for description */
void
linked_list_insert2(linked_list_t* linked_list, void* item, int item_index)
{
    // Check arguments
    if (linked_list == NULL || item == NULL || item_index < 0)
        return;
    
    // Initialize node to add 
    linked_list_node_t * new_node = linked_list_node_new(item);

    // Initialize address of the node next to the new_node
    register int curr_index = 0;
    linked_list_node_t ** next_it = &(linked_list->head);

    // Iterate until the desired index, or end of list
    while (*next_it != NULL && curr_index < item_index) {
        next_it = &((*next_it)->next);
        curr_index++;
    }

    // Insert new node
    new_node->next = *next_it; // set new_node->next to currently reached node
    *next_it       = new_node; // update the next node of currently reached node to new_node
}

/**************** linked_list_extract() ****************/
/* see linked_list.h for description */
void *
linked_list_extract2(linked_list_t* linked_list, int item_index)
{
    // Check arguments
    if (linked_list == NULL || item_index < 0 || linked_list->head == NULL)
        return NULL;
    
    // Iterate towards node to remove
    register int curr_index = 0;
    linked_list_node_t ** next_it = &(linked_list->head);

    while ((*next_it)->next != NULL && curr_index < item_index) {
        next_it = &((*next_it)->next);
        curr_index++;
    }

    void * item = (*next_it)->item;        // save item of node to remove
    linked_list_node_t * temp = *next_it;  // save node pointer to free
    *next_it = (*next_it)->next;           // Remove node
    free(temp);
    return item;
}

/**************** linked_list_print() ****************/
/* see linked_list.h for description */
void
linked_list_print(linked_list_t* linked_list, FILE* fp, void (*itemprint)(FILE* fp, void* item) )
{
    if (fp == NULL || itemprint == NULL)
        return;

    if (linked_list == NULL) {
        fprintf(fp, "(null)");
        return;
    }

    fprintf(fp, "["); // opening bracket
    linked_list_node_t* iterator_node = linked_list->head; // start PRE-CONDITION loop

    while (iterator_node != NULL) {
        (*itemprint)(fp, iterator_node->item);

        fprintf(fp, " -> ");

        iterator_node = iterator_node->next;
    }
    
    fprintf(fp, "]"); // closing bracket
}

/**************** linked_list_delete() ****************/
/* see linked_list.h for description */
void 
linked_list_delete(linked_list_t* linked_list, void (*itemdelete)(void* item) )
{
    if (linked_list == NULL || itemdelete == NULL)
        return;

    linked_list_node_t* iterator_node = linked_list->head; // start PRE-CONDITION loop
    linked_list_node_t* next;
    while (iterator_node != NULL) {
        (*itemdelete)(iterator_node->item); 
        next = iterator_node->next;
        free(iterator_node);
        iterator_node = next;
    }
    free(linked_list);
}
