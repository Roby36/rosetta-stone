
/*
 * playerstruct.c - this module is responsible for keeping
 *                  track of all internal features of a player, including
 *                  nuggets collected, currently visible grid, position,
 *                  number and name.
 * 
 * CS 50 Group 33, 23W
 */

#include "playerstruct.h"

typedef struct player
{
    bool isActive;             // whether player is still part of the game or has left the game
                               // this attribute is necessary because hashtables don't support
                               // single item removal
    char *name;                // name of player given when player joins
    int playerNumber;          // number of player in the game
    int pos;                   // array position of player in grid array
    int nuggets;               // nuggets collected by the player so far
    grid_t *originalMap;       // original empty map of game for reference
    char currGrid[MAXMAPCHAR]; // the grid that is currently visible to the player
} player_t;

/**************** player_new ****************/
/* see playerstruct.h for description */

/*
player_t *
player_new(const char *name, int playerNumber, int pos, grid_t *spectatorGrid, grid_t *originalMap)
{
    // Validate parameters:
    if (name == NULL || 
        playerNumber < 0 || 
        spectatorGrid == NULL || 
        originalMap == NULL || 
        getX(spectatorGrid, pos) == -1)
        return NULL;

    // Not checking for NULL malloc returns for simplification purposes 
    player_t *playerp = malloc(sizeof(player_t));
    int name_length = strlen(name) + 1;
    playerp->name = malloc(name_length);
    strncpy(playerp->name, name, name_length);

    // Set player as active by default (no reason to initiate a "dead player")
    playerp->isActive = true;
    playerp->playerNumber = playerNumber;
    playerp->pos = pos;
    playerp->nuggets = 0;

    // Update player's grid to visible section of spectator's
    // grid from player's initial position:
    int x = getX(spectatorGrid, pos);
    int y = getY(spectatorGrid, pos);
    // printf("(x, y) = (%d, %d)\n", x, y);
    getVisibleGrid(spectatorGrid, playerp->currGrid, x, y);

    playerp->originalMap = originalMap;

    return playerp;
}
*/


/**************** player_updateGrid ****************/
/* see playerstruct.h for description */
/*
void player_updateGrid(void *spectGrid, const char *key, void *playerp)
{
    // Casting 
    grid_t *spectatorGrid = spectGrid;
    player_t *player = playerp;

    // Validate parameters, and check that player is still active:
    if (player == NULL || 
        spectatorGrid == NULL || 
        !player->isActive)
        return;
    
    // Iterate through entire (updated) spectatorGrid:
    for (int i = 0; i < get_TC(spectatorGrid); i++)
    {
        char currSpectatorChar = get_gridPoint(spectatorGrid, i);
        char originalChar = get_gridPoint(player->originalMap, i);

        // If player no longer in former position,
        // update gridpoint with what's on the spectatorGrid:
        if (i == player->pos)
            (player->currGrid)[i] = playerChar;
        else if ((player->currGrid)[i] == playerChar)
            (player->currGrid)[i] = currSpectatorChar;
        // Update every visible point from the player's position:
        else if (isVisible(spectatorGrid, getX(spectatorGrid, player->pos), getY(spectatorGrid, player->pos),
                           getX(spectatorGrid, i), getY(spectatorGrid, i)))
            (player->currGrid)[i] = currSpectatorChar;
        // Otherwise, any point which is not currently visible from the player's position
        // can remain in the player's vision iff it is of any of the following types:
        else if ((player->currGrid)[i] == solidRock || 
                 (player->currGrid)[i] == horizontalBoundary ||
                 (player->currGrid)[i] == verticalBoundary || 
                 (player->currGrid)[i] == cornerBoundary ||
                 (player->currGrid)[i] == roomSpot || 
                 (player->currGrid)[i] == passageSpot)
        {
        }
        // Thus, any gridpoint which is neither visible nor one that can be remembered
        // is reverted back to its original character:
        else
            (player->currGrid)[i] = originalChar;
    }
}
*/

/**************** player_print ****************/
/* see playerstruct.h for description */
void player_print(void * summ, const char *key, void *playerp)
{
    // Casting
    player_t * player = playerp;
    // Validate parameters:
    if (player == NULL)
        return;
    // Create temporary array for player's information:
    char playerArray[MAXCHARLINE];
    // Enter player's information on the array:
    snprintf(playerArray, MAXCHARLINE, "%s %6d %s\n", key, player->nuggets, player->name);
    // Malloc sufficient space for resulting concatenated string 
    const int str_len = strlen( (char *) summ) + 1;
    char * summArray = malloc(str_len + MAXCHARLINE);
    strncpy(summArray, (char *) summ, str_len);
    strncat(summArray, playerArray, MAXCHARLINE);    

    // Print out string and player map and then free it 
    puts(summArray);
    puts(player->currGrid);
    free(summArray);
}

/**************** player_delete ****************/
/* see playerstruct.h for description */
void player_delete(void *player)
{
    player_t *playerp = player;

    if (playerp != NULL)
    {
        free(playerp->name);
        free(playerp);
    }
}

/* ******************* Getters and Setters **************************** */

void player_deactivate(player_t *player)
{
    if (player == NULL)
    {
        return;
    }
    player->isActive = false;
}

int player_getPos(player_t *player)
{
    if (player == NULL)
    {
        return -1;
    }
    return player->pos;
}

bool player_setPos(player_t *player, int pos)
{
    // Validate player and position:
    if (player == NULL || get_TC(player->originalMap) < pos + 1 || pos < 0)
    {
        return false;
    }
    player->pos = pos;
    return true;
}

bool player_isActive(player_t *player)
{
    if (player == NULL)
    {
        return false;
    }
    return player->isActive;
}

void player_addNuggets(player_t *player, int nuggets)
{
    if (player == NULL)
    {
        return;
    }
    player->nuggets += nuggets;
}

char *
player_getGrid(player_t *player)
{
    if (player == NULL)
    {
        return NULL;
    }
    return player->currGrid;
}

// Unit testing 
#ifdef PS_UT

int main() {

    const int pos1 = 2000;

    // Initialize EMPTY spectator grid 
    FILE *mapFp = fopen("../maps/blobby.txt", "r");
    grid_t * spect_grid = grid_new(mapFp);

    // Initialize original map
    rewind(mapFp); // File pointer must be restored!
    grid_t * or_map = grid_new(mapFp);

    // Initialize player structs
    player_t* pstruct1 = player_new("Rob", 0, pos1, spect_grid, or_map);
    player_updateGrid(spect_grid, "A", pstruct1);
    player_print("<no_summary> ", "A", pstruct1);

    // Alter player's position and update grid & print out again
    pstruct1->pos += 5;
    player_updateGrid(spect_grid, "A", pstruct1);
    player_print("<no_summary> ", "A", pstruct1);

    // clean up
    player_delete(pstruct1);
    fclose(mapFp);

    return 0;
}

#endif // PS_UT


