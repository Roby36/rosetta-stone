
DS = ../../data_structures
C  = ../common
CC = gcc

CFLAGS = -Wall -pedantic -g $(LOG) -I$C -I$(DS) -I$(DS)/set -DLOGGING
SRC = $(DS)/linked_list/linked_list.c $(DS)/set/set.c $(DS)/hashtable/hash.c $(DS)/hashtable/hashtable.c $C/file.c $C/webpage.c $C/pagedir.c crawler.c 

all: crawler

crawler: $(OBJS) $(LLIBS)
	$(CC) $(CFLAGS) $(OBJS) $(LLIBS) $(LIBS) $(SRC) -o crawler

clean:
	rm -f *~ *.o
	rm -rf *.dSYM