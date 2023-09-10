#!/bin/bash

# testing.sh
#
# Tests the client (and the server indirectly) by running many of them at a time
# Usage: ./testing.sh <hostname> <port> <playerNum> <speed>
#   hostname - hostname where the server is running
#   port - port where the server is running
#   playerNum - number of clients to spawn
#   speed - amount delay in between movements, in seconds
#
# To use this, run a server, put the server's info as arguments for this script,
#   then run a spectator on the same server to view the players' behavior.
#
# Run the `capture-pane` command printed by this script to view the terminal of any particular client
#
# CS50 Group 33, 23W

set -e

keystrokes=("l" "h" "k" "j" "y" "u" "b" "n" "L" "H" "K" "J" "Y" "U" "B" "N")
num_keystrokes=${#keystrokes[@]}

client_ids=()

runclient(){
    clientId=$4
    tmux new-session -d  -x150 -y150 -s $clientId: ./client $1 $2 $clientId
    echo "Added client_id $clientId. To view output: tmux capture-pane -t $clientId: -S - -E - -p | cat -n"
    while [ true ]
    do
        sleep $3
        curr_keystroke=${keystrokes[$(($RANDOM % $num_keystrokes))]}
        tmux send-keys -t $clientId: $curr_keystroke
    done
}

cleanup(){
    echo ""
    echo "Cleaning up..."
    # Kills every tmux session at the end
    for client_id in ${client_ids[@]}; do
        tmux kill-session -t $client_id
    done
    echo "Done!"
}

# Run cleanup upon the script exiting
trap cleanup EXIT

# First, create the array of clientIds so that they are shared between concurrent processes
for i in $(seq "$3"); do
    clientId=`echo $RANDOM | md5sum | head -c 12; echo;`
    client_ids+=("$clientId")
done

# Then, for each clientId, make a new tmux session and run a client within it
for client_id in ${client_ids[@]}; do
    runclient $1 $2 $4 $client_id &
done

# This loop ensures that the script doesn't exit (and cleanup) until the user does so manually
while [ true ]
do
    sleep 5
done