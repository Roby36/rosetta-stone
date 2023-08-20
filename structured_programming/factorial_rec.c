
#include <stdio.h>

unsigned long factorial(int x) 
{
    if (x < 2)
        return 1;
    return x * factorial(x - 1);
}

int main()
{
    int x, goodval;
    do {
        printf("Enter x: ");
        goodval = scanf("%d", &x);
        if (goodval == 1)
            printf("%d! = %lu\n", x, factorial(x));
    } while (goodval == 1);
    return 0;
}