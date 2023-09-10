
/*
 * server.c - This module is responsible for handling all the
 *            internal logic and parameters of the game
 * 
 * usage: ./server <mapFile> [seed]
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

#include "mem.h"
#include "hashtable.h"
#include "counters.h"
#include "message.h"
#include "log.h"
#include "game.h"
#include "grid.h"
#include "playerstruct.h"


/**************** non-static global constants ****************/
extern const int MaxPlayers;

/****************** Mem module variables ********************/

int nmalloc = 0;         // number of successful malloc calls
int nfree = 0;           // number of free calls
int nfreenull = 0;       // number of free(NULL) calls


/**************** Function headers ****************/

/* ******************* parseArgs ************************************** */
/* This function parses command-line arguments.
 *
 * We assume:
 *   caller provides arguments of main(), pointer to string holding
 *   the map directory, and pointer to integer holding the optional seed
 *   parameter.
 * 
 * We return:
 *   Nothing (void).
 *   
 * We guarantee:
 *   If the function returns, all the parameters are valid and pointers
 *   appropriately set. 
 *   Otherwise, pertinent error messages are printed and the program exits.
 *   If the optional seed parameter is given and is valid, 
 *   the integer pointer is updated.  Else, the integer pointer is unchanged.
 *   The function allocates memory for the string containing the map
 *   directory only once this is validated.
 *   
 * Caller is responsible for:
 *   Later free'ing the string containing the map directory.
 *   
 * Notes:
 *   This function does NOT validate the map file other than ensuring
 *   that it can be opened for reading. 
 *   The validity of the map file is assumed throughout the program.
 */
void parseArgs(const int argc, char* argv[], char** mapDirectory, int* seedp);


/* ******************* str2int ************************************** */
/* This function converts a string into an integer.
 *
 * We assume:
 *   Caller provides a valid string string[] 
 *   and a valid pointer to an integer *number.
 * 
 * We return:
 *   If the string can be casted to an integer, the function returns 
 *   true and assigns the resulting integer to the pointer *number
 *   provided by the caller.
 *   Otherwise, the function returns false.
 *  
 * Caller is responsible for:
 *   Providing a string which contains one and only one integer,
 *   and nothing else.
 */
static bool str2int(const char string[], int *number);

/* ******************* handleMessage ************************************** */
/* This function is called by `message_loop` upon the server receiving a message
 *
 * Given an arg, which in our case is the server_state, 
 *   along with the source address and the message sent,
 *   parses & validates the message, then calls game functions accordingly
 *  
 * Returns true upon success,
 * returns false upon any error
 */
static bool handleMessage(void* arg, const addr_t from, const char* message);

/* ******************* handleTimeout ************************************** */
/* This function is called by `message_loop` upon the server timing out
 * 
 * Given the arg, which in our case is the server_state,
 *   calls handleEnd to clean everything up, returning the result
 */
static bool handleTimeout(void* arg);

/* ******************* handleEnd ************************************** */
/* This function is called to clean everything up once the game is over
 *
 * Given the server state, cleans up all the memory 
 *   and sends GAME OVER messages with the summary to all clients
 *
 * Returns true upon success,
 * returns false upon any error.
 */
static bool handleEnd(game_t* gameState);

/* ******************* handleEndIterator ************************************** */
/* This function is used in hashtable_iterate to send game over messages to all
 *   players in playerConnections once the game ends
 *
 * Takes the full game over message as an argument, 
 *   along with a key and item within playerConnections
 * 
 * Upon any error, no message will be sent to the player at the ip of `key`
 */
static void handleEndIterator(void* arg, const char *key, void* item);

/* 
* The following functions send their respective messages to the given client address.
* The message is parsed from inputs, and sent to clientAddr
*/
static void sendOk(char* playerId, const addr_t clientAddr);
static void sendGold(int n, int p, int r, const addr_t clientAddr);
static void sendGrid(int nRows, int nCols, const addr_t clientAddr);
static void sendDisplay(char* grid, const addr_t clientAddr);
static void sendQuit(char* quitMessage, const addr_t clientAddr);
static void sendError(char* errorMessage, const addr_t clientAddr);

/* ******************* str2addr ************************************** */
/* Converts a stringified addr from message_stringAddr back into an addr object
 *
 * Takes the stringified addr, 
 *    along with the addr object to assign the parsed address to
 * 
 * Returns true upon success,
 * upon failure, returns false and doesn't change addr
 */
static bool str2addr(const char* addrString, addr_t* addr);


/* ******************* updateDisplays ************************************** */
/* Loops thru all players' addresses and sends an updated display to each
 *
 * Takes the playerConnections hashtable, which has the IPs, 
 *   and the playerHash hashtable, which has the updated displays
 * 
 */
static void updateDisplays(game_t* gameState);

/* ******************* updateDisplayIterator ************************************** */
/* Sends a display message for the current playerId key
 * Used in hashtable_iterate on playerHash, passed playerConnections as the arg
 */
static void updateDisplayIterator(void* arg, const char* key, void* value);

/* ******************* updateGolds ************************************** */
/* Loops thru all players' addresses and sends an updated GOLD message to each
 *
 * Takes the gameState and the `oldPlayerHash`, which is a copy of 
 *   gameState->playerHash from before the game change.
 */
static void updateGolds(game_t* gameState);

/* ******************* updateGoldIterator ************************************** */
/* For the current playerId key, sends a message to that player with the updated gold
 *
 * Used in hashtable_iterate on updateGolds's oldPlayerHash, and passed gameState as the arg
 * Compares the current player's gold count in oldPlayerHash to their count in
 *   gameState->playerHash to get the number picked up, and combines that with the other
 *   gold totals to send the GOLD message back to the respective player.
 */
static void updateGoldIterator(void* arg, const char* key, void* value);

#ifndef GAME_TEST

/**************** Main program ****************/

int main (const int argc, char* argv[]){
    int seed = 0;                                                       // Set randomness seed to default value of zero
    char* mapDirectory;

    parseArgs(argc, argv, &mapDirectory, &seed);

    game_t* gameState = game_new(mapDirectory, seed);                  

    if (gameState == NULL){
        fprintf(stderr, "Error initiating new game. \n");
        // TODO: document error codes & figure out cleanup upon exit
        exit(4);
    }

    hashtable_t* playerConnections = hashtable_new(2*(MaxPlayers+1));                 // Initialize hash table to store players' addresses (26 letters + spectator)
    if (playerConnections == NULL)
    {
        fprintf(stderr, "Error building playerConnections structure. \n");
        exit(4);
    }

    gameState->playerConnections = playerConnections;                   // Store it within gameState for easy access

    // MALLOC space for spectator address, before insering it in playerConnections:
    addr_t* spectatorAddr = mem_malloc(sizeof(addr_t));
    *spectatorAddr = message_noAddr();
    bool spectatorInsertResult = hashtable_insert(playerConnections, "\0", spectatorAddr);   // Store spectator in playerConnections,
    if (!spectatorInsertResult){            
        fprintf(stderr, "Error adding spectator entry to hashtable");
    }
                                          
    log_init(stderr);                                                   // Initialize logging 

    int port = message_init(stderr);                                    // Initiate message module, which handles requests
    if (port == 0){
        fprintf(stderr, "Error initializing server message module. \n");
        exit(5);
    }

    log_d("Ready on port %d", port);

    message_loop(gameState, 60000, *handleTimeout, NULL, *handleMessage); // Start listening for messages

    return 0;
}

#endif // GAME_TEST


/**************** Function implementations ****************/
// TODO: consider making this static
void parseArgs(const int argc, char* argv[], char** mapDirectory, int* seedp){

    const char* programName = argv[0];

    if (argc != 2 && argc != 3)
    {
        fprintf(stderr, "Usage: %s map.txt [seed]\n", programName);
        exit(1);
    }

   
    else if (argc == 3)             // Verify that optional seed, if entered, is a positive integer and update the pointer
    {

        if ( !str2int(argv[2], seedp) || *seedp <= 0 )
        {
            fprintf(stderr, "%s: Seed must be a positive integer\n", programName);
            exit(2);
        }
    }

    FILE* fp = fopen(argv[1],"r");  // Verify that the mapDirectory can be opened for reading and allocate space for it
    if (fp == NULL)
    {
        fprintf(stderr,"%s: Error opening %s for reading\n", programName, argv[1]);
        exit(3);
    } 
    else 
    { 
        fclose(fp); 
    }

    *mapDirectory = mem_malloc_assert(strlen(argv[1])+1,"mapDirectory");
    strcpy(*mapDirectory,argv[1]);
}


static bool handleMessage(void* arg, const addr_t from, const char* message)
{
    bool noError = true;                                                                   // This variable remains true if no errors are encountered
    game_t* gameState = (game_t*)arg;
    if (gameState == NULL)
    {
        log_v("handleMessage called with arg=NULL");
        noError = false;
    }

    char* fromString = mem_malloc(strlen(message_stringAddr(from))+1); 
    strcpy(fromString, message_stringAddr(from));

    char* clientId = (char*) hashtable_find(gameState->playerConnections, fromString);     // Will be NULL if a new player is joining or the client is a spectator
    player_t* clientPlayer = hashtable_find(gameState->playerHash, clientId);          

    addr_t* spectatorAddr = hashtable_find(gameState->playerConnections, "\0");   // retrieve spectator address from hashtable (no need to cast)

    // TODO: really think about how best to do error handling
    if (strncmp(message, "PLAY ", strlen("PLAY ")) == 0) {

        const char* playerName = message + strlen("PLAY ");                                  

        char playerId = add_player(gameState, playerName);

        if (playerId == ' ')
        {
            log_v("Unable to add new player to game: no room available");
            sendError("Unable to join the game: no room available", from);
            sendQuit("Unable to join the game: no room available\n", from);
            return false;
        }
        char* playerIdString = mem_malloc(2);                                             // Malloc'ng memory to make it easier to free later
        snprintf(playerIdString, 2, "%c", playerId);
        player_t* addedPlayer = hashtable_find(gameState->playerHash, playerIdString);
        if (addedPlayer == NULL)
        {
            log_v("Unable to retrieve playerID from playerHash\n");
        }
        else
        {
            hashtable_insert(gameState->playerConnections, fromString, playerIdString);   // Add both playerId - addr and addr - playerId keypairs to hashtable
            // You must MALLOC the address before inserting it into the hashtable
            // Otherwise you will keep using the same pointer each time, hence the same address for every player
            addr_t* newPlayerAddr = mem_malloc(sizeof(addr_t));
            *newPlayerAddr = from; // set malloc'd address to point to incoming address
            hashtable_insert(gameState->playerConnections, playerIdString, newPlayerAddr);
            sendOk(playerIdString, from);
            sendGold(0, 0, gameState->goldRemaining, from);
            sendGrid(gameState->spectatorGrid->NR, gameState->spectatorGrid->NC, from);
            updateDisplays(gameState); // remember to update displays as soon as new player joins (including new player's display)

            log_v("Added new player to the game\n");
        }
    } 
    else if (strncmp(message, "SPECTATE", strlen("SPECTATE")) == 0 ) {
        log_s("New spectator at IP %s", fromString);
        add_player(gameState, NULL);

        if (spectatorAddr == NULL){
            log_v("NULL spectator found in playerConnections. \n");
            noError = false;
        }
        else
        {
            // First QUIT previous spectator:
            sendQuit("Sorry, other spectator joined the game.\n", *spectatorAddr);
            // Now update spectatorAddr pointer with incoming address:
            str2addr(message_stringAddr(from), spectatorAddr);                  // Sets spectatorAddr to the addr of the sender
            sendOk(NULL, from);
            sendGold(0, 0, gameState->goldRemaining, from);
            sendGrid(gameState->spectatorGrid->NR, gameState->spectatorGrid->NC, from);
            sendDisplay(gameState->spectatorGrid->map, from);  // no need to update all displays when spectator joins
        }
    }
    else if ((clientId != NULL && clientPlayer != NULL && clientPlayer->isActive) || message_eqAddr(*spectatorAddr, from))
    {
        if (strncmp(message, "KEY ", strlen("KEY ")) == 0){
            const char* content = message + strlen("KEY ");
            if (clientId != NULL){                                              // If the player is not a spectator:
                int prevGold = clientPlayer->nuggets;
                bool keyResult = handle_keyStroke(gameState, *clientId, *content); // This will also take into account a quitting spectator
                if (keyResult)
                {                                                               // Because keystroke could have changed the game state, 
                    int newGold = clientPlayer->nuggets;                        //   send updated gold and displays to everyone
                    sendGold(newGold-prevGold, newGold, gameState->goldRemaining, from);
                    updateGolds(gameState);
                    updateDisplays(gameState);
                }
                else 
                {
                    log_v("Invalid key stroke. \n");
                    sendError("Please enter a valid keystroke.\n", from);
                }
            }
            // Handle QUIT messages
            if (strcmp(content, "Q") == 0)
            {                                    
                // Quit message for spectator
                if (spectatorAddr!= NULL && message_eqAddr(from, *spectatorAddr))
                {
                    sendQuit("Thanks for watching!\n", from);
                    log_v("Spectator has quit.");
                }
                // Quit message for client
                else
                {
                    sendQuit("Thanks for playing!\n", from);
                    log_s("Player %s has quit", clientId);
                }
                log_s("reason: %s", content);
            }
            if (gameState->goldRemaining == 0){                                 // If the previous action(s) caused the end of the game
                handleEnd(gameState);                                           //   send QUIT GAME OVER messages,
                // Don't forget to free the malloc'd string before exiting!
                mem_free(fromString);
                return true;                                                    //   and stop listening for messages
            }
        }
    }
    else {
        if (clientId == NULL || (clientPlayer != NULL && !(clientPlayer->isActive)) )
        {
            log_s("Non-client sent a message: %s", message);
            sendError("You must join the game before doing that.", from);
            noError = true;                                                     // We do this to avoid multiple error messages being sent
        }
        else 
        {
            log_s("Invalid message received: %s", message);
        }
    }
    if (!noError)
    {
        sendError("An unknown error occurred while processing your message. \n", from);
    }

    mem_free(fromString);                                                       // Free the address string, since it is only used in this function (it isnt stored in a hashtable)

    return false;
}


static void updateDisplays(game_t* gameState)
{
    hashtable_iterate(gameState->playerHash, gameState, updateDisplayIterator);
    if (gameState->spectator)
    {
        addr_t* spectatorAddr = (addr_t*)hashtable_find(gameState->playerConnections, "\0");
        if (spectatorAddr == NULL || !message_isAddr(*spectatorAddr)) {
            log_v("Unable to update DISPLAY for spectator");
        }
        sendDisplay(gameState->spectatorGrid->map, *spectatorAddr);
    }
}


static void updateDisplayIterator(void* arg, const char* key, void* value)
{
    game_t* gameState = (game_t*) arg;
    player_t* currPlayer = (player_t*)value;
    addr_t* currPlayerAddr = (addr_t*)hashtable_find(gameState->playerConnections, key);  // We don't dereference the hashtable result immediately because it may be null pointer

    if (currPlayerAddr == NULL || !message_isAddr(*currPlayerAddr)) 
    {
        fprintf(stderr, "While sending DISPLAY, unable to find ip for player %s\n", key);
        return;
    }

    sendDisplay(currPlayer->currGrid, *currPlayerAddr);
}


static void updateGolds(game_t* gameState)
{
    hashtable_iterate(gameState->playerHash, gameState, updateGoldIterator);
    // Don't forget to update gold status for spectator as well:
    addr_t* spectAddr = hashtable_find(gameState->playerConnections, "\0");
    sendGold(0, 0, gameState->goldRemaining, *spectAddr);
}


static void updateGoldIterator(void* arg, const char* key, void* value)
{
    
    game_t* currentGame = (game_t*)arg;

    if (strcmp(key, "\0") == 0 && !currentGame->spectator) {        // First check that we are not dealing with a non-present spectator:
        return;
    }     
    player_t* currentPlayer = (player_t*)value;
    hashtable_t* playerConnections = currentGame->playerConnections;

    addr_t* playerAddr = (addr_t*)hashtable_find(playerConnections, key);
    if (playerAddr == NULL || !message_isAddr(*playerAddr)){
        log_v("Unable to retrieve player address upon gold change.");
        return;
    }
    int n = 0;                                                      // This is 0 because currentPlayer is only the players that aren't sending KEY message
    int p = currentPlayer->nuggets;                                 // Forming the n, p, and r sent in GOLD message                   
    int r = currentGame->goldRemaining;

    sendGold(n, p, r, *playerAddr);
    return;
}


static bool handleTimeout(void* arg)
{
    game_t* state = (game_t*)arg;
    return handleEnd(state);
}


static bool handleEnd(game_t* gameState)
{
    char* gameSummary = game_summary(gameState);

    hashtable_iterate(gameState->playerConnections, gameSummary, *handleEndIterator);  // Send GAME OVER messages

    // No need to check hashtable values, since all values are pointers to be free'd by now
    hashtable_delete(gameState->playerConnections, mem_free);                 
    game_delete(gameState);                                                            // Delete game

    mem_free(gameSummary);                                                             // Free summary
    log_done();                                                                        // Stop logging
    return true;                                                                            
}


static void handleEndIterator(void* arg, const char *key, void* item)
{
    char* gameSummary = (char*) arg;

    // Ensure that we are dealing with a valid address
    // Check specifically that this is NOT a playerID
    // to avoid memory read errors
    char character = *(char*)item;
    int ASCII = character;
    if (character != '\0' && !(ASCII >= 65 && ASCII <= 90))
    { 
        // Now we are sure that we are  dealing with some address
        addr_t* addr = item;
        if (message_isAddr(*addr))
        {
            sendQuit(gameSummary, *addr);
        }
    }
}


static void sendOk(char* playerId, const addr_t clientAddr)
{
    const char* okPrefix = "OK ";
    if (playerId == NULL){
        playerId = "";
    }
    int okMessageLength = strlen(okPrefix) + strlen(playerId) + 1;
    char* okMessage = mem_malloc(okMessageLength);
    snprintf(okMessage, okMessageLength, "%s%s", okPrefix, playerId);
    message_send(clientAddr, okMessage);
    mem_free(okMessage);
}


static void sendGold(int n, int p, int r, const addr_t clientAddr)
{
    int maxDigitSize = floor(log((double) r + 1));
    const char* goldPrefix = "GOLD ";
    int messageSize = strlen(goldPrefix) + maxDigitSize * 3 + 5;      // Size of prefix, max digit lengths, 4 spaces, and null terminator
    char* goldMessage = mem_malloc(messageSize);
    snprintf(goldMessage, messageSize, "%s%d %d %d", goldPrefix, n, p, r);
    message_send(clientAddr, goldMessage);
    mem_free(goldMessage);
}


static void sendGrid(int nRows, int nCols, const addr_t clientAddr)
{
    const char* gridPrefix = "GRID ";
    int gridMessageLength = strlen(gridPrefix) + floor(log((double) nRows + 1)) + 1 + floor(log((double)nCols + 1)) + 1; // Size of prefix, + digit lengths, + space, + null terminator
    char* gridMessage = mem_malloc(gridMessageLength);
    snprintf(gridMessage, gridMessageLength, "%s%d %d", gridPrefix, nRows, nCols );
    message_send(clientAddr, gridMessage);
    mem_free(gridMessage);
}


static void sendDisplay(char* grid, const addr_t clientAddr)
{
    const char* displayPrefix = "DISPLAY\n";
    int displayMessageLength = strlen(displayPrefix) + strlen(grid) + 1;
    char* displayMessage = mem_malloc(displayMessageLength);
    snprintf(displayMessage, displayMessageLength, "%s%s", displayPrefix, grid);
    message_send(clientAddr, displayMessage);
    mem_free(displayMessage);
}


static void sendQuit(char* quitContent, const addr_t clientAddr)
{
    const char* quitPrefix = "QUIT ";
    int quitMessageLength = strlen(quitPrefix) + strlen(quitContent) + 1;
    char* quitMessage = mem_malloc(quitMessageLength);
    snprintf(quitMessage, quitMessageLength, "%s%s", quitPrefix, quitContent);
    message_send(clientAddr, quitMessage);
    mem_free(quitMessage);
}


static void sendError(char* errorContent, const addr_t clientAddr)
{
    const char* errorPrefix = "ERROR ";
    int errorMessageLength = strlen(errorPrefix) + strlen(errorContent) + 1;
    char* errorMessage = mem_malloc(errorMessageLength);
    snprintf(errorMessage, errorMessageLength, "%s%s", errorPrefix, errorContent);
    message_send(clientAddr, errorMessage);
    mem_free(errorMessage);
}


static bool str2addr(const char* addrString, addr_t* addr)
 {
     if (addrString == NULL || addr == NULL)
     {
        return false;
     }

     char addrStringCopy[strlen(addrString)+1];
     strcpy(addrStringCopy, addrString);                                 // Copy addrString to ensure it isn't changed by the following char iterations

     char* currSubstring = (char*) (addrStringCopy) + 1 ;
     while (*currSubstring != '\0'){      
         if (*(currSubstring - 1) == ':'){                              // If the previous character was `:` 
             *(currSubstring - 1) = '\0';                               // Terminate the hostname there, and
             return message_setAddr(addrStringCopy, currSubstring, addr);   // since the currSubstring is therefore the port, use it to create the addr, returning the result
         }
         currSubstring += 1;
     } 
     return false;
 }


static bool str2int(const char string[], int *number) 
{ 
  char nextchar;
  if (sscanf(string, "%d%c", number, &nextchar) == 1) 
  { 
    return true; 
  } 
  else 
  { 
    return false; 
  }
}

