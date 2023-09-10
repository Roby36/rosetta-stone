# Makefile for 'client' module
# Group 33, 23W

L = ../libcs50
S = ../support

OBJS = client.o 

# GRID_TEST = -DGRID_TEST
CFLAGS = -Wall -pedantic -std=c11 -ggdb -I$S -I$L 
CC = gcc

LLIBS = $L/libcs50-given.a $L/mem.h $L/file.h $S/message.h $S/log.h
SLIBS = $S/support.a
MAKE = make
PROGS = client
VALGRIND = valgrind --leak-check=full --show-leak-kinds=all

.PHONY: all test leaks clean

all: $(PROGS) 

client: $(OBJS) 
	$(CC) $(CFLAGS) $^ -lcurses $(SLIBS) $(LLIBS) -o $@

client.o: client.c 

clean:
	rm -rf *.dSYM  # MacOS debugger info
	rm -f *~ *.o
	rm -f core
	rm -f logging_output.txt
	rm -f client
