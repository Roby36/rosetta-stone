
/*
 * grid.h - this module handles all geometric and vision-related
 *          issues of the game by implementing a grid struct
 *          supporting a variety of functions
 * 
*/

#pragma once

#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <strings.h>
#include <stdlib.h>
#include <math.h>
#include <unistd.h>

#define MAXMAPCHAR 10000 // maximum number of characters to be stored in map array

/**************** Global constants, defined in commConsts.h ****************/

extern const char solidRock;
extern const char horizontalBoundary;
extern const char verticalBoundary;
extern const char cornerBoundary;
extern const char passageSpot;
extern const char roomSpot;

/**************** Global types ****************/

typedef struct grid grid_t;

/* ******************* grid_new ************************************** */
/* This function creates a new grid struct.
 *
 * We assume:
 *   caller provides a file pointer to a valid map file.
 * 
 * We return:
 *   NULL if mapFp is NULL or error.
 *   Otherwise, we return a pointer to the newly created grid struct. 
 *   
 * Caller is responsible for:
 *   Later free'ing the grid pointer by calling grid_delete().
 *   
 * Notes:
 *   This function, and the entire module itself, do not validate the map 
 *   file to make sure it is in the right format. 
 *   The caller/user is responsible for ensuring that.
 */
grid_t* grid_new(FILE* mapFp);


/* ******************* getX ************************************** */
/* This function extracts the x-coordinate for a given position
 * of a character array representing a map.
 *
 * We assume:
 *   caller provides grid pointer and array position of the string
 *   representing the grid's map.
 * 
 * We return:
 *   -1 if grid pointer is NULL or position out of range.
 *   Otherwise, we return the x-coordinate corresponding to the 
 *   given array position.
 */
int getX(grid_t* grid, int pos);


/* ******************* getY ************************************** */
/* This function extracts the y-coordinate for a given position
 * of a character array representing a map.
 *
 * We assume:
 *   caller provides grid pointer and array position of the string
 *   representing the grid's map.
 * 
 * We return:
 *   -1 if grid pointer is NULL or position out of range.
 *   Otherwise, we return the y-coordinate corresponding to the 
 *   given array position.
 */
int getY(grid_t* grid, int pos);


/* ******************* getPos ************************************** */
/* This function extracts the array position of a grid's map, given
 * a corresponding set of x,y coordinates.
 * 
 * We assume:
 *   caller provides grid pointer and x,y coordinates referring to
 *   a position within the grid's map.
 * 
 * We return:
 *   -1 if grid pointer is NULL or coordinates out of range.
 *   Otherwise, we return the array position corresponding to the 
 *   given coordinates.
 */
int getPos(grid_t* grid, int x, int y);


/* ******************* isVisible ************************************** */
/* This function determines whether an arbitrary point (ox,oy) 
 * is visible from an arbitrary position (px,py).
 * 
 * We assume:
 *   caller provides pointer to a grid and two sets of coordinates 
 *   (ox,oy) and (px,py) within the grid.
 * 
 * We return:
 *    true if and only if (ox,oy) is visible from (px,py).
 *    false otherwise, or if grid is NULL or any coodinate 
 *    out of range.
 *   
 * Notes:
 *    This function only determines visibility at a given time.
 *    Do not rely entirely on this function when updating the grid:
 *    - this function does not account for remembered 
 *      roomSpots, walls, passages, etc.
 *    - this function marks newline characters '\n' as not visible
 *      but they must be drawn anyway at all times
 */
bool isVisible(grid_t* grid,int px, int py, int ox, int oy);


/* ******************* getVisibleGrid ************************************** */
/* Given a position, this function computes a grid of tiles that are visible from it.
 *
 * We assume:
 *   caller provides a pointer to a grid, an initialized array with
 *   sufficient capacity to hold each updated gridpoint,
 *   and a set of coordinates within the grid.
 * 
 * We return:
 *   Nothing (void).
 *   
 * We guarantee:
 *   If the player lies on a non-allowed position, an error is printed
 *   to stderr and the function returns.
 *   Otherwise, if all parameters are valid, the given array is updated to 
 *   contain the player's vision of the grid's map from his position.
 *   
 * Caller is responsible for:
 *   Providing an initialized array with sufficient capacity. 
 *   The function assumes this.
 *   
 * Example usage:
 * 
 *  char pmap[MAXCHAR];  // initialize array with sufficient capacity
 *  getVisibleGrid(grid, pmap, 15, 7); // update pmap to contain grid
 *                                     // vision from position (15,7)
 *    // do something with pmap
 */ 
void getVisibleGrid(grid_t* grid, char pmap[], int px, int py);


/* ******************* grid_delete ************************************** */
/* This function deletes a grid
 *
 * We assume:
 *   caller provides grid pointer for grid to delete.
 * 
 * We return:
 *   Nothing (void).
 *   
 * We guarantee:
 *   All memory occupied by grid struct is free'd.
 *   NULL pointers are ignored.
 */
void grid_delete(grid_t* grid);




/******************** Getters and Setters *****************************/
/*  These functions are used to access or change internal attributes 
 *  of grids from external modules  


 ******************* get_gridPoint ***************************************/
/*  This function extracts the character on a given grid at a given position.
 *
 * We assume:
 *   caller provides grid pointer and valid position within grid.
 * 
 * We return:
 *   The character on the grid at the given position.
 *   '\0' (null character) if any parameter is invalid. 
 *   
 * Notes:
 *   This function requires the array position of the desired gridpoint.
 *   You may want to call getPos(gridp, x, y) first if you are using cartesian
 *   coordinates.
 */
char get_gridPoint(grid_t* grid, int pos);


/* ******************* get_TC ************************************** */
/* This function gives the total number of characters in a grid.
 *
 * We assume:
 *   caller provides valid grid pointer.
 * 
 * We return:
 *   Total number of characters in grid, or -1 if NULL grid pointer.
 *   
 * Notes:
 *   The count includes the trailing '\0'. Thus, to iterate through 
 *   each array position in the grid you may want to use
 *       for (int i = 0; i < get_TC(grid); i++) ...
 */
int get_TC(grid_t* grid);


/* ******************* set_gridPoint ************************************** */
/* This function sets a given position of a grid to a given character.
 *
 * We assume:
 *   caller provides grid pointer, position on grid to be changed,
 *   and character to be entered on grid at that position.
 * 
 * We return:
 *   true iff gridpoint successfully modified.
 *   false if any parameter is invalid. 
 */
bool set_gridPoint(grid_t* grid, int pos, char c);


/* ******************* get_map ************************************** */
/* This function extracts the string represention from a given grid.
 *
 * We assume:
 *   caller provides grid pointer.
 * 
 * We return:
 *   NULL if grid pointer is NULL.
 *   Otherwise, we return the string representation of the grid.
 */
char* get_map(grid_t* grid);



