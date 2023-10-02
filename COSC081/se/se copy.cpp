
#include <stdio.h>
#include <math.h>

const int cells     = 10;
const int uSeq[]    = {1, 1, 1, -1, -1};
double curr_probs[] = {0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1};
const int commands  = 5;

double transition_prob(int x1, int x0, int u) {
    // Edge cases
    if ((x0 == 0 && u == -1 && x1 == 0) || 
        (x0 == cells - 1 && u == 1 && x1 == cells - 1))
        return 1;
    if ((x0 == 1 && u == -1 && x1 == 0) || 
        (x0 == cells - 2 && u == 1 && x1 == cells - 1))
        return 0.75;
    if ((x0 == 1 && u == -1 && x1 == 1) || 
        (x0 == cells - 2 && u == 1 && x1 == cells - 2))
        return 0.25;
    // General cases
    if ((u == 1 && x0 < cells - 2) || 
        (u == -1 && x0 > 1))
        if ((u == 1 || u == -1) && x0 == x1 || (u == 1 && x1 == x0 + 2) || (u == -1 && x1 == x0 - 2))
            return 0.25;
        if ((u == 1 && x1 == x0 + 1) || (u == -1 && x1 == x0 - 1))
            return 0.5;
    return 0;
}

void print_transition_prob(int u) {
    for (int x1 = 0; x1 < cells; x1++) {
        for (int x0 = 0; x0 < cells; x0++) {
            printf("\t%f", transition_prob(x1, x0, u));
        }
        printf("\n");
    }
    printf("\n");
}

void update_probs( double (&curr_probs)[cells], int u) {
    double updated_probs[cells];
    // Iterate through each new state
    double sum = 0.0;
    for (int x1 = 0; x1 < cells; x1++) {
        // For each new state, update probability applying transition 
        // on sum of all previous states
        double new_prob = 0.0;
        for (int x0 = 0; x0 < cells; x0++) {
            new_prob += transition_prob(x1, x0, u)*curr_probs[x0];
        }
        updated_probs[x1] = new_prob;
        sum += new_prob;
    }
    // Overwrite old probabilities with normalized updated ones:
    for (int i = 0; i < cells; i++) {
        curr_probs[i] = updated_probs[i] / sum;
    }
}

void execute_commands() {
    int round = 0;
    for (;;) {
        // First print current state estimations
        printf("State estimations for round %d: ", round);
        for (int i = 0; i < cells; i++) {
            printf("  %f", curr_probs[i]);
        }
        printf("\n");
        if (round == commands) // break loop just in time
            break;
        // Then update state estimations
        update_probs(curr_probs, uSeq[round++]);
    }
}

int main() {
    execute_commands();
}
