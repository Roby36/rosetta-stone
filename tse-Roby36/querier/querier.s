
.include "../../utils/macro_defs.s"

.equ RDBG, 1

.equ MAXDOCUMENTS, 128
.equ MAXQUERYCHARS, 1024

.data
bc_str:   .asciz  "Bad character; %c\n"
is_alpha_c:  .asciz  "is_alpha called with %d\n"
is_alpha_r:  .asciz  "is_alpha returned %d\n"
reg_str:     .asciz  "register value; %d\n"
and_str:    .asciz  "and"
or_str:     .asciz  "or"
err_str0:   .asciz  "Operator '%s' cannot be first.\n"
err_str1:   .asciz  "Operator '%s' cannot be last.\n"
err_str2:   .asciz  "Operators '%s'/'%s' cannot be adjacent.\n"
ex_str0:    .asciz  "Usage; %s pageDirectory indexFilename\n"
ex_str1:    .asciz  "%s; Please enter a valid pageDirectory marked for crawling.\n"
ex_str2:    .asciz  "%s; Error opening %s for reading.\n"
t_str0:     .asciz  "/.crawler"
t_str1:     .asciz  "/1"
q_str0:     .asciz  "Query; "
q_str1:     .asciz  "%s "
nl_str:     .asciz  "\n"
endq_str:   .asciz  "-------------------------------------------------------------------\n"
emptyq_str: .asciz  "No documents match.\n"
succq_str:  .asciz  "Matches %d document(s) (ranked);\n"
ds_str:     .asciz  "score %d doc %d; %s\n"
r_str:      .asciz  "r"
qm_str:     .asciz  "Query? "

.text
.p2align 2
_is_alpha:   // checks if w3 is an alphabetical character and keeps result in x4
    stp x29, x30, [sp, #-16]!
// RWRP x3, is_alpha_c
    cmp w3, 'A'                 // if w3 < A, return 0
    blo is_alpha_neg                  
    cmp w3, 'z'                 // if w3 > z, return 0
    bhi is_alpha_neg
    cmp w3, 'Z'                 // if w3 <= Z, return 1
    bls is_alpha_pos      
    cmp w3, 'a'                 // if w3 >= a, return 1
    bhs is_alpha_pos   

is_alpha_neg:
    mov x4, xzr                 // prepare false return value
    b is_alpha_end
is_alpha_pos:
    mov x4, #1                  // prepare true return value
is_alpha_end:
// RWRP x4, is_alpha_r
    ldp x29, x30, [sp], #16
    ret

.p2align 2
_normalizeWord:
    stp x29, x30, [sp, #-16]!

    cbz x0, normalizeWord_end   // if (word == NULL) return
loop14: // while (*p != '\0')
    ldrb w3, [x0]               // w3 = *p            
    cmp w3, wzr 
    beq normalizeWord_end
    // leave *p unchanged if not between 'A' and 'Z' 
    cmp w3, 'A'
    blo loop14_p_inc            
    cmp w3, 'Z'
    bhi loop14_p_inc
    // if *p between 'A' and 'Z', increment by 32
    add w3, w3, #32
    strb w3, [x0]               // *p = w3
loop14_p_inc:
    add x0, x0, #1              // p++
    b loop14 

normalizeWord_end:
    ldp x29, x30, [sp], #16
    ret 

.p2align 2
.globl _tokenize
.macro CHECK_EOQ
//!!! Query string ends with ASCII code 10 (EOL) instead of 0 !!!//
    cmp w3, #'\n'
    beq tokenize_eoq
.endm

_tokenize:  // int tokenize(char query[], char* words[])
    stp x29, x30, [sp, #-16]!
    cbz x0, tokenize_m1_ret     // if (query == NULL) return -1
    mov x2, x0                  // x2 = p
    mov w0, wzr                 // w0 = wordNo
loop1:  // while (true)
loop2:  // while (isspace(*p)) p++;
    ldrb w3, [x2]              // w3 = *p
    cmp w3, #' '
    cinc x2, x2, eq             // p += 1 if *p is a space
    beq loop2
loop2_end:
    CHECK_EOQ
    bl _is_alpha
    cbz x4, tokenize_bc         // else if (!isalpha(*p)) {fprintf(stderr, "Bad character; %c\n", *p); return -1;}
    str x2, [x1, x0, lsl #3]    // words[wordNo] = p;
    add w0, w0, #1              // wordNo++
loop3: // while (isalpha(*p))  p++;
    ldrb w3, [x2]               // w3 = *p
    bl _is_alpha
    add x2, x2, x4              // p++ if *p alphabetical 
    cbnz x4, loop3              // if isalpha(*p), continue loop
loop3_end:
    CHECK_EOQ
    cmp w3, #' '                // else if (!isspace(*p)) {fprintf(stderr, "Bad character; %c\n", *p); return -1;}
    bne tokenize_bc  
    strb wzr, [x2]              // *p = '\0'
    add x2, x2, #1              // p++;  
    b loop1
tokenize_eoq:
    str x2, [x1, x0, lsl #3]    //  words[wordNo] = p
    strb wzr, [x2]              // Ensure query string null-terminated
    b tokenize_end              
tokenize_bc:    // fprintf(stderr, "Bad character; %c\n", *p);
    LOAD_CONT_GOT x0, ___stderrp // load the standard error pointer into x0
    ldr x0, [x0]                 // load the content stored at the pointer into x0
    LOAD_ADDR x1, bc_str         // load output string address into x1 (second argument for fprintf)
    str x3, [sp, #-16]!          
    bl _fprintf
    add sp, sp, #16
tokenize_m1_ret:
    mov w0, #-1               // return -1
tokenize_end:
    ldp x29, x30, [sp], #16
    ret

.globl _take_set_intersection
.p2align 2
_take_set_intersection: 
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    stp x27, x28, [sp, #-16]!

    mov x20, x0                 // x20 = pageDirectory, 
    mov x21, x1                 // x21 = index,
    mov x22, x2                 // x22 = words[], 
    mov x23, x3                 // x23 = currIntp, 
    mov w24, w4                 // w24 = currWordNo 
    mov w25, w5                 // w25 = andIt

    bl _set_new 
    mov x19, x0                 // x19 = wordScores
    mov w26, #1                 // w26 = docID
loop4: // for (int docID = 1; docID < MAXDOCUMENTS; docID++ )
    cmp w26, #MAXDOCUMENTS  
    bge loop4_end

    mov x0, x21
    ldr x1, [x22, x24, lsl #3]  // words[currWordNo]
    mov w2, w26                 // index_get(index, words[currWordNo], docID)
    bl _index_get
    mov w27, w0                 // w27 = docScore
    cmp w27, wzr                // if (docScore <= 0), continue
    ble loop4_pre_end
    mov x0, x20 
    mov w1, w26                 
    bl _buildPath
    mov x28, x0                 // x28 = docPath = buildPath(pageDirectory, docID);
    mov w0, w27                 // intsave(docScore)
    bl _intsave 
    mov x2, x0                  // set_insert(wordScores, docPath, intsave(docScore));
    mov x0, x19 
    mov x1, x28
    bl _set_insert
    mov x0, x28 
    MWRP _free, fdbg0, fdbg1    // free(docPath);   
loop4_pre_end:
    add w26, w26, #1            // docID++
    b loop4
loop4_end:
    ldr x0, [x23]
    mov x1, x19 
    cbz w25, if1
    b else1
if1: // if (andIt == 0) { set_merge(*currIntp, wordScores); }
    bl _set_merge
    b endif1
else1:
    bl _set_intersect
    mov x25, x0                 // x25 = newInt
    ldr x0, [x23]
    LOAD_ADDR x1, _itemdelete   // set_delete(*currIntp, itemdelete)
    bl _set_delete
    str x25, [x23]              // *currIntp = newInt;
endif1:
    mov x0, x19 
    LOAD_ADDR x1, _itemdelete   // set_delete(wordScores, itemdelete);
    bl _set_delete

take_set_intersection_end:
    ldp x27, x28, [sp], #16
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.globl _Query 
.p2align 2
_Query:
    stp x29, x30, [sp, #-16]!
    stp x20, x21, [sp, #-16]!
    stp x22, x23, [sp, #-16]!
    stp x24, x25, [sp, #-16]!
    stp x26, x27, [sp, #-16]!

    mov x20, x0                 // x20 = pageDirectory
    mov x21, x1                 // x21 = index
    mov x22, x2                 // x22 = words[]
    mov w23, w3                 // w23 = wordNo

    bl _validate_query
    tbz w0, #0, Query_end       // if (!validate_query(pageDirectory, index, words, wordNo)) return false
    mov w0, #1
    cbz w23, Query_end          // if (wordNo == 0) return true;
    mov x0, x22 
    mov w1, w23                 // printQuery(words, wordNo);
    bl _printQuery
    bl _set_new 
    mov x24, x0                 // x24 = currUnion
    mov w25, wzr                // w25 = currWordNo
    mov w26, wzr                // w26 = andIt
loop5: // while (currWordNo < wordNo)
    cmp w25, w23 
    bge loop5_end 
    bl _set_new 
    str x0, [sp, #-16]!
    mov x27, sp                 // x27 = &currInt

loop6: // while ( currWordNo < wordNo && strcmp(words[currWordNo], "or") != 0 )
    cmp w25, w23 
    bge loop6_end 
    ldr x0, [x22, x25, lsl #3]  
    LOAD_ADDR x1, or_str        // strcmp(words[currWordNo], "or")
    bl _strcmp
    cbz w0, loop6_end
    ldr x0, [x22, x25, lsl #3]  
    LOAD_ADDR x1, and_str       // strcmp(words[currWordNo], "and")
    bl _strcmp 
    cbnz w0, if2
    b endif2
if2:
    mov x0, x20 
    mov x1, x21 
    mov x2, x22 
    mov x3, x27 
    mov w4, w25 
    mov w5, w26 
    bl _take_set_intersection
endif2:
    add w25, w25, #1            // currWordNo++
    add w26, w26, #1            // andIt++
    b loop6

loop6_end:
    mov x0, x24 
    ldr x1, [x27]               // set_merge(currUnion, currInt)
    bl _set_merge
    ldr x0, [x27]
    LOAD_ADDR x1, _itemdelete   // set_delete(currInt, itemdelete)
    bl _set_delete 
    mov w26, wzr                // andIt = 0
    add w25, w25, #1            // currWordNo++
    add sp, sp, #16             // pop &currInt from the stack
    b loop5

loop5_end:
    mov x0, x24                 // print_query_results( currUnion)
    bl _print_query_results
    mov x0, x24 
    LOAD_ADDR x1, _itemdelete   // set_delete(currUnion, itemdelete);
    bl _set_delete
    mov w0, #1                  // return true

Query_end:
    ldp x26, x27, [sp], #16
    ldp x24, x25, [sp], #16
    ldp x22, x23, [sp], #16
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret 

.globl _parseInt
.p2align 2
_parseInt:
    stp x29, x30, [sp, #-16]!
    stp x20, x21, [sp, #-16]!

    mov x20, x0                 // x20 = directory
    stp xzr, xzr, [sp, #-16]!
    mov x21, sp                 // x21 = int_str[]
    str xzr, [sp, #-16]!        // sp = &num 
    mov x0, x20                 // strlen(directory)
    bl _strlen 
    add x2, x20, x0             // x2 = p = &directory[strlen(directory)]
loop7:  // while (*p != '/') 
    ldrb w3, [x2]               // w3 = *p
    cmp w3, #'/'
    beq loop7_end
    sub x2, x2, #1              // if (*p != '/') p-- and goto start of loop
    b loop7 
loop7_end:
    mov x5, x21                 // x5 = int_str        
loop8:  // while (*p != '\0')
    cmp w3, wzr                 // if (*p == '\0') goto loop end --> SAFER TO USE WZR??
    beq loop8_end              
    add x2, x2, #1              // p++
    ldrb w3, [x2]               // x3 = *p
    strb w3, [x5], #1           // int_str[pos++] = *p
    b loop8
loop8_end:
    mov x0, x21 
    mov x1, sp                  // str2int(int_str, num)               
    bl _str2int
    ldr x0, [sp]                // return num

parseInt_end:
    add sp, sp, #32             // pop int_str and &num from stack
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.globl _validate_query
.macro STRCMP_AND_OR wreg, rreg
// Assumes wreg, rreg non-voltile 
    mov x0, \wreg
    LOAD_ADDR x1, and_str
    bl _strcmp 
    mov \rreg, x0 
    mov x0, \wreg
    LOAD_ADDR x1, or_str
    bl _strcmp 
    mul \rreg, \rreg, x0 
.endm
.macro PRINT_ERR_N_RET w1reg, w2reg, err_str
// Assumes wreg non-voltile 
    LOAD_CONT_GOT x0, ___stderrp
    ldr x0, [x0]
    LOAD_ADDR x1, \err_str
    stp \w1reg, \w2reg, [sp, #-16]!
    bl _fprintf 
    add sp, sp, #16
    b validate_query_false_ret
.endm
.p2align 2
_validate_query:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    str x23,      [sp, #-16]!

    // if (pageDirectory == NULL || index == NULL || words == NULL || wordNo < 0) return false 
    cbz x0, validate_query_false_ret
    cbz x1, validate_query_false_ret
    cbz x2, validate_query_false_ret
    tbnz w3, #31, validate_query_false_ret
    cbz w3, loop9_end                       // if (wordNo == 0) return true

    mov x20, x2                             // x20 = words[]
    mov w21, w3                             // w21 = wordNo
    ldr x22, [x20]                          // x22 = words[0]
    STRCMP_AND_OR x22, x19
    cbz x19, if3
    b endif3 
if3:    // fprintf(stderr, "Operator '%s' cannot be first.\n", words[0]);
    PRINT_ERR_N_RET x22, xzr, err_str0
endif3:
    sub w8, w21, #1                         // w8 = wordNo - 1
    ldr x22, [x20, x8, lsl #3]              // x22 = words[wordNo - 1]
    STRCMP_AND_OR x22, x19
    cbz x19, if4
    b endif4 
if4:    // fprintf(stderr, "Operator '%s' cannot be last.\n", words[wordNo - 1]);
    PRINT_ERR_N_RET x22, xzr, err_str1
endif4:
    mov w23, #1                             // w23 = i
loop9:
    sub w1, w21, #1                         // w1 = wordNo - 1
    cmp w23, w1 
    bge loop9_end
    ldr x22, [x20, x23, lsl #3]             // x22 = words[i]
    STRCMP_AND_OR x22, x19
    cbnz x19, endif5
    add w1, w23, #1                         // w1 = i + 1
    ldr x22, [x20, x1, lsl #3]              // x22 = words[i + 1]
    STRCMP_AND_OR x22, x19
    cbnz x19, endif5
if5:    // fprintf(stderr,"Operators '%s'/'%s' cannot be adjacent.\n", words[i], words[i + 1]);
    ldr x21, [x20, x23, lsl #3]             // x21 = words[i] 
    PRINT_ERR_N_RET x21, x22, err_str2      // wordNo be overwritten at this point
endif5:
    add w23, w23, #1                        // i++;
    b loop9

loop9_end:
    mov w0, #1                              // return true
    b validate_query_end
validate_query_false_ret:
    mov w0, wzr                 // return false

validate_query_end:
    ldr x23,      [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret


.globl _parseArgs
.macro PRINT_ERR_N_EXIT ex_str, ex_val
    LOAD_CONT_GOT x0, ___stderrp
    ldr x0, [x0]
    LOAD_ADDR x1, \ex_str
    stp x23, x4, [sp, #-16]!         // push progName (& argv[2]) to stack
    bl _fprintf
    add sp, sp, #16
    mov x0, #\ex_val                // fill-up exit code
    bl _exit
    // go to end of subroutine anyway
    b parseArgs_end                
.endm
.macro PAGEDIR_TEST_STR t_str
    ldr x0, [x21, #8]               // x0 = argv[1]
    LOAD_ADDR x1, \t_str 
    bl _pagedir_test
.endm
.p2align 2
_parseArgs: // index_t * parseArgs(const int argc, char* argv[], char** pageDirectory)
    stp x29, x30, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    str x23,      [sp, #-16]!

    mov x21, x1                     // x21 = argv[]
    mov x22, x2                     // x22 = pageDirectory
    ldr x23, [x21]                  // x23 = progName = argv[0]
    cmp w0, #3                      // if (argc != 3)
    beq endif6
    PRINT_ERR_N_EXIT ex_str0, 1     // fprintf (stderr, "Usage; %s pageDirectory indexFilename\n", progName); exit(1);
endif6:
    PAGEDIR_TEST_STR t_str0
    tbz w0, #0, if7                 // if (!pagedir_test(argv[1], "/.crawler"))
    PAGEDIR_TEST_STR t_str1 
    tbz w0, #0, if7
    b endif7
if7:
    PRINT_ERR_N_EXIT ex_str1, 2     // fprintf(stderr,"%s; Please enter a valid pageDirectory marked for crawling.\n",progName); exit(2)
endif7:
    ldr x0, [x21, #8]               // strlen(argv[1])
    bl _strlen
    add x0, x0, #1
    MWRP _malloc, mdbg0, mdbg1      // malloc(strlen(argv[1]) + 1)
    str x0, [x22]                   // *pageDirectory = malloc(strlen(argv[1]) + 1);
    ldr x0, [x22]
    ldr x1, [x21, #8]               // strcpy(*pageDirectory,argv[1]);
    bl _strcpy 
    ldr x0, [x21, #16]              // loadIndex(argv[2])
    bl _loadIndex
    cbnz x0, parseArgs_end          // if (index != NULL) return index
    ldr x0, [x22]
    MWRP _free, fdbg0, fdbg1        // free(*pageDirectory)
    ldr x4, [x21, #16]              // x4 = argv[2] (will be pushed on stack by macro)
    PRINT_ERR_N_EXIT ex_str2, 3     // fprintf(stderr, "%s; Error opening %s for reading.\n", progName, argv[2]); exit(3);

parseArgs_end:
    ldr x23,      [sp], #16
    ldp x21, x22, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.globl _newQuery
.p2align 2
_newQuery:
    stp x29, x30, [sp, #-16]!
    str x20,      [sp, #-16]!

    mov x20, x0                 // x20 = query
    bl _prompt 
    mov x0, x20 
    mov w1, #MAXQUERYCHARS
    LOAD_CONT_GOT x2, ___stdinp 
    ldr x2, [x2]                // fgets(query, QUERYMAXCHARACTERS, stdin)
    bl _fgets  
    cbz x0, newQuery_end        // return false
    mov w0, #1                  // return true           

newQuery_end:
    ldr x20,      [sp], #16
    ldp x29, x30, [sp], #16
    ret

.globl _printQuery
.p2align 2
_printQuery: 
    stp x29, x30, [sp, #-16]!
    stp x20, x21, [sp, #-16]!
    str x22,      [sp, #-16]!

    mov x20, x0                 // x20 = words[]
    mov w21, w1                 // w21 = wordNo 
    LOAD_ADDR x0, q_str0        // printf("Query; ")
    bl _printf
    mov w22, wzr                // w22 = i
loop10:
    cmp w22, w21                // if (i >= wordNo) break loop
    bge loop10_end 
    LOAD_ADDR x0, q_str1       
    ldr x1, [x20, x22, lsl #3]  
    str x1, [sp, #-16]!         // printf("%s ", words[i])
    bl _printf 
    add sp, sp, #16
    add w22, w22, #1            // i++
    b loop10
loop10_end:
    LOAD_ADDR x0, nl_str        // printf("\n")
    bl _printf                  

printQuery_end:
    ldr x22,      [sp], #16
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.globl _print_query_results
.p2align 2
_print_query_results:
    stp x29, x30, [sp, #-16]!
    stp x20, x21, [sp, #-16]!
    stp x22, x23, [sp, #-16]!

    mov x20, x0                 // x20 = currUnion
    str xzr, [sp, #-16]!        // &max = sp; &size = sp + 8
    mov x1, sp                  //! set max to zero by default, since set_iterate won't invoke _findmax when currUnion is empty!
    LOAD_ADDR x2, _findmax      // set_iterate(currUnion, &max findmax)
    bl _set_iterate 
    ldr w21, [sp]               // w21 = max
    mov x0, x20 
    add x1, sp, #8 
    LOAD_ADDR x2, _findsize     // set_iterate(currUnion, &size, findsize)
    bl _set_iterate 
    ldr w22, [sp, #8]           // w22 = size
    add sp, sp, #16             // pop &max and &size from stack
    cbnz w21, else8            
    // if (max == 0)  
    LOAD_ADDR x0, emptyq_str    
    bl _printf 
    b print_query_results_end
else8:  // if (max != 0)
    LOAD_ADDR x0, succq_str         
    str w22, [sp, #-16]!        // printf("Matches %d document(s) (ranked);\n", size);
    bl _printf
    add sp, sp, #16
    mov w23, wzr                // w23 = i
    sub sp, sp, #16             // make space for int thresh
loop11:
    cmp w23, w21
/*
    str x23, [sp, #-16]!
    LOAD_ADDR x0, reg_str
    bl _printf 
    add sp, sp, #16
*/
    bhs loop11_end 
    sub w2, w21, w23            // w2 = max - i 
    str w2, [sp]                // thresh = max - i
    mov x0, x20 
    mov x1, sp 
    LOAD_ADDR x2, _printRanked  // set_iterate(currUnion, &thresh, printRanked);
    bl _set_iterate
    add w23, w23, #1            // i++
    b loop11
loop11_end:
    add sp, sp, #16             // pop int thresh from stack
print_query_results_end:
    LOAD_ADDR x0, endq_str
    bl _printf 

    ldp x22, x23, [sp], #16
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.globl _printRanked
.p2align 2
_printRanked:
    stp x29, x30, [sp, #-16]!
    stp x20, x21, [sp, #-16]!
    stp x22, x23, [sp, #-16]!

    ldr x20, [x2]               // x20 = *num
    mov x21, x1                 // x21 = key
    ldr x2, [x0]                // x2 = *thresh
    cmp x20, x2                 // if (*num != *thresh) return
    bne printRanked_end  
    mov x0, x21 
    LOAD_ADDR x1, r_str         // fopen(key, "r")
    bl _fopen 
    mov x22, x0                 // x22 = fp
    bl _file_readLine          
    mov x23, x0                 // x23 = url 
    mov x0, x21                 // parseInt(key)
    bl _parseInt
    stp x20, x0, [sp, #-32]!
    str x23, [sp, #16]
    LOAD_ADDR x0, ds_str        // printf("score %d doc %d; %s\n", *num, docID, url);
    bl _printf
    add sp, sp, #32
    mov x0, x23 
    MWRP _free, fdbg0, fdbg1     // free(url)
    mov x0, x22                  // fclose(fp);
    bl _fclose

printRanked_end:
    ldp x22, x23, [sp], #16
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.p2align 2 
_findmax:
    ldr w3, [x0]                // w3 = *max
    ldr w4, [x2]                // w4 = *num 
    cmp w4, w3                  
    csel w5, w4, w3, ge         // w5 = (*num > *max) ? *num ; *max
    str w5, [x0]                // *max = w5
    ret 

.p2align 2
_findsize:
    ldr w3, [x0]                // w3 = *size 
    add w3, w3, #1              // w3 = w3 + 1
    str w3, [x0]                // *size = w3
    ret 

.p2align 2
_prompt:
    stp x29, x30, [sp, #-16]!

    LOAD_CONT_GOT x0, ___stdinp
    ldr x0, [x0]
    bl _fileno 
    bl _isatty
    tbz w0, #0, prompt_end      // if (isatty(fileno(stdin)) == 0) goto end of function
    LOAD_ADDR x0, qm_str        // printf("Query? ");
    bl _printf

prompt_end:
    ldp x29, x30, [sp], #16
    ret 

.p2align 2
_intsave:
    stp x29, x30, [sp, #-16]!
    str x20,      [sp, #-16]!

    mov w20, w0                 // w20 = item 
    mov x0, #4
    MWRP _malloc, mdbg0, mdbg1  // malloc(sizeof(int))
    str w20, [x0]               // *saved = item 

intsave_end:
    ldr x20,      [sp], #16
    ldp x29, x30, [sp], #16
    ret 

.p2align 2 
_itemdelete:
    stp x29, x30, [sp, #-16]!

    cbz x0, itemdelete_end
    bl _free

itemdelete_end:
    ldp x29, x30, [sp], #16
    ret 

.globl _main 
.p2align 2
_main:
    stp x29, x30, [sp, #-16]!
    stp x20, x21, [sp, #-16]!
    stp x22, x23, [sp, #-16]!
    stp x24, x25, [sp, #-16]!
    
    sub sp, sp, #16
    mov x20, sp                 // x20 = &pageDirectory
    mov x2, x20                 // parseArgs(argc, argv, &pageDirectory)
    bl _parseArgs 
    mov x21, x0                 // x21 = index 
    sub sp, sp, #MAXQUERYCHARS
    mov x22, sp                 // x22 = query[]
    sub sp, sp, #(4 * MAXQUERYCHARS)    // Each char * in words[] requires 8 bytes
    mov x23, sp                 // x23 = words[]
loop12: // while (newQuery(query))
    mov x0, x22                 // newQuery(query)
    bl _newQuery
    tbz w0, #0, loop12_end      // if (!newQuery(query)) goto loop12_end
    mov x0, x22 
    mov x1, x23                 // tokenize(query, words)
    bl _tokenize
    mov w24, w0                 // w24 = wordNo 
    cmp w24, #-1                // if (wordNo == -1) continue;
    beq loop12  
    mov w25, wzr                // w25 = i
loop13: // for (int i = 0; i < wordNo; i++)
    cmp w25, w24 
    bge loop13_end 
    ldr x0, [x23, x25, lsl #3]  // normalizeWord(words[i])
    bl _normalizeWord
    add w25, w25, #1            // i++
    b loop13 

loop13_end:
    ldr x0, [x20]               // x0 = pageDirectory
    mov x1, x21 
    mov x2, x23 
    mov w3, w24                 // Query(pageDirectory, index, words, wordNo)
    bl _Query 
    b loop12

loop12_end:
    add sp, sp, #(4 * MAXQUERYCHARS)        // pop words[] from stack 
    add sp, sp, #MAXQUERYCHARS              // pop query[] from stack
    LOAD_CONT_GOT x0, ___stdoutp 
    ldr x0, [x0]
    LOAD_ADDR x1, nl_str                    // fprintf(stdout,"\n");
    bl _fprintf 
    ldr x0, [x20]               // x0 = pageDirectory
    MWRP _free, fdbg0, fdbg1    // free(pageDirectory)
    add sp, sp, #16             // pop &pageDirectory from stack 
    mov x0, x21                 // index_delete(index)
    bl _index_delete
    mov x0, xzr                 // return 0

main_end:
    ldp x24, x25, [sp], #16
    ldp x22, x23, [sp], #16
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret
