
#include <stdint.h>
#include <stdio.h>

int main() {
    int32_t a = 10;
    if (a < 5) {
        a++;
    } else {
        a--;
    }
    printf("a: %d\n", a);
}