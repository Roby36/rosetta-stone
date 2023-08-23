
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <strings.h>
#include <stdlib.h>
#include <time.h>
#include "hashtable.h"
#include "file.h"
#include "inline_asm_funcs.h"

#define NUMSLOTS  256
#define HASHITEMS 50000

#define PRINT_SP()  printf("Current sp: %llx\n", get_sp())

static void nameprint(FILE* fp, const char* key, void* item);
static void namedelete(void* item);
static void namecount(void* arg, const char* key, void* item);
static void nodelete(void * item);

static void test0();
static void test1();

/* **************************************** */
int main() 
{
    test1();

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

void test0() {
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
        return;
    }

    printf("Test hashtable_insert with null set, null key...\n");
    hashtable_insert(NULL, NULL, "Dartmouth");

    printf("\nTest hashtable_insert with null hashtable, good (key,item)...\n");
    hashtable_insert(NULL, "University", "Dartmouth");

    printf("Test hashtable_insert with null key...\n");
    hashtable_insert(ht1, "University", NULL); 
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

    printf("\nCount (should be %d): ", itemcount);
    hashcount = 0;
    hashtable_iterate(ht1, &hashcount, namecount);
    printf("%d\n", hashcount);

    printf("\nPrinting the hash:\n");
    hashtable_print(ht1, stdout, nameprint);
    printf("\n");

    printf("\nDeleting the hash...\n");
    hashtable_delete(ht1, namedelete);

    fclose(keyfile);
    fclose(itemfile);
}

void test1() {
    hashtable_t * ht = hashtable_new(NUMSLOTS);    
    int hashcount = 0;               // number of items found in the set
    volatile char a = 0;             // characters used to generate random strings to put in the set
    volatile char b = 0;
    volatile char c = 0;

    clock_t start_time = clock();
    // Insert & extract random strings in set
    for (volatile  int i = 0; i < HASHITEMS; i++) {
        a += 1;
        b += 1;
        c += 1;
        char test_string0[] = {a, b, c};
        char test_string1[] = {a, b, c + 1};

        hashtable_insert(ht, test_string0, test_string0);
        hashtable_find(ht, test_string1); // deliberately searching a string not present in set
    }

    // Count number of items in the set
    hashtable_iterate(ht, &hashcount, namecount);
    printf("%d items successfully added to the hashtable\n", hashcount);
    // Delete the set
    hashtable_delete(ht, nodelete);
    printf("Deleted hashtable\n");

    clock_t end_time = clock();
    printf("test2() with HASHITEMS %d and NUMSLOTS %d took %f seconds\n", HASHITEMS, NUMSLOTS, ((double) end_time - (double) start_time) / 1000000.00);

}