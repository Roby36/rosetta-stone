
/*
 * Roberto Brera,  CS50
 *
 * Implementation of hashtable.h interface
 * 
*/

#ifndef __HASHTABLE_H
#define __HASHTABLE_H

#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <strings.h>
#include <stdlib.h>
#include "set.h"
#include "mem.h"
#include "hash.h"


/**************** global types ****************/
typedef struct hashtable{
    int CAPACITY;
    set_t** setArray;
} hashtable_t;  // opaque to users of the module


/**************** malloc, free, and freenull counters ****************/
int nmalloc = 0;
int nfree = 0;
int nfreenull = 0;

/**************** hashtable_new ****************/
/* see hashtable.h for description */
hashtable_t* 
hashtable_new(const int num_slots) {

    if (num_slots <= 0) {return NULL;}
    hashtable_t* hashtablep = mem_malloc(sizeof(hashtable_t));
    if (hashtablep == NULL) {return NULL;}

    hashtablep -> CAPACITY = num_slots;
    // setArray initialized to NULL-pointers:
    hashtablep -> setArray = mem_calloc(num_slots, sizeof(set_t*));
    if (hashtablep -> setArray == NULL) { return NULL; }
    for (int i = 0; i < (hashtablep -> CAPACITY); i++) { (hashtablep -> setArray)[i] = NULL; }
    
    return hashtablep;
}

/**************** hashtable_find ****************/
/* see hashtable.h for description */
void* 
hashtable_find(hashtable_t* ht, const char* key) {
    if (ht == NULL || key == NULL) { return NULL; }

    for (int i = 0; i < (ht -> CAPACITY); i++) {
        set_t* setp = (ht -> setArray)[i];
        if (set_find(setp,key) != NULL) {
            return set_find(setp,key);
        }
    }
    return NULL;
}

/**************** hashtable_insert ****************/
/* see hashtable.h for description */
bool 
hashtable_insert(hashtable_t* ht, const char* key, void* item) {
    if (ht == NULL || key == NULL || item == NULL ) { return false; }

    // First check if key is already present:
    if (hashtable_find(ht,key) != NULL) {return false;}

    // If key is not already present,
    // use Jenkins' Hash to map key to index within setArray:
    int setn = hash_jenkins(key,ht -> CAPACITY);
    if ((ht -> setArray)[setn] == NULL) { (ht -> setArray)[setn] = set_new(); }
    return set_insert((ht -> setArray)[setn], key, item);  
}

/**************** hashtable_print ****************/
/* see hashtable.h for description */
void 
hashtable_print(hashtable_t* ht, FILE* fp, 
                     void (*itemprint)(FILE* fp, const char* key, void* item)) {
                        if (fp != NULL) {
                            if (ht != NULL) {
                                for (int i = 0; i < (ht -> CAPACITY); i++){
                                    set_print((ht -> setArray)[i], fp, itemprint);
                                    fputc('\n',fp);
                                }
                            }
                            else {fputs("(null)", fp); }
                        }
                     }



/**************** hashtable_iterate ****************/
/* see hashtable.h for description */
void 
hashtable_iterate(hashtable_t* ht, void* arg,
                       void (*itemfunc)(void* arg, const char* key, void* item) ){
                        if (ht == NULL || itemfunc == NULL) { return; }
                        for (int i = 0; i < (ht -> CAPACITY); i++){
                            set_iterate((ht -> setArray)[i], arg, itemfunc);
                        }
                       }


/**************** hashtable_delete ****************/
/* see hashtable.h for description */
void 
hashtable_delete(hashtable_t* ht, void (*itemdelete)(void* item) ){
    if (ht == NULL) {return; }
    // Delete & free each set in hashtable:
    for (int i = 0; i < (ht -> CAPACITY); i++){
        set_delete((ht -> setArray)[i], itemdelete);
    }
    // Delete & free empty setArray:
    mem_free(ht -> setArray);
    // Delete & free hashtable itself:
    mem_free(ht);
}


#endif // __HASHTABLE_H
