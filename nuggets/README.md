# Nuggets
## Group 3: Whalewatchers (Zachary Badda, Roberto Brera, Julian George, Ivy Mayende)
## March 2023

This repository contains the "nuggets" game. In this game, players explore a 2D map and pick up gold nuggets until there are none left.

## Directories
Within this module, the two main modules are `client` and `server`. Modules within the libraries `libcs50` and `support` are also utilized. The `client` module is used for players who seek to participate in the game, along with spectators. The `server` module handles the state of the game, sending and receiving messages from all the clients. It loads games on maps from the `maps` directory. Within `maps`, the new map that we added is named `blobby.txt`. See each module's individual `README.md` for more.

## Compilation
To compile the scripts within this repo's modules, run `make` in this directory.
