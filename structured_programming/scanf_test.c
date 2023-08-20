
#include <stdio.h>

static char str1[] = "%d";
static char str2[] = "You entered %d\n";
static int n = 0;

int main(void)
{
    scanf(str1, &n);
    printf(str2, n);
    return 0;
}