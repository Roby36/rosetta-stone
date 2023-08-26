#!/bin/bash

# Invalid arguments tests:

# No arguments
./indexer

# One argument
./indexer ../crawler/letters

# Three or more arguments
./indexer ../crawler/letters lettersIndex lettersIndex 

# Invalid page directory (non-existent path)
./indexer ../crawler/letter lettersIndex

# Invalid page directory (not a crawler directory)
./indexer ../crawler lettersIndex

# Invalid indexFile (non-existent path)
./indexer ../crawler/letters ../comon/lettersIndex

# Invalid indexFile (read-only directory)
./indexer ../crawler/letters /thayerfs/home/f004rxq/cs50-dev/shared/examples/bag-unit/lettersIndex

# Invalid indexFile (existing, read-only file)
./indexer ../crawler/letters /thayerfs/home/f004rxq/cs50-dev/shared/examples/bag-unit/bag.c


# Valid arguments tests:

# Using "letters" as pageDirectory:
# 1) Create index file with indexer (with Valgrind)
valgrind --leak-check=full --show-leak-kinds=all ./indexer ../crawler/letters ./indexFiles/lettersIndex

# 2) Copy index file with indextest (with Valgrind)
valgrind --leak-check=full --show-leak-kinds=all ./indextest ./indexFiles/lettersIndex ./indexFiles/lettersCopy

# 3) Sort both files
sort ./indexFiles/lettersIndex > ./indexFiles/lettersIndex.sorted
sort ./indexFiles/lettersCopy > ./indexFiles/lettersCopy.sorted

# 4) Check files for differences (notice that they are equal)
diff ./indexFiles/lettersIndex.sorted ./indexFiles/lettersCopy.sorted
echo $?


# Repeating the same process with "toscrape" and "wikipedia" page directories:

# Using "toscrape" as pageDirectory:
# 1) Create index file with indexer (with Valgrind)
valgrind --leak-check=full --show-leak-kinds=all ./indexer ../crawler/toscrape ./indexFiles/toscrapeIndex

# 2) Copy index file with indextest (with Valgrind)
valgrind --leak-check=full --show-leak-kinds=all ./indextest ./indexFiles/toscrapeIndex ./indexFiles/toscrapeCopy

# 3) Sort both files
sort ./indexFiles/toscrapeIndex > ./indexFiles/toscrapeIndex.sorted
sort ./indexFiles/toscrapeCopy > ./indexFiles/toscrapeCopy.sorted

# 4) Check files for differences (notice that they are equal)
diff ./indexFiles/toscrapeIndex.sorted ./indexFiles/toscrapeCopy.sorted
echo $?


# Using "wikipedia" as pageDirectory:
# 1) Create index file with indexer (with Valgrind)
valgrind --leak-check=full --show-leak-kinds=all ./indexer ../crawler/wikipedia ./indexFiles/wikipediaIndex

# 2) Copy index file with indextest (with Valgrind)
valgrind --leak-check=full --show-leak-kinds=all ./indextest ./indexFiles/wikipediaIndex ./indexFiles/wikipediaCopy

# 3) Sort both files
sort ./indexFiles/wikipediaIndex > ./indexFiles/wikipediaIndex.sorted
sort ./indexFiles/wikipediaCopy > ./indexFiles/wikipediaCopy.sorted

# 4) Check files for differences (notice that they are equal)
diff ./indexFiles/wikipediaIndex.sorted ./indexFiles/wikipediaCopy.sorted
echo $?





