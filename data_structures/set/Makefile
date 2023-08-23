
# Makefile for 'set' module

CFLAGS 	= 
MAKE 	= make
CC 		= gcc
LIBDIR 	= ../lib

.PHONY: c asm clean

c:
# compile optimized assembly file
	$(CC) $(CFLAGS) -O3 -S set.c -o set_O3.s
# link with other source files
	$(CC) $(CFLAGS) -o test_c $(LIBDIR)/file.c set_O3.s test.c
cclean:
	$(CC) $(CFLAGS) -o test_cclean $(LIBDIR)/file.c set_O3_clean.s test.c
asm:
# link .s file directly
	$(CC) $(CFLAGS) -o test_asm $(LIBDIR)/file.c set.s test.c
clean:
	rm -rf *.dSYM  # MacOS debugger info
	rm -f test_c
	rm -f test_asm
	rm -f test_cclean
	rm -f *~ *.o
	rm -f core
