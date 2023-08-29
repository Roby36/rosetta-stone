
C = ../common
DS = ../../data_structures

CC = gcc

CFLAGS = -Wall -pedantic -std=c11 -g -I$C -I$(DS) -I$(DS)/hashtable -I$(DS)/set -I$(DS)/counters
SRC = $C/index.c $C/word.c  $(DS)/counters/counters.c $(DS)/set/set.c $(DS)/hashtable/hash.c $(DS)/hashtable/hashtable.c $C/file.c $C/webpage.c $C/pagedir.c

.PHONY: all indexer indextest test clean 

all: indexer indextest

indexer: 
	$(CC) $(CFLAGS) $(SRC) indexer.c  -o indexer

indextest: 
	$(CC) $(CFLAGS) $(SRC) indextest.c -o indextest

test: indexer indextest testing.sh
	make
	mkdir indexFiles
	chmod +x testing.sh
	bash -v ./testing.sh &> testing.out
	@echo "end of test"

clean:
	rm -f indextest
	rm -f indexer
	rm -f *~ *.o
	rm -rf *.dSYM
	rm -rf indexFiles