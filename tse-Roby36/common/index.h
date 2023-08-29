
/*
 *
 * index.h - header for 'index' module
 *
 * An 'index' is a data structure consisting of a hash table
 * mapping words to countersets, which map each docID to the 
 * count of occurences of the word in the document with given doc ID. 
 *
 */

#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <strings.h>
#include <stdlib.h>
#include "hashtable.h"
#include "counters.h"
#include "file.h"

/**************** global types ****************/
typedef struct index index_t;

/**************** functions ****************/

/* ******************* index_new ************************************** */
/* This function is used to allocate memory for a new index data structure.
 *
 * We assume:
 *  Caller provides a parameter for the maximum number 
 *  of words in the index given by num_slots > 0, 
 *  else NULL is returned.
 * 
 * We return:
 *  The pointer to a new index, or NULL if error.
 *   
 * We guarantee:
 *  The index is initialized empty.
 *  
 * Caller is responsible for:
 *  Later calling index_delete() to free the memory.
 */
index_t* index_new(const int num_slots);

/* ******************* index_add ************************************** */
/* This function is used to record within an index the occurrence
 * of a given word.
 *
 * We assume:
 *   Caller provides a non-NULL pointer to an index,
 *   a string as a word, and a docID >= 1.
 * 
 * We return:
 *   false if either index is NULL, word is NULL or docID < 1.
 *   false if any error occured while adding the word to the index.
 *   true if and only if word is succesfully added to the index.
 *   
 * We guarantee:
 *   word is added to the index and countersets are initialized 
 *   whenever necessary
 *   
 * Notes:
 *   The key string is copied for use by the index; that is, the module
 *   is responsible for allocating memory for a copy of the key string, and
 *   later deallocating that memory; thus, the caller is free to re-use or 
 *   deallocate its key string after this call.  
 */
bool index_add(index_t* index, const char* word, const int docID);




/**************** index_get ****************/
/* see index.h for description */
int index_get(index_t* index, const char* word, const int docID);




/* ******************* index_print ************************************** */
/* This function prints an index in the required format.
 *
 * We assume:
 *   caller provides a non-NULL pointer to an index and a non-NULL pointer 
 *   to a file open for writing where the index needs to be printed.
 * 
 * We return:
 *   Nothing (void).
 *   If any of the pointers is null the function prints nothing.
 *   Otherwise the function prints the given index in the given file,
 *   in the format described below.
 *   
 * We guarantee:
 *   If the parameters are valid, we print one word per line
 *   and one line per word to the file in the required format:
 * 
 *   word docID count [docID count] ...
 * 
 * Notes:
 *  Within the file, the words may be in any order.
 */
void index_print(index_t* index, FILE* fp);

/* ******************* index_delete ************************************** */
/* This function deletes the entire index
 *
 * We assume:
 *   Caller provides a non-NULL pointer to an index.
 * 
 * We return:
 *   Nothing.
 *   
 * We guarantee:
 *   We free all the memory within the index data structure.
 *     
 * Notes:
 *   the order in which items are deleted is undefined.
 */
void index_delete(index_t* index);

/* ******************* hashprint ************************************** */
/* Static function, called by index_print 
 * to print index in required format.
 */
void hashprint(void* arg, const char* key, void* item);

/* ******************* counterprint ************************************** */
/* Static function, called by hashprint
 * to print index in required format.
 */
void counterprint(void* arg, const int docID, const int count);

/* ******************* counters_delete_casted ************************************** */
/* Static function, called by index_delete to cast items of hashtable
 * to counters pointers so that they can be deleted by counters_delete.
 */
void counters_delete_casted(void* item);


/* ******************* loadIndex ************************************** */
/* This function stores the contents of a file created by the indexer
 * into an index data structure.
 *
 * We assume:
 *   Caller provides pathname oldIndexFilename of a file created
 *   by the indexer in the required format.
 * 
 * We return:
 *   NULL if oldIndexFilename is not a valid pathname.
 *   Otherwise, we return a pointer to an index storing 
 *   the contents of the file.
 *   
 * We guarantee:
 *   We handle all the memory malloc'ing and free'ing related to
 *   copying the file's contents into the index
 *   
 * Caller is responsible for:
 *   Later calling index_delete on the index.
 *   
 * Notes:
 *   The function assumes that the file provided is written
 *   in the appropriate format.
 */
index_t* loadIndex(char* oldIndexFilename);


/* ******************* str2int ************************************** */
/* This function converts a string into an integer.
 *
 * We assume:
 *   Caller provides a valid string string[] 
 *   and a valid pointer to an integer *number.
 * 
 * We return:
 *   If the string can be casted to an integer, the function returns 
 *   true and assigns the resulting integer to the pointer *number
 *   provided by the caller.
 *   Otherwise, the function returns false.
 *  
 * Caller is responsible for:
 *   Providing a string which contains one and only one integer,
 *   and nothing else.
 */
bool str2int(const char string[], int *number);
