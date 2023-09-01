

#include "querier.h"


index_t* 
parseArgs(const int argc, char* argv[], char** pageDirectory)
{
    const char* progName = argv[0];

    if (argc != 3) {
        fprintf(stderr, "Usage: %s pageDirectory indexFilename\n", progName);
        exit(1);
    }

    if (!pagedir_test(argv[1], "/.crawler") || !pagedir_test(argv[1], "/1")){
        fprintf(stderr,"%s: Please enter a valid pageDirectory marked for crawling.\n", progName);
        exit(2);
    }

    *pageDirectory = malloc(strlen(argv[1]) + 1);
    strcpy(*pageDirectory,argv[1]);

    index_t* index = loadIndex(argv[2]);

    if (index == NULL){
        free(*pageDirectory);
        fprintf(stderr, "%s: Error opening %s for reading.\n", progName, argv[2]);
        exit(3);
    }
    return index;
}



bool 
newQuery(char query[]) {

    prompt(); 
    if (fgets(query, QUERYMAXCHARACTERS, stdin) == NULL) {
        return false;
    }
    return true;
}



int
tokenize(char query[], char* words[])
{
    if (query == NULL) 
        return -1;

    int wordNo = 0;
    char* p = &query[0];    // pointer to first character in array

    while (true) {
        // Ignore spaces 
        while (isspace(*p)) 
            p++;
        // End of query string 
        if (*p == '\0') {
            words[wordNo] = p; // Trailing array with pointer to null character
            return wordNo;
        }
        // Non-alphabetical character 
        else if (!isalpha(*p)) // no need for function call: can directly check with ascii codes
        {
            fprintf(stderr, "Bad character: %c\n", *p);
            return -1;
        }
        // Found valid alphabetical character, at start of word 
        words[wordNo++] = p;
        
        // Keep iterating until first non-alphabetical character 
        while (isalpha(*p))  
            p++;
        // End of query string: DRY 
        if (*p == '\0') {
            words[wordNo] = p; // Trailing array with pointer to null character
            return wordNo;
        }
        // Bad character 
        else if (!isspace(*p)){
            fprintf(stderr, "Bad character: %c\n", *p);
            return -1;
        }
        // Space = End of word 
        *(p++) = '\0'; //Truncate word by setting first space encountered to null character
    }
}



void 
printQuery(char* words[], int wordNo){
    printf("Query: ");
    for (int i = 0; i < wordNo - 1; i++){
        printf("%s ", words[i]);
    }
    printf("%s \n", words[wordNo-1]);
}



void take_set_intersection(char* pageDirectory, index_t* index, char* words[], 
                                set_t** currIntp, int currWordNo, int andIt)
{
    int docScore;
    char* docPath;
    set_t* newInt;  // Temporary pointer 
    set_t * wordScores = set_new(); // New temporary set mapping document -> word occurrence 

    // Insert in the set the word occurrence of the new word in each document 
    for (int docID = 1; docID < MAXDOCUMENTS; docID++ ) {

        if ( (docScore = index_get(index, words[currWordNo], docID) ) > 0) {
            docPath = buildPath(pageDirectory, docID);
            set_insert(wordScores, docPath, intsave(docScore));
            free(docPath);
        }
    }

    // Initialize interection set upon fist "and" iteration 
    if (andIt == 0) {
        set_merge(*currIntp, wordScores);
    }
    // Update intersection set if not first "and" iteration 
    else {
        // generate new intersection set (items are malloc'd)
        newInt = set_intersect(*currIntp, wordScores);
        // delete old intersection set
        set_delete(*currIntp, itemdelete);
        // update current intersection set pointer
        *currIntp = newInt;
    }

    // Clean up temporary set holding scores for given word
    set_delete(wordScores, itemdelete);
}



void print_query_results(set_t * currUnion)
{
    int max = 0;
    int size = 0; 
    set_iterate(currUnion, &max,  findmax);
    set_iterate(currUnion, &size, findsize);

    if (max == 0) {
        printf("No documents match.\n");
    }
    else {
        printf("Matches %d document(s) (ranked):\n", size);
        for (int i = 0; i < max; i++) {
            int thresh = max - i;
            set_iterate(currUnion, &thresh, printRanked);
        }
    }
    printf("-------------------------------------------------------------------\n");
}



bool validate_query(char* pageDirectory, index_t* index, char* words[], int wordNo)
{
// Checking for NULL pointers 
    if (pageDirectory == NULL || index == NULL || words == NULL || wordNo < 0) 
        return false;
// Checking for "and" & "or" operators at the beginning 
    if ( strcmp(words[0], "and") == 0 || strcmp(words[0], "or") == 0) {
        fprintf(stderr, "Operator '%s' cannot be first.\n", words[0]);
        return false;
    }
// Checking for "and" & "or" operators at the end 
/** ERROR: Bad memory access words[wordNo - 1]: 
 * doesn't segfault probably because compiler allocates a copy of words[] on the stack...  */
    if ( strcmp(words[wordNo - 1], "and") == 0 || strcmp(words[wordNo - 1], "or") == 0){
        fprintf(stderr, "Operator '%s' cannot be last.\n", words[wordNo - 1]);
        return false;
    }
// Checking for consecutive operators 
    for (int i = 1; i < wordNo - 1; i++) {
        if ((strcmp(words[i],"and") == 0     || strcmp(words[i],"or") == 0) &&
            (strcmp(words[i + 1],"and") == 0 || strcmp(words[i + 1],"or") == 0)) 
        {
            fprintf(stderr,"Operators '%s'/'%s' cannot be adjacent.\n", words[i], words[i + 1]);
            return false;
        }
    }
// Return true if no query invalidities 
    return true;
}



bool 
Query(char* pageDirectory, index_t* index, char* words[], int wordNo) {

    if (!validate_query(pageDirectory, index, words, wordNo))
        return false;

    // Checking empty query 
    if (wordNo == 0)
        return true;

    printQuery(words, wordNo);

    set_t* currUnion = set_new(); // initialize union set
    set_t* currInt;               // declare intersection set
    int currWordNo = 0;
    int andIt = 0;  // number of inner "and" iterations

    // Iterate until we reach total word count 
    while (currWordNo < wordNo) {
        // Enter inner "and" intersection  
        currInt = set_new();   
        while ( currWordNo < wordNo && strcmp(words[currWordNo], "or") != 0 ) {
            // Ignore "and" operator, and update intersection set 
            if (strcmp(words[currWordNo], "and") != 0) {
                take_set_intersection(pageDirectory, index, words, &currInt, currWordNo, andIt);
            }
            // Increment word iterator, and and-iteration 
            currWordNo++; 
            andIt++;
        }
        set_merge(currUnion, currInt);      // Merge current intersection into current union
        set_delete(currInt, itemdelete);    // Delete current intersection set
        andIt = 0;                          // Reset and iterations
        currWordNo++;
    }

    // Print results & clean up 
    print_query_results( currUnion);
    set_delete(currUnion, itemdelete);
    return true;
}

void printRanked(void* arg, const char*key, void* item){
    
    int* thresh = arg;
    int* num    = item;

    if (*num != *thresh)
        return;
    FILE* fp = fopen(key,"r");
    char* url = file_readLine(fp);
    int docID = parseInt(key);
    printf("score %d doc %d: %s\n", *num, docID, url);
    free(url);
    fclose(fp);
}

int parseInt(char* directory)
{
    char int_str[MAXINTDIGITS];
    int pos = 0;
    int num = 0;

    // Access final string character 
    char* p = &directory[strlen(directory)]; 

    // Go back to character just before slash 
    while (*p != '/') 
        p--;
    
    // Populate int_str 
    while (*p != '\0') {
        p++;
        int_str[pos++] = *p;
    }

    // Extract integer from strign and return 
    str2int(int_str, &num);
    return num;
}

void 
findmax(void* arg, const char* key, void* item){
    int * max = arg;
    int * num = item;
    *max = (*num > *max) ? *num : *max;
}


void 
findsize(void* arg, const char* key, void* item){
    int * size = arg;
    *size = *size + 1;
}

void
prompt(void){
  if (isatty(fileno(stdin))) {
    printf("Query? ");
  }
}

int* 
intsave(int item) {
  int * saved = malloc(sizeof(int));
  *saved = item;
  return saved;
}

void 
itemdelete(void* item) {
  if (item != NULL)
    free(item);
}

void 
normalizeWord(char* word){

    if (word == NULL)
        return; 

    char* p = word;

    while (*p != '\0') {
        *p = tolower(*p);
        p++;
    }  
}

/******************* Main program starts here **************************/

int main(const int argc, char* argv[]) {

    char* pageDirectory;
    
    index_t* index = parseArgs(argc, argv, &pageDirectory);

    char query[QUERYMAXCHARACTERS];

    while (newQuery(query)) {

        char* words[(int)(strlen(query)/2) + 1];
        int wordNo = tokenize(query, words);

        if (wordNo == -1) 
            continue;

        for (int i = 0; i < wordNo; i++)
            normalizeWord(words[i]);
        
        if (!Query(pageDirectory, index, words, wordNo))
            continue;
    }

    fprintf(stdout,"\n");
    free(pageDirectory);
    index_delete(index);
    return 0;
}
