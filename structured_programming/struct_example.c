
#include <string.h>

struct student {
    char first_name [30];
    char last_name  [30];
    unsigned char class;
    int grade;
};

int main(void)
{
    struct student newstudent;
    strcpy(newstudent.first_name, "Rob");
    strcpy(newstudent.last_name, "Brera");
    newstudent.class = 2;
    newstudent.grade = 8;

    return 0;
}