# CS50 TSE Querier

## Design Spec

In this document, we focus on design-specific decisions, including:
- User interface
- Inputs and outputs
- Major data structures
- Pseudocode for logic/algorithmic flow of the main program


## User interface

As described in the Requirements Spec, the command-line must have the following three arguments:

```bash
$ querier pageDirectory indexFilename
```


## Inputs and outputs

If any input is entered incorrently on the command-line, the user receives a warning message and the program is terminated.

For example:

```
Usage: querier/querier pageDirectory indexFilename
```
```
querier/querier: Please enter a valid pageDirectory marked for crawling.
```
```
querier/querier: Error opening nonExistingFile for reading.
```

If the user enters the right parameters on the command-line, the program starts running and the user is prompted to provide a query phrase. The "Query? " prompt will only appear when a keyboard is used for standard input.
If the user enters an invalid query string, an error message is printed and the user is prompted to enter a new query. For example: 

```
Query? cs50
Bad character: 5
Query? don't crash
Bad character: '
Query? and travel
Operator 'and' cannot be first.
Query? travel and or mountains
Operators 'and'/'or' cannot be adjacent.
Query? dog or
Operator 'or' cannot be last.
```

If the query entered by the user is accepted, it is repeated in a normalized version, stripped of all excess spaces, and printed above the results of the query. 

If no documents match the query, the following output is printed:

```
Query?    school and    fun         
Query: school and fun 
No documents match.
-------------------------------------------------------------------
```

If several documents match the query, they are printed ordered by their scores, starting from the one with the highest. Scores are calculated by taking the minimum score when an "and" is applied, and taking the sum of both scores when an "or" is applied, and generally represent the number of occurrences of a given word in a document. Moreover, the number of documents matching the query is printed and the documents are printed with their score, docID, and URL.

Sample output:

```
Query? travel
Query: travel 
Matches 55 document(s) (ranked):
score 4 doc 72: http://cs50tse.cs.dartmouth.edu/tse/toscrape/catalogue/category/books/travel_2/index.html
score 1 doc 74: http://cs50tse.cs.dartmouth.edu/tse/toscrape/index.html
...
```


## Major data structures

The major data structures of this program will be:

- An index holding the occurrences of each word in each document
- A main set containing all the documents matching a given query and their scores
- A set containing the current intersection of documents matching a collection of words, which is eventually merged into the main set
- A set containing the documents matching the current word, which is eventually merged into the current intersection set 


## Pseudocode for logic/algorithmic flow of the main program

Below is a basic outline of the main program. More details regarding the algorithmic flow of each module and error-checking are provided in the [Implementation Spec](IMPLEMENTATION.md).
Pseudocode:

        validate command-line arguments
        load index data structure from indexFilename
        prompt user for query
        while user input is not EOF
            tokenize query into words and validate it
            normalize each word in query
            initialize the main set of documents
            for each word in query
                while the word is not "or"
                    if the word is not "and"
                        create new word set storing occurrences of word in each document of pageDirectory
                        if this is the first word of an and-sequence
                            initialize the current intersection set and merge the word set into it
                        else
                            update the current intersection set to its intersection with the word set
                    go to the next word
                merge the current intersection set into the main set
            print each document in the main set by descending scores
            prompt the user for the next query



 