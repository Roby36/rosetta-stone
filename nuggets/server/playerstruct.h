
/*
 * playerstruct.h - this module is responsible for keeping
 *                  track of all internal features of a player, including
 *                  nuggets collected, currently visible grid, position,
 *                  number and name.
 * 
 * CS 50 Group 33, 23W
 */   


#ifndef __PLAYER_H
#define __PLAYER_H

#include "grid.h"
#include "mem.h"

#define MAXMAPCHAR 10000 // maximum number of characters to be stored in map array

/**************** Global types ****************/

typedef struct player
{
    bool isActive;             // whether player is still part of the game or has left the game
                               // this attribute is necessary because hashtables don't support
                               // single item removal
    char *name;                // name of player given when player joins
    int playerNumber;          // number of player in the game
    int pos;                   // array position of player in grid array
    int nuggets;               // nuggets collected by the player so far
    char currGrid[MAXMAPCHAR]; // the grid that is currently visible to the player
    grid_t *originalMap;       // original empty map of game for reference
} player_t;

/**************** Function headers ****************/

/* ******************* player_new ************************************** */
/* This function allocates space for and 
 * initiates a new player struct.
 *
 * We assume:
 *   caller provides string for player's name, positive integer
 *   for playerNumber, starting position of player, the current
 *   spectatorGrid, and the originalMap for the game
 * 
 * We return:
 *   The pointer to the newly created player struct, 
 *    NULL if error or parameters invalid.
 *   
 * We guarantee:
 *   The module is responsible for malloc'ing memory for the player's name
 *   and later free'ing it, thus the name string need not be malloc'd.
 *   All relevant information for the player (including his visible grid)
 *   is initiated appropriately.
 *   
 * Caller is responsible for:
 *   Later calling player_delete() to free the returned pointer.
 *   
 * IMPORTANT:
 *   * The function assumes that a valid starting position is provided for 
 *     the player (this is determined by a random procedure in add_player())
 *   * The function does not verify the uniqueness and validity 
 *     of playerNumber (the higher-level add_player() is responsible for that)  
 *   * The function only uses the spectatorGrid for reference, and is not 
 *     responsible for updating it with the new player's character 
 *      (the higher-level add_player() is responsible for that)
 *   * The player stores no copy of originalMap, which is shared by all player
 *     structs and must not be deleted nor changed until the end of the game 
 */
player_t* player_new(const char* name, int playerNumber, int pos, grid_t* spectatorGrid, grid_t* originalMap);


/* ******************* player_updateGrid ************************************** */
/* This function is used to update the current visible grid of a player
 * after any change in the game.
 *
 * We assume:
 *   Pointers are casted to void* in order to use this function as parameter
 *   for hashtable_iterate() on the hashtable of all players in the game, updating
 *   their grids simultaneously.
 *     Hence, the caller provides the updated spectator grid, the hashtable of players
 *   in the game, and this function as parameters for hashtable_iterate().
 * 
 * We return:
 *   Nothing (void).
 *   
 * We guarantee:
 *   The player's currently visible grid is updated to reflect any changes in the
 *   game. 
 *   
 * IMPORTANT:
 *   Before calling this function, the caller must ensure that
 *   1) The player's position playerp -> pos is updated
 *   2) The spactator grid spectGrid is updated
 *   The grid is updated only for currently active players. 
 *   Once a player leaves the game its grid will not be updated anymore.
 */
void player_updateGrid(void* spectGrid, const char* key, void* playerp);


/* ******************* player_delete ************************************** */
/* This function is used to delete a player struct.
 *
 * We assume:
 *   caller provides a player pointer to be free'd.
 * 
 * We return:
 *   Nothing (void).
 * 
 * We guarantee:
 *   All the memory previously malloc'd by the player struct and its
 *   attributes is free'd. NULL pointers are ignored
 *   
 * Notes:
 *  Pointer is cast to void* to use this function as parameter to hashtable_delete() 
 */
void player_delete(void* player);


/* ******************* player_print ************************************** */
/* This function is used to print letter, nuggets, and name of a given player.
 *
 * We assume:
 *   This function is designed to be used as a parameter to hashtable_iterate().
 *   caller provides hashtable of players, character pointer for array where 
 *   player's information needs to be added, and this function player_print
 *   as parameters to hashtable_iterate().
 *   
 * We return:
 *   Nothing (void).
 *   
 * We guarantee:
 *   Player's letter, nuggets, and name are added to the array in the 
 *   appropriate format. Invalid parameters are ignored.
 */
void player_print(void* summ, const char* key, void* playerp);



/* ******************* Getters and Setters **************************** */
/*  These functions are used to access or change internal attributes 
 *  of players from external modules  */

void player_deactivate(player_t* player);

int player_getPos(player_t* player);

bool player_setPos(player_t* player, int pos);

bool player_isActive(player_t* player);

void player_addNuggets(player_t* player, int nuggets);

char* player_getGrid(player_t* player);



#endif //__PLAYER_H