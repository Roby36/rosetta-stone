
/*
 * Roberto Brera,  CS50
 *
 * A test for hashtable.c, inspired from the bagtest.c file.
 * Output is documented in testing.out file.
 * 
*/

#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <strings.h>
#include <stdlib.h>
#include "hashtable.h"
#include "mem.h"
#include "file.h"

static void nameprint(FILE* fp, const char* key, void* item);
static void namedelete(void* item);
static void namecount(void* arg, const char* key, void* item);

/* **************************************** */
int main() 
{
  hashtable_t* ht1 = NULL;       // Initialize hash table to NULL
  char* key = NULL;              // a key in the hashtable
  char* item = NULL;            // a item in the hashtable
  int itemcount = 0;            // number of items put in the hashtable
  int hashcount = 0;             // number of items found in the hashtable
  FILE* keyfile = fopen("states","r");  // input file (keys)
  FILE* itemfile = fopen("doses_administered","r");  // input file (items)

  printf("Create hash table, with 6 slots...\n");
  ht1 = hashtable_new(6);
  if (ht1 == NULL) {
    fprintf(stderr, "hashtable_new failed for ht1\n");
    return 1;
  }

  mem_report(stdout, "Mem_report");

  printf("\nTest hashtable_insert with null hashtable, good (key,item)...\n");
  hashtable_insert(NULL, "University", "Dartmouth");
  printf("Test hashtable_insert with null key...\n");
  hashtable_insert(ht1, "University", NULL); 
  printf("Test hashtable_insert with null set, null key...\n");
  hashtable_insert(NULL, NULL, "Dartmouth");

  printf("\nCount (should be %d): ", itemcount);
  hashcount = 0;
  hashtable_iterate(ht1, &hashcount, namecount);
  printf("%d\n", hashcount);



  printf("\nTesting hash_insert, using keys and items as from input files...\n");
  // read lines from input
  itemcount = 0;
  while (!feof(keyfile) && !feof(itemfile)) {
    key = file_readLine(keyfile);
    item = file_readLine(itemfile);
    if (hashtable_insert(ht1, key, item)) { 
      printf("Inserted key: %s; item: %s\n", key, item);
      itemcount++; }
      else { printf("Failed to insert %s: key already present in hastable. \n", key); }
  }

  mem_report(stdout, "Mem_report");

  printf("\nCount (should be %d): ", itemcount);
  hashcount = 0;
  hashtable_iterate(ht1, &hashcount, namecount);
  printf("%d\n", hashcount);

  printf("\nPrinting the hash:\n");
  hashtable_print(ht1, stdout, nameprint);
  printf("\n");

  printf("\nDeleting the hash...\n");
  hashtable_delete(ht1, namedelete);

  mem_report(stdout, "Mem_report");

  printf("\nFinal mem_net (should be zero): %d\n", mem_net());

  return 0;
}


/* count the non-null (key,items) in the set.
 * note here we don't care what kind of item is in set.
 */
static void namecount(void* arg, const char* key, void* item)
{
  int* nitems = arg;

  if (nitems != NULL && key != NULL && item != NULL)
    (*nitems)++;
}

// print a (key,name), in quotes.
void nameprint(FILE* fp, const char* key, void* item)
{
  if (key != NULL) {
    char* name = item; 
    if (name == NULL) {
      fprintf(fp, "(null)");
    }
    else {
      fprintf(fp, "(%s,%s)",key, name); 
    }
  }
}

// delete a name 
void namedelete(void* item)
{
  if (item != NULL) {
    free(item);   
  }
}




