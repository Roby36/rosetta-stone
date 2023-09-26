
T_test_asm:
	gcc -o $@ Q1.2.s
	./$@

T_test_c:
	gcc -DT_TEST -o $@ Q1.2.c
	./$@

test_c:
	gcc -o $@ Q1.2.c test.c 
	./$@

test_asm:
	gcc -o $@ Q1.2.s test.c 
	./$@

test_asm_v2:
	gcc -o $@ Q1.2.V2.s test.c 
	./$@

clean:
	rm -f T_test_asm
	rm -f T_test_c 
	rm -f test_c 
	rm -f test_asm
	rm -f test_asm_v2
	

