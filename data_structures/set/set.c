
/*
 * Roberto Brera,  CS50
 *
 * Implementation of set.h interface:
 * 
*/

#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <strings.h>
#include <stdlib.h>
#include "set.h"
#include "mem.h"

/**************** local types ****************/
typedef struct element {
  char* key;  
  void* item;                 
  struct element* next;       
} element_t;


/**************** global types ****************/
typedef struct set{
    struct element* head;
} set_t;  // opaque to users of the module



/**************** functions ****************/
static element_t* element_new(char* key, void* item);
static element_t* key_find(set_t* setp, const char* key);

/**************** malloc, free, and freenull counters ****************/
int nmalloc = 0;
int nfree = 0;
int nfreenull = 0;



/**************** set_new ****************/
/* see set.h for description */
set_t* 
set_new(void){

    set_t* setp = mem_malloc(sizeof(set_t));
    if (setp == NULL) { return NULL;}

    setp -> head = NULL;
    return setp;
}

/**************** set_insert ****************/
/* see set.h for description */
bool 
set_insert(set_t* set, const char* key, void* item){

    if (set == NULL || key == NULL || item == NULL ) { return false; }

    // First check if key exists already in set:
    if (key_find(set, key) != NULL) { return false; }

    // If key does not already exist in set, then we allocate space for it:
    char* key_copy = mem_malloc(strlen(key)+1);
    if (key_copy == NULL) { return false; }
    strcpy(key_copy,key);
    if (strcmp(key_copy,key) != 0) { return false; }

    // Generate new element, using copied string:
    element_t* new = element_new(key_copy,item);
    if (new == NULL) { return false; }

    // Inserting element in set:
    new -> next = set -> head;
    set -> head = new;

    return true;
}

/**************** set_find ****************/
/* see set.h for description */
void* 
set_find(set_t* set, const char* key) {

    if (set == NULL || key == NULL) { return NULL; }

    element_t* elementp = key_find(set, key);
    if (elementp == NULL) { return NULL; }
    return (elementp -> item);
}

/**************** set_print ****************/
/* see set.h for description */
void 
set_print(set_t* set, FILE* fp, 
            void (*itemprint)(FILE* fp, const char* key, void* item) ){

                if (fp != NULL) {
                    if (set != NULL) {
                        fputc('{',fp);
                        for (element_t* elementp = set -> head; elementp != NULL; elementp = elementp -> next){
                            if (itemprint != NULL) {
                                (*itemprint)(fp, elementp -> key, elementp -> item);
                                fputc(',',fp);
                            }
                        }
                        fputc('}',fp);
                    }
                    else {
                        fputs("(null)", fp);
                    }
                }
               }


/**************** set_iterate ****************/
/* see set.h for description */
void 
set_iterate(set_t* set, void* arg,
                 void (*itemfunc)(void* arg, const char* key, void* item) ){
                    
                    if (set == NULL || itemfunc == NULL) { return; }
                    for (element_t* elementp = set -> head; elementp != NULL; elementp = elementp -> next){
                        (*itemfunc)(arg, elementp -> key, elementp -> item);
                    }
                 }

/**************** set_delete ****************/
/* see set.h for description */
void 
set_delete(set_t* set, void (*itemdelete)(void* item) ){

    if (set == NULL) { return; }
    for (element_t* elementp = set -> head; elementp != NULL;) {
        if (itemdelete != NULL) {
            (*itemdelete)(elementp -> item);
        }
        // Key strings freed even if itemdelete is NULL:
        mem_free(elementp -> key);
        element_t* next = elementp -> next;
        mem_free(elementp);
        elementp = next;
    }
    mem_free(set);
}



/**************** element_new ****************/
/* Allocate and initialize an element */
static element_t* 
element_new(char* key, void* item){

    mem_assert((void*) key, "key"); mem_assert(item, "item");

    element_t* elementp = mem_malloc(sizeof(element_t));
    if (elementp == NULL) { return NULL;}

    elementp -> key = key;
    elementp -> item = item;
    elementp -> next = NULL;
    return elementp;
}

/**************** key_find ****************/
/* Return pointer to element with desired key if key exists in set,
 * and NULL if key does not exist in set, or if a given pointer is invalid: */
static element_t*
key_find(set_t* setp, const char* key) {

    if (setp == NULL || key == NULL) { return NULL; }

    for (element_t* elementp = setp -> head; elementp != NULL; elementp = elementp -> next) {
        if (strcmp(elementp -> key, key) == 0) { 
            return elementp; }
    }

    return NULL;

}


