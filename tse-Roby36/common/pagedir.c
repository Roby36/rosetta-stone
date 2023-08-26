
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

    char* pathName = malloc(strlen(pageDirectory)+10);
    strcpy(pathName, pageDirectory);

    char* p = pathName;

    concatInt(docID, p);

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
void 
concatInt(int n, char* p){

    while (*p != '\0') { p++; }
    *p = '/'; 

    int i = 1;
    while (n % i != n) { i*=10; }

    while (i > 1){
    p++;   
    *p = ((n % i) - (n % (i/10)))/(i/10) + '0';
    i = i/10;
    }
     
    p++;
    *p = '\0';
}

/**************** buildPath ****************/
/* see pagedir.h for description */
char*
buildPath(const char* pageDirectory, int docID){

    if (pageDirectory == NULL) {return NULL;}

    char* pathName = malloc(strlen(pageDirectory)+10);
    strcpy(pathName,pageDirectory);
    char* p = pathName;
    concatInt(docID,p);

    return pathName;
}

