# Client
# WhaleWatchers, Winter 2023

 ## Client
 The **client** is a program that handles the participant ie `Player` and `Spectator` components of the Nuggets program. It parses the `hostname` and `portID` passed in by the user, handles sending and receiving messages from the server module, and handles the intialization and update of `ncurses` display window of the game that is visible on the `client`'s side of the program.

 ## Usage
 The **client** module, implemented in `client.c`, implements a `client` struct as discussed in `IMPLEMENTATION.md` , and exports the following main functions:

 ```c
void parseArgs(const char* hostname, const char *portNumber);
void send_player(char* real_name,const addr_t serverAddress);
void send_spectator(const addr_t serverAddress);
void ncurses_init();
static bool handle_grid(char nRows, char nColumns);
 ``` 
## Implementation
`parseArgs` takes arguments passed in by the user, verifies them and returns an error in the case that at least one of the parameters is invalid;

`send_player` sends a message to the server, requesting for a player to be initialized;

`send_spectator` sends a message to the server, requesting for a spectator to be initialized;

`ncurses_init` initializes the display window containing the visible component of the game to the user 

`handle_grid` ensures that the current grid size has a valid size

## Assumptions
In our `client` implementation we made the following assumptions:
    
    1. The user knows the `hostname` and `portNumber` of the current server before initializing the server
    2. The user has the `ncurses` library installed in their current library.

## Files
`Makefile` - compilation procedure

`client.c` - the implementation

## Compilation
To `make` the **client**, simply run `make` on the main Nuggets Makefile. 

## Testing
In our **Nuggets** implementation, we chose to include one main test script, `./testing.sh`, that contains the **Client** testing, while also indirectly testing the server.

