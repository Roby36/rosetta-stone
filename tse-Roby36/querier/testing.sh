#!/bin/bash

# Invalid arguments tests:

# Invalid number of arguments:
./querier
./querier querier querier querier 

# Invalid pageDirectory (non-existing)
./querier pageDirectory ../indexer/lettersIndex

# pageDirectory not marked for crawling:
./querier ../indexer ../indexer/lettersIndex

# Invalid index file:
./querier ../crawler/letters ../indexer/letters


# Valid arguments tests:

# Testing invalid queries (toscrape):

echo contractions aren\'t allowed > invalidQuery
./querier ../crawler/toscrape ../indexer/toscrapeIndex < invalidQuery
rm -f invalidQuery

echo n0 numbers > invalidQuery
./querier ../crawler/toscrape ../indexer/toscrapeIndex < invalidQuery
rm -f invalidQuery

echo no special characters! > invalidQuery
./querier ../crawler/toscrape ../indexer/toscrapeIndex < invalidQuery
rm -f invalidQuery

echo and cannot be first > invalidQuery
./querier ../crawler/toscrape ../indexer/toscrapeIndex < invalidQuery
rm -f invalidQuery

echo nor last      and > invalidQuery
./querier ../crawler/toscrape ../indexer/toscrapeIndex < invalidQuery
rm -f invalidQuery

echo no adjacent and or operators > invalidQuery
./querier ../crawler/toscrape ../indexer/toscrapeIndex < invalidQuery
rm -f invalidQuery


# Testing valid queries (toscrape):

echo sometimes no documents match > testQuery
./querier ../crawler/toscrape ../indexer/toscrapeIndex < testQuery
rm -f testQuery

echo new Hampshire > testQuery
./querier ../crawler/toscrape ../indexer/toscrapeIndex < testQuery
rm -f testQuery

echo where are you from > testQuery
./querier ../crawler/toscrape ../indexer/toscrapeIndex < testQuery
rm -f testQuery

echo hypochondriac mother > testQuery
./querier ../crawler/toscrape ../indexer/toscrapeIndex < testQuery
rm -f testQuery

echo demo website for web scraping purposes > testQuery
./querier ../crawler/toscrape ../indexer/toscrapeIndex < testQuery
rm -f testQuery

echo travel and Himalayas > testQuery
./querier ../crawler/toscrape ../indexer/toscrapeIndex < testQuery
rm -f testQuery

echo travel or Himalayas > testQuery
./querier ../crawler/toscrape ../indexer/toscrapeIndex < testQuery
rm -f testQuery

# Testing valid queries (wikipedia and valgrind):
echo where are you from > testQuery
valgrind --leak-check=full --show-leak-kinds=all ./querier ../crawler/wikipedia/ ../indexer/wikipediaIndex < testQuery 
rm -f testQuery

echo Computer Science   or    Mathematics and Physics > testQuery
valgrind --leak-check=full --show-leak-kinds=all ./querier ../crawler/wikipedia/ ../indexer/wikipediaIndex < testQuery
rm -f testQuery

echo Algorithms or Computer Science or coding > testQuery
valgrind --leak-check=full --show-leak-kinds=all ./querier ../crawler/wikipedia/ ../indexer/wikipediaIndex < testQuery
rm -f testQuery

echo Dartmouth College between Vermont and New Hampshire has snow > testQuery
valgrind --leak-check=full --show-leak-kinds=all ./querier ../crawler/wikipedia/ ../indexer/wikipediaIndex < testQuery
rm -f testQuery


# Testing using 100 inputs from fuzzquery (wikipedia and valgrind):

./fuzzquery ../indexer/wikipediaIndex 100 100 > fuzzTest
valgrind --leak-check=full --show-leak-kinds=all ./querier ../crawler/wikipedia/ ../indexer/wikipediaIndex < fuzzTest
rm -f fuzzTest


# Final exit code:
echo $?