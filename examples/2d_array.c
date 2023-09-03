
#include <stdio.h>
#include <stdlib.h>

static int x_size   = 4;
static int y_size   = 4;
static int str_len  = 32;

int main() {

    char*** str_double_array;

    // Malloc the first series of pointers 
    str_double_array = malloc(x_size * sizeof (char **));
    for (int i = 0; i < x_size; i++) {
        // Access each malloc'd pointer 
        str_double_array[i] = malloc(y_size * sizeof (char *));
        for (int j = 0; j < y_size; j++) {
            // Malloc and fill up internal string
            str_double_array[i][j] = malloc(str_len * sizeof(char));
            snprintf(str_double_array[i][j], str_len, "str_double_array[%d][%d]", i, j);
            printf("Allocated %s\n", str_double_array[i][j]);
        }
    }

    // Access, print and free each string 
    for (int i = 0; i < x_size; i++) {
        for (int j = 0; j < y_size; j++) {
            printf("Freeing %s\n", str_double_array[i][j]);
            // Free internal string 
            free (str_double_array[i][j]);
        }
        // Free string array pointer 
        free (str_double_array[i]);
    }
    free(str_double_array);

    return 0;
}

