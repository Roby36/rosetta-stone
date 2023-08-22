
# Makefile for 'set' module

CFLAGS 	= -g -O3
MAKE 	= make
CC 		= gcc
LIBDIR 	= ../lib

.PHONY: c asm clean

c:
	$(CC) $(CFLAGS) -o test_c $(LIBDIR)/file.c set.c test.c
asm:
	$(CC) $(CFLAGS) -o test_asm $(LIBDIR)/file.c set.s test.c

clean:
	rm -rf *.dSYM  # MacOS debugger info
	rm -f test_c
	rm -f test_asm
	rm -f *~ *.o
	rm -f core
