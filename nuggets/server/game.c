
/*
 * game.c - This module is responsible for handling all the
 *            internal logic and parameters of the game
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
#include <ctype.h>

#include "log.h"
#include "game.h"
#include "grid.h"
#include "playerstruct.h"
#include "mem.h"
#include "hashtable.h"
#include "counters.h"


/**************** non-static global constants ****************/
const int MaxPlayers = 26;

/**************** Static global constants ****************/

#define MAXMAPCHAR 10000  // maximum number of characters to be stored in map array
#define MAXSUMMCHAR 10000 // maximum number of characters for storing the game summary

static const int MaxNameLength = 50;   // max number of chars in playerName
static const int GoldTotal = 250;      // amount of gold in the game
static const int GoldMinNumPiles = 10; // minimum number of gold piles
static const int GoldMaxNumPiles = 30; // maximum number of gold piles

static const char roomSpot = '.';
static const char passageSpot = '#';
static const char goldPile = '*';

/**************** Test headers ****************/

#ifdef GAME_TEST

void parseArgs(const int argc, char *argv[], char **mapDirectory, int *seedp);

#endif // GAME_TEST

/**************** Function implementations ****************/

/**************** game_new ****************/
/* see game.h for description */
game_t *
game_new(char *mapDirectory, int seed)
{

    // Allocate space for game struct:
    game_t *game = mem_malloc(sizeof(game_t));
    if (game == NULL)
    {
        return NULL;
    }

    // Initiate goldRemaining and currPlayers:
    game->goldRemaining = GoldTotal;
    game->currPlayers = 0;

    // Initiate playerHash to new empty hash
    game->playerHash = hashtable_new(MaxPlayers);
    if (game->playerHash == NULL)
    {
        fprintf(stderr, "Error initiating playerHash.\n");
        exit(5);
    }

    // Load original map and spectator grid from file and clean up:
    FILE *mapFp1 = fopen(mapDirectory, "r");
    FILE *mapFp2 = fopen(mapDirectory, "r");
    game->originalMap = grid_new(mapFp1);
    game->spectatorGrid = grid_new(mapFp2);
    if (game->originalMap == NULL || game->spectatorGrid == NULL)
    {
        fprintf(stderr, "Error loading initial maps\n");
        exit(6);
    }
    fclose(mapFp1);
    fclose(mapFp2);
    mem_free(mapDirectory);

    // Finally, we initialize the pileCounters:
    game->pileCounters = counters_new();
    if (game->pileCounters == NULL)
    {
        fprintf(stderr, "Error initializing pileCounters.\n");
        exit(7);
    }

    // If seed provided, seed random number generator with it:
    if (seed != 0)
    {
        srand(seed);
    }
    else
    {
        srand(getpid());
    }

    // Generate random number of gold piles in range
    // [GoldMinNumPiles, GoldMaxNumPiles] (note inclusivity)
    int numPiles = (rand() % (GoldMaxNumPiles - GoldMinNumPiles + 1)) + GoldMinNumPiles;

    // Now create an array of all roomSpot positions in the original map,
    // keeping track of its length:
    int roomSpotCount = 0;
    int roomSpotPositions[MAXMAPCHAR];
    for (int pos = 0; pos < get_TC(game->originalMap); pos++)
    {
        char currGridpoint = get_gridPoint(game->originalMap, pos);
        if (currGridpoint == roomSpot)
        {
            roomSpotPositions[roomSpotCount] = pos;
            roomSpotCount++;
        }
    }

    // Now add at random numPiles to the selected positions within the array:
    int addedPiles = 0;
    int i;
    while (addedPiles < numPiles && addedPiles < roomSpotCount)
    {
        // Generate random index within array (i.e. select a random room spot):
        i = rand() % roomSpotCount;

        // If corresponding room spot position does not contain a gold pile yet, add it:
        if (counters_get(game->pileCounters, roomSpotPositions[i]) == 0)
        {
            counters_add(game->pileCounters, roomSpotPositions[i]);
            // Update spectatorGrid and addedPiles:
            set_gridPoint(game->spectatorGrid, roomSpotPositions[i], goldPile);
            addedPiles++;
        }
    }

    // Now randomly increase the piles' counts until we reach the desired
    // number of nuggets:
    int addedNuggets = numPiles;
    while (addedNuggets < GoldTotal)
    {
        // Generate random index within array (i.e. select a random room spot):
        i = rand() % roomSpotCount;
        // If corresponding room spot position contains at least a gold pile,
        // increase its count:
        if (counters_get(game->pileCounters, roomSpotPositions[i]) > 0)
        {
            counters_add(game->pileCounters, roomSpotPositions[i]);
            addedNuggets++;
        }
    }

    // Initialize game with no spectator:
    game->spectator = false;

    return game;
}

/**************** add_player ****************/
/* see game.h for description */
char 
add_player(game_t *game, const char *name)
{
    // Validate parameters and ensure that we haven't yet reached
    // the maximum players allowed in the game:
    if (game == NULL || game->currPlayers == MaxPlayers)
    {
        log_v("game == NULL || game->currPlayers == MaxPlayers");
        return ' ';
    }

    // If the name is NULL, then we add spectator if possible:
    // The spectator grid is constantly accessible as an attribute of the main game
    if (name == NULL)
    {
        if (!(game->spectator))
        {
            game->spectator = true;
            return '\0';
        }
        else
        {
            log_v("Unable to add new spectator: previous one has not quit.");
            return ' ';
        }
    }

    // Ensure name doesn't exceed maximum length:
    if (strlen(name) > MaxNameLength)
    {
        log_s("Player name is greater than max lenth: %s", name);
        return ' ';
    }

    // Create an array of all roomSpot positions in the current spectator grid,
    // keeping track of its length:
    int roomSpotCount = 0;
    int roomSpotPositions[MAXMAPCHAR];
    for (int pos = 0; pos < get_TC(game->spectatorGrid); pos++)
    {
        char currGridpoint = get_gridPoint(game->spectatorGrid, pos);
        if (currGridpoint == roomSpot)
        {
            roomSpotPositions[roomSpotCount] = pos;
            roomSpotCount++;
        }
    }

    // If grid has NO available room spots to add the player, the player won't be added:
    if (roomSpotCount == 0)
    {
        log_v("No available spots for player");
        return ' ';
    }

    // Select a random room spot on the current spectatorGrid
    // where player will be added:
    int i = rand() % roomSpotCount;
    int playerPos = roomSpotPositions[i];

    // Create new player struct and add it to the hashtable of
    // all current players in the game.
    // Notice the string conversion of the letter required to enter it
    // in the hashtable:
    int playerNumber = game->currPlayers;
    char playerLetter = 'A' + playerNumber;
    player_t *player = player_new(name, playerNumber, playerPos, game->spectatorGrid, game->originalMap);
    if (player == NULL)
    {
        fprintf(stderr, "Error initiating player %c\n", playerLetter);
        return ' ';
    }

    char key[2] = {playerLetter, '\0'};
    if (!hashtable_insert(game->playerHash, key, (void *)player))
    {
        fprintf(stderr, "Error adding player %c to the game\n", playerLetter);
        return ' ';
    }

    // Now update the spectator grid to keep track of the addition of the player:
    set_gridPoint(game->spectatorGrid, playerPos, playerLetter);

    // Now that
    // 1) Spectator grid is up to date with addition of new player
    // 2) EACH player's position is up to date
    // we can update the visible grid of each active player in the game:
    hashtable_iterate(game->playerHash, (void *)game->spectatorGrid, player_updateGrid);

    // Increment the number of players in the game:
    game->currPlayers++;
    logPlayers("joined", playerLetter, game->currPlayers);

    return playerLetter;
}

/**************** handle_keyStroke ****************/
/* see game.h for description */
bool handle_keyStroke(game_t *game, char playerLetter, char keyStroke)
{

    if (game == NULL)
    {
        return false;
    }

    // If player wants to quit, remove it from the game.
    // Notice that quit_player handles spectator and any other exceptions:
    if (keyStroke == 'Q')
    {
        return quit_player(game, playerLetter);
    }

    // The only valid input for a spectator is 'Q' for quitting the game:
    if (playerLetter == '\0')
    {
        return false;
    }

    // Now verify if the playerLetter can be traced back to any active player in the game.
    // Return false if playerLetter invalid, or player inactive.
    player_t *player = find_player(game, playerLetter);
    if (player == NULL || !player_isActive(player))
    {
        return false;
    }

    // Now that player is validated, if capital letters are used
    // we call the function recursively with lower cases until it returns false:
    if (keyStroke == 'L' || keyStroke == 'H' || keyStroke == 'K' || keyStroke == 'J' ||
        keyStroke == 'Y' || keyStroke == 'U' || keyStroke == 'B' || keyStroke == 'N')
    {
        // If first call successful, we keep calling until possible and then return true
        // Else, we return false:
        if (!handle_keyStroke(game, playerLetter, tolower(keyStroke)))
        {
            return false;
        }
        while (handle_keyStroke(game, playerLetter, tolower(keyStroke)))
        {
        }
        return true;
    }

    // Grab current array position and cartesian coordinates of the player:
    int currPos = player_getPos(player);
    int x = getX(game->originalMap, currPos);
    int y = getY(game->originalMap, currPos);

    switch (keyStroke)
    {
    // Either set current coordinates to where the player is requesting to move:
    case 'l':
        x++;
        break;
    case 'h':
        x--;
        break;
    case 'k':
        y--;
        break;
    case 'j':
        y++;
        break;
    case 'y':
        x--;
        y--;
        break;
    case 'u':
        x++;
        y--;
        break;
    case 'b':
        x--;
        y++;
        break;
    case 'n':
        x++;
        y++;
        break;

    // Or if any other invalid keystroke is given return false:
    default:
        return false;
    }

    // Now identify the position and gridpoint on the current spectator grid where
    // the player is requesting to move:
    int destPos = getPos(game->spectatorGrid, x, y);
    char destGridpoint = get_gridPoint(game->spectatorGrid, destPos);

    // This boolean records whether a player has been displaced:
    bool playerDisplaced = false;

    // If the player is attempting to move on an empty spot,
    // skip to the end of the if-clauses:
    if (destGridpoint == roomSpot || destGridpoint == passageSpot)
    {
    }
    else if (destGridpoint == goldPile)
    {
        // First determine the nuggets in the gold pile:
        int nuggets = counters_get(game->pileCounters, destPos);
        if (nuggets == 0)
        {
            // For debugging purposes:
            fprintf(stderr, "Error: nuggets not found at position (%d,%d)\n",
                    getX(game->originalMap, destPos), getY(game->originalMap, destPos));
        }
        // Add nuggets to player's purse and remove them from the game:
        player_addNuggets(player, nuggets);
        game->goldRemaining -= nuggets;
        logGold(playerLetter, nuggets, game->goldRemaining);
        counters_set(game->pileCounters, destPos, 0);
    }
    // Otherwise, player must either have attempted to step on other player
    // or on illegal gridpoint:
    else
    {
        player_t *trampled = find_player(game, destGridpoint);
        if (trampled == NULL)
        {
            return false;
        } // illegal gridpoint
        playerDisplaced = true;
        // Update the position of the second player and spectator grid accordingly.
        // Note that the original player's position and spectator grid are updated later.
        player_setPos(trampled, currPos);
        logMove(destGridpoint, x, y, getX(game->originalMap, currPos), getY(game->originalMap, currPos));
        set_gridPoint(game->spectatorGrid, currPos, destGridpoint);
    }

    // Notice that if we make it to here, then the player's move must be acceptable.

    // If no player has been displaced, revert the former position of the player
    // to its original gridpoint:
    if (!playerDisplaced)
    {
        set_gridPoint(game->spectatorGrid, currPos,
                      get_gridPoint(game->originalMap, currPos));
    }

    // Update the player's position,
    // and the spectator grid for the player's new position:
    player_setPos(player, destPos);
    logMove(playerLetter, getX(game->originalMap, currPos), getY(game->originalMap, currPos), x, y);
    set_gridPoint(game->spectatorGrid, destPos, playerLetter);

    // Finally, update the visible grid of each player in the game
    hashtable_iterate(game->playerHash, (void *)game->spectatorGrid, player_updateGrid);


    return true;
}

/**************** quit_player ****************/
/* see game.h for description */
bool quit_player(game_t *game, char playerLetter)
{
    // Validate parameters:
    if (game == NULL)
    {
        return false;
    }
    
    // If playerLetter = '\0', remove spectator if present and return:
    if (playerLetter == '\0')
    {
        if (game->spectator)
        {
            game->spectator = false;
            return true;
        }
        else
        {
            return false;
        }
    }

    if (game->currPlayers == 0)
    {
        return false;
    }

    // Otherwise, validate playerLetter and grab corresponding active player.
    // Return false if we are trying to remove a player which isn't active.
    player_t *player = find_player(game, playerLetter);
    if (player == NULL || !player_isActive(player))
    {
        return false;
    }

    // Make player inactive:
    player_deactivate(player);

    // Update spectator map, reverting back player's position with
    // original character:
    set_gridPoint(game->spectatorGrid, player_getPos(player),
                  get_gridPoint(game->originalMap, player_getPos(player)));

    // Now that
    // 1) Spectator grid is up to date with removal of player
    // 2) EACH player's position is up to date
    // we can update the visible grid of each active player in the game:
    hashtable_iterate(game->playerHash, (void *)game->spectatorGrid, player_updateGrid);

    // Do not decrement the total number of players in the game
    // The quitting player is simply set as inactive
    logPlayers("removed from", playerLetter, game->currPlayers);

    return true;
}

/**************** game_summary ****************/
/* see game.h for description */
char* 
game_summary(game_t *game)
{
    char summArray[MAXSUMMCHAR];

    // Validate parameters:
    if (game == NULL)
    {
        return NULL;
    }

    // First enter "GAME OVER:" in array:
    sprintf(summArray, "GAME OVER: \n");

    // Now iterate through each player, appending their information to the array:
    hashtable_iterate(game->playerHash, (void *)summArray, player_print);

    // Allocate space for the summary string:
    char* summString = mem_malloc(strlen(summArray)+1);
    if (summString == NULL){
        fprintf(stderr, "Error allocating memory for summString\n");
        return NULL;
    }

    // Copy contents of game summary and return pointer:
    strcpy(summString, summArray);
    return summString;
}

/**************** game_delete ****************/
/* see game.h for description */
void game_delete(game_t *game)
{

    if (game != NULL)
    {
        // These function already handle potential NULL-pointers:
        hashtable_delete(game->playerHash, player_delete);
        counters_delete(game->pileCounters);
        grid_delete(game->originalMap);
        grid_delete(game->spectatorGrid);

        mem_free(game);
    }
}

/**************** find_player ****************/
/* see game.h for description */
player_t *
find_player(game_t *game, char playerLetter)
{
    if (game == NULL)
    {
        return NULL;
    }
    char key[2] = {playerLetter, '\0'};
    return ((player_t *)hashtable_find(game->playerHash, key));
}

/* ******************* logging functions ************************************** */

void logGold(char playerLetter, int collected, int remaining)
{
#ifdef LOG
    fprintf(stderr, "%d nuggets collected by %c: %d remaining\n", collected, playerLetter, remaining);
#else
    ;
#endif
}

void logPlayers(char *joinedleft, char playerLetter, int currPlayers)
{
#ifdef LOG
    fprintf(stderr, "%c %s the game: %d current players\n", playerLetter, joinedleft, currPlayers);
#else
    ;
#endif
}

void logMove(char playerLetter, int x1, int y1, int x2, int y2)
{
#ifdef LOG
    fprintf(stderr, "%c moved from (%d,%d) to (%d,%d)\n", playerLetter, x1, y1, x2, y2);
#else
    ;
#endif
}

/******************** GLASS BOX TESTING **********************/

#ifdef GAME_TEST

int main(const int argc, char *argv[])
{

    // Set seed to default value of zero,
    // and pass pointers to parseArgs
    int seed = 0;
    char *mapDirectory;

    // // parse arguments:
    parseArgs(argc, argv, &mapDirectory, &seed);

    // Initiate new game with parsed arguments:
    game_t *game = game_new(mapDirectory, seed);
    if (game == NULL)
    {
        fprintf(stderr, "Error initiating new game\n");
        exit(4);
    }

    // Open a file where all testing output will be recorded.
    // This will mostly be static maps of each player's vision.
    // The "make test" target will also create a "logging.out" file
    // for all logging messages (redirecting stderr)
    FILE *fp = fopen("./testing.out", "w");

    // Add 4 players to the game:
    if (add_player(game, "Rob") == ' ')
    {
        puts("Error adding player\n");
    }
    if (add_player(game, "Julian") == ' ')
    {
        puts("Error adding player\n");
    }
    if (add_player(game, "Ivy") == ' ')
    {
        puts("Error adding player\n");
    }
    if (add_player(game, "Zac") == ' ')
    {
        puts("Error adding player\n");
    }

    player_t *Rob = hashtable_find(game->playerHash, "A");
    if (Rob == NULL)
    {
        puts("Error retrieving player\n");
    }

    player_t *Julian = hashtable_find(game->playerHash, "B");
    if (Julian == NULL)
    {
        puts("Error retrieving player\n");
    }

    player_t *Ivy = hashtable_find(game->playerHash, "C");
    if (Ivy == NULL)
    {
        puts("Error retrieving player\n");
    }

    player_t *Zac = hashtable_find(game->playerHash, "D");
    if (Zac == NULL)
    {
        puts("Error retrieving player\n");
    }

    // Print the initial spectator grid and each player's vision:
    fprintf(fp, "%s", get_map(game->spectatorGrid));
    fprintf(fp, "%s", player_getGrid(Rob));
    fprintf(fp, "%s", player_getGrid(Julian));
    fprintf(fp, "%s", player_getGrid(Ivy));
    fprintf(fp, "%s", player_getGrid(Zac));

    /*******************************************************************************/
    /******** ENTER ANY INPUT KEYSTROKES FROM ANY PLAYER TO SIMULATE A GAME ********/
    /**********************+********************************************************/

    handle_keyStroke(game, 'A', 'H');
    handle_keyStroke(game, 'A', 'J');
    handle_keyStroke(game, 'A', 'L');

    handle_keyStroke(game, 'D', 'L');

    handle_keyStroke(game, 'C', 'J');
    handle_keyStroke(game, 'C', 'H');
    handle_keyStroke(game, 'C', 'K');
    handle_keyStroke(game, 'C', 'H');

    handle_keyStroke(game, 'B', 'Y');

    // Print spectator grid and each player's vision after keystrokes:
    fprintf(fp, "%s", get_map(game->spectatorGrid));
    fprintf(fp, "%s", player_getGrid(Rob));
    fprintf(fp, "%s", player_getGrid(Julian));
    fprintf(fp, "%s", player_getGrid(Ivy));
    fprintf(fp, "%s", player_getGrid(Zac));

    // Remove all 4 players from the game:
    if (!quit_player(game, 'A'))
    {
        puts("Error deleting player\n");
    }
    if (!quit_player(game, 'B'))
    {
        puts("Error deleting player\n");
    }
    if (!quit_player(game, 'C'))
    {
        puts("Error deleting player\n");
    }
    if (!quit_player(game, 'D'))
    {
        puts("Error deleting player\n");
    }

    fclose(fp);

    // Get game summary:
    char* summString = game_summary(game);

    if (summString == NULL){
        fprintf(stderr, "Error retrieving game summary\n");
        exit(8);
    }

    // Print array to stdout:
    puts(summString);

    // Clean up:
    mem_free(summString);
    game_delete(game);
    return 0;
}

#endif // GAME_TEST
