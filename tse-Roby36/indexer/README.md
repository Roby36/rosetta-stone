In the indexer program, strings containing numbers may not be counted as words.
This is not due to my program's implementation, but to the webpage_getNextWord 
function in the webpage module.
By uncommenting the "CS50_TEST" variable for the indexer Makefile, and running 
the indexer on the crawler/letters directory, it can be seen that the word "CS50" 
in the html of a webpage is read by webpage_getNextWord as "CS," hence not added
to the index since it doesn't reach the minimum of three characters.

It is also worth noting that the "testing.out" file is generated directly by
running "make test," thus no need to redirect the output again. Moreover,
because "make test" creates a directory to store all index files in one place
(so that they can be easily deleted afterwards), it is important to run
"make clean" (which removes the directory) before and after running "make test" 
in order to avoid errors.

Running a memory test by uncommenting MEM_TEST in the Makefile is not useful
since the file and webpage modules do not use "mem_malloc" or "mem_free,"
hence we get a negative net memory allocation throughout the program 
(since mem_free was called more often than mem_malloc). However, consistent
tests on Valgrind (see testing.out) show that no memory leaks are present.
