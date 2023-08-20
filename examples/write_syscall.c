
#include <unistd.h>

int main() {
    write(1, "Write syscall!\n", 16);
    return 0;
}