#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_STATES 100
#define MAX_ALPHABET 26

typedef struct {
    char state[10];
    char symbol;
    char nextState[10];
} Transition;

typedef struct {
    char states[MAX_STATES][10];
    char alphabet[MAX_ALPHABET];
    Transition transitions[MAX_STATES * MAX_ALPHABET];
    int numStates;
    int numAlphabet;
    int numTransitions;
    char startState[10];
    char finalStates[MAX_STATES][10];
    int numFinalStates;
} FiniteAutomaton;
void loadFAFromFile(FiniteAutomaton *fa, const char *filePath) {
    FILE *file = fopen(filePath, "r");
    if (file == NULL) {
        perror("Error opening file");
        exit(1);
    }

    // Initialize counters
    fa->numStates = 0;
    fa->numAlphabet = 0;
    fa->numTransitions = 0;
    fa->numFinalStates = 0;

    char line[256];
    
    // Read states
    if (fgets(line, sizeof(line), file) != NULL) {
        char *token = strtok(line, ",\n");
        while (token != NULL) {
            strcpy(fa->states[fa->numStates++], token);
            token = strtok(NULL, ",\n");
        }
    }

    // Read alphabet
    if (fgets(line, sizeof(line), file) != NULL) {
        char *token = strtok(line, ",\n");
        while (token != NULL) {
            fa->alphabet[fa->numAlphabet++] = token[0];
            token = strtok(NULL, ",\n");
        }
    }

    // Read transitions
    while (fgets(line, sizeof(line), file) != NULL) {
        if (line[0] == 'q' || line[0] == '\n') break;  // End of transitions section
        Transition *t = &fa->transitions[fa->numTransitions++];
        sscanf(line, "%s %c %s", t->state, &t->symbol, t->nextState);
    }

    // Read start state (this should be on the next line after transitions)
    if (strlen(line) > 1) {  // This checks if a valid start state line was read
        sscanf(line, "%s", fa->startState);
    } else if (fgets(line, sizeof(line), file) != NULL) {
        sscanf(line, "%s", fa->startState);
    }

    // Read final states
    if (fgets(line, sizeof(line), file) != NULL) {
        char *token = strtok(line, ",\n");
        while (token != NULL) {
            strcpy(fa->finalStates[fa->numFinalStates++], token);
            token = strtok(NULL, ",\n");
        }
    }

    fclose(file);
}



void displayFA(const FiniteAutomaton *fa) {
    printf("States: ");
    for (int i = 0; i < fa->numStates; i++) {
        printf("%s ", fa->states[i]);
    }
    printf("\nAlphabet: ");
    for (int i = 0; i < fa->numAlphabet; i++) {
        printf("%c ", fa->alphabet[i]);
    }
    printf("\nTransitions:\n");
    for (int i = 0; i < fa->numTransitions; i++) {
        printf("%s --%c--> %s\n", fa->transitions[i].state, fa->transitions[i].symbol, fa->transitions[i].nextState);
    }
    printf("Start State: %s\n", fa->startState);
    printf("Final States: ");
    for (int i = 0; i < fa->numFinalStates; i++) {
        printf("%s ", fa->finalStates[i]);
    }
    printf("\n");
}

int isFinalState(const FiniteAutomaton *fa, const char *state) {
    for (int i = 0; i < fa->numFinalStates; i++) {
        if (strcmp(fa->finalStates[i], state) == 0) {
            return 1;
        }
    }
    return 0;
}

int isValidToken(const FiniteAutomaton *fa, const char *token) {
    char currentState[10];
    strcpy(currentState, fa->startState);

    for (int i = 0; token[i] != '\0'; i++) {
        char symbol = token[i];
        int transitionFound = 0;
        
        for (int j = 0; j < fa->numTransitions; j++) {
            if (strcmp(fa->transitions[j].state, currentState) == 0 && fa->transitions[j].symbol == symbol) {
                strcpy(currentState, fa->transitions[j].nextState);
                transitionFound = 1;
                break;
            }
        }
        
        if (!transitionFound) return 0;
    }
    
    return isFinalState(fa, currentState);
}

int main() {
    FiniteAutomaton fa;
    loadFAFromFile(&fa, "FA.in");
    
    displayFA(&fa);

    char input[100];
    printf("Enter a string to validate: ");
    scanf("%s", input);

    if (isValidToken(&fa, input)) {
        printf("The string is a valid lexical token.\n");
    } else {
        printf("The string is not a valid lexical token.\n");
    }

    return 0;
}
