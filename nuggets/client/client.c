
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
#include <unistd.h>
#include <time.h>
#include <ncurses.h>
#include <stdio.h>
#include "mem.h"
#include "file.h"
#include "message.h"
#include "log.h"

/*
 * client.c - client module for "nuggets" project
 *
 * USAGE ./client hostname port [playername]
 * 
 */

/*********************** local variable ******************************/
typedef struct client{
    char client_letter;    // letter of the client
    char* realName;        // real name of the client
    int p;                 // amount of gold in player's purse
    int r;                 // amount of gold remaining in the game  
    int n;                 // amount of gold that has currently been collected 
}client_t;

/********************* global variables *******************************/
static const int MinPort = 1024;            // maximum and minimum port numbers allowed
static const int MaxPort = 65535;
FILE *loggingFp;                            // file where logging will be stored
char* loggingFpName = "logging_output.txt"; // name of file where logging will be stored
static client_t* client;                    // information about the client struct stored by this module


/********************** local functions headers *************************/

/*************** parseArgs ***********************/
/**
 * parses arguments passed in by the user
 * 
 * for hostname, verify that it is not NULL
 * for portNumber, verify that it is not NULL
 * if either conditions are not met, exit with a non-zero exit status
 * 
 */
void parseArgs(const char* hostname, const char* portNumber);


/*************** handle_receipt ***********************/
/**
 * Receives messages from the server and calls the respective handler methods
 * 
 * Parameters:
 *      arg is is the server's address, used to validate the address of the sender
 *      an address of a server (server_address)
 *      the message sent by the server (message)
 * 
 * If the message received is:
 *      OK, store the letter passed in within the respective client struct
 *      QUIT, pass the message onto handle_quit
 *      ERROR, pass the error text of the message onto handle_error
 *      GOLD, pass the client's n, p, and r components of the message onto handle_gold
 *      DISPLAY, pass the grid from the message onto handle_display
 *      GRID, pass the nRows and nColumns onto handle_grid
 *      else, ignore it
 * 
 * returns a boolean indicating whether the game was quit or interrupted
 */
static bool handle_receipt(void* arg, addr_t server_address, const char* message);


/*************** handle_gold ***********************/
/**
 * helper method responsible for updating the gold status in the client's struct
 * 
 * Parameters: 
 *      n: the amount of gold that has just been collected
 *      p: the updated amount of gold in the client's purse
 *      r: the remaining amount of gold in the game
 * 
 * We guarantee:
 *      for each of the variables passed in, update them in the client's struct
 * 
 * returns false , representing that the update was succesful
*/
static bool handle_gold (int n, int p, int r);


/********************  handle_quit ********************************/
/**
 * helper method responsible for quiting the game
 * 
 * Parameter: quit_message: contains the quit explanation passed in by the server
 * 
 * We guarantee:    
 *     closes the ncurses
 *     prints the quit explanations to client's stdout 
 *    
 * retuns true, ending the game
 */
static bool handle_quit(const char* quit_message);


/*************** handle_display ***********************/
/**
 * helper method to output display to the client
 * 
 * Parameter: display_message, containing the client's display
 * 
 * We guarantee:
 *      prints the display onto the client's screen
 *      redraws the screen
 * 
 * returns false to keep the game going
 */ 
static bool handle_display(const char* message);


/*************** handle_error ***********************/
/**
 * helper method to handle the printing of error messages 
 * onto the display screen
 * 
 * takes in error_text containing the error explanation from the server
 * 
 * We guarantee:
 *      prints the error message in the assigned output file
 *      prints the error explanation onto the screen
 *      redraws the screeen to ensure the message is printed
 * 
 * return false to keep the game going
 **/ 
static bool handle_error(const char* error_text);


/*************** handle_keystroke ***********************/
/** 
 * helper method to handle the input from keystrokes
 * 
 * Parameters: arg, representing the server address
 * 
 * We guarantee:
 *      verifies that the server address is not NULL
 *      checks the validity of the server address
 *      reads and stores the character passed in by the user
 *      sends the key message
 *      
 * returns false if all goes well, else returns true
 **/
static bool handle_keystroke(void* arg);


/*************** send_player ***********************/
/**
 * helper method responsible for intitializing the player
 * 
 * Parameters:
 *      real_name, representing the name used by the player when joining the game
 *      serverAddress, representing the address of the server that will receive the message
 * 
 * We guarantee:
 *      constructs and sends the PLAY message to the server
 */
void send_player(char* real_name, const addr_t serverAddress);


/*************** send_spectator ***********************/
/**
 * helper method responsible for initializing the spectator
 * 
 * Parameters:
 *      serverAddress, representing the address of the server which 
 *      will receive the message
 * 
 * We guarantee:
 *      sends the SPECTATOR message to the server
 * 
 */
void send_spectator(const addr_t serverAddress);


/*************** ncurses_init ***********************/
/**
 * resposible for calling on methods to handle the display
 * 
 * We guarantee:
 *      Initializes the display screen
 *      Sets the the screen color
 *      Cleans up
 */
void ncurses_init();


/*************** handle_grid ***********************/
/** 
 * helper method responsible for handling grid/display
 * 
 * takes in:
 *      nRows,representing the number of rows in the display grid
 *      nColumns,representing the number of columns in the display
 * 
 * does:
 *      keeps looping until the user passes in valid screen dimensions
 *      
 * returns false 
 */
static bool handle_grid(char nRows, char nColumns);


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


/********************** local functions implementations *************************/

/********************** main *************************/

int main(const int argc, char *argv[])
{
    // Initialize logging file, log on stderr if error
    loggingFp = fopen(loggingFpName, "a");
    if (loggingFp == NULL)
    {
        fprintf(stderr, "Error opening logging file. Logging in stderr.\n");
        loggingFp = stderr;
    }

    char* program = argv[0];

    if(argc < 3 || argc > 4)
    {
        //print out an error to the user directly to stdout regarding invalid input numbers and correct usage
        fprintf(loggingFp, "Invalid number of inputs. \n");
        fprintf(stdout, "USAGE:  %s hostname port [playername] \n", program);
        exit(1);
    }

    const char* hostname = argv[1];
    const char* portNumber = argv[2];
    
    // Parse and validate the arguments
    parseArgs(hostname, portNumber);

    //initialize the client global struct:
    client = mem_malloc(sizeof(client_t));
    if (client == NULL)
    {
        fprintf(stdout, "Error initializing client global struct.\n");
        exit(5);
    }

    // initialize the communication between the client and the server,
    // logging into the logging file,
    // and record client port if valid:
    int port = message_init(loggingFp);
    if(port == 0) 
    { 
        fprintf(stdout, "Error: message_init returned zero.\n");
        exit(6); 
    }

    // Establishing address of the server
    addr_t server_addr; 
    if (message_setAddr(hostname, portNumber, &server_addr) == false)
    {
        fprintf(stdout, "Error: failed to initialize the message with the following hostname: %s \n", hostname);
        exit(7);
    }

    // in case the user passes in a third parameter initialize a player
    if (argc == 4)
    {
        // Allocate memory for player's name:
        client -> realName = mem_malloc_assert(strlen(argv[3])+1, "Player's name");
        strcpy(client->realName, argv[3]);
        send_player(client->realName, server_addr); 
    }
    else
    {
        //in the case that the third parameter was not passed in then initialize a spectator
        send_spectator(server_addr);
        client->client_letter = '\0'; // null character for spectator letter
        client->realName = NULL;     // null name for spectator name
    }

    //keep receiving messages until the game has been  quit
    bool game_exit = message_loop(&server_addr, 0, NULL, handle_keystroke, handle_receipt);

    //disconnect the connection between the client and the server
    message_done();

    // Cleaning up
    if (client->realName != NULL) 
    {
        mem_free(client->realName); 
    }
    mem_free(client);

    fclose(loggingFp);

    return game_exit ? 0 : 1;
}


void 
parseArgs(const char* hostname, const char *portNumber)
{
    // for hostname check that it not NULL
    if(hostname == NULL)
    {
        fprintf(stdout, "Error: hostname is (null). \n");
        exit(2);
    }

    // for portNumber check that it is not NULL
    if(portNumber == NULL)
    {
        fprintf(stdout, "Error: portNumber is (null). \n");
        exit(3);
    }

    // Ensure that portNumber is an integer in the allowed range
    int n = 0;
    str2int(portNumber, &n);
    if (n < MinPort || n > MaxPort)
    {
        fprintf(stdout, "Please enter a valid port number.\n");
        exit(4);
    }
}


static bool 
handle_receipt(void* arg, const addr_t server_address, const char* message)
{
    bool quit = false; // informs on whether the game is continuing or not

    // Accept communication only from server 
    addr_t* serverp = arg;
    if (!message_eqAddr(*serverp, server_address))
    {
        fprintf(loggingFp, "Error: Message from unknown sender.\n");
        return quit;
    }

    // if the first part is OK, intiialize the player's letterID
    if(strncmp("OK ", message, strlen("OK ")) == 0)
    {
        //update the player's client_letter with the given letter
        sscanf(message, "OK %c",&client->client_letter);
    }

    //If the first part is QUIT, print out game summary
    else if(strncmp("QUIT ",message, strlen("QUIT ")) == 0)
    {
       quit = handle_quit(message);
    }

    //if the first part is ERROR, store the current error and log it to users
    else if(strncmp("ERROR ",message, strlen("ERROR ")) == 0)
    {
        // store error message and pass that into handle_error 
        quit = handle_error(message);
    }

    //if the first part is GOLD, update the players' gold statuses
    else if(strncmp("GOLD ",message, strlen("GOLD ")) == 0)
    {
        int n, p, r; 
        sscanf(message, "GOLD %d %d %d", &n, &p, &r);
        if(client->client_letter != '\0') // If we are not dealing with spectator, refresh screen:
        {
            refresh();
        }
        quit = handle_gold(n, p, r);
    }

    //if the first part is DISPLAY, update players' field of view
    else if(strncmp("DISPLAY\n",message, strlen("DISPLAY"))== 0)
    {
        const char* display_text = message + strlen("DISPLAY");
        quit = handle_display(display_text);
    }

    //if the first part is GRID, ensure players' window is sufficiently large
    else if(strncmp("GRID ",message, strlen("GRID ")) == 0)
    {
        char nRows, nColumns;
        sscanf(message,"GRID %c %c",&nRows, &nColumns);
        quit = handle_grid(nRows, nColumns);
    }

    // Log malformed and misordered messages to the logging file:
    else 
    {
       fprintf(loggingFp, "Error: Malformed or misordered message.\n");
       quit = false; //ignore such messages, and keep looping
    }

    if(!quit)
    {
        refresh();  //update the display accordingly
    }

    return quit;
}


static bool 
handle_gold(int n, int p, int r) 
{ 
    //update gold status for client
    client->n = n;
    client->p = p;
    client->r = r;

    char letter = client->client_letter;
    if(letter == '\0') // handling the spectator case
    {
        mvprintw(1, 0, "\n");
        mvprintw(1, 0, "Unclaimed gold: %d", r);
    }
    else // handling player case
    {
        if(n != 0){
            mvprintw(0, 1, "\n");
            mvprintw(0, 1, "You have collected %d gold. \n", n);
        }
        mvprintw(1, 1, "\n");
        mvprintw(1, 1, "You currently have %d gold. \n", p);
        mvprintw(2, 1, "\n");
        mvprintw(2, 1, "Remaining gold in game is %d. \n", r);
    }
    refresh(); // refresh display of client
    return false; //this keeps the game going
}


static bool 
handle_quit(const char* quit_message)
{
    // closing the ncurses
    endwin();

    // if the game ends for all, client prints summary    
    if(strncmp("QUIT GAME OVER\n",quit_message, strlen("QUIT GAME OVER"))== 0)
    {
        const char* game_summary = quit_message + strlen("QUIT ");
        fprintf(stdout,"%s",game_summary);
    }

    // if client receives individual quit message, it prints it out
    else
    {
        const char* end_text = quit_message + strlen("QUIT ");
        fprintf(stdout,"%s", end_text);
    }
    fflush(stdout);
    
    // terminate message loop
    return true; 
}


static bool 
handle_display(const char* display_message)
{
   //drawing the display onto the client's screen   
   mvprintw(3,1,"%s",display_message);
   refresh();
   return false;
}   


static bool 
handle_error(const char* error_text)
{
    // print error in the output file
    fprintf(loggingFp, "%s", error_text);

    // return false, keeping message loop going:
    return false;
}


static bool 
handle_keystroke(void* arg)
{
    addr_t* server_Address = arg;

    //checking that the address is not NULL
    if(server_Address == NULL)
    {
        fprintf(loggingFp, "Error: the server address provided is (null). \n");
        return true; // exit message loop (unrecoverable error at this point)
    }

    // checking the validity of the address
    if(!message_isAddr(*server_Address))
    {
        fprintf(loggingFp,"The server address provided is not valid. \n");
        return false; // keep looping
    }
   
    //creating an array to store the KEY message (6 characters including null character at the end):
    char key_message[6];
    
    //reading and storing the key passed in by the user 
    char c = getch();

    // If the used inputs ^D (EOT character, with ASCII 4), send quit message:
    if (c == 4)
    {
        message_send(*server_Address, "KEY Q");
        return false;
    }   

    //constructing and sending the KEY message
    sprintf(key_message, "KEY %c", c); 

    message_send(*server_Address, key_message);

    refresh();
    
    return false;   
}


void 
send_player(char* real_name, const addr_t serverAddress)
{
    //constructing and sending the PLAY message
    char play_message[message_MaxBytes];
    sprintf(play_message, "PLAY %s", real_name);
    message_send(serverAddress, play_message);
}


void send_spectator(const addr_t serverAddress)
{
    message_send(serverAddress, "SPECTATE");
}


void ncurses_init()
{
    //initializing the display screen
    WINDOW *screen = initscr();
    if(screen == NULL)
    {
        fprintf(loggingFp,"Error: failure to initialize the screen. \n");
    }
  
    //begin accepting the keystrokes
    cbreak();  

    //making sure that the characters are not echoed onto the screen
    noecho();           

    //handling the visual components of the display
    start_color();                       //turning on the color component of the game
    init_pair(1, COLOR_WHITE, COLOR_BLACK); //definition of color 1
    attron(COLOR_PAIR(1));               // turning on color 1
}

 
static bool 
handle_grid(char nRows, char nColumns)
{
    //initializing the display and its components
    ncurses_init(); 

    int grid_width;    //proposed width of the client's screen
    int grid_length;   //proposed length of the client's screen

    int user_columns = (int)(nColumns)+1;
    int user_rows = (int)(nRows)+1;
    //checking that the current display meets the requirement specifications
    while(grid_width < (user_columns +1) || grid_length <(user_rows +1))
    {
        getmaxyx(stdscr, grid_length, grid_width);
        mvprintw(0,0,"Please enlarge your screen. \n");
        sleep(1); //allowing the player sometime to adjust their display
        refresh();
    } 
    clear(); 
    return false;
}


static bool 
str2int(const char string[], int *number) 
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
