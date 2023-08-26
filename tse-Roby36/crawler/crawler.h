
#pragma once

#include "linked_list/linked_list.h"
#include "hashtable/hashtable.h"
#include "webpage.h"
#include "pagedir.h"
#include <string.h>
#include <strings.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#define HASHTABLE_SIZE 128

/* ******************* parseArgs ******************************************** */
/* Given arguments from the command line, this function extracts from them
 * the seedURL, pageDirectory and maxDepth and validates them.
 * 
 * We assume:
 *   Caller provides any arguments.
 * 
 * We return:
 *   The function returns nothing if and only if all the arguments are valid.
 *   If any argument is invalid the function prints an error to stderr
 *   and exists non-zero.
 * 
 * We guarantee:
 *   If no error is printed, all the arguments are valid and the program
 *   continues.
 */
static void parseArgs(const int argc, char* argv[], char** seedURL, char** pageDirectory, int* maxDepth);

/* ******************* crawl ******************************************************* */
/* This function crawls the seedURL until maxDepth is reached and saves
 * the pages in pageDirectory.
 * 
 * We assume:
 *   Caller provides valid seedURL (from http internal website), 
 *   existing pageDirectory (after calling mkdir pageDirectory from Terminal),
 *   and an an integer value for maxDepth in the inclusive range [0,10].
 * 
 * We return:
 *   The function returns nothing but creates a numbered file (from 1 onwards) 
 *   containing the url, depth, and html contents of each page within pageDirectory. 
 *   Any errors in the process are documented to stderr, and cause the function to
 *   exit non-zero.
 */  
static void crawl(char* seedURL, char* pageDirectory, const int maxDepth);

/* ******************* pageScan ************************************************** */
/* Given a webpage, this function extracts url links contained within it, 
 * ignoring any non-internal urls, and for any url not seen before 
 * (not in the pagesSeen hashtable) it adds the url to both the hashtable
 * and the bag pagesToCrawl.
 *
 * We assume:
 *   Caller provides valid page with internal url, valid pagesToCrawl bag,
 *   and valid pagesSeen hashtable.
 * 
 * We return:
 *   The function returns nothing if successful, and prints an error message
 *   to stderr exiting non-zero if any fatal error is encountered.
 *   
 * Caller is responsible for:
 *    Later deleting the bag pagesToCrawl and hashtable pagesSeen,
 *    and free'ing their memory.
 */
static void pageScan(webpage_t* page, linked_list_t* pagesToCrawl, hashtable_t* pagesSeen);

/* ******************* str2int ************************************** */
/* This function converts a string into an integer.
 *
 * We assume:
 *   Caller provides a valid string string[] 
 *   and a valid pointer to an integer *number.
 * 
 * We return:
 *   If the string can be casted to an integer, the function returns 
 *   true and assigns the resulting integer to the pointer *number
 *   provided by the caller.
 *   Otherwise, the function returns false.
 *  
 * Caller is responsible for:
 *   Providing a string which contains one and only one integer,
 *   and nothing else.
 */
static bool str2int(const char string[], int *number);

/* ******************* logr ************************************** */
/* This function provides a log message of the state of the crawler,
 * whenever the variable "APPTEST" is defined by the user.
 *
 * We assume:
 *   Caller provides string word, integer depth, and a string 
 *   containing the desired url to see in the message,
 *   
 * We return:
 *   The function returns nothing.
 *   If "APPTEST" is defined, the function directly prints to stdout
 *   the message inputted by the user.
 */
static void logr(const char *word, const int depth, const char *url);

/* ******************* nodelete ************************************** */
/* Blank function used when deleting hashtable, since no memory had 
 * been malloc'd for items in hashtable.
 */
static void nodelete(void* item);
