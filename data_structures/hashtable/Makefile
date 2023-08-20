
# Makefile for 'hashtable' module

# PROG =
OBJS = hash.o mem.o file.o set.o test.o hashtable.o
LIBS = -lm

CFLAGS = -Wall -pedantic -std=c11 -ggdb 
MAKE = make
CC = gcc

.PHONY: clean test

test: $(OBJS) 
	$(CC) $(CFLAGS) $(OBJS) $(LIBS) -o test

set.o: set.h mem.h
mem.o: mem.h 
file.o: file.h
test.o: mem.h file.h hashtable.h
hash.o: hash.h
hashtable.o: set.h mem.h hash.h


clean:
	rm -rf *.dSYM  # MacOS debugger info
	rm -f *~ *.o
	rm -f core
