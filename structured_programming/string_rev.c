
#include <stdio.h>
#include <string.h>

void reverse (char * a, int left, int right)
{
    if (left < right)
    {
        char tmp = a[left];
        a[left]  = a[right];
        a[right] = tmp;

        reverse(a, left + 1, right - 1);
    }
}

int main()
{
    char str[] = "\nRoberto\n";

    printf(str);
    reverse(str, 0, strlen(str) - 1);

    printf(str);
    reverse(str, 0, strlen(str) - 1);

    printf(str);
    return 0;
}