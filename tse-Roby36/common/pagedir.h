
/*
 * pagedir.h - header file for 'pagedir' module
 *
 * The pagedir module contains a variety of functions used by the 
 * TSE to handle page directories.
 * 
 */

#pragma once

#include "webpage.h"
#include <string.h>
#include <strings.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#define MAX_CONC_CHAR   16

/* ******************* pagedir_init ********************* */
/* This function marks a given directory where the 
 * crawled pages will be collected.
 *
 * We assume:
 *   The caller provides a string pageDirectory containing an existing local
 *   directory, and a string fileName containing
 *   the file name extension for a file to be created within that
 *   directory (e.g. ".crawler").
 * 
 * We guarantee:
 *   A file with the desired name is created in the desired directory.
 *   All memory allocated within the process is freed.
 * 
 * We return:
 *   True if and only if the file was successfully created.
 *   False otherwise.
 * 
 * Important:
 *  A slash "/" must be included either at the end of pageDirectory,
 *  or at the beginning of fileName, but not in both.
 *  pageDirectory is not chanegd by this function.
 */
bool pagedir_init(const char* pageDirectory, char* fileName);


/* ******************* pagedir_test ********************* */
/* This function tests the existence of a given file
 * in a given directory.
 *
 * We assume:
 *   The caller provides a string pageDirectory containing a local
 *   directory, and a string fileName containing
 *   the file name extension for a file to be contained within that
 *   directory (e.g. ".crawler").
 * 
 * We return:
 *   True if and only if the file exists in the directory.
 *   False otherwise.
 * 
 * Important:
 *  A slash "/" must be included either at the end of pageDirectory,
 *  or at the beginning of fileName, but not in both.
 *  pageDirectory is not chanegd by this function.
 */
bool pagedir_test(const char* pageDirectory, char* fileName);


/* ******************* pagedir_save *********************************/
/* This function creates a file in a given directory
 * to save the contents of a webpage.
 *
 * We assume:
 *   Caller provides valid webpage_t type, existing pageDirectory,
 *   and a docID >= 1 that has not been used already.
 *   We also assume that the provided pageDirectory contains a ./crawler
 *   file and is used for storing crawled pages.
 * 
 * We return:
 *   The function returns nothing, but creates a file with name docID
 *   in pageDirectory and prints url, depth, and html contents of 
 *   the page provided in the file.
 *   If any error is encountered, this is printed to stderr
 *   and the function exits non-zero. 
 */
void pagedir_save(const webpage_t* page, const char* pageDirectory, const int docID);


/* ******************* concatInt ************************************** */
/* This helper-function constructs the required path name for creating 
 * a file with a given docID.
 *
 * We assume:
 *   p is a malloc'd string
 * 
 * We return:
 *   The function returns the pointer to the extended pathname
 */
char * concatInt(char* p, int n);


/* ******************* buildPath ************************************** */
/* This helper-function builds a path name for a given pageDirectory
 * by extending it with a given docID.
 *
 * We assume:
 *   Caller provides valid string for pageDirectory, and integer docID.
 * 
 * We return:
 *   Pointer to string containing full path name, 
 *   or NULL if NULL pageDirectory was provided.
 *   
 * We guarantee:
 *   Memory is malloc'd appropriately to accommodate the longer string.
 *   
 * Caller is responsible for:
 *   Later free'ing the returned string
 *   
 * Notes:
 *  pageDirectory is not changed by this function.
 */
char* buildPath(const char* pageDirectory, int docID);

