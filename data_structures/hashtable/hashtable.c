
#include "hashtable.h"

/**************** global types ****************/
typedef struct hashtable{
    int CAPACITY;
    set_t** setArray;
} hashtable_t;  // opaque to users of the module

/**************** hashtable_new ****************/
/* see hashtable.h for description */
hashtable_t* 
hashtable_new(const int num_slots) {

    if (num_slots <= 0) 
        return NULL;
    hashtable_t* ht = malloc(sizeof(hashtable_t));
    if (ht == NULL) 
        return NULL;

    // setArray initialized to NULL-pointers:
    ht->CAPACITY = num_slots;
    ht->setArray = calloc(num_slots, sizeof(set_t*));
    if (ht->setArray == NULL)
        return NULL;
    for (int i = 0; i < (ht->CAPACITY); i++) 
        (ht->setArray)[i] = NULL;
    
    return ht;
}

/**************** hashtable_find ****************/
/* see hashtable.h for description */
void* 
hashtable_find(hashtable_t* ht, const char* key) {

    if (ht == NULL || key == NULL) 
        return NULL;

    for (int i = 0; i < (ht->CAPACITY); i++) {
        void * item = set_find((ht->setArray)[i], key);
        if (item != NULL)
            return item;
    }
    return NULL;
}

/**************** hashtable_insert ****************/
/* see hashtable.h for description */
bool 
hashtable_insert(hashtable_t* ht, const char* key, void* item) {
    if (ht == NULL || key == NULL || item == NULL ) 
        return false;

    // First check if key is already present:
    if (hashtable_find(ht,key) != NULL) 
        return false;

    // If key is not already present,
    // use Jenkins' Hash to map key to index within setArray:
    int setn = hash_jenkins(key, ht->CAPACITY);
    if ((ht->setArray)[setn] == NULL) 
        (ht->setArray)[setn] = set_new();
    return set_insert((ht->setArray)[setn], key, item);  
}

/**************** hashtable_iterate ****************/
/* see hashtable.h for description */
void 
hashtable_iterate(hashtable_t* ht, void* arg,
                       void (*itemfunc)(void* arg, const char* key, void* item) ) {
    if (ht == NULL || itemfunc == NULL) 
        return; 
    for (int i = 0; i < (ht -> CAPACITY); i++) {
        set_iterate((ht->setArray)[i], arg, itemfunc);
    }
}
            
/**************** hashtable_print ****************/
/* see hashtable.h for description */
void 
hashtable_print(hashtable_t* ht, FILE* fp, 
                     void (*itemprint)(FILE* fp, const char* key, void* item)) {

    if (fp == NULL)
        return;
    if (ht == NULL) {
        fprintf(fp, "(null)");
        return;
    }  
    fprintf(fp, "{");
    hashtable_iterate(ht, fp, itemprint);  
    fprintf(fp, "}");       
 }

/**************** hashtable_delete ****************/
/* see hashtable.h for description */
void 
hashtable_delete(hashtable_t* ht, void (*itemdelete)(void* item) ){
    if (ht == NULL) 
        return; 
    // Delete & free each set in hashtable:
    for (int i = 0; i < (ht -> CAPACITY); i++) {
        set_delete((ht -> setArray)[i], itemdelete);
    }
    // Delete & free empty setArray:
    free(ht->setArray);
    // Delete & free hashtable itself:
    free(ht);
}

