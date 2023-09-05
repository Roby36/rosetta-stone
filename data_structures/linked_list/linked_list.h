
#pragma once

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/**************** global types ****************/
typedef struct linked_list linked_list_t;  // opaque to users of the module

/**************** functions ****************/

/**************** linked_list_new ****************/
/* Create a new (empty) linked_list.
 *
 * We return:
 *   pointer to a new linked_list, or NULL if error.
 * We guarantee:
 *   The linked_list is initialized empty.
 * Caller is responsible for:
 *   later calling linked_list_delete.
 */
extern linked_list_t* linked_list_new(void);

/**************** linked_list_insert ****************/
/* Add new item to the linked_list, at given index
 *
 * Caller provides:
 *   a valid linked_list pointer and a valid item pointer.
 * We guarantee:
 *   a NULL linked_list is ignored; a NULL item is ignored.
 *   the item is added to the linked_list.
 * Caller is responsible for:
 *   not free-ing the item as long as it remains in the linked_list.
 */
extern void linked_list_insert2(linked_list_t* linked_list, void* item, int item_index);

/**************** linked_list_extract ****************/
/* Return any data item from the linked_list.
 *
 * Caller provides:
 *   valid linked_list pointer, and index of item to extract
 * We return:
 *   pointer to an item, 
 *   or NULL if linked_list is NULL or empty, or index invalid
 * We guarantee:
 *   the item is no longer in the linked_list.
 * Caller is responsible for:
 *   free-ing the item if it was originally allocated with malloc.
 */
extern void * linked_list_extract2(linked_list_t* linked_list, int item_index);

extern void linked_list_reverse(linked_list_t * linked_list);

/**************** linked_list_print ****************/
/* Print the whole linked_list in order.
 *
 * Caller provides:
 *   a FILE open for writing, and a function to print items.
 * We guarantee:
 *   If fp==NULL; do nothing. If linked_list==NULL, print (null). 
 *   If itemprint==NULL, print nothing for each item.
 * We print: 
 *   A comma-separated list of items, surrounded by {brackets}.
 */
extern void linked_list_print(linked_list_t* linked_list, FILE* fp, 
               void (*itemprint)(FILE* fp, void* item));


/**************** linked_list_delete ****************/
/* Delete the whole linked_list.
 *
 * Caller provides:
 *   a valid linked_list pointer.
 *   a function that will delete one item (may be NULL).
 * We guarantee:
 *   we call itemdelete() on each item.
 *   we ignore NULL linked_list.
 */
extern void linked_list_delete(linked_list_t* linked_list, void (*itemdelete)(void* item) );

