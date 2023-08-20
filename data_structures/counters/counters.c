
/*
 * Roberto Brera,  CS50
 *
 * Implementation of counters.h interface
 * 
*/

#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <strings.h>
#include <stdlib.h>
#include "mem.h"

/**************** local types ****************/
typedef struct counter {
  int key;  
  int count;                 
  struct counter* next;       
} counter_t;


/**************** global types ****************/
typedef struct counters {
    struct counter* head;
} counters_t;  

/**************** functions ****************/
static counter_t* counter_new(int key);
static counter_t* key_find(counters_t* setp, const int key);


/**************** malloc, free, and freenull counters ****************/
int nmalloc = 0;
int nfree = 0;
int nfreenull = 0;


/**************** counters_new ****************/
/* see counters.h for description */
counters_t* 
counters_new(void) {

    counters_t* setp = mem_malloc(sizeof(counters_t));
    if (setp == NULL) { return NULL; }

    setp -> head = NULL;
    return setp;
}

/**************** counters_add ****************/
/* see counters.h for description */
int 
counters_add(counters_t* ctrs, const int key){

    if (ctrs == NULL || key < 0) { return 0; }

    counter_t* counterp = key_find(ctrs, key);

    // If counter not already present in set, generate new counter,
    // and add to head  of set:
    if (counterp == NULL) {
        counterp = counter_new(key);
        if (counterp == NULL) { return 0; }
        counterp -> next = ctrs -> head;
        ctrs -> head = counterp;
    }

    // If counter already present in set, increment count by 1:
    else { (counterp -> count)++; }

    return (counterp -> count);

}

/**************** counters_get ****************/
/* see counters.h for description */
int 
counters_get(counters_t* ctrs, const int key){

    if (ctrs == NULL || key < 0) { return 0; }

    counter_t* counterp = key_find(ctrs, key);
    if (counterp == NULL) { return 0; }
    return (counterp -> count);
}

/**************** counters_set ****************/
/* see counters.h for description */
bool 
counters_set(counters_t* ctrs, const int key, const int count){
    
    if (ctrs == NULL || key < 0 || count < 0) { return false; }

    counter_t* counterp = key_find(ctrs, key);

    // If counter not already present in set, add new counter at head of set:
    if (counterp == NULL){
        counterp = counter_new(key);
        if (counterp == NULL) { return false; }
        counterp -> next = ctrs -> head;
        ctrs -> head = counterp;
    }

    // Set counter to desired value:
    counterp -> count = count;

    return true;
}

/**************** counters_print ****************/
/* see counters.h for description */
void 
counters_print(counters_t* ctrs, FILE* fp){

    if (fp != NULL) {
        if (ctrs == NULL) { fputs("(null)", fp); }
        else{
            fputc('{',fp);
            for (counter_t* counterp = ctrs -> head; counterp != NULL; counterp = counterp -> next){
                fprintf(fp, "%d=%d, ", counterp->key, counterp->count);
            }
            fputc('}',fp);
        }
    }
}

/**************** counters_iterate ****************/
/* see counters.h for description */
void 
counters_iterate(counters_t* ctrs, void* arg, 
        void (*itemfunc)(void* arg, const int key, const int count)){

            if (ctrs == NULL || itemfunc == NULL) { return; }
            for (counter_t* counterp = ctrs -> head; counterp != NULL; counterp = counterp -> next) {
                (*itemfunc)(arg, counterp -> key, counterp -> count);
            }
        }

/**************** counters_delete ****************/
/* see counters.h for description */
void 
counters_delete(counters_t* ctrs){
    if (ctrs == NULL) { return; }
    for (counter_t* counterp = ctrs -> head; counterp != NULL;) {
        counter_t* next = counterp -> next;
        mem_free(counterp);
        counterp = next;
    }
    mem_free(ctrs);
}



/**************** counter_new ****************/
/* Allocate and initialize a counter for a new key to 1: */
static counter_t* 
counter_new(int key) {

    counter_t* counterp = mem_malloc(sizeof(counter_t));
    if (counterp == NULL) { return NULL;}

    counterp -> key = key;
    counterp -> count = 1;
    counterp -> next = NULL;
    return counterp;
}

/**************** key_find ****************/
/* Return pointer to counter with desired key if key exists in counters set,
 * and NULL if key does not exist in set, or if a given pointer is invalid: */
static counter_t*
key_find(counters_t* setp, const int key) {

    if (setp == NULL) { return NULL; }

    for (counter_t* counterp = setp -> head; counterp != NULL; counterp = counterp -> next) {
        if ((counterp -> key) == key) { 
            return counterp; }
    }

    return NULL;

}
