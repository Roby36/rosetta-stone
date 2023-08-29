
/*
 * pagedir.c - source file for 'pagedir' module
 */

#include "pagedir.h"

/**************** pagedir_init ****************/
/* see pagedir.h for description */
bool 
pagedir_init(const char* pageDirectory, char* fileName){

    char* pathName = malloc(strlen(pageDirectory)+strlen(fileName)+1);
    strcpy(pathName, pageDirectory);
    strcat(pathName, fileName);

    FILE* fp;
    if ((fp = fopen(pathName,"w")) == NULL) { 
        free(pathName);
        return false; 
    }

    free(pathName);
    fclose(fp);
    return true;
}

/**************** pagedir_test ****************/
/* see pagedir.h for description */
bool 
pagedir_test(const char* pageDirectory, char* fileName){

    char* pathName = malloc(strlen(pageDirectory)+strlen(fileName)+1);
    strcpy(pathName, pageDirectory);
    strcat(pathName, fileName);

    FILE* fp;
    if ((fp = fopen(pathName,"r")) == NULL) { 
        free(pathName);
        return false; 
    }

    fclose(fp);
    free(pathName);
    return true;
}

/**************** pagedir_save ****************/
/* see pagedir.h for description */
void 
pagedir_save(const webpage_t* page, const char* pageDirectory, const int docID){

    char* pathName = malloc(strlen(pageDirectory) + 1);
    strcpy(pathName, pageDirectory);

    pathName = concatInt(pathName, docID);

    FILE* fp;
    if ((fp = fopen(pathName,"w")) == NULL) { 
        fprintf(stderr, "Error: could not create file for docIC %d. Please enter valid directory. \n", docID);
        exit(1);
    }
    
    fprintf(fp,"%s\n",webpage_getURL(page));
    fprintf(fp,"%d\n",webpage_getDepth(page));
    fprintf(fp,"%s\n",webpage_getHTML(page));

    free(pathName);
    fclose(fp);
}

/**************** concatInt ****************/
/* see pagedir.h for description */
char *
concatInt(char* p, int n) {

    // Initialize string on stack holding characters to append 
    char q[MAX_CONC_CHAR];

    // Find the least power of 10 exceeding the number to append 
    int i = 1;
    while (n % i != n)
        i *= 10;

    int bw = 0; // extra bits written 
    while (i > 1 && bw < MAX_CONC_CHAR) {
        // Access each base-10 digit and convert it to ascii 
        q[bw++] = (((n % i) - (n % (i/10))) / (i/10)) + '0';
        i = i/10;
    }

    // Allocate new space for resulting string, and concatenate int string from stack 
    char * r = malloc(strlen(p) + bw + 1);
    strncpy(r, p, strlen(p) + 1); // copy original string into new pointer
    strncat(r, q, bw);            // concatenate new chunk
    free(p);

    // Return pointer to new string 
    return r;
}

/**************** buildPath ****************/
/* see pagedir.h for description */
char*
buildPath(const char* pageDirectory, int docID){

    if (pageDirectory == NULL) {return NULL;}

    char* pathName = malloc(strlen(pageDirectory) + 1);
    strcpy(pathName, pageDirectory);
    pathName = concatInt(pathName, docID);

    return pathName;
}

#ifdef PAGEDIR_TEST

static void concatInt_test() {

    char * tp_temp      = "test_pagedir";
    int int_to_conc     = 0x111111111111;

    char * test_pagedir = malloc(strlen(tp_temp) + 1);
    strncpy(test_pagedir, tp_temp, strlen(tp_temp) + 1);

    printf("Extending %s with %d:\n", test_pagedir, int_to_conc);
    test_pagedir = concatInt(test_pagedir, int_to_conc);
    printf("Resulting string: %s\n", test_pagedir);
    free(test_pagedir);
}

int main() {

    concatInt_test();

    return 0;
}

#endif

