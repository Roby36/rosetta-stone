
.include "../../utils/macro_defs.s"

.equ RDBG, 1

.equ MAXDOCUMENTS, 128

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
    str x22,      [sp, #-16]!

    mov x20, x0                 // x20 = directory
    stp xzr, xzr, [sp, #-16]!
    mov x21, sp                 // x21 = int_str[]
    str xzr, [sp, #-16]!
    mov x22, sp                 // x22 = &num 
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
    mov x1, x22                 // str2int(int_str, &num);
    bl _str2int
    ldr x0, [x22]               // return num

parseInt_end:
    add sp, sp, #32             // pop int_str and &num from stack
    ldr x22,      [sp], #16
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.globl _validate_query
.macro STRCMP_AND_OR wreg, rreg
/* Assumes wreg, rreg non-voltile */
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
/* Assumes wreg non-voltile */
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
    ldr x22, [x20, x8, lsl #3]              // x22 = wordNo[wordNo - 1]
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

