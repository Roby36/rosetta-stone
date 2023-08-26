L = ../libcs50
C = ../common

CC = gcc

# MEM_TEST = -DMEM_TEST

CFLAGS = -Wall -pedantic -std=c11 -ggdb $(MEM_TEST) -I$L -I$C
LIBS = -lm
CLIBS = $C/common.a
LLIBS = $L/libcs50.a

.PHONY: all querier test

all: querier

querier: querier.o $(LLIBS) $(CLIBS)
	$(CC) $(CFLAGS) querier.o $(CLIBS) $(LLIBS) $(LIBS) -o querier


test: fuzzquery.o $(LLIBS)
	$(CC) $(CFLAGS) fuzzquery.o $(LLIBS) $(LIBS) -o fuzzquery
	bash -v testing.sh
	rm -f fuzzquery


querier.o: querier.c $C/index.h $C/word.h $L/file.h $C/pagedir.h $L/mem.h $L/set.h
fuzzquery.o: $L/file.h $L/mem.h

clean:
	rm -f *~ *.o
	rm -rf *.dSYM