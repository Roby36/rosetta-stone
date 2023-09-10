
/*
 * playerstruct.c - this module is responsible for keeping
 *                  track of all internal features of a player, including
 *                  nuggets collected, currently visible grid, position,
 *                  number and name.
 * 
 * CS 50 Group 33, 23W
 */

#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <strings.h>
#include <stdlib.h>
#include <math.h>
#include <unistd.h>

#include "playerstruct.h"
#include "grid.h"
#include "mem.h"

/**************** Global constants ****************/

#define MAXCHARLINE 100  // maximum number of characters per line when printing player information

static const char solidRock = ' ';
static const char horizontalBoundary = '-';
static const char verticalBoundary = '|';
static const char cornerBoundary = '+';
static const char roomSpot = '.';
static const char passageSpot = '#';

/**************** Function implementations ****************/

/**************** player_new ****************/
/* see playerstruct.h for description */
player_t *
player_new(const char *name, int playerNumber, int pos, grid_t *spectatorGrid, grid_t *originalMap)
{

    // Validate parameters:
    if (name == NULL || playerNumber < 0 || spectatorGrid == NULL || originalMap == NULL || getX(spectatorGrid, pos) == -1)
    {
        return NULL;
    }

    player_t *playerp = mem_malloc(sizeof(player_t));
    if (playerp == NULL)
    {
        return NULL;
    }

    // Allocate space for player's name (later to be free'd)
    playerp->name = mem_malloc(strlen(name) + 1);
    if (playerp->name == NULL)
    {
        return NULL;
    }
    strcpy(playerp->name, name);

    // Set player as active by default (no reason to initiate a "dead player")
    playerp->isActive = true;
    playerp->playerNumber = playerNumber;
    playerp->pos = pos;
    playerp->nuggets = 0;

    // Update player's grid to visible section of spectator's
    // grid from player's initial position:
    getVisibleGrid(spectatorGrid, playerp->currGrid,
                   getX(spectatorGrid, pos), getY(spectatorGrid, pos));

    playerp->originalMap = originalMap;

    return playerp;
}

/**************** player_updateGrid ****************/
/* see playerstruct.h for description */
void player_updateGrid(void *spectGrid, const char *key, void *playerp)
{

    grid_t *spectatorGrid = spectGrid;
    player_t *player = playerp;

    // Validate parameters, and check that player is still active:
    if (player == NULL || spectatorGrid == NULL || !player->isActive)
    {
        return;
    }

    // Iterate through entire (updated) spectatorGrid:
    for (int i = 0; i < get_TC(spectatorGrid); i++)
    {

        char currSpectatorChar = get_gridPoint(spectatorGrid, i);
        char originalChar = get_gridPoint(player->originalMap, i);

        // If player no longer in former position,
        // update gridpoint with what's on the spectatorGrid:
        if (i == player->pos)
        {
            (player->currGrid)[i] = '@';
        }
        else if ((player->currGrid)[i] == '@')
        {
            (player->currGrid)[i] = currSpectatorChar;
        }
        // Update every visible point from the player's position:
        else if (isVisible(spectatorGrid, getX(spectatorGrid, player->pos), getY(spectatorGrid, player->pos),
                           getX(spectatorGrid, i), getY(spectatorGrid, i)))
        {
            (player->currGrid)[i] = currSpectatorChar;
        }
        // Otherwise, any point which is not currently visible from the player's position
        // can remain in the player's vision iff it is of any of the following types:
        else if ((player->currGrid)[i] == solidRock || (player->currGrid)[i] == horizontalBoundary ||
                 (player->currGrid)[i] == verticalBoundary || (player->currGrid)[i] == cornerBoundary ||
                 (player->currGrid)[i] == roomSpot || (player->currGrid)[i] == passageSpot)
        {
        }
        // Thus, any gridpoint which is neither visible nor one that can be remembered
        // is reverted back to its original character:
        else
        {
            (player->currGrid)[i] = originalChar;
        }
    }
}

/**************** player_print ****************/
/* see playerstruct.h for description */
void player_print(void *summ, const char *key, void *playerp)
{
    // Cast array containing current game summary and playerpointer:
    char *summArray = summ;
    player_t *player = playerp;

    // Validate parameters:
    if (summArray == NULL || player == NULL)
    {
        return;
    }

    // Create array for player's information:
    char playerArray[MAXCHARLINE];

    // Enter player's information on the array:
    sprintf(playerArray, "%s %6d %s\n", key, player->nuggets, player->name);

    // Append player's relevant information to current character array:
    strcat(summArray, playerArray);
}

/**************** player_delete ****************/
/* see playerstruct.h for description */
void player_delete(void *player)
{

    player_t *playerp = player;

    if (playerp != NULL)
    {
        mem_free(playerp->name);
        mem_free(playerp);
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
