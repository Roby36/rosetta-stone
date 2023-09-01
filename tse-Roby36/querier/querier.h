
/*
 * 
 * The TSE Querier is a standalone program that reads the index file 
 * produced by the TSE Indexer, and page files produced by the TSE Crawler, 
 * and answers search queries submitted via stdin.
 * 
 */

#include <stdio.h>
#include <ctype.h>
#include <stdbool.h>
#include <string.h>
#include <strings.h>
#include <stdlib.h>
#include <ctype.h>
#include <unistd.h>
#include "pagedir.h"
#include "index.h"
#include "set.h"
#include "file.h"

#define MAXINTDIGITS 16

/* ******************* fileno ************************************** 
 * The fileno() function is provided by stdio, but for some 
 * reason not declared by stdio.h, so we declare it here.
 */
int fileno(FILE *stream);

/******************* Global constants **************************/
const int QUERYMAXCHARACTERS = 1000;
const int MAXDOCUMENTS = 1000;

/* ******************* prompt ************************************** */
/* This function is used to print a prompt if and only if stdin
 * comes from a keyboard.  
 *
 * We assume:
 *   caller provides no parameters (void)
 * 
 * We return:
 *   Nothing (void)
 * 
 * We guarantee:
 *   A prompt "Query? " is printed if and only if stdin comes from
 *   a keyboard, else no prompt is printed.
 */
void prompt(void);

/* ******************* normalizeWord ************************************** */
/* This function normalizes a word, converting it to lower-case.
 *
 * We assume:
 *   Caller provides a pointer to a non-NULL string pointer.
 * 
 * We return:
 *   Nothing (void).
 *   
 * We guarantee:
 *   If the provided word is NULL, it is ignored.
 *   Otherwise, every alphabetical character of the word is converted
 *   to lower-case, and all non-alphabetical characters remain unchanged.
 *   
 * Notes:
 *   Memory is neither allocated nor freed; the word characters
 *   are changed in place, maintaining their original places in memory.
 *   The normalized word maintains the same pointer and memory address
 *   as the original word (which is permanently changed).
 */
void normalizeWord(char* word);

/* ******************* parseArgs ************************************** */
/* This function is used to validate the command line arguments, and
 * create an index which will be used for the query. 
 *
 * We assume:
 *   Caller provides the arguments of main, and a pointer 
 *   char** pageDirectory to a string declared but without any 
 *   malloc'd memory.
 * 
 * We return:
 *   The index created from the indexFilename entered by the user.
 *   If error, we exit the program with an error message.
 *   
 * We guarantee:
 *   Memory is malloc'd for the pageDirectory string if and only if
 *   the directory is a valid directory marked for crawling.
 *   We ensure that only three commandline arguments are entered and,
 *   if the indexFilename provided by the user is a valid path to
 *   a file (with the correct indexing format) we return the resulting
 *   index data structure.
 *   
 * Caller is responsible for:
 *   Later free'ing the pageDirectory string.
 *   
 * Notes:
 *   This function does verify the validity of the crawling directory,
 *   but NOT of the indexing file (as required by the specs). Hence, 
 *   the user must input an appropriate indexFilename.
 */
index_t* parseArgs(const int argc, char* argv[], char** pageDirectory);

/* ******************* newQuery ************************************** */
/* This function is used to start a new query.
 *
 * We assume:
 *   Caller provides an initialized array of characters query[].
 * 
 * We return:
 *   True if the user input is successfully entered in the query[]
 *   array from stdin.
 *   False if either there was an error saving the query string or if
 *   the user entered EOF.
 *   
 * We guarantee:
 *   A prompt "Query? " is printed if and only if stdin comes from a 
 *   keyboard. If true is returned, the query[] array is updated
 *   with the current query string entered by the user.
 */
bool newQuery(char query[]);

/* ******************* tokenize ************************************** */
/* This function is used to "tokenize" the query string entered by the
 * user into separate words.
 *
 * We assume:
 *   Caller provides query[] array containing current query string and
 *   initialized array of strings char* words[].
 * 
 * We return:
 *   The number of words contained by the query. 
 *   -1 if any error occurs, or if the query contains any 
 *   non-alphabetical characters.
 * 
 * We guarantee:
 *   The array of strings is updated to contain all the words contained 
 *   in the query string, and we return its length (number of words).
 *   We also guarantee that the input query contains alphabetical 
 *   characters only.
 *   
 * Notes:
 *   No memory is malloc'd for the words. The char* words[] array simply
 *   contains the pointers to the first characters of each word, which
 *   has been appropriately truncated with a null character at the end.
 *   Thus, the query[] array IS modified by this function.
 *   This function only ensures that each character is either alphabetical
 *   or a space, hence the caller is responsible for later checking
 *   that the "and/or" operators are used appropriately, and
 *   normalizing the words. 
 */
int tokenize(char query[], char* words[]);

/* ******************* printQuery ************************************** */
/* This function prints the query string to stdout, after it has been 
 * validated, normalized, and stripped of excess white spaces.
 *
 * We assume:
 *   Caller provides the array of words for the query and the number 
 *   of words contained in it.
 * 
 * We return:
 *   Nothing (void).
 *   
 * We guarantee:
 *   Query string printed appropriately to stdout, 
 *   including new line at the end.
 *   
 * Caller is responsible for:
 *   Ensuring that wordNo matches the number of words in the array.
 *   Else the query may not be printed properly or a stack smashing 
 *   error may be triggered if wordNo exceeds the size of the array
 */
void printQuery(char* words[], int wordNo);

/* ******************* Query ************************************** */
/* This is the main function of the program, finding the approipriate
 * documents for the query.
 *
 * We assume:
 *   Caller provides pageDirectory containing crawled pages/documents,
 *   valid index data structure storing the occurrences of each word
 *   in the crawled documents, array of words of current query,
 *   and the number of words stored in the array.
 *   We assume that these parameters have been validated already.
 * 
 * We return:
 *   True if and only if the documents (including none) were 
 *   successfully retrieved and printed to stdout, false if any error 
 *   occurs, or if the syntax of the query is unacceptable. 
 *   
 * We guarantee:
 *   We verify that and/or operators are never adjacent, nor 
 *   first or last in the query string. We also print all the 
 *   retrieved documents' URLs ranked, and using the required format.
 *   
 * Caller is responsible for:
 *   Later free'ing pageDirectory and index.  
 */
bool Query(char* pageDirectory, index_t* index, char* words[], int wordNo);

/* ******************* printRanked ************************************** */
/* This is a helper-function called by Query() to print the retrieved
 * documents in a descending order, starting from the one with the 
 * highest score. It is used as a parameter for set_iterate().
 */
void printRanked(void* arg, const char*key, void* item);

/* ******************* parseInt ************************************** */
/* This function is used to extract the trailing docID from a 
 * pathname to a document.
 *
 * We assume:
 *   Caller provides a pathname string with a tailing integer.
 * 
 * We return:
 *   The integer at the end of the pathname, or 0 if any error,
 *   or if the pathname contains no integer at the end.
 *   
 * We guarantee:
 *   The directory string is unchanged.
 */
int parseInt(char* directory);

/******************* Set functions headers **************************/

/* ******************* intsave ************************************** */
/* This function is used to store integers as items in sets.
 *
 * We assume:
 *   Caller provides an integer.
 * 
 * We return:
 *   A pointer to malloc'd memory for the integer.
 *   
 * We guarantee:
 *   Memory is appropriately malloc'd for the integer. 
 *   Otherwise, if malloc fails, an error message is printed and the 
 *   program is exited.
 *   
 * Caller is responsible for:
 *  Later free'ing the memory allocated for the integer.
 */
int* intsave(int item);

/* ******************* findmax ************************************** */
/* This is a helper-function used by Query() to compute the highest
 * integer item in a set. It is used as a parameter for set_iterate().
 */
void findmax(void* arg, const char*key, void* item);


/* ******************* findsize ************************************** */
/* This is a helper-function used by Query() to compute the 
 * number of elements in a set. It is used as a parameter for set_iterate().
 */
void findsize(void* arg, const char*key, void* item);


/* ******************* itemdelete ************************************** */
/* This is the standard function used by set_delete to delete a set.
 * It frees every non-NULL item in the set.
 */
void itemdelete(void* item);

/* Additional helpers */

bool validate_query(char* pageDirectory, index_t* index, char* words[], int wordNo);
void take_set_intersection(char* pageDirectory, index_t* index, char* words[], 
                                set_t** currIntp, int currWordNo, int andIt);

void print_query_results(set_t * currUnion);
