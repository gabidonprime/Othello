/**
 * othello.c
 *
 * Do NOT translate this file. You are required to translate `othello.c`.
 * This file has been provided to make exploring the reference implementation
 * easier.
 */

#include <stdio.h>
#include <stdlib.h>


///// Constants /////

// Bools
#define TRUE  1
#define FALSE 0

// Players
#define PLAYER_EMPTY 0
#define PLAYER_BLACK 1
#define PLAYER_WHITE 2

// Characters shown when rendering board
#define WHITE_CHAR         'W'
#define BLACK_CHAR         'B'
#define POSSIBLE_MOVE_CHAR 'x'
#define EMPTY_CELL_CHAR    '.'

// Smallest and largest possible board sizes
#define MIN_BOARD_SIZE 4
// Standard Othello board size is 8
#define MAX_BOARD_SIZE 12

// There are 8 directions a capture line can have (2 vertical, 2 horizontal and 4 diagonal).
#define NUM_DIRECTIONS 8


///// Structs /////

// A 2D point, which contains the vertical component (row) and the horizontal component (col).
typedef struct vector {
    int row;
    int col;
} vector;


///// Global variables /////

// The actual board size, selected by the player
int board_size;

// Who's turn it is - either PLAYER_BLACK or PLAYER_WHITE
int current_player = PLAYER_BLACK;

// The contents of the board
char board[MAX_BOARD_SIZE][MAX_BOARD_SIZE];

// The 8 directions which a line can have when capturing
const vector directions[] = {
    { -1, -1 }, // Up left
    { -1,  0 }, // Up
    { -1,  1 }, // Up right
    {  0, -1 }, // Left
    {  0,  1 }, // Right
    {  1, -1 }, // Down left
    {  1,  0 }, // Down
    {  1,  1 }, // Down right
};


///// Function prototypes /////

int main(void);

void read_board_size(void);
void initialise_board(void);
void place_initial_pieces(void);

void play_game(void);
void announce_winner(void);
unsigned int count_discs(int player);
int  play_turn(void);
void place_move(int row, int col);
int  player_has_a_valid_move(void);

int is_valid_move(int row, int col);
unsigned int capture_amount_from_direction(int row, int col, const vector *delta);
int other_player(void);
const char *current_player_str(void);

void print_board(void);


///// Function implementations /////

int main(void) {
    printf("Welcome to Reversi!\n");

    read_board_size();
    initialise_board();
    place_initial_pieces();
    play_game();
}

// Read in the board size, and check that it's not too big, not too small, and even.
// If it isn't, ask agin.
void read_board_size(void) {
    while (TRUE) {
        printf("How big do you want the board to be? ");

        if (scanf("%d", &board_size) != 1) {
            exit(1);
        }

        if (board_size < MIN_BOARD_SIZE || board_size > MAX_BOARD_SIZE) {
            printf("Board size must be between %d and %d\n", MIN_BOARD_SIZE, MAX_BOARD_SIZE);
            continue;
        }

        if (board_size % 2 != 0) {
            printf("Board size must be even!\n");
            continue;
        }

        printf("OK, the board size is %d\n", board_size);
        break;
    }
}

// Fill the board with all EMPTY
void initialise_board(void) {
    for (int row = 0; row < board_size; ++row) {
        for (int col = 0; col < board_size; ++col) {
            board[row][col] = PLAYER_EMPTY;
        }
    }
}

// Place the centre four pieces:
//    W B
//    B W
void place_initial_pieces(void) {
    board[board_size / 2 - 1][board_size / 2 - 1] = PLAYER_WHITE;
    board[board_size / 2][board_size / 2]         = PLAYER_WHITE;
    board[board_size / 2 - 1][board_size / 2]     = PLAYER_BLACK;
    board[board_size / 2][board_size / 2 - 1]     = PLAYER_BLACK;
}

// Repeatedly call play_turn until the game is over, then call announce_winner
void play_game(void) {
    while (play_turn());

    announce_winner();
}

// Count up how many pieces and black and how many are white, and then
// accordingly display the outcome of the game
void announce_winner(void) {
    int black_count = count_discs(PLAYER_BLACK);
    int white_count = count_discs(PLAYER_WHITE);

    if (white_count > black_count) {
        printf("The game is a win for WHITE!\n");
        white_count += count_discs(PLAYER_EMPTY);
    } else if (black_count > white_count) {
        printf("The game is a win for BLACK!\n");
        black_count += count_discs(PLAYER_EMPTY);
    } else {
        printf("The game is a tie! Wow!\n");
    }

    printf("Score for black: %d, for white: %d.\n", black_count, white_count);
}

// Count the number of pieces on the board belonging to a specific player
unsigned int count_discs(int player) {
    int count = 0;
    for (int row = 0; row < board_size; ++row) {
        for (int col = 0; col < board_size; ++col) {
            if (board[row][col] == player) {
                count++;
            }
        }
    }
    return count;
}

// Attempt to play a single turn.
// Returns TRUE if the game is continuing.
// Otherwise returns FALSE if the game is over
int play_turn(void) {
    printf("\nIt is %s's turn.\n", current_player_str());
    print_board();

    if (!player_has_a_valid_move()) {
        // If there are no valid moves for the current player,
        // play just switches over to the other player - unless
        // they also have no moves, in which case the game ends
        printf("There are no valid moves for %s!\n", current_player_str());

        current_player = other_player();

        if (player_has_a_valid_move()) {
            return TRUE;
        } else {
            printf("There are also no valid moves for %s...\n", current_player_str());
            printf("Game over!\n");
            return FALSE;
        }
    }

    printf("Enter move (e.g. A 1): ");
    int move_row;
    char move_col_letter;
    // Entering something invalid here (like 1A) will case an infinite loop
    // But there is no way to detect this error in MIPSY
    if (scanf(" %c%d", &move_col_letter, &move_row) != 2) {
        // Note that the leading space in the format string is required for scanf
        // It doesn't need to be translated to MIPS, only the "%c%d"
        exit(1);
    }

    // Subtract 1 from move_row since the user input is
    // 1-indexed, but we want a row which is 0-indexed
    move_row -= 1;

    int move_col = move_col_letter - 'A';

    if (move_row < 0 || move_row >= board_size) {
        printf("Invalid row!\n");
        return TRUE;
    }

    if (move_col < 0 || move_col >= board_size) {
        printf("Invalid column!\n");
        return TRUE;
    }

    if (!is_valid_move(move_row, move_col)) {
        printf("Invalid move!\n");
        return TRUE;
    }

    place_move(move_row, move_col);
    current_player = other_player();

    return TRUE;
}

// Execute a move by the current player and (move_row, move_col)
void place_move(int move_row, int move_col) {
    for (int direction = 0; direction < NUM_DIRECTIONS; ++direction) {
        // For each of the 8 directions, check to see if there are any
        // captures, and if so set the whole capture line to the current
        // player's colour

        const vector *delta = &directions[direction];

        int capture_amt = capture_amount_from_direction(move_row, move_col, delta);

        // capture_amt might be 0, to indicate an invalid direction,
        // but that's fine since we want to set the piece
        // at (move_row, move_col) anyway

        for (int i = 0; i <= capture_amt; ++i) {
            int row = move_row + i * delta->row;
            int col = move_col + i * delta->col;
            board[row][col] = current_player;
        }
    }
}

// Return TRUE if the player has ANY possible move, other return FALSE
int player_has_a_valid_move(void) {
    for (int row = 0; row < board_size; ++row) {
        for (int col = 0; col < board_size; ++col) {
            if (is_valid_move(row, col)) {
                return TRUE;
            }
        }
    }

    // If we've gotten here it must be because is_valid_move returned
    // FALSE for every valid row and col, meaning that the player must
    // not have any valid moves
    return FALSE;
}

// Check if a move at (row, col) is valid, meaning that it's on
// an empty square, and that it captures at least one piece from
// the other player
int is_valid_move(int row, int col) {
    if (board[row][col] != PLAYER_EMPTY) {
        return FALSE;
    }

    for (int direction = 0; direction < NUM_DIRECTIONS; ++direction) {
        if (capture_amount_from_direction(row, col, &directions[direction])) {
            return TRUE;
        }
    }

    return FALSE;
}

// Returns the number length of the capture line at (row, col) for the
// current player, in the direction of the delta vector. Returns 0 to
// indicate that that there is no captures because the line is invalid
unsigned int capture_amount_from_direction(int row, int col, const vector *delta) {
    int opposite = other_player();

    // This loop will travel along the line until it hits a square
    // which isn't occupied by the opposites player piece
    int line_length = 0;
    while (TRUE) {
        row += delta->row;
        col += delta->col;

        if (row < 0 || row >= board_size || col < 0 || col >= board_size) {
            // The capture line goes out of bounds before hitting a
            // piece from the current player, so is invalid
            return 0;
        }

        if (board[row][col] != opposite) {
            break;
        }

        line_length++;
    }

    if (board[row][col] != current_player) {
        // If the loop stopped at an empty square then
        // this isn't a valid capture line, so we return 0
        return 0;
    }

    // Otherwise this was a valid capture line
    return line_length;
}

// Returns the player which isn't the current player
int other_player(void) {
    if (current_player == PLAYER_WHITE) {
        return PLAYER_BLACK;
    } else {
        return PLAYER_WHITE;
    }
}

// Returns a string representation of the current player
const char *current_player_str(void) {
    if (current_player == PLAYER_WHITE) {
        return "white";
    } else {
        return "black";
    }
}

// Print out a display of the current board
//        THIS FUNCTION IS PROVIDED
void print_board(void) {
    printf("Board:\n   ");

    for (int col = 0; col < board_size; ++col) {
        printf("%c ", 'A' + col);
    }
    printf("\n");

    for (int row = 0; row < board_size; ++row) {
        // printf("%2d ", row + 1);
        if (row + 1 < 10) {
            putchar(' ');
        }
        printf("%d ", row + 1);


        for (int col = 0; col < board_size; ++col) {
            char cell = board[row][col];

            if (cell == PLAYER_WHITE) {
                printf("%c ", WHITE_CHAR);
            } else if (cell == PLAYER_BLACK) {
                printf("%c ", BLACK_CHAR);
            } else if (is_valid_move(row, col)) {
                printf("%c ", POSSIBLE_MOVE_CHAR);
            } else {
                printf("%c ", EMPTY_CELL_CHAR);
            }
        }

        printf("\n");
    }
}
