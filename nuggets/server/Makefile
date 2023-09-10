# Makefile for 'client' module
# Group 33, 23W


OBJS = server.o game.o playerstruct.o grid.o
LIBS = -lm
L = ../libcs50
S = ../support

# GRID_TEST = -DGRID_TEST
LOG = -DLOG
GAME_TEST = -DGAME_TEST
CFLAGS = -Wall -pedantic -std=c11 -ggdb $(LOG) -I$L -I$S
CC = gcc
LLIBS = $L/libcs50.a $S/support.a

all: server

server: $(OBJS) 
	$(CC) $(CFLAGS) $(OBJS) $(LIBS) $(LLIBS) -o server

grid: grid.o
	$(CC) $(CFLAGS) grid.o $(LIBS) $(LLIBS) -o grid

.PHONY: all server grid test clean

test:
	make server $(GRID_TEST) $(GAME_TEST)
	./server "../maps/main.txt" 36 2> ./logging.out

server.o: server.c game.h grid.h playerstruct.h $L/mem.h $L/hashtable.h $L/counters.h $S/message.h $S/log.h
game.o: game.h grid.h playerstruct.h $L/mem.h $L/hashtable.h $L/counters.h
grid.o: grid.h $L/mem.h
playerstruct.o: playerstruct.h grid.h $L/mem.h


clean:
	rm -rf *.dSYM  # MacOS debugger info
	rm -f *~ *.o
	rm -f core
	rm -f testing.out
	rm -f logging.out
	rm -f server