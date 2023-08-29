#!/bin/bash

# Invalid arguments tests:

# No arguments
./indexer

# One argument
./indexer ../crawler/test_dir

# Three or more arguments
./indexer ../crawler/test_dir lettersIndex lettersIndex 

# Invalid page directory (non-existent path)
./indexer ../crawler/letter lettersIndex

# Invalid page directory (not a crawler directory)
./indexer ../crawler lettersIndex

# Invalid indexFile (non-existent path)
./indexer ../crawler/test_dir ../comon/lettersIndex

# Invalid indexFile (read-only directory)
./indexer ../crawler/test_dir /thayerfs/home/f004rxq/cs50-dev/shared/examples/bag-unit/lettersIndex

# Invalid indexFile (existing, read-only file)
./indexer ../crawler/test_dir /thayerfs/home/f004rxq/cs50-dev/shared/examples/bag-unit/bag.c


# Valid arguments tests:

# Using "wikipedia" as pageDirectory:
# 1) Create index file with indexer (with Valgrind)
./indexer ../crawler/wikipedia/ ./indexFiles/lettersIndex

# 2) Copy index file with indextest (with Valgrind)
./indextest ./indexFiles/lettersIndex ./indexFiles/lettersCopy

# 3) Sort both files
sort ./indexFiles/lettersIndex > ./indexFiles/lettersIndex.sorted
sort ./indexFiles/lettersCopy > ./indexFiles/lettersCopy.sorted

# 4) Check files for differences (notice that they are equal)
diff ./indexFiles/lettersIndex.sorted ./indexFiles/lettersCopy.sorted
echo $?



