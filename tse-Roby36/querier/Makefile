
C = ../common
DS = ../../data_structures
CC = gcc

CFLAGS = -I$C -I$(DS) -I$(DS)/hashtable -I$(DS)/set -I$(DS)/counters
SRC = $C/index.c $C/word.c  $(DS)/counters/counters.c $(DS)/set/set.c $(DS)/hashtable/hash.c $(DS)/hashtable/hashtable.c $C/file.c $C/webpage.c $C/pagedir.c


.PHONY: all querier test

all: querier

querier: 
	$(CC) $(CFLAGS) $(SRC) -g querier.c -o querier

querier_asm: 
	$(CC) $(CFLAGS) $(SRC) -g querier.c querier.s -o querier_asm

test: 
	$(CC) $(CFLAGS) fuzzquery.o $(LLIBS) $(LIBS) -o fuzzquery
	bash -v testing.sh
	rm -f fuzzquery

clean:
	rm -f querier_asm
	rm -f *~ *.o
	rm -rf *.dSYM