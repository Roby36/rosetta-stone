
L = ../libcs50
C = ../common

CC = gcc

# CS50_TEST = -DWORD_TEST
# MEM_TEST = -DMEM_TEST

CFLAGS = -Wall -pedantic -std=c11 -ggdb $(MEM_TEST) $(CS50_TEST) -I$L -I$C
LIBS = -lm
CLIBS = $C/common.a
LLIBS = $L/libcs50.a

.PHONY: all indexer indextest test clean 

all: indexer indextest

indexer: indexer.o $(LLIBS) $(CLIBS)
	$(CC) $(CFLAGS) indexer.o $(CLIBS) $(LLIBS) $(LIBS) -o indexer

indextest: indextest.o $(LLIBS) $(CLIBS)
	$(CC) $(CFLAGS) indextest.o $(CLIBS) $(LLIBS) $(LIBS) -o indextest

indexer.o: indexer.c $C/index.h $C/pagedir.h $L/mem.h $L/webpage.h $L/file.h
indextest.o: indextest.c $L/mem.h $C/index.h $L/file.h

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