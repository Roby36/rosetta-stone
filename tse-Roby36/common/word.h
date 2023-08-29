
/*
 *
 * word.h - header file for 'word' module
 * 
 */

/* ******************* normalizeWord ************************************** */
/* This function normalizes a word, converting it to lower-case.
 *
 * We assume:
 *   Caller provides a pointer to a non-NULL string pointer.
 * 
 * We return:
 *   Nothing (void).
 *   
 * We guarantee:
 *   If the provided word is NULL, it is ignored.
 *   Otherwise, every alphabetical character of the word is converted
 *   to lower-case, and all non-alphabetical characters remain unchanged.
 *   
 * Notes:
 *   Memory is neither allocated nor freed; the word characters
 *   are changed in place, maintaining their original places in memory.
 *   The normalized word maintains the same pointer and memory address
 *   as the original word (which is permanently changed).
 */
void normalizeWord(char* word);


