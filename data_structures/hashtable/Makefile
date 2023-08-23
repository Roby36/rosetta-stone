
# Makefile for 'hashtable' module

CFLAGS 	= 
MAKE 	= make
CC 		= gcc
LIBDIR 	= ../lib
SETDIR  = ../set
UTILSDIR= ../../utils
INCL    = -I$(LIBDIR) -I$(SETDIR) -I$(UTILSDIR)

.PHONY: c asm clean

c:
# compile optimized assembly file
	$(CC) $(CFLAGS) $(INCL) -O3 -S hashtable.c -o hashtable_O3.s	
# link it with other source files to make binary	
	$(CC) $(CFLAGS) $(INCL) -o test_c $(LIBDIR)/file.c $(SETDIR)/set.c $(UTILSDIR)/inline_asm_funcs.c hash.c hashtable_O3.s test.c	
asm:
# link .s file with other source files
	$(CC) $(CFLAGS) -g $(INCL) -o test_asm $(LIBDIR)/file.c $(SETDIR)/set.c $(UTILSDIR)/inline_asm_funcs.c hash.c hashtable.s test.c

clean:
	rm -rf *.dSYM  # MacOS debugger info
	rm -f test_c
	rm -f test_asm
	rm -f *~ *.o
	rm -f core
