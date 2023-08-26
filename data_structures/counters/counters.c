
#include "counters.h"

/**************** local types ****************/
typedef struct counter {
  int key;  
  int count;                 
  struct counter * next;       
} counter_t;

/**************** global types ****************/
typedef struct counters {
    struct counter* head;
} counters_t;  

/**************** functions ****************/
static counter_t* counter_new(int key);static counter_t* key_find(counters_t* setp, const int key);

/**************** counters_new ****************/
/* see counters.h for description */
counters_t* 
counters_new(void) 
{

    counters_t* ctrs = malloc(sizeof(counters_t));
    if (ctrs == NULL) 
        return NULL;

    ctrs->head = NULL;
    return ctrs;
}

/**************** counters_add ****************/
/* see counters.h for description */
int 
counters_add(counters_t* ctrs, const int key)
{
    if (ctrs == NULL || key < 0) 
        return 0;

    counter_t* ctr = key_find(ctrs, key);

    // If counter not already present in set, generate new counter,
    // and add to head of set:
    if (ctr == NULL) {
        ctr = counter_new(key);
        if (ctr == NULL) 
            return 0;
        ctr -> next = ctrs -> head;
        ctrs -> head = ctr;
    }

    // Increment count
    return (++ctr->count);
}


/**************** counters_get ****************/
/* see counters.h for description */
int 
counters_get(counters_t* ctrs, const int key){

    if (ctrs == NULL || key < 0) 
        return 0; 

    counter_t* ctr = key_find(ctrs, key);
    if (ctr == NULL) 
        return 0;
    return (ctr -> count);
}

/**************** counters_set ****************/
/* see counters.h for description */

bool 
counters_set(counters_t* ctrs, const int key, const int count){
    
    if (ctrs == NULL || key < 0 || count < 0) 
        return false; 

    counter_t* ctr = key_find(ctrs, key);

    // If counter not already present in set, add new counter at head of set:
    if (ctr == NULL) {
        ctr = counter_new(key);
        if (ctr == NULL) 
            return false;
        ctr -> next = ctrs -> head;
        ctrs -> head = ctr;
    }

    // Set counter to desired value:
    ctr -> count = count;

    return true;
}


/**************** counters_print ****************/
/* see counters.h for description */


static void print_counter(void * fp, const int key, const int count)
{
    fprintf((FILE*)fp, "%d=%d, ", key, count);
}

void 
counters_print(counters_t* ctrs, FILE* fp)
{
    if (fp == NULL)
        return;
    if (ctrs == NULL) {
        fprintf(fp, "(null)");
        return;
    }
    fprintf(fp, "{");
    counters_iterate(ctrs, fp, print_counter);
    fprintf(fp, "}");
}

/**************** counters_iterate ****************/
/* see counters.h for description */

void 
counters_iterate(counters_t* ctrs, void* arg, 
        void (*itemfunc)(void* arg, const int key, const int count)) 
{
    if (ctrs == NULL || itemfunc == NULL) 
        return; 
    for (counter_t* ctr = ctrs -> head; ctr != NULL; ctr = ctr -> next) {
        (*itemfunc)(arg, ctr->key, ctr->count);
    }
}


/**************** counters_delete ****************/
/* see counters.h for description */

void 
counters_delete(counters_t* ctrs){
    if (ctrs == NULL) 
        return;
    for (counter_t* ctr = ctrs -> head; ctr != NULL;) {
        counter_t* next = ctr -> next;
        free(ctr);
        ctr = next;
    }
    free(ctrs);
}

/**************** counter_new ****************/
/* Allocate and initialize a counter for a new key to 1: */
static counter_t* 
counter_new(int key) {

    counter_t* ctr = malloc(sizeof(counter_t));
    if (ctr == NULL) 
        return NULL;

    ctr -> key   = key;
    ctr -> count = 0;
    ctr -> next  = NULL;
    return ctr;
}

/**************** key_find ****************/
/* Return pointer to counter with desired key if key exists in counters set,
 * and NULL if key does not exist in set, or if a given pointer is invalid: */
static counter_t*
key_find(counters_t* ctrs, const int key) {

    if (ctrs == NULL) 
        return NULL; 

    for (counter_t* ctr = ctrs -> head; ctr != NULL; ctr = ctr -> next) {
        if ((ctr -> key) == key) 
            return ctr;
    }
    return NULL;
}

