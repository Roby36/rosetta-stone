# Implementation Spec - Whale Watchers, Winter 2023

## Plan for division of labor
The current status of the division of labor is as follows:
- Client program: Ivy Mayende
- Server module: Zachary Badda
- Game module: Roberto Brera
- Code review, Git, support: Julian George
- Documentation and testing: All group members are responsible for this section and will work together to achieve this.
## Client
### Data structures
In our implementation of the `client` module we made use of the structure `client`, which is discussed in detail below.
### Client
The client struct holds the following information about each spectator and player:
- n , the amount of gold that a player that a player has just collected
- p, the amount of gold each player has in their purse. In the case of the spectator this would be NULL
- r, the amount of gold remaining in the game 
- realName, the name used by the player to join the game initially. In the case of the spectator this would remain as ‘_’
- clientLetter, the unique letter given to the player by the server when the player just joined the game

That information is stored with the following `client` struct
```
typedef struct client{
   char client_letter;  
   char* realName;    
   int p; 
   int r; 
   int n;  
}client_t;
```

### Definition of function prototypes
The following are the main functions used within the `Client` module and their respective descriptions.

#### parseArgs
A function to parse the command-line arguments:
```
void parseArgs(const char* hostname, const char *portNumber);
```

#### handle_keystroke()
A function to validate keystroke inputs from the user:
```
static bool handle_keystroke ();
```

#### handle_display()
A function to print display to client's screen given display message:
```
static bool handle_display(const char* display_message);
```

#### ncurses_init()
A function to initialize the grid-component of the spectator:
```
void ncurses_init();
```

#### handle_receipt()
A function to parse and direct the messages received from the server to helper methods:
```
static bool handle_receipt(client_t* player, char** message);
```

#### handle_error()
A function to handle printing of errors onto the display screen
```
static bool handle_error(const char* error_text);
```

#### Initializing communication
Helper functions responsible for sending initialization messages to the server:
```
void send_player(char* real_name,const addr_t serverAddress); // sending PLAY
void send_spectator(const addr_t serverAddress); // sending SPECTATE
```

#### handle_gold()
A function to update the amount of gold within a player’s struct:
```
static void handle_gold(client_t* player, int n, int p, int r);
```

#### handle_quit()
A function responsible for ending the game and printing out the gameOver summary:
```
static void handle_quit(char** messageGame);
```

#### handle_grid()
A function to ensure valid screen dimensions:
```
static bool handle_grid(char nRows, char nColumns)
```

### Detailed pseudo code
Below is detailed pseudo code for each function above.

#### parseArgs:
```
validate command line
decide whether spectator or player
```
	
#### handle_keystroke:

```
Keep reading from the stdin character by character until game is terminated
For each key passed in:
Validate that each is not null
Send KEY message to server 
```

#### nCurses_init:

```
Initialize the screen display
Begin accepting keystrokes
Confirm that the characters are not displayed on the screen
Initialize the screen’s color and turn it on
```


#### handle_receipt:

```
Validate that the message passed in is not null
Tokenize message and check what the first word of the message is:
	If OK, initialize the `clientLetter` of the player
	If QUIT, call on handle_quit
	If ERROR, log out the rest of the message to the user
	If GOLD, call on handle_gold
	If GRID, check that the rows and columns are valid then initialize the Display
	If DISPLAY, update the display of the players
	Else, log out an error message warning about an invalid message 
```


#### send_player

```
Validate that the name of the player meets the requirements
Construct and send PLAY message to the server
```


#### send_spectator

```
construct and send SPECTATE message to the Server
```


#### handle_gold 

```
validate n, p, and r 
for n, update the client’s n
for p, update the client’s p
for r, update the client’s r
```


#### handle_quit:

```
Close the display
Close the message connection	
Close ncurses_init
Log out a quit message to the user
Clean up
```

#### handle_grid():

```
Initialize display
Check that the current display meets the requirement specifications
Prompt user to enlarge their screen if length or width requirements not met 
```

#### handle_error():

```
Print error to the outpit file
Return false
```

#### handle_display():

```
Draw display on clients screen
Call refresh() to update
Return false
```
	
Please note that the server connection is iniitialized within the `main` function.

## Server
### Data structures
#### playerConnections
A hash table that acts as an enum between character IDs and IPs. It is implemented as a hashtable, where some keys are IDs with values of IPs, and where the rest of the keys are IPs with values of IDs. Here’s an example playerConnections object:
```
{
A : 192.0.0.7
192.0.0.7: A
B: 89.1.3.6
89.1.3.6: B
}
```

#### grid
The `grid` data structure is used to load a map text file and process it into the spectator grid and visible grids for each player. Below is its struct definition:
```
typedef struct grid
{
    int NR;               // number of rows in grid
    int NC;               // number of columns in grid
    int TC;            	 // number of total characters in grid (including '\0')
    char map[MAXMAPCHAR]; // string representing map of grid
} grid_t;
```


#### player
The `player` data structure keeps track of all information required by each player in the game:
```
typedef struct player
{
    bool isActive;             // this boolean records whether player is still
							   // part of the game or has left the game   
    char *name;                // name of player given when player joins
    int playerNumber;          // number of player in the game
    int pos;                   // array position of player in grid array
    int nuggets;               // nuggets collected by the player so far
    char currGrid[MAXMAPCHAR]; // the grid currently visible to the player
    grid_t *originalMap;       // original empty map of game for reference
} player_t;
```

#### game
The `game` data structure keeps track of the game environment and all the variables involved in it. Below is its struct definition:
```
typedef struct game
{
    int goldRemaining;        		// total gold nuggets remaining in the game
    int currPlayers;          		// current number of players in the game
    hashtable_t *playerHash;  		// hashtable of players in the game
	hashtable_t *playerConnections; // hashtable of character ids to addresses and vice versa
    counters_t *pileCounters; 		// counters keeping track of piles in the game,
                              		// keyed by position of pile in the grid,
                              		// and with values given by the nuggets in pile
    grid_t *originalMap;      		// map on which the game is played 
    grid_t *spectatorGrid;    		// current spectator grid (constantly updated) 
    bool spectator;           		// records whether a spectator is currently
      								// present in the game
} game_t;
```

### Definition of function prototype

#### server

#### parseArgs
This function validates command-line arguments and updates the respective pointers (`seedp` is set to zero by default).
```
void parseArgs(const int argc, char* argv[], char** mapDirectory, int* seed);
```
#### handleMessage
This function handles messages sent from the client to the server. Takes the `server_state` as its arg.
```
static bool handleMessage(void* arg, const addr_t from, const char* message);
```

#### grid

#### grid_new
This function loads a map file into a grid struct:
```
grid_t * grid_new(FILE *mapFp);
```
#### isVisible
This function determines whether a point `(ox,oy)` is visible from a player’s position `(px,py)` on a given `grid_t` struct:
```
bool isVisible(grid_t *grid, int px, int py, int ox, int oy);
```
#### getVisibleGrid
Given a position, this function computes a grid of tiles that are visible from it.
```
void getVisibleGrid(grid_t *grid, char pmap[], int px, int py);
```

#### game

#### game_new
This function is used to set up a new game environment:
```
game_t * game_new(char *mapDirectory, int seed);
```
#### handleKeystroke
This function is used to handle any keystroke from any player in the game, and update the game environment accordingly:
```
bool handle_keyStroke(game_t *game, char playerLetter, char keyStroke);
```
#### add_player
This function adds a spectator or player with a given name to the game.
```
char add_player(game_t* game, const char* name);
```

#### player

#### player_new
This function allocates space for and initiates a new player struct.
```
player_t* player_new(const char* name, int playerNumber, int pos, grid_t* spectatorGrid, grid_t* originalMap);
```

#### player_updateGrid
This function is used to update the current visible grid of a player after any change in the game.
```
void player_updateGrid(void* spectGrid, const char* key, void* playerp);
```

### Detailed pseudo code
Below is a detailed pseudocode for each major function of each module.
#### server
##### main 
See Design spec for pseudocode detailing the logical flow in main.

##### parse_Args

```
verify that there are either two or three command-line arguments
if three arguments are given
verify that third argument is a positive integer
set seed to third argument
verify that second argument is a directory that can be opened for reading 
set mapDirectory to second argument 
```

##### handleMessage
```
if message begins with “PLAY ”
	call add_Player() with name passed
if message begins with “SPECTATE ”
	call quit_player() on ‘\0’
	call add_player() with null name
if message begins with “KEY “
	find the character id from ip using playerConnections
	call handle_keystroke() with character id and key passed
if message begins with “QUIT “
	find the character id from ip using playerConnections
	call quit_player() on the character id
```

#### grid
##### grid_new
```
validate mapFp
allocate memory for grid_t struct
set grid->NC=0, grid->NR=0, grid->TC=0
for each character in mapFp file
if character is not a newline and grid->NC==grid->TC
increment grid->NC
if character is a newline
	increment grid->NR
add character to grid->map array
increment grid->TC
	add null character to grid->map array
```

##### isVisible
```
validate parameters
compute the gradient of the straight line connecting (ox,oy) to (px,py)
for each vertical column between (ox,oy) and (px,py)
	compute the y-coordinate where line intersects column
	if both upper and lower integer grid points block vision
		return false
for each horizontal row between (ox,oy) and (px,py)
	compute the x-coordinate where line intersects row
	if both left and right integer grid points block vision
		return false
return true
```

##### getVisibleGrid
```
validate parameters
verify that player is on allowed position
iterate through entire grid
	extract x, y coordinates
	enter player's character
	enter newlines regardless of visibility
	enter arbitrary map coordinate only if visible 
close array with null characters
```

#### game

##### game_new

```
set goldRemaining to GoldTotal
set currPlayers to zero
set spectator to false
initialize playerHash
initialize pileCounters
call grid_new() to load originalMap and spectatorGrid from mapDirectory
if optional seed is provided
	call srand(seed)
else
	call srand(getpid())
generate random NumPiles between GoldMinNumPiles and GoldMinNumMaxPiles
select at random NumPiles empty room spot positions in the originalMap
for each empty room spot position
	enter position as key in pileCounters
while GoldTotal nuggets haven’t been distributed
	increment a random counter in pileCounters
```

##### handle_keyStroke
```
validate parameters
if player/spectator enters ‘Q’
	call quit_player()
if input comes from spectator
	return false
get active player corresponding to playerLetter
if player enters a valid upper-case character
	call handle_keyStroke() until it returns true
	return what handle_keyStroke() returned on first call
if player enters a valid character
	determine position where player is requesting to move
else
	return false
if player is requesting to move on an illegal grid point
	return false
else if player is requesting to move on gold pile
	add corresponding nuggets to player’s purse
	set appropriate counter in pileCounters to zero
	decrement goldRemaining by the corresponding nuggets 
else if player is requesting to move on another player
	set position of second player to position of first player
	update spectatorGrid with updated position of second player
	set position of player to requested position
	set corresponding grid point on spectatorGrid to playerLetter
if no player was displaced
	set former player position to its grid point on originalMap
	call player_updateGrid on each active player
return true   
```

##### add_player
```
validate parameters and ensure we haven't reached max players
if the game is null
	add spectator if possible
ensure name doesn't exceed maximun length
create an array of all roomSpot positions in the current spectator grid
keep track of length of array
if grid has no available room spots to add the player
	player not added, return ' '
select a random room spot on the current spectatorGrid to add player to
create new player struct and add it to the hashtable of current players
update the spectator grid to keep track of the addition of the player
update the visible grid of each active player in the game
increment the number of players in the game
```


#### player

##### player_new
```
validate parameters
allocate space for player's name
set player as active by default
update player's grid to visibile section of spectator's grid from player's initial position
```

##### player_updateGrid

```
validate parameters
for each grid point in spectatorGrid
	if we are on player’s position
		set player’s corresponding grid entry to ‘@’
	else if player’s corresponding grid entry is ‘@’
		update it to the character on spectatorGrid
	else if this grid point is visible from player’s position
		add it to the player’s visible grid
	else if this grid point can be remembered
		keep the player’s visible grid unchanged
	else
		reset player’s corresponding grid entry to original maps
```

### Testing plan
*Unit Testing* : This shall be done progressively throughout the development process where smaller units of the Nugget game are tested before testing the whole program.
*Integration Testing*: The *Nuggets*, as a complete program will be tested by initializing the server then the client module; followed by creating several players and spectators and testing their performance in the general game. During our tests we shall also incorporate the following edge cases:
- Testing the nuggets game to initialize more Players once the `maxPlayers` limit has been reached
- Prompting the creation of more than one Spectator
- Less inputs than expected for both the `Player` module and the `Server` module
- More inputs than expected for both the `Player` module and the `Server` module
- Invalid inputs for both the `Player` and the `Client` module
- Testing the performance of the nuggets game on the same device and on different devices
- Testing the performance of the game on different `grid` designs
-Valgrind testing


### Limitations
The game module does not have a map-validating mechanism. It merely verifies that  the text file provided can be opened for reading, but does not ensure that the file represents a valid map (including all the necessary `\n` characters). Hence, even a small problem in the map file can lead to unexpected behavior of the program.
Our messaging protocol uses UDP. This protocol is less reliable than TCP. Thus, even a single character failing to arrive correctly to the client can greatly affect the grid the player receives, since the entire grid is sent from server to client through messaging.
Because we send over the entire visible grid to every client after every change in the game, this may negatively affect the speed of the program.

### Assumptions
The following are the assumptions made in our implementation:
The maximum number of players is 26.  It can be changed by changing the corresponding global constant but the assigned characters may not be appropriate, since they are computed based on increasing ASCII numbers (e.g. the 27th player would get `[` as letter)
The maximum number of spectators is 1.
The server program  is run before the client program. Therefore the client is responsible for obtaining the server’s IP address.
The `grid` module assumes that players don’t block visibility. This implies that if a player exits an empty passage spot into a room it makes that passage spot permanently visible to each player in the room (who is now able to see the first two passage spots of the passage rather than the first passage spot only)
