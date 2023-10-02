
#include <stdio.h>
#include <math.h>

/* Keep number of cells low for simplicity:
 * Prevents statically allocated transition matrix from becoming too large 
*/
#define CELLS 4 
#define COMMANDS 5

#define ZP 0.0      /* zero probability                          */
#define P0 0.25     /* probability of remaining in same position */
#define P1 0.5      /* probability of moving by one position     */
#define P2 0.25     /* probability of moving by two positions    */
#define PS 0.1      /* starting probability for each cell        */

#define UIND(x, u)  ((u)*(x) + ((1 - (u))/2) * (CELLS - 1))

/* Testing function prototypes */
extern int uIND(int x, int u);
extern void update_probs(double * curr_probs, int u);

/* Statically allocated arrays */
static const int uSeq[COMMANDS] = {1, 1, 1, -1, -1};
static double curr_probs[CELLS] = {PS, PS, PS, PS};
static const double transition_probs_mat[CELLS][CELLS]
    = {{P0, P1, P2, ZP},
       {ZP, P0, P1, P2},
       {ZP, ZP, P0, (P1 + P2)},
       {ZP, ZP, ZP, (P0 + P1 + P2)}};

void update_probs(double * curr_probs, int u) {
    double updated_probs[CELLS];
    // Iterate through each new state
    double sum = 0.0;
    for (int x1 = 0; x1 < CELLS; x1++) {
        // For each new state, update probability applying transition 
        // on sum of all previous states
        double new_prob = 0.0;
        for (int x0 = 0; x0 < CELLS; x0++) {
            new_prob += curr_probs[x0] * transition_probs_mat[uIND(x0, u)][uIND(x1, u)];
        }
        updated_probs[x1] = new_prob;
        sum += new_prob;
    }
    // Overwrite old probabilities with normalized updated ones:
    for (int i = 0; i < CELLS; i++) {
        curr_probs[i] = updated_probs[i] / sum;
    }
}

void execute_commands() {
    int round = 0;
    for (;;) {
        // First print current state estimations
        printf("State estimations for round %d: ", round);
        for (int i = 0; i < CELLS; i++) {
            printf("  %f", curr_probs[i]);
        }
        printf("\n");
        if (round == COMMANDS) // break loop just in time
            break;
        // Then update state estimations
        update_probs(curr_probs, uSeq[round++]);
    }
}

int main() {
    execute_commands();
    return 0;
}
