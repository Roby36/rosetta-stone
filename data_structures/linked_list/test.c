
#include "linked_list.h"
#include <time.h>
#define STRLEN 2
#define LISTLEN 500000

static void nameprint(FILE* fp, void* item);
static void namedelete(void* item);
static void linked_list_test0();
static void linked_list_test1();

int main() 
{
    linked_list_test0();
    
    return 0;
}

// print a name, in quotes.
void nameprint(FILE* fp, void* item)
{
    char* name = item; 
    if (name == NULL)
        fprintf(fp, "(null)");
    else 
        fprintf(fp, "\"%s\"", name); 
}

// delete a name 
void namedelete(void* item)
{
    if (item != NULL)
        free(item);   
}

void linked_list_test0()
{
    printf("\n --- Initilaizing linked list ---\n");
    linked_list_t * m_ll = linked_list_new();
    printf("\n --- Linked list initialized ---\n");

    /* Allocate strings, later free'd by namedelete */

    printf("\n --- Allocating items ---\n");
    char * it1 = (char*) malloc(STRLEN);
    strncpy(it1, "1", STRLEN);
    char * it2 = (char*) malloc(STRLEN);
    strncpy(it2, "2", STRLEN);
    char * it3 = (char*) malloc(STRLEN);
    strncpy(it3, "3", STRLEN);
    char * it4 = (char*) malloc(STRLEN);
    strncpy(it4, "4", STRLEN);
    char * it5 = (char*) malloc(STRLEN);
    strncpy(it5, "5", STRLEN);
    char * it6 = (char*) malloc(STRLEN);
    strncpy(it6, "6", STRLEN);

    printf("\n --- Items allocated ---\n");

    printf("\n-----------------------------\n");
    linked_list_print(m_ll, stdout, nameprint);

    /* Insert all the items at the head */
    printf("\n --- Inserting items ---\n");
    linked_list_insert2(m_ll, it1, 0);
    linked_list_insert2(m_ll, it2, 0);
    linked_list_insert2(m_ll, it3, 0);
    linked_list_insert2(m_ll, it4, 0);
    linked_list_insert2(m_ll, it5, 0);
    linked_list_insert2(m_ll, it6, 0);
    printf("\n --- Items inserted ---\n");

    printf("\n-----------------------------\n");
    linked_list_print(m_ll, stdout, nameprint);

    /* Reverse linked list */
    printf("\n --- Reversing list ---\n");
    linked_list_reverse(m_ll);
    linked_list_print(m_ll, stdout, nameprint);
    printf("\n --- List reversed ---\n");

    /* Extract some items */
    printf("\n --- Extracting items ---\n");
    free(linked_list_extract2(m_ll, 0)); // first

    printf("\n-----------------------------\n");
    linked_list_print(m_ll, stdout, nameprint);

    free(linked_list_extract2(m_ll, 4)); // last

    printf("\n-----------------------------\n");
    linked_list_print(m_ll, stdout, nameprint);

    free(linked_list_extract2(m_ll, 2)); // middle 

    printf("\n-----------------------------\n");
    linked_list_print(m_ll, stdout, nameprint);

    linked_list_extract2(m_ll, 10); // out of range
    linked_list_extract2(m_ll, 5);
    linked_list_extract2(m_ll, -1);

    printf("\n-----------------------------\n");
    linked_list_print(m_ll, stdout, nameprint);

    printf("\n --- Items extracted ---\n");

    /* Delete list */
    printf("\n --- Deleting list ---\n");
    linked_list_delete(m_ll, namedelete);
    printf("\n --- List deleted ---\n");
}

void linked_list_test1() {

    time_t start_time = time(NULL);

    linked_list_t * m_ll = linked_list_new();
    for (int i = 0; i < LISTLEN; i++) {
        char * it = (char*) malloc(STRLEN);
        linked_list_insert2(m_ll, it, i);    // more expensive to insert at the end of linked list
    }
    for (int i = 0; i < (LISTLEN / 2); i++) // extract half of the items
        linked_list_extract2(m_ll, 0);
    linked_list_delete(m_ll, namedelete);   // delete the rest

    time_t end_time = time(NULL);
    printf("linked_list_test1() with LISTLEN %d took %ld seconds\n", LISTLEN, end_time - start_time);
}
