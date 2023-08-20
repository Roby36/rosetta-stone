
# Makefile for 'counters' module

# PROG =
OBJS = mem.o file.o counters.o test.o
LIBS = -lm
# DEBUG = -DEBUG

CFLAGS = -Wall -pedantic -std=c11 -ggdb 
MAKE = make
CC = gcc

.PHONY: clean test

test: $(OBJS)
	$(CC) $(CFLAGS) $(DEBUG) $(OBJS) $(LIBS) -o test

counters.o: counters.h mem.h
mem.o: mem.h 
file.o: file.h
test.o: counters.h mem.h file.h


clean:
	rm -rf *.dSYM  # MacOS debugger info
	rm -f *~ *.o
	rm -f core
