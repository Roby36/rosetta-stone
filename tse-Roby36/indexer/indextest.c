
/*
 *
 * indextest.c - source file for 'indextest' module
 * 
 * The indextester is a program that loads an index file 
 * produced by the indexer and saves it to another file,
 * in order to test the index data structure.
 * 
 */

#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <strings.h>
#include <stdlib.h>
#include <ctype.h>
#include "mem.h"
#include "index.h"
#include "file.h"


/****************** Mem module variables ********************/
int nmalloc = 0;         
int nfree = 0;           
int nfreenull = 0;      

/* ******************* parseArgs ************************************** */
/* This function validates the command line arguments.
 *
 * We assume:
 *   Caller provides the arguments of the main method, and
 *   initialized string pointers oldIndexFilename and newIndexFilename,
 *   storing file names.
 * 
 * We return:
 *   Nothing.
 *   
 * We guarantee:
 *   The function verifies that exactly 3 command line arguments are entered,
 *   and prints an appropriate error message if not. 
 *   We also allocate memory for the strings *oldIndexFilename and *newIndexFilename
 *   but do not verify whether they represent valid path names.
 * 
 * Caller is responsible for:
 *   Later free'ing the memory allocated for *oldIndexFilename and *newIndexFilename.
 */
static void parseArgs(const int argc, char* argv[], char** oldIndexFilename, char** newIndexFilename);


int main(const int argc, char* argv[]){

    char* oldIndexFilename;
    char* newIndexFilename;

    parseArgs(argc, argv, &oldIndexFilename, &newIndexFilename);

    index_t* index = loadIndex(oldIndexFilename);
    FILE* fp = fopen(newIndexFilename,"w");
    index_print(index,fp);

    index_delete(index);
    if (fp != NULL) { fclose(fp); }
    mem_free(oldIndexFilename);
    mem_free(newIndexFilename);

    #ifdef MEM_TEST
    mem_report(stdout,"End of main in indextest.c");
    #endif

    return 0;
}

static void 
parseArgs(const int argc, char* argv[], char** oldIndexFilename, char** newIndexFilename){

    const char* progName = argv[0];

    if (argc != 3) {
    fprintf(stderr, "Usage: %s oldIndexFilename newIndexFilename\n", progName);
    exit(1);
    }

    *oldIndexFilename = mem_malloc_assert(strlen(argv[1])+1, "oldIndexFilename");
    *newIndexFilename = mem_malloc_assert(strlen(argv[2])+1, "newIndexFilename");

    strcpy(*oldIndexFilename,argv[1]);
    strcpy(*newIndexFilename,argv[2]);
}

