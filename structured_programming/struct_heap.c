
#include <stdio.h>
#include <stdlib.h>

const int width = 100;
const int height = 100;

struct pixel {
    unsigned char red;
    unsigned char green;
    unsigned char blue;
};

int main(void)
{
    struct pixel * image = malloc (width * height * sizeof(struct pixel));
    if (image == NULL) {
        fprintf(stderr, "Error: malloc() failed\n");
        return 1;
    }

    for (int j = 0; j < height; j++) {
        for (int i = 0; i < width; i++) {
            image[j * width + i].red = 0;
            image[j * width + i].blue = 0;
            image[j * width + i].green = 0;
        }
    }

    free(image);
    return 0;
}
