
/*
 * Roberto Brera,  CS50
 *
 * A test for set.c, inspired from the bagtest.c file.
 * Output is documented in testing.out file.
 * 
*/

#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <strings.h>
#include <stdlib.h>
#include "set.h"
#include "mem.h"
#include "file.h"

static void nameprint(FILE* fp, const char* key, void* item);
static void namedelete(void* item);
static void namecount(void* arg, const char* key, void* item);

/* **************************************** */
int main() 
{
  set_t* set1 = NULL;       // Initialize set to NULL
  char* key = NULL;              // a key in the set
  char* item = NULL;            // a item in the set
  int itemcount = 0;            // number of items put in the set
  int setcount = 0;             // number of items found in the set
  FILE* keyfile = fopen("states","r");  // input file (keys)
  FILE* itemfile = fopen("doses_administered","r");  // input file (items)

  printf("Create set...\n");
  set1 = set_new();
  if (set1 == NULL) {
    fprintf(stderr, "set_new failed for set1\n");
    return 1;
  }

  mem_report(stdout, "Mem_report");

  printf("\nTest set_insert with null set, good (key,item)...\n");
  set_insert(NULL, "University", "Dartmouth");
  printf("Test set_insert with null key...\n");
  set_insert(set1, "University", NULL); 
  printf("Test set_insert with null set, null key...\n");
  set_insert(NULL, NULL, "Dartmouth");

  printf("\nCount (should be %d): ", itemcount);
  setcount = 0;
  set_iterate(set1, &setcount, namecount);
  printf("%d\n", setcount);



  printf("\nTesting set_insert, using keys and items from input files...\n");
  // read lines from input
  itemcount = 0;
  while (!feof(keyfile) && !feof(itemfile)) {
    key = file_readLine(keyfile);
    item = file_readLine(itemfile);
    if (set_insert(set1, key, item)) { 
      printf("Inserted key: %s; item: %s\n", key, item);
      itemcount++; }
  }

  mem_report(stdout, "Mem_report");

  printf("\nCount (should be %d): ", itemcount);
  setcount = 0;
  set_iterate(set1, &setcount, namecount);
  printf("%d\n", setcount);

  printf("\nPrinting the set:\n");
  set_print(set1, stdout, nameprint);
  printf("\n");

  printf("\nDeleting the set...\n");
  set_delete(set1, namedelete);

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

