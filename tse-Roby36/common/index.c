
/*
 *
 * index.c - source file for 'index' module
 *
 * An 'index' is a data structure consisting of a hash table
 * mapping words to countersets, which map each docID to the 
 * count of occurences of the word in the document with given doc ID. 
 *
 */

#include "index.h"

/**************** global types ****************/
typedef struct index{
    int CAPACITY;
    hashtable_t* hp;
} index_t;

/**************** index_new ****************/
/* see index.h for description */
index_t*
index_new(const int num_slots){

    if (num_slots <= 0) {return NULL;}

    hashtable_t* hp = hashtable_new(num_slots);
    if (hp == NULL) {return NULL;}

    index_t* new = malloc(sizeof(index_t));
    new -> CAPACITY = num_slots;
    new -> hp = hp;

    return new;  
}

/**************** index_add ****************/
/* see index.h for description */
bool
index_add(index_t* index, const char* word, const int docID) {

    if (index == NULL || word == NULL || docID < 1) {return false; }

    counters_t* countersp = (counters_t*) hashtable_find(index -> hp, word);

    if (countersp == NULL) {
        countersp = counters_new();
        if (!hashtable_insert(index -> hp, word, countersp)){
            fprintf(stderr, "Error initializing new counterset for %s",word);
            return false;
        }
    }

    if (counters_add(countersp, docID) == 0) {
        fprintf(stderr, "Error incrementing counters for %s in docID %d",word, docID);
            return false;
    }

    return true; 
}

/**************** index_get ****************/
/* see index.h for description */
int
index_get(index_t* index, const char* word, const int docID){

    if (index == NULL || word == NULL || docID < 1) {return -1; }

    counters_t* countersp = (counters_t*) hashtable_find(index -> hp, word);

    if (countersp == NULL) { return 0; }

    return counters_get(countersp,docID);

}

/**************** index_print ****************/
/* see index.h for description */
void
index_print(index_t* index, FILE* fp) {

    if (index == NULL || fp == NULL) { return; }

    hashtable_iterate(index -> hp, (void*) fp, hashprint);
}

/**************** hashprint ****************/
/* see index.h for description */
void
hashprint(void* arg, const char* key, void* item){

    FILE* fp = arg;
    counters_t* counters = item;

    fprintf(fp, "%s", key);
    counters_iterate(counters, (void*) fp, counterprint);
    fprintf(fp,"\n");
}

/**************** counterprint ****************/
/* see index.h for description */
void 
counterprint(void* arg, const int docID, const int count){
    FILE* fp = arg;
    fprintf(fp," %d %d", docID, count);
}

/**************** index_delete ****************/
/* see index.h for description */
void
index_delete(index_t* index) {

    if (index == NULL) {return;}

    hashtable_delete(index -> hp, counters_delete_casted);

    free(index);
}

/**************** counters_delete_casted ****************/
/* see index.h for description */
void
counters_delete_casted(void* item){
    counters_t* counters = item;
    counters_delete(counters);
}


/**************** str2int ****************/
/* see index.h for description */
bool 
str2int(const char string[], int* number) { 

  char nextchar;
  if (sscanf(string, "%d%c", number, &nextchar) == 1) { 
    return true; } 
  else { return false; }
}


/**************** loadIndex ****************/
/* see index.h for description */
index_t* 
loadIndex(char* oldIndexFilename){

    FILE* fp = fopen(oldIndexFilename,"r");
    if (fp== NULL) { return NULL; }

    index_t* index = index_new(file_numLines(fp)+1);

    char* currWord;
    char* nextWord;

    char* word;
    int docID;
    int count;

    word = file_readWord(fp);

    while ( (currWord = file_readWord(fp)) != NULL && (nextWord = file_readWord(fp)) != NULL ){

        if (!str2int(currWord,&docID)){

            // Copy currWord into word:
            free(word);
            word = malloc(strlen(currWord)+1);
            strcpy(word,currWord);

            // Copy nextWord into currWord:
            free(currWord);
            currWord = malloc(strlen(nextWord)+1);
            strcpy(currWord,nextWord);

            // Shift forward nextWord and file pointer by one word:
            free(nextWord);
            nextWord = file_readWord(fp);
        }

        str2int(currWord,&docID);
        str2int(nextWord,&count);
        for (int i = 0; i < count; i++){
            index_add(index,word,docID);
        }
            
        free(currWord);
        free(nextWord);
    }

    free(word);

    fclose(fp);
    return index;
}



/**************** testing ****************/

#ifdef INDEX_UNIT_TEST

int main(){

    index_t* index = index_new(100);

    index_add(index, NULL, 1);
    index_add(NULL,"rr",1);
    index_add(index, "cat", 0);
    index_add(index, "cat", -20);
    index_add(index, "dog", -1);

    index_add(index, "cat", 1);
    index_add(index, "cat", 1);
    index_add(index, "cat", 1);
    index_add(index, "cat", 2);
    index_add(index, "cat", 2);

    index_add(index, "CS50", 1);
    index_add(index, "CS50", 1);
    index_add(index, "CS50", 1);
    index_add(index, "cs50", 2);
    index_add(index, "cs50", 2);

    index_add(index, "dog", 3);
    index_add(index, "dog", 3);
    index_add(index, "dog", 3);
    index_add(index, "dog", 5);
    index_add(index, "dog", 5);
    index_add(index, "dog", 6);
    index_add(index, "dog", 7);

    index_print(index,stdout);

    index_delete(index);   

    return 0;
    
}

#endif  // INDEX_UNIT_TEST

