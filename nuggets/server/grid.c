
#include "grid.h"

/**************** Global constants ****************/

static const char solidRock = ' ';
static const char horizontalBoundary = '-';
static const char verticalBoundary = '|';
static const char cornerBoundary = '+';
static const char passageSpot = '#';

/***************** Grid struct definition ************************/
typedef struct grid
{
    int NR;               // number of rows in grid
    int NC;               // number of columns in grid
    int TC;               // number of total characters in grid (including '\0')
    char map[MAXMAPCHAR]; // string representing map of grid
} grid_t;

/**************** grid_new ****************/
/* see grid.h for description */
grid_t *
grid_new(FILE * mapFp)
{
    if (mapFp == NULL)
        return NULL;
    
    grid_t * grid = malloc(sizeof(grid_t));
    if (grid == NULL)
        return NULL;

    // Iterate through file to compute number of rows, columns,
    // and total characters for map, whilst entering each character
    // in array:
    char c; 
    grid->NR = 0;
    grid->NC = 0;
    grid->TC = 0;
    while ((c = getc(mapFp)) != EOF)
    {
        if (c != '\n' && (grid->NC == grid->TC)) // first row
            grid->NC++;
        else if (c == '\n')                  // new-line
            grid->NR++;
        (grid->map)[grid->TC++] = c;     // record character 
    }
    (grid->map)[grid->TC] = '\0';     // termiante grid with null character
    return grid;
}

/**************** getX ****************/
/* see grid.h for description */
int getX(grid_t *grid, int pos)
{
    // return -1 if any parameter is invalid:
    if (grid == NULL || grid->TC < pos + 1 || pos < 0)
        return -1;

    // Integer division by number of columns + newline character (included in array):
    return pos % (grid->NC + 1);
}

/**************** getY ****************/
/* see grid.h for description */
int getY(grid_t *grid, int pos)
{
    // return -1 if any parameter is invalid:
    if (grid == NULL || grid->TC < pos + 1 || pos < 0)
        return -1;

    // Subtract x coordinate from array position,
    // then divide by number of columns (including newline):
    return ((pos - getX(grid, pos)) / (grid->NC + 1));
}

/**************** getPos ****************/
/* see grid.h for description */
int getPos(grid_t * grid, int x, int y)
{
    // return -1 if parameters out of range:
    if (grid == NULL || x < 0 || x > grid->NC || y < 0 || y > grid->NR - 1)
        return -1;

    // We have y rows (including newlines) + x units:
    return (y * (grid->NC + 1) + x);
}

/**************** isVisible ****************/
/* see grid.h for description */
bool isVisible(grid_t *grid, int px, int py, int ox, int oy)
{
    // return false is any parameter is invalid:
    if (grid == NULL || 
        px < 0 || 
        px > grid->NC || 
        py < 0 || 
        py > grid->NR - 1 || 
        ox < 0 || 
        ox > grid->NC || 
        oy < 0 || 
        oy > grid->NR - 1)
        return false;

    // Get the minimum and maximum x and y values:
    int xmin, xmax, ymin, ymax;
    xmin = (px < ox) ? px : ox;
    xmax = (px < ox) ? ox : px;
    ymin = (py < oy) ? py : oy;
    ymax = (py < oy) ? oy : py;

    // Compute the gradient m of the line as a float:
    float m = (float)(oy - py) / (float)(ox - px);

    // Iterate through each x-coordinate between xmin and xmax exclusive
    // Loop will be skipped if xmax - xmin < 2
    for (int x = xmin + 1; x < xmax; x++)
    {
        // Compute the y-coordinate corresponding to the present x-coordinate
        // on the line connecting (px,py) to (ox,oy)
        float y = m * ((float)(x - px)) + (float)py;

        // Compute the gridpoints of both adjacent y-coordinates floorf(y) and ceilf(y):
        char prevTile = (grid->map)[getPos(grid, x, floorf(y))];
        char nextTile = (grid->map)[getPos(grid, x, ceilf(y))];

        // If both adjacent y-coordinates' gridpoints block vision, we return false.
        // Notice that if the y-coordinate is already an integer, floorf(y) = ceilf(y) = y.
        if ((prevTile == solidRock || prevTile == horizontalBoundary || prevTile == verticalBoundary || prevTile == cornerBoundary || prevTile == passageSpot) &&
            (nextTile == solidRock || nextTile == horizontalBoundary || nextTile == verticalBoundary || nextTile == cornerBoundary || nextTile == passageSpot))
        {
            return false;
        }
    }

    // Now repeat the process for each y-coordinate:
    for (int y = ymin + 1; y < ymax; y++)
    {
        // Compute the x-coordinate corresponding to the present y-coordinate
        // on the line connecting (px,py) to (ox,oy)
        float x = ((float)(y - py) / m) + (float) px;

        // Compute the gridpoints of both adjacent x-coordinates floorf(x) and ceilf(x):
        char prevTile = (grid->map)[getPos(grid, floorf(x), y)];
        char nextTile = (grid->map)[getPos(grid, ceilf(x), y)];

        // If both adjacent x-coordinates' gridpoints block vision, we return false.
        // Notice that if the x-coordinate is already an integer, floorf(x) = ceilf(x) = x.
        if ((prevTile == solidRock || prevTile == horizontalBoundary || prevTile == verticalBoundary || prevTile == cornerBoundary || prevTile == passageSpot) &&
            (nextTile == solidRock || nextTile == horizontalBoundary || nextTile == verticalBoundary || nextTile == cornerBoundary || nextTile == passageSpot))
        {
            return false;
        }
    }

    // If we reached this point, then nothing blocks vision:
    return true;
}

/**************** getVisibleGrid ****************/
/* see grid.h for description */
void getVisibleGrid(grid_t *grid, char pmap[], int px, int py)
{
    // Validate parameters:
    if (grid == NULL || 
        px < 0 || 
        px > grid->NC || 
        py < 0 || 
        py > grid->NR - 1)
        return;

    // Verify that player is on allowed position:
    char p = (grid->map)[getPos(grid, px, py)];
    if (p == horizontalBoundary || p == verticalBoundary || p == cornerBoundary || p == solidRock || p == '\n') {
        fprintf(stderr, "(%d, %d) position not allowed: %c\n", px, py, p);
        return;
    }

    // Iterate through entire grid:
    for (int i = 0; i < grid->TC; i++)
    {
        // Extract x,y coordinates:
        int x = getX(grid, i);
        int y = getY(grid, i);

        // Enter player's character
        if (x == px && y == py)
            pmap[i] = '@';
        // Enter newlines regardless of visibility:
        else if ((grid->map)[i] == '\n')
            pmap[i] = (grid->map)[i];
        // Enter arbitrary map coordinate only if visible:
        else if (isVisible(grid, px, py, x, y))
            pmap[i] = (grid->map)[i];
        else
            pmap[i] = solidRock;
    }
    // Finally, close array with null character:
    pmap[grid->TC] = '\0';
}

/**************** grid_delete ****************/
/* see grid.h for description */
void grid_delete(grid_t *grid)
{
    if (grid != NULL)
        free(grid);
}

/******************** Getters and Setters *****************************/
/*  These functions are used to access or change internal attributes
 *  of grids from external modules

 **************** get_gridPoint ****************/
/* see grid.h for description */
char get_gridPoint(grid_t *grid, int pos)
{
    if (grid == NULL || grid->TC < pos + 1 || pos < 0)
        return '\0';
    return (grid->map)[pos];
}

/**************** get_TC ****************/
/* see grid.h for description */
int get_TC(grid_t *grid)
{
    if (grid == NULL)
        return -1;
    return grid->TC;
}

/**************** set_gridPoint ****************/
/* see grid.h for description */
bool set_gridPoint(grid_t *grid, int pos, char c)
{
    if (grid == NULL || grid->TC < pos + 1 || pos < 0)
        return false;
    (grid->map)[pos] = c;
    return true;
}

/**************** get_map ****************/
/* see grid.h for description */
char *
get_map(grid_t *grid)
{
    if (grid == NULL)
        return NULL;
    return grid->map;
}

/**************** Unit-testing ****************/


#ifdef GRID_TEST

int main()
{

    // Open any map for testing by specifying its directory
    FILE *mapFp = fopen("../maps/blobby.txt", "r");
    grid_t * grid = grid_new(mapFp);

    // Print the entire map and the visible grid from an arbitrary position:
    // (Remember that remembered room spots are not accounted for)
    char pmap[MAXMAPCHAR];
    getVisibleGrid(grid, pmap, 45, 12);

    puts(grid->map);
    puts(pmap);

    // Clean up:
    grid_delete(grid);
    fclose(mapFp);

    return 0;
}

#endif // GRID_TEST

