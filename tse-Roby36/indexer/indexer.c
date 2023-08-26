
/*
 *
 * indexer.c - source file for 'indexer' module
 * 
 * The indexer is a standalone program that reads the files produced
 * by the crawler, builds an index, and writes that index into a file.
 * 
 */

#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <strings.h>
#include <stdlib.h>
#include "word.h"
#include "mem.h"
#include "index.h"
#include "pagedir.h"
#include "webpage.h"
#include "file.h"


/****************** Mem module variables ********************/
int nmalloc = 0;         
int nfree = 0;           
int nfreenull = 0;      

/****************** Global constants ********************/
const int MAX_INDEX_SLOTS = 1000;

/* ******************* parseArgs ************************************** */
/* This function validates command-line arguments.
 *
 * We assume:
 *   Caller passes the parameters of main(), and two non-NULL string pointers 
 *   to store the pageDirectory and indexFilename parameters.
 *  
 * We return:
 *   Nothing (void).
 *   
 * We guarantee:
 *   If the provided page directory is not a valid directory marked for crawling, 
 *   or the provided index filename is not a valid path to a file which can be 
 *   opened for writing, we print an appropriate error message and exit the program.
 *   Otherwise, we malloc memory for *pageDirectory and *indexFilename
 *   to store the valid parameters.
 *   
 * Caller is responsible for:
 *   Later free'ing the memory allocated for pageDirectory and indexFilename.
 */
static void parseArgs(const int argc, char* argv[], char** pageDirectory, char** indexFilename);

/* ******************* indexBuild ************************************** */
/* This function makes an index for a crawling directory.
 *
 * We assume:
 *   Caller provides a valid pageDirectory marked for crawling,
 *   which has been validated by parseArgs.
 * 
 * We return:
 *   The pointer to an index for all the files in pageDirectory. 
 *   
 * We guarantee:
 *   All words in the index are normalized (converted to lowercase),
 *   and words with fewer than three characters are not added to the index.
 * 
 * Caller is responsible for:
 *   Later calling index_delete, and freeing the memory malloc'd
 *   for pageDirectory.
 */
static index_t* indexBuild(char* pageDirectory);

/* ******************* indexPage ************************************** */
/* This is a helper-function called by indexBuild which 
 * given an index, webpage, and docID adds all the appropriate words 
 * contained in the webpage to the index.
 */
static void indexPage(index_t* index, webpage_t* webpage, int docID);


int main(const int argc, char* argv[]){

    char* pageDirectory;
    char* indexFilename;
    parseArgs(argc, argv, &pageDirectory, &indexFilename);

    index_t* index = indexBuild(pageDirectory);
    FILE* fp = fopen(indexFilename,"w");
    index_print(index,fp);

    fclose(fp);
    index_delete(index);
    mem_free(pageDirectory);
    mem_free(indexFilename);

    #ifdef MEM_TEST
    mem_report(stdout,"End of main in indexer.c");
    #endif

    return 0;
}

static void 
parseArgs(const int argc, char* argv[], char** pageDirectory, char** indexFilename){

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

    FILE* fp = fopen(argv[2],"w");
    if (fp == NULL) {
        fprintf(stderr,"%s: Error opening %s for writing.\n",progName,argv[2]);
        exit(3);
    }
    fclose(fp);

    *indexFilename = mem_malloc_assert(strlen(argv[2])+1,"indexFilename");
    strcpy(*indexFilename,argv[2]);
}

static index_t* 
indexBuild(char* pageDirectory){

    index_t* index = index_new(MAX_INDEX_SLOTS);
    if (index == NULL) {
        fprintf(stderr, "indexBuild: Could not initialize index\n");
        exit(4);
    }

    int docID = 1;
    FILE* fp;
    webpage_t* webpage;

    char* pathName = buildPath(pageDirectory,docID);
    
    while ( (fp = fopen(pathName,"r")) != NULL ){

        char* url = file_readLine(fp); 
        char* depth = file_readLine(fp); 
        int depthInt;
        if (!str2int(depth, &depthInt)){
            fprintf(stderr,"buildPath: Error reading depth for %s", pathName);
            continue;
        }
        mem_free(depth);
        char* html = file_readFile(fp);
        
        webpage = webpage_new(url, depthInt, html);
        if (webpage != NULL) {
            indexPage(index, webpage, docID);
        } else{
            fprintf(stderr,"buildPath: Error loading webpage for %s", pathName);
        }

        webpage_delete( (webpage_t*) webpage);
        mem_free(pathName);
        fclose(fp);

        docID++;
        pathName = buildPath(pageDirectory, docID);
    }

    mem_free(pathName);
    return index; 
}

static void
indexPage(index_t* index, webpage_t* webpage, int docID){

    int pos = 0;
    char* word;

    while ((word = webpage_getNextWord(webpage,&pos)) != NULL){

        #ifdef WORD_TEST
        if (docID == 1) {fprintf(stdout,"%s \n",word);}
        #endif

        if (strlen(word) >= 3){
    
         normalizeWord(word);
         index_add(index,word,docID);
        }
        mem_free(word);
    }
}


