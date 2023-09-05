
CC = gcc

asm:
	$(CC) -g -o test_asm linked_list.s test.c
c:
	$(CC) -g -o test_c linked_list.c test.c
co3:
	$(CC) -O3 -o test_co3 linked_list.c test.c

clean:
	rm -f test_c
	rm -f test_asm
	rm -f test_co3
	
