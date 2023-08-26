
#include "counters.h"
#include "file.h"

static void totalcount(void* arg, const int key, const int count);
static void keycount(void* arg, const int key, const int count);
static bool str2int(const char string[], int *number);

static void test0();

/* **************************************** */
int main() 
{
    test0();

    return 0;
}

void test0() {
    counters_t* ctrs1 = NULL;        // initialize NULL counter        
    int ctrs1_keys = 0;              // number of keys added to ctrs1
    int ctrs1_count = 0;             // total count for ctrs1
    int ctrs1_keys_exp = 0;          // number of keys expected in ctrs1
    int ctrs1_count_exp = 0;         // total count expected for ctrs1
    FILE* input1 = fopen("input1","r"); // input files included in directory
    FILE* input2 = fopen("input2","r"); // (can be modified for testing as desired)
    
    printf("Initializing ctrs1...\n");
    ctrs1 = counters_new();
    if (ctrs1 == NULL) {
        fprintf(stderr, "counters_new failed for ctrs1\n");
        return;
    }

    printf("\nTest counters_add with null counters, good key...\n");
    counters_add(NULL, 3);
    printf("Test counters_add with ctrs1, negative key...\n");

    if (counters_add(ctrs1, -3) != 0) { ctrs1_keys++; ctrs1_count++; }

    ctrs1_keys_exp = 0; 
    ctrs1_count_exp = 0;
    counters_iterate(ctrs1, &ctrs1_count_exp, totalcount);
    counters_iterate(ctrs1, &ctrs1_keys_exp, keycount);
    printf("\nTotal keys (should be %d): %d ", ctrs1_keys_exp, ctrs1_keys);
    printf("\nTotal count (should be %d): %d ", ctrs1_count_exp, ctrs1_count);
    printf("\nPrinting ctrs1:\n");
    counters_print(ctrs1, stdout);
    printf("\n");
    printf("\n");

    printf("Testing counters_add, entering keys from input1...\n");
    // read lines from input1
    int key;
    char* line;
    while (!feof(input1)) {
        line = file_readLine(input1);
        if (line != NULL && !str2int(line, &key)) {
            fprintf(stdout, "Error: key must be an integer\n");
            continue;
        }
        int count = counters_add(ctrs1, key);
        if (count == 0) {
            fprintf(stdout, "Error: key must be a positive integer\n");
            continue;
        }
        fprintf(stdout, "Key %d added; Counter count: %d\n", key, count);
        ctrs1_count++;
        if (count == 1) {ctrs1_keys++;}
    }

    ctrs1_keys_exp = 0; 
    ctrs1_count_exp = 0;
    counters_iterate(ctrs1, &ctrs1_count_exp, totalcount);
    counters_iterate(ctrs1, &ctrs1_keys_exp, keycount);
    printf("\nTotal keys (should be %d): %d ", ctrs1_keys_exp, ctrs1_keys);
    printf("\nTotal count (should be %d): %d ", ctrs1_count_exp, ctrs1_count);
    printf("\nPrinting ctrs1:\n");
    counters_print(ctrs1, stdout);
    printf("\n");
    printf("\n");

    printf("Testing counters_set, entering keys from input2 file \n and setting each key to a random number between 0-100...\n");
    // read lines from input2, and reset key variable:
    key = 0;
    line = NULL;
    while (!feof(input2)) {
        line = file_readLine(input2);
        if (line != NULL && !str2int(line, &key)) {
            fprintf(stdout, "Error: key must be an integer\n");
            continue;
        }
        // If key is already present, we first subract it from both counts,
        // and later refresh the counts:
        if (counters_get(ctrs1,key) != 0) {
            ctrs1_count -= counters_get(ctrs1,key);
            ctrs1_keys --;
        }
        
        // Generate random number between 0-100:
        int r = rand() % 101;
        if (!counters_set(ctrs1, key, r)){
            fprintf(stdout, "Error: key must be a positive integer\n");
            continue;
        }
        fprintf(stdout, "Setting key %d to random number %d...\n", key, r);
        // Update counts:
        ctrs1_count += r;
        ctrs1_keys ++;
    }

    ctrs1_keys_exp = 0; 
    ctrs1_count_exp = 0;
    counters_iterate(ctrs1, &ctrs1_count_exp, totalcount);
    counters_iterate(ctrs1, &ctrs1_keys_exp, keycount);
    printf("\nTotal keys (should be %d): %d ", ctrs1_keys_exp, ctrs1_keys);
    printf("\nTotal count (should be %d): %d ", ctrs1_count_exp, ctrs1_count);
    printf("\nPrinting ctrs1:\n");
    counters_print(ctrs1, stdout);
    printf("\n");
    printf("\n");

    printf("\nTrying to delete NULL counters...\n");
    counters_delete(NULL);

    printf("\nTesting counters_delete on ctrs1...\n");
    counters_delete(ctrs1);

}
/* 
 */
 void 
totalcount(void* arg, const int key, const int count)
{
  int* nitems = arg;
  if (nitems != NULL) { (*nitems) += count; }
}

/* 
 */
 void 
keycount(void* arg, const int key, const int count)
{
  int* nitems = arg;
  if (nitems != NULL) { (*nitems) ++; }
}

/*
 * String to integer function:
 */
 bool 
str2int(const char string[], int *number)
{ // int * means "pointer to an integer"

  char nextchar; // local variable
  if (sscanf(string, "%d%c", number, &nextchar) == 1)
  {
    return true;
  } // ensures that exactly one number is entered by the user
  else
  {
    return false;
  }
}

