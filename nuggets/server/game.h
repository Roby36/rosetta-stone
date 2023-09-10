
/*
 * game.h - This module is responsible for handling all the
 *            internal logic and parameters of the game
 * 
 * CS 50 Group 33, 23W
 */

#ifndef __GAME_H
#define __GAME_H

#include "hashtable.h"
#include "counters.h"
#include "playerstruct.h"
#include "grid.h"

/**************** Global types ****************/

typedef struct game
{
    int goldRemaining;              // total gold nuggets remaining in the game
    int currPlayers;                // current number of players in the game
    hashtable_t *playerHash;        // hashtable of player structs in the game, keyed by their character IDs
    hashtable_t *playerConnections; // hashtable of character ids to addresses and addressed to character ids
    counters_t *pileCounters;       // counters keeping track of piles in the game,
                                    // keyed by position of pile in the grid,
                                    // and with values given by the nuggets in pile
    grid_t *originalMap;            // map on which the game is played (will be constant throughout)
    grid_t *spectatorGrid;          // current spectator grid (constantly updated throughout the game)
    bool spectator;                 // determines whether a spectator is currently present in the game
} game_t;



/**************** Function headers ****************/


/* ******************* game_new ************************************** */
/* This function is used to initialize a new game struct holding all
 * global variables when a game begins.
 *
 * We assume:
 *   caller provides mapDirectory and optional seed which have been already 
 *   validated by parseArgs. (seed = 0 if no seed provided)
 *   
 * We return:
 *   Pointer to the initialized game struct.
 *   NULL if malloc error.
 *   Exit program if unrecoverable error occurs.
 *   
 * We guarantee:
 *   If no exit and no NULL pointer returned, the game's 
 *   attributes are initialized as required by the specs.
 *   
 * Caller is responsible for:
 *   Later calling game_delete() on the returned pointer.   
 */
game_t* game_new(char* mapDirectory, int seed);


/* ******************* add_player ************************************** */
/* This function adds a spectator or player with a given name to the game.
 *
 * We assume:
 *   caller provides a game pointer and either a
 *   non-NULL string to add a player or a
 *   NULL string to add a spectator
 * 
 * We return:
 *   playerLetter iff player added
 *   '\0' iff spectator added
 *   empty character ' ' if the player/spectator can't be added either due to
 *   the game rules or due to any other error
 *   
 * We guarantee:
 *   Player's game and parameters are initiated as required by the 
 *   specs upon successful return.
 *   The spectator grid, as well as all the players' visible grids
 *   are updated to account for the addition of the new player.
 *   Hence, the entire game environment is appropriately updated
 *   following the addition of the player.
 *   
 * Important:
 *   The string providing the player's name need not be malloc'd.
 *   The player module is responsible for malloc'ing the player's
 *   name and later free'ing it.
 *   This function is not responsible for handling any of the implications 
 *   of adding a spectator to the game other than recording its presence
 *   by setting game -> spectator to true.
 */
char add_player(game_t* game, const char* name);


/* ******************* handle_keyStroke ************************************** */
/* This function handles any command coming from a player or spectator.
 *
 * We assume:
 *   caller provides pointer to the game, characte playerLetter identifying the 
 *   player giving the input (use '\0' if input comes from spectator), and
 *   character keyStoke provided by the player
 *   
 * We return:
 *   true iff the player's request is successfully executed
 *   false if
 *    * any parameter or keyStroke from the player/spectator is invalid
 *    * we are trying to remove a player/spectator which was already removed
 *    * the player is attempting to move on an illegal position
 *   
 * We guarantee:
 *    All possible keyStrokes (including 'Q' and capital letters) are handled
 *    by the function. 
 *   
 * IMPORTANT:
 *    When quitting spectators/players, this function is merely responsible for
 *    making the appropriate updates within the current game struct. For spectators,
 *    the function sets game -> spectator to false. For players, the function sets
 *    player -> isActive to false whenever a player requests to quit. This keeps
 *    the internal game environment updated. 
 * 
 *    Thus, whenever a player makes a valid quit request, the request must first be passed
 *    to this function (updating the game environment) before quitting the 
 *    connection with the player.
 */
bool handle_keyStroke(game_t* game, char playerLetter, char keyStroke);


/* ******************* quit_player ************************************** */
/* This function is used to remove a spectator or player from the game.
 *
 * We assume:
 *   caller provides game pointer and unique letter to identify the
 *   player to remove. 
 *   To remove spectator, caller provides the null
 *   character '\0' as the playerLetter.
 * 
 * We return:
 *   true iff player/spectator successfully removed from the game.
 *   false if any parameter is invalid, if player has already been removed, 
 *   or if any error.
 *   
 * We guarantee:
 *   The whole game variables, including the spectatorGrid and the visible 
 *   grids of each player are updated to account for the player's removal.
 *   
 * IMPORTANT:
 *   The removed player's player struct will remain in the hashtable of 
 *   players until the end of the game when the whole hashtable will be deleted.
 *   However, the player struct will be marked as inactive and will stop
 *   receiving any updates after the player's removal.
 */
bool quit_player(game_t* game, char playerLetter);


/* ******************* game_summary ************************************** */
/* This function is used to store the end-of-game summary in an string.
 *
 * We assume:
 *   caller provides pointer to the game.
 * 
 * We return:
 *   The pointer to a malloc'd string containing the game summary.
 *   NULL if game is NULL or if malloc error.
 *   
 * We guarantee:
 *   Memory is malloc'd to hold the string.
 *   Game summary is printed on string in required format.
 * 
 * IMPORTANT:
 *  This function is responsible for malloc'ing space for the game summary
 *  string. The caller is responsible for later free'ing that string. 
 */
char* game_summary(game_t* game);


/* ******************* game_delete ************************************** */
/* This function is used to delete a game struct.
 *
 * We assume:
 *   caller provides pointer to game struct to delete.
 * 
 * We return:
 *   Nothing (void).
 *   
 * We guarantee:
 *   NULL pointers are ignored.
 *   Otherwise, the memory previously malloc'd for each attribute of the game
 *   struct is free'd.
 */
void game_delete(game_t* game);


/* ******************* find_player ************************************** */
/* This function is used to find a player in the game.
 *
 * We assume:
 *   caller provides game pointer and character representing the
 *   playerLetter.
 * 
 * We return:
 *   NULL if any parameter is invalid or if player not found.
 *   Otherwise, we return the pointer to the player with the given character.
 *   
 * Notes:
 *   This function is necessary because the playerHash requires players to
 *   be keyed by strings rather than characters. 
 */
player_t* find_player(game_t* game, char playerLetter);



/* ******************* logging functions ************************************** */

void logGold(char playerLetter, int collected, int remaining);

void logPlayers(char* joinedleft, char playerLetter, int currPlayers);

void logMove(char playerLetter, int x1, int y1, int x2, int y2);

#endif //__GAME_H
