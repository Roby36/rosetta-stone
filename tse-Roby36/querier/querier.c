
/*
 *
 * querier.c - source file for 'querier' module
 * 
 * The TSE Querier is a standalone program that reads the index file 
 * produced by the TSE Indexer, and page files produced by the TSE Crawler, 
 * and answers search queries submitted via stdin.
 * 
 */

#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <strings.h>
#include <stdlib.h>
#include <ctype.h>
#include <unistd.h>
#include "pagedir.h"
#include "index.h"
#include "mem.h"
#include "word.h"
#include "set.h"
#include "file.h"


/****************** Mem module variables ********************/
int nmalloc = 0;         
int nfree = 0;           
int nfreenull = 0;


/******************* Global constants **************************/
const int QUERYMAXCHARACTERS = 1000;
const int MAXDOCUMENTS = 1000;


/******************* Querier function headers **************************/

/* ******************* fileno ************************************** 
 * The fileno() function is provided by stdio, but for some 
 * reason not declared by stdio.h, so we declare it here.
 */
int fileno(FILE *stream);

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
static void prompt(void);

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
static index_t* parseArgs(const int argc, char* argv[], char** pageDirectory);


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
static bool newQuery(char query[]);


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
 *   Thus, the query[] array is modified by this function.
 *   This function only ensures that each character is either alphabetical
 *   or a space, hence the caller is responsible for later checking
 *   that the "and/or" operators are used appropriately, and
 *   normalizing the words. 
 */
static int tokenize(char query[], char* words[]);


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
static void printQuery(char* words[], int wordNo);


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
static bool Query(char* pageDirectory, index_t* index, char* words[], int wordNo);


/* ******************* printRanked ************************************** */
/* This is a helper-function called by Query() to print the retrieved
 * documents in a descending order, starting from the one with the 
 * highest score. It is used as a parameter for set_iterate().
 */
static void printRanked(void* arg, const char*key, void* item);


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
static int parseInt(const char* directory);


/******************* Set functions headers **************************/

/* ******************* set_merge ************************************** */
/* This function is used to evaluate the union between two sets.
 *
 * We assume:
 *   Caller provides two non-NULL pointers to sets, with integer items.
 * 
 * We return:
 *   Nothing (void).
 *   
 * We guarantee:
 *   The fist set is changed to contain the union of both sets.
 *   The second set is unchanged.
 *   
 * Caller is responsible for:
 *   Later free'ing the set(s) of required.
 * 
 * Imporant:
 *   The value for each key in the union is given by the SUM of the
 *   key's values in the original sets.
 */
static void set_merge(set_t* setA, set_t* setB);


/* ******************* set_merge_helper ************************************** */
/* This is a helper-function used by set_merge().
 * It is used as a parameter for set_iterate().
 */
static void set_merge_helper(void* arg, const char* key, void* item);


/* ******************* set_intersect ************************************** */
/* This function is used to evaluate the intersection between two sets.
 *
 * We assume:
 *   Caller provides two non-NULL pointers to sets, with integer items.
 * 
 * We return:
 *   A set pointer to a new set containing the intersection of both sets.
 * 
 * We guarantee:
 *   Memory is malloc'd for the newly generated intersection set,
 *   and both sets are unchanged.
 *   
 * Caller is responsible for:
 *   Later free'ing the newly generated sets, 
 *   and the other sets if required.
 *   
 * Imporant:
 *   The value for each key in the intersection is given by the MINIMUM 
 *   of the key's values in the original sets.
 */
static set_t* set_intersect(set_t* setA, set_t* setB);


/* ******************* set_intersect_helper ******************************* */
/* This is a helper-function used by set_intersect().
 * It is used as a parameter for set_iterate().
 */
static void set_intersect_helper(void* arg, const char* key, void* item);


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
static int* intsave(int item);


/* ******************* set_copy ************************************** */
/* This is a helper-function used by Query() to copy and update sets.
 * It is used as a parameter for set_iterate().
 */
static void setcopy(void* arg, const char* key, void* item);


/* ******************* findmax ************************************** */
/* This is a helper-function used by Query() to compute the highest
 * integer item in a set. It is used as a parameter for set_iterate().
 */
static void findmax(void* arg, const char*key, void* item);


/* ******************* findsize ************************************** */
/* This is a helper-function used by Query() to compute the 
 * number of elements in a set. It is used as a parameter for set_iterate().
 */
static void findsize(void* arg, const char*key, void* item);


/* ******************* itemdelete ************************************** */
/* This is the standard function used by set_delete to delete a set.
 * It frees every non-NULL item in the set.
 */
static void itemdelete(void* item);


/* ******************* emptydelete ************************************** */
/* This is an empty function. It is used when deleting a set whose items 
 * have been passed into another set, as a parameter for set_delete().
 */
static void emptydelete(void* item){}


/******************* Main program starts here **************************/

int main(const int argc, char* argv[]) {

    char* pageDirectory;
    
    index_t* index = parseArgs(argc, argv, &pageDirectory);

    char query[QUERYMAXCHARACTERS];

    while (newQuery(query)) {

        char* words[(int)(strlen(query)/2)+1];
        int wordNo = tokenize(query,words);

        if (wordNo == -1) { continue; }

        for (int i = 0; i < wordNo; i++){
            normalizeWord(words[i]);
        }

        if (!Query(pageDirectory, index, words, wordNo)) {
            continue;
        }
    }

    fprintf(stdout,"\n");
    mem_free(pageDirectory);
    index_delete(index);
    return 0;
}


static index_t* 
parseArgs(const int argc, char* argv[], char** pageDirectory){

    const char* progName = argv[0];

    if (argc != 3) {
    fprintf(stderr, "Usage: %s pageDirectory indexFilename\n", progName);
    exit(1);
    }

    if (!pagedir_test(argv[1],"/.crawler") || !pagedir_test(argv[1],"/1")){
        fprintf(stderr,"%s: Please enter a valid pageDirectory marked for crawling.\n",progName);
        exit(2);
    }

    *pageDirectory = mem_malloc_assert(strlen(argv[1])+1,"pageDirectory");
    strcpy(*pageDirectory,argv[1]);

    index_t* index = loadIndex(argv[2]);

    if (index == NULL){
        mem_free(*pageDirectory);
        fprintf(stderr, "%s: Error opening %s for reading.\n",progName,argv[2]);
        exit(3);
    }
    return index;
}

static bool 
newQuery(char query[]) {

    prompt(); 
    if (fgets(query,QUERYMAXCHARACTERS,stdin) == NULL){
        return false;
    }
    return true;
}

static int
tokenize(char query[], char* words[]){

    if (query == NULL) {return -1; }

    int wordNo = 0;
    char* p = &query[0];

    while (1) {

        while (isspace(*p)) { p++; }

        if (*p == '\0'){
            words[wordNo] = p; // Trailing array with pointer to null character
            return wordNo;
        }
        else if (!isalpha(*p)){
            fprintf(stderr, "Bad character: %c\n", *p);
            return -1;
        }
        else{
            words[wordNo] = p;
            wordNo++;
        }

        while (isalpha(*p))  { p++; }

        if (*p == '\0') {
            words[wordNo] = p; // Trailing array with pointer to null character
            return wordNo;
        }
        else if (!isspace(*p)){
            fprintf(stderr, "Bad character: %c\n", *p);
            return -1;
        }
        else{
            *p = '\0'; //Truncate word by setting first space encountered to null character
            p++;
        } 
    }
}


static void 
printQuery(char* words[], int wordNo){
    fprintf(stdout,"Query: ");
    for (int i = 0; i < wordNo-1; i++){
        fprintf(stdout, "%s ", words[i]);
        }
    fprintf(stdout, "%s \n", words[wordNo-1]);
}


static bool 
Query(char* pageDirectory, index_t* index, char* words[], int wordNo){

    if (pageDirectory == NULL || index == NULL || words == NULL
    || wordNo < 0) { return false; }

    if ( strcmp(words[0],"and") == 0 || strcmp(words[0],"or") == 0){
        fprintf(stderr, "Operator '%s' cannot be first.\n", words[0]);
        return false;
    }
    if ( strcmp(words[wordNo-1],"and") == 0 || strcmp(words[wordNo-1],"or") == 0){
        fprintf(stderr, "Operator '%s' cannot be last.\n", words[wordNo-1]);
        return false;
    }

    for (int i = 1; i < wordNo-1; i++){
        if (strcmp(words[i],"and") == 0 || strcmp(words[i],"or") == 0){
            if (strcmp(words[i+1],"and") == 0 || strcmp(words[i+1],"or") == 0){
                fprintf(stderr,"Operators '%s'/'%s' cannot be adjacent.\n",words[i],words[i+1]);
                return false;
            }
        }
    }

    if (wordNo == 0){ return true; }

    printQuery(words, wordNo);

    set_t* currUnion = mem_assert(set_new(), "Current union");
    set_t* newInt;
    set_t* currInt;

    set_t* wordScores;
    int docScore;
    char* docPath;

    int currWordNo = 0;
    int andIt = 0;

    while (currWordNo < wordNo){

        while ( currWordNo < wordNo && strcmp(words[currWordNo], "or") != 0 ){

        if (strcmp(words[currWordNo], "and") != 0){

            wordScores = mem_assert(set_new(),"Word scores");

            for (int docID = 1; docID <= MAXDOCUMENTS; docID++ ){

                if ( (docScore = index_get(index, words[currWordNo],docID) ) > 0){

                    docPath = buildPath(pageDirectory,docID);
                    set_insert(wordScores, docPath, intsave(docScore));
                    mem_free(docPath);

                }
            }

            if (andIt == 0){
                currInt = mem_assert(set_new(), "Current intersection");
                set_merge(currInt,wordScores);
            }
            else{
                newInt = set_intersect(currInt,wordScores);
                set_delete(currInt,itemdelete);
                currInt = mem_assert(set_new(), "Current intersection");
                set_iterate(newInt,currInt,setcopy);
                set_delete(newInt,emptydelete);
            }
            set_delete(wordScores,itemdelete);
        }
        
        currWordNo++; 
        andIt++;
        }

        set_merge(currUnion, currInt);
        set_delete(currInt,itemdelete);
        andIt = 0;
        currWordNo++;
    }

    int max = 0;
    int size = 0; 

    set_iterate(currUnion,&max,findmax);
    set_iterate(currUnion,&size,findsize);

    if (max == 0) {
        fprintf(stdout, "No documents match.\n");
    }
    else{
        fprintf(stdout, "Matches %d document(s) (ranked):\n", size);
        for (int i = 0; i < max; i++){

        int thresh = max - i;

        set_iterate(currUnion, &thresh, printRanked);
        }
    }

    fprintf(stdout,"-------------------------------------------------------------------\n");

    set_delete(currUnion,itemdelete);
    
    return true;
}


static void printRanked(void* arg, const char*key, void* item){
    
    int* thresh = arg;
    int* num = item;

    if (*num == *thresh){

        FILE* fp = fopen(key,"r");
        char* url = file_readLine(fp);
        int docID = parseInt(key);

        fprintf(stdout,"score %d doc %d: %s\n", *num, docID, url);

        mem_free(url);
        fclose(fp);
    }
}


static int parseInt(const char* directory){

    char str[10];
    int pos = 0;
    char* copy = mem_malloc_assert(strlen(directory)+1,"Directory copy");
    strcpy(copy,directory);
    char* p = copy;
    int num = 0;

    while (*p != '\0') { p++; }
    while (*p != '/') { p--; }
    p++;
    while (*p != '\0'){
        str[pos] = *p;
        pos++;
        p++;
    }
    str[pos] = '\0';

    str2int(str,&num);
    mem_free(copy);
    return num;
}


static void 
findmax(void* arg, const char*key, void* item){
    int* max = arg;
    int* num = item;
    if (*num > *max) {*max = *num; }
}


static void 
findsize(void* arg, const char*key, void* item){
    int* size = arg;
    *size = *size + 1;
}


static void
prompt(void){
  if (isatty(fileno(stdin))) {
    printf("Query? ");
  }
}


static void 
set_merge(set_t* setA, set_t* setB) { 
    set_iterate(setB, setA, set_merge_helper);
}


static void 
set_merge_helper(void* arg, const char* key, void* item) {

  set_t* setA = arg;
  int* itemB = item;
  
  int* itemA = set_find(setA, key);
  if (itemA == NULL) {
    set_insert(setA, key, intsave(*itemB));

  } else {
    *itemA += *itemB;
  }
}


static set_t*
set_intersect(set_t* setA, set_t* setB){

    if ( setA == NULL || setB == NULL) {return NULL; }

    set_t* pointerSet = mem_assert(set_new(),"Pointer set");
    set_t* result = mem_assert(set_new(),"result");
    set_insert(pointerSet,"setB",setB);
    set_insert(pointerSet,"result",result);

    set_iterate(setA, pointerSet, set_intersect_helper);
    set_delete(pointerSet,emptydelete);

    return result;
}


static void 
set_intersect_helper(void* arg, const char* key, void* item){

    set_t* pointerSet = arg;

    set_t* setB = set_find(pointerSet,"setB");
    set_t* result = set_find(pointerSet,"result");

    int* itemA = item;

    int* itemB = set_find(setB,key);

    if ( itemB != NULL ) {

    int itemResult;
    if (*itemB < *itemA) { itemResult = *itemB; }
    else{ itemResult = *itemA; }

    set_insert(result, key, intsave(itemResult));
    }
}


static int* 
intsave(int item) {
  int* saved = mem_assert(malloc(sizeof(int)), "intsave");
  *saved = item;
  return saved;
}


static void 
setcopy(void* arg, const char* key, void* item){
    set_t* setA = arg;
    set_insert(setA, key, item);
}


static void 
itemdelete(void* item) {
  if (item != NULL)
    mem_free(item);
}

