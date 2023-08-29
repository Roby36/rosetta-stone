
/*
 *
 * word.c - source file for 'word' module
 * 
 */

#include <ctype.h>
#include <string.h>
#include <strings.h>
#include <stdlib.h>
#include "word.h"

/**************** normalizeWord ****************/
/* see word.h for description */
void 
normalizeWord(char* word){

    if (word == NULL){ return; }

    char* p = word;
    while (*p != '\0') {
        *p = tolower(*p);
        p++;
    }  
}




