
#include <time.h>
#include <stdio.h>

extern void value_iteration_test(const int tot_rounds);

#define TOT_ROUNDS 100000

int main()
{
    clock_t start_time = clock();
    value_iteration_test(TOT_ROUNDS);
    clock_t end_time = clock();
    printf("value_iteration_test(%d) took %f seconds\n", TOT_ROUNDS, ((double) end_time - (double) start_time) / 1000000.00);
    return 0;
}

