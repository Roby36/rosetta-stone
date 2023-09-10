# Client
# WhaleWatchers, Winter 2023

## Server

This directory contains the `server` module. The `server` module is composed of the `server.c` script along with the following submodules:
- `game`
- `grid`
- `player`

Within the nuggets game, the server, once run, listens for messages from `client`s. Upon a received message, the server validates it, edits the stored game state accordingly, and sends the appropriate message back to the client.

To run the server, execute `server <mapPath> [seed]`, where the `mapPath` is a path to a text file containing a game map in the correct format, and `seed` is an optional param that defines the positions of pseudo-randomly placed goldpiles.

For more information, see the submodules' header files and `server.c`'s header comments.

## Compilation
Run `make` within this directory (assuming you've compiled the dependent libraries `support` and `libcs50`) to compile `server` and its submodules.