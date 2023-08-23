
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <strings.h>
#include <stdlib.h>
#include <time.h>
#include "set.h"
#include "../lib/file.h"

#define NUMITEMS 50000

static void nameprint(FILE* fp, const char* key, void* item);
static void namedelete(void* item);
static void namecount(void* arg, const char* key, void* item);
static void nodelete(void * item);

static void test1();
static void test2();

/* **************************************** */
int main() 
{
    test2();

    return 0;
}


/* count the non-null (key,items) in the set.
 * note here we don't care what kind of item is in set.
 */
void namecount(void* arg, const char* key, void* item)
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
      fprintf(fp, "(%s,%s), ",key, name); 
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

void nodelete(void * item)
{
}

void test1() {

    set_t* set1 = NULL;           // Initialize set to NULL
    char* key = NULL;             // a key in the set
    char* item = NULL;            // a item in the set
    int itemcount = 0;            // number of items put in the set
    int setcount = 0;             // number of items found in the set
    FILE* keyfile = fopen("states","r");                // input file (keys)
    FILE* itemfile = fopen("doses_administered","r");  // input file (items)

    printf("Create set...\n");
    set1 = set_new();
    if (set1 == NULL) {
        fprintf(stderr, "set_new failed for set1\n");
        return;
    }

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
        itemcount++; 
        }
    }

    printf("\nCount (should be %d): ", itemcount);
    setcount = 0;
    set_iterate(set1, &setcount, namecount);
    printf("%d\n", setcount);

    printf("\nPrinting the set:\n");
    set_print(set1, stdout, nameprint);
    printf("\n");

    printf("\nDeleting the set...\n");
    set_delete(set1, namedelete);

    fclose(keyfile);
    fclose(itemfile);

}

void test2() {

    set_t* set = set_new();    
    int setcount = 0;       // number of items found in the set
    volatile char a = 0;             // characters used to generate random strings to put in the set
    volatile char b = 0;
    volatile char c = 0;

    clock_t start_time = clock();
    // Insert & extract random strings in set
    for (volatile  int i = 0; i < NUMITEMS; i++) {
        a += 1;
        b += 1;
        c += 1;
        char test_string0[] = {a, b, c};
        char test_string1[] = {a, b, c + 1};

        set_insert(set, test_string0, test_string0);
        set_find(set, test_string1); // deliberately searching a string not present in set
    }

    // Count number of items in the set
    set_iterate(set, &setcount, namecount);
    printf("%d items successfully added to the set\n", setcount);
    // Delete the set
    set_delete(set, nodelete);
    printf("Deleted set\n");

    clock_t end_time = clock();
    printf("test2() with NUMITEMS %d took %f seconds\n", NUMITEMS, ((double) end_time - (double) start_time) / 1000000.00);

}
