# CS50 TSE Querier

## Implementation Spec

In this document, we focus on implementation-specific decisions, including
- Control flow
- Functional decomposition into modules
- Pseudocode for logic/algorithmic flow of each module
- Testing plan

## Control flow

The Querier is implemented in one file `querier.c`. Detailed descriptions of each function's interface, as well as several other helper-functions, is provided as a paragraph comment prior to each function's implementation in `querier.c` and is not repeated here.
Moreover, `querier.c` contains an additional "mini-library" of set functions used to merge and intersect sets.

Below are the main functions responsible for the program:

```c
int main(const int argc, char* argv[]);
static index_t* parseArgs(const int argc, char* argv[], char** pageDirectory);
static int tokenize(char query[], char* words[]);
static bool Query(char* pageDirectory, index_t* index, char* words[], int wordNo);
```

### main

The `main` function validates the command line arguments, and collects queries from the user until the user enters EOF.
Pseudocode:

        call parseArgs
        initialize array holding query string
        prompt user for query
        while user input is not EOF
            initialize array holding words in query
            call tokenize 
            if query successfully tokenized
                normalize each word in query
                call Query
            prompt user for query
        delete index


### parseArgs

Given arguments from the command line, this function extracts from them the `pageDirectory` parameter and validates it. Moreover, it loads the index of the data contained in `indexFilename`. 
> As required, this function assumes that `indexFilename` is a valid path to a valid index file

### tokenize

This function enters the words of the query in an array, returns its length, and checks for bad characters.
Pseudocode:

        initialize wordNo to zero
        fetch a pointer p at the beginning of the query string
        while (1)
            while p points to a space
                slide p forwards
            if p points to the null character
                set words[wordNo] to p
                return wordNo
            else if p points to a non-alphabetical character
                print error to stderr
                return -1
            else
                set words[wordNo] to p
                increment wordNo
            while p points to an alphabetical character
                slide p forwards
            if p points to the null character
                set words[wordNo] to p
                return wordNo
            else if p does not point to a space
                print error to stderr
                return -1
            else
                set p to point to the null character
                slide p forwards


### Query

This is the main function of the program, responsible for finding, ranking, and displaying all documents containing the words in the query.
Pseudocode:

        if and/or operators are first or last or adjacent
            return false
        print normalized query
        initialize main set of documents
        initialize currWordNo to zero
        initialize andIteration to zero
        while currWordNo is strictly below total number of words in query
            while currWordNo is strictly below total number of words in query and current word is not "or"
                if current word is not "and"
                    initialize wordScores set
                    for each document in pageDirectory
                        if current word appears at least once in document
                            insert document in wordScores, entering occurences of current word as its value
                    if andIteration equals to zero
                        initialize current intersection set
                        merge wordScores set into current intersection
                    else
                        update current intersection to its intersection with wordScores
                    delete wordScores set
                increment currWordNo
                increment andIteration
            merge current intersection into main set
            delete current intersection set
            set andIteration to zero
            increment currWordNo
        compute maximum value of main set
        compute size of main set
        if main set is empty
            print "No documents match"
        else
            set threshold value to maximum
            while threshold value is above one
                iterate through each document in main set
                    if value of document equals to threshold
                        print url of document
                increment threshold value
        delete main set
        return true


## Testing plan

The program will be tested via a `make test` target, which will first compile the `fuzzquery.c` module and then run a `testing.sh` script.

The script will first perform the following tests:
- invalid number of arguments
- invalid `pageDirectory` (non-existing)
- `pageDirectory` not marked for crawling
- invalid `indexFilename`
- bad characters (e.g. `'0! ...`)
- and/or operators first or last
- and/or operators adjacent

Next, the script will test the querier on a variety of queries including:
- random queries in the "toscrape" web-pages
- random queries in the "wikipedia" web-pages with Valgrind in the background
- 100 random queries (with random seed 100) generated by the `fuzzquery.c` module, with Valgrind in the background

The output of the entire test is saved and documented in `testing.out` by running `make test &> testing.out`.





            

