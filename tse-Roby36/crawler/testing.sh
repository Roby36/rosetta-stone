#!/bin/bash

# More than 4 arguments:
./crawler http://cs50tse.cs.dartmouth.edu/tse/wikipedia/ wikipedia 1 extra_argument

# Less than 4 arguments:
./crawler

# Invalid URL:
./crawler http://cs50tse.cs.dartmoth.edu/tse/wikipedia/ wikipedia 1

# External URL:
./crawler https://www.wikipedia.org wikipedia 1

# Invalid directory:
./crawler http://cs50tse.cs.dartmouth.edu/tse/wikipedia/ wikpedia 1

# Non-integer maxDepth:
./crawler http://cs50tse.cs.dartmouth.edu/tse/wikipedia/ wikipedia max

# maxDepth out of range:
./crawler http://cs50tse.cs.dartmouth.edu/tse/wikipedia/ wikipedia 11
./crawler http://cs50tse.cs.dartmouth.edu/tse/wikipedia/ wikipedia -1

# Valgrind test (letters depth 10, logging on):
valgrind --leak-check=full --show-leak-kinds=all ./crawlerLog http://cs50tse.cs.dartmouth.edu/tse/letters/ letters 10

# Valgrind test (wikipedia depth 1, logging off):
valgrind --leak-check=full --show-leak-kinds=all ./crawler http://cs50tse.cs.dartmouth.edu/tse/wikipedia/ wikipedia 1

# Valgrind test (toscrape depth 1, logging off):
valgrind --leak-check=full --show-leak-kinds=all ./crawler http://cs50tse.cs.dartmouth.edu/tse/toscrape/ toscrape 1

# Test runs on letters (logging on):
./crawlerLog http://cs50tse.cs.dartmouth.edu/tse/letters/ letters 0
./crawlerLog http://cs50tse.cs.dartmouth.edu/tse/letters/ letters 1
./crawlerLog http://cs50tse.cs.dartmouth.edu/tse/letters/ letters 2
./crawlerLog http://cs50tse.cs.dartmouth.edu/tse/letters/ letters 10

# Test runs on toscrape (logging off):
./crawler http://cs50tse.cs.dartmouth.edu/tse/toscrape/ toscrape 0
./crawler http://cs50tse.cs.dartmouth.edu/tse/toscrape/ toscrape 1
# ./crawler http://cs50tse.cs.dartmouth.edu/tse/toscrape/ toscrape 2
# ./crawler http://cs50tse.cs.dartmouth.edu/tse/toscrape/ toscrape 3

# Test runs on wikipedia (logging off):
./crawler http://cs50tse.cs.dartmouth.edu/tse/wikipedia/ wikipedia 0
./crawler http://cs50tse.cs.dartmouth.edu/tse/wikipedia/ wikipedia 1
# ./crawler http://cs50tse.cs.dartmouth.edu/tse/wikipedia/ wikipedia 2

# Final exit code:
echo $?
