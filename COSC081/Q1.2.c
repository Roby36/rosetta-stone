
#include <stdlib.h>
#include <float.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>

// Hard-coded constants
static const int numColumns  = 3;
static const int numRows     = 2;
static const double discount = 0.9;
static const int tot_rounds  = 10;

// Value matrix
static double ivalues[numRows][numColumns] = {{0.0, 0.0, 0.0},
                                              {0.0, 0.0, 0.0}};

// namespace Transitions 
static const double desired = 0.9;
static const double left    = 0.05;
static const double right   = 0.05;

// enum Action
static const int NORTH      = 0;
static const int EAST       = 1;
static const int SOUTH      = 2;
static const int WEST       = 3;
static const int STILL      = 4;
static const int NUMACTIONS = 5;

// Hard-coding terminal state
static const int termState_x = numColumns - 1; 
static const int termState_y = numRows    - 1;

// Convert from matrix format to double pointer 
double ** allocate_matrix(double m[numRows][numColumns]) {
    // Allocate array of numRows pointers to doubles
    double ** res = (double **) malloc (sizeof(double *) * sizeof(numRows));
    for (int row = 0; row < numRows; row++) {
        // For each array element, allocate array of numColumns doubles 
        res[row] = (double *) malloc (sizeof(double) * sizeof(numColumns));
        // Fill up the array of doubles 
        for (int col = 0; col < numColumns; col++) {
            res[row][col] = m[row][col];
        }
    }
    // Return pointer to array of double pointers 
    return res;
}

void free_matrix(double ** res) {
    for (int row = 0; row < numRows; row++) {
        // Free the array pointer
        free(res[row]);
    }
    // Finally free the main pointer 
    free(res);
}

typedef struct State {
    int x;
    int y;
} State_t;

State_t * State_new(int x, int y) {
    State_t * state = (State_t *) malloc (sizeof(State_t));
    if (state == NULL)
        return NULL;
    state->x = x;
    state->y = y;
    return state;
}

void State_delete(State_t * state) {
    if (state != NULL)
        free(state);
}

bool State_equal(const State_t * s1, const State_t * s2) {
    if (s1 == NULL || s2 == NULL)
        return false;
    return ((s1->x == s2->x) && (s1->y == s2->y));
}

bool State_is_inside(const State_t * s) {
    if (s == NULL)
        return false;
    return ((s->x >= 0) && (s->x < numColumns) &&
            (s->y >= 0) && (s->y < numRows));
}

// Function to print array to stdout in matrix format
void printArray(double ** values) {
    for (int y = 0; y < numRows; y++) {
        for (int x = 0; x < numColumns; x++) {
            printf("\t%f", values[y][x]);
        }
        printf("\n\n");
    }
}

// Hard-coding reward function
double R(const State_t * sf)
{
    // Reward determined only by final state reached  
    // Illegal states zeroed out by T already
    switch (sf->x) {
        case 0:
        case 1:
            return -0.1;
        case 2:
            if (sf->y == 0)
                return -0.05;
            else if (sf->y == 1)
                return 1.0;
            else
                break;
        default:
            break;
    }
    return 0.0;
}

// Transition probabilities
double T( State_t * si, const int a, State_t * sf)
{
    // Check if initial state is within grid or if terminal state reached
    if (!State_is_inside(si) || (si->x == termState_x && si->y == termState_y))
        return 0.0;
    // Determine possible final states given initial state and action
    bool N = (a == NORTH);
    bool S = (a == SOUTH);
    bool E = (a == EAST);
    bool W = (a == WEST);
    State_t * s_desired = State_new(si->x + E - W, si->y + N - S);
    State_t * s_right   = State_new(si->x + N - S, si->y + W - E);
    State_t * s_left    = State_new(si->x + S - N, si->y + E - W);
    // If any final state fails to be inside, record missed probability
    double sup_desired = desired * (double) !State_is_inside(s_desired);
    double sup_right   = right   * (double) !State_is_inside(s_right);
    double sup_left    = left    * (double) !State_is_inside(s_left);
    // Check each possible final state
    double ret_val;
    if (State_equal(sf, si)) {
        // Consider the case where the robot does not move
        if (a == STILL)
            ret_val = 1.0;
        // Otherwise the only possible way to remains still is to hit some wall
        else
            ret_val = sup_desired + sup_left + sup_right;
      // Now consider the possibility of moving in each state
    } else if (State_equal(sf, s_desired)) {
        ret_val = desired * (double) (sup_desired == 0.0);
    } else if (State_equal(sf, s_right)) {
        ret_val = right * (double) (sup_right == 0.0);
    } else if (State_equal(sf, s_left)) {
        ret_val = left * (double) (sup_left == 0.0);
    } else {
        ret_val = 0.0; // return 0 whenever final state invalid
    }
    State_delete(s_desired);
    State_delete(s_right);
    State_delete(s_left);

    return ret_val;
}

void update_values(double *** values)
{
    // Copy array
    double next_values [numRows][numColumns];
    // Iterate through each initial state
    for (int xi = 0; xi < numColumns; xi++) {
    for (int yi = 0; yi < numRows; yi++) {
        State_t * si = State_new(xi,yi);
        double maximum = -DBL_MAX;
        // Iterate through each possible action
        for (int a = 0; a < NUMACTIONS; a++) {
            double sum = 0;
            // Iterate through each final state
            for (int xt = 0; xt < numColumns; xt++) {
            for (int yt = 0; yt < numRows; yt++) {
                // Apply transition formula
                State_t * st = State_new(xt, yt);
                sum += T(si, a, st) * (R(st) + discount * ((*values)[yt][xt]));
                State_delete(st);
            }
            }
            // Update maximum
            maximum = (sum > maximum) ? sum : maximum;
        }
        // Update value in copy array
        next_values[yi][xi] = maximum;
        State_delete(si);
    }
    }
    // Update array
    free_matrix(*values);
    *values = allocate_matrix(next_values);
}

// Iteration function
void value_iteration(double *** values, int totRounds, int round) {
    // Base-case
    if (round == totRounds) {
        printf("Iteration terminated\n");
        return;
    }
    // Print current result
    printf("Round %d:\n", round);
    printArray(*values);
    // Update array
    update_values(values);
    // Recurse
    value_iteration(values, totRounds, round + 1);
}

// Testing
int main() {
    double ** values = allocate_matrix(ivalues);
    double *** values_ptr = &values;
    value_iteration(values_ptr, tot_rounds, 0);
    free_matrix(*values_ptr);
    return 0;
}
