
L = ../libcs50
CC = gcc

# UNIT_TEST = -DUNIT_TEST
# MEM_TEST = -DMEM_TEST

CFLAGS = -Wall -pedantic -std=c11 -ggdb $(UNIT_TEST) $(MEM_TEST) -I$L
OBJS = index.o pagedir.o word.o
LIBS = -lm
CLIBS = common.a
LLIBS = $L/libcs50.a

$(CLIBS): $(OBJS)
	ar cr $(CLIBS) $(OBJS)

.PHONY: all indexUnitTest clean

all: $(CLIBS)

indexUnitTest: index.o $(LLIBS)
	$(CC) $(CFLAGS) index.o $(LLIBS) $(LIBS) -o indexUnitTest


index.o: index.h $L/hashtable.h $L/mem.h $L/counters.h $L/file.h
pagedir.o: pagedir.h $L/mem.h $L/webpage.h



clean:
	rm -f indexUnitTest
	rm -f *~ *.o
	rm -rf *.dSYM