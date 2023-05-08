########################################################################
# COMP1521 23T1 -- Assignment 1 -- Othello!
#
#
# !!! IMPORTANT !!!
# Before starting work on the assignment, make sure you set your tab-width to 8!
# It is also suggested to indent with tabs only.
# Instructions to configure your text editor can be found here:
#   https://cgi.cse.unsw.edu.au/~cs1521/22T1/resources/mips-editors.html
# !!! IMPORTANT !!!
#
#
# This program was written by Gabriel Esquivel (z5358503)
# on (27/3/23)
#
# Description: This program is a MIPS implementation of the popular board game Othello.
#   		Completed for 23T1 COMP1521 assignment 1.
#
# Version 1.0 (06-03-2023): Team COMP1521 <cs1521@cse.unsw.edu.au>
#
########################################################################

#![tabsize(8)]

# Constant definitions.
# !!! DO NOT ADD, REMOVE, OR MODIFY ANY OF THESE DEFINITIONS !!!

# Bools
TRUE  = 1
FALSE = 0

# Players
PLAYER_EMPTY = 0
PLAYER_BLACK = 1
PLAYER_WHITE = 2

# Character shown when rendering board
WHITE_CHAR         = 'W'
BLACK_CHAR         = 'B'
POSSIBLE_MOVE_CHAR = 'x'
EMPTY_CELL_CHAR    = '.'

# Smallest and largest possible board sizes (standard Othello board size is 8)
MIN_BOARD_SIZE = 4
MAX_BOARD_SIZE = 12

# There are 8 directions a capture line can have (2 vertical, 2 horizontal and 4 diagonal).
NUM_DIRECTIONS = 8

# Some constants for accessing vectors
VECTOR_ROW_OFFSET = 0
VECTOR_COL_OFFSET = 4
SIZEOF_VECTOR     = 8


########################################################################
# DATA SEGMENT
# !!! DO NOT ADD, REMOVE, MODIFY OR REORDER ANY OF THESE DEFINITIONS !!!
	.data
	.align 2

# The actual board size, selected by the player
board_size:		.space 4

# Who's turn it is - either PLAYER_BLACK or PLAYER_WHITE
current_player:		.word PLAYER_BLACK

# The contents of the board
board:			.space MAX_BOARD_SIZE * MAX_BOARD_SIZE

# The 8 directions which a line can have when capturing
directions:
	.word	-1, -1  # Up left
	.word	-1,  0  # Up
	.word	-1,  1  # Up right
	.word	 0, -1  # Left
	.word	 0,  1  # Right
	.word	 1, -1  # Down left
	.word	 1,  0  # Down
	.word	 1,  1  # Down right

welcome_to_reversi_str:		.asciiz "Welcome to Reversi!\n"
board_size_prompt_str:		.asciiz "How big do you want the board to be? "
wrong_board_size_str_1:		.asciiz "Board size must be between "
wrong_board_size_str_2:		.asciiz " and "
wrong_board_size_str_3:		.asciiz "\n"
board_size_must_be_even_str:	.asciiz "Board size must be even!\n"
board_size_ok_str:		.asciiz "OK, the board size is "
white_won_str:			.asciiz "The game is a win for WHITE!\n"
black_won_str:			.asciiz "The game is a win for BLACK!\n"
tie_str:			.asciiz "The game is a tie! Wow!\n"
final_score_str_1:		.asciiz	"Score for black: "
final_score_str_2:		.asciiz ", for white: "
final_score_str_3:		.asciiz ".\n"
whos_turn_str_1:		.asciiz "\nIt is "
whos_turn_str_2:		.asciiz "'s turn.\n"
no_valid_move_str_1:		.asciiz "There are no valid moves for "
no_valid_move_str_2:		.asciiz "!\n"
game_over_str_1:		.asciiz "There are also no valid moves for "
game_over_str_2:		.asciiz "...\nGame over!\n"
enter_move_str:			.asciiz "Enter move (e.g. A 1): "
invalid_row_str:		.asciiz "Invalid row!\n"
invalid_column_str:		.asciiz "Invalid column!\n"
invalid_move_str:		.asciiz "Invalid move!\n"
white_str:			.asciiz "white"
black_str:			.asciiz "black"
board_str:			.asciiz "Board:\n   "

############################################################
####                                                    ####
####   Your journey begins here, intrepid adventurer!   ####
####                                                    ####
############################################################

################################################################################
#
# Implement the following functions,
# and check these boxes as you finish implementing each function.

#  - [1] main				
#  - [1] read_board_size		
#  - [1] initialise_board		
#  - [1] place_initial_pieces		
#  - [] play_game			
#  - [1] announce_winner		
#  - [1] count_discs		
#  - [1] play_turn			
#  - [1] place_move
#  - [1] player_has_a_valid_move
#  - [1] is_valid_move
#  - [] capture_amount_from_direction
#  - [1] other_player
#  - [1] current_player_str
#  - [X] print_board			(provided for you)
################################################################################



################################################################################
# .TEXT <main>
	.text
main:
	# Args:     void
	#
	# Returns:
	#    - $v0: int
	#
	# Frame:    [$ra]
	# Uses:     [$a0, $v0]
	# Clobbers: [...]
	#
	# Locals:
	# 
	# Structure:
	#   main
	#   -> [prologue]
	#       -> body
	#   -> [epilogue]

main__prologue:
	begin
	push	$ra

main__body:

	li 	$v0, 4
	la 	$a0, welcome_to_reversi_str
	syscall

	jal	read_board_size
	jal	initialise_board
	jal	place_initial_pieces
	jal 	play_game

main__epilogue:
	pop	$ra
	end
	jr	$ra
	li	$v0, 10
	syscall

################################################################################
# .TEXT <read_board_size>
	.text

# Read in the board size, and check that it's not too big, not too small, and even.
# If it isn't, ask agin.

read_board_size:
	# Args:     void
	#
	# Returns:  void
	#
	# Frame:    [$ra, $s0]
	# Uses:     [$a0, $v0, $t0, $t1, $s0]
	# Clobbers: [$a0, $v0, $t0, $t1]
	#
	# Locals:
	#   - $t0: board_size
	#
	# Structure:
	#   read_board_size
	#   -> [prologue]
	#       -> body
	#	   -> check_range
	#	   -> range_wrong
	# 	   -> check_even
	#  	   -> not_even
	#   -> [epilogue]

read_board_size__prologue:
	begin
	push 	$ra
	push	$s0

read_board_size__body:
	li	$v0, 4					# syscall 4: print_string
	la	$a0, board_size_prompt_str	
	syscall						# printf("How big do you want the board to be? ");

	li	$v0, 5					# syscall 5: read_int
	syscall					
	move	$t0, $v0	    			# scanf("%d", &n);
	sw 	$t0, board_size
 
check_range:
	blt	$t0, MIN_BOARD_SIZE, range_wrong	# if (board_size < MIN_BOARD_SIZE) goto range_wrong
	bgt	$t0, MAX_BOARD_SIZE, range_wrong	# if (board_size > MAX_BOARD_SIZE) goto range_wrong
	j	check_even

range_wrong:
	li	$v0, 4					# syscall 4: print_string
	la	$a0, wrong_board_size_str_1	
	syscall						# printf("Board size must be between )

	li	$v0, 1
	li	$a0, MIN_BOARD_SIZE			# printf("%d", MIN_BOARD_SIZE)
	syscall

	li	$v0, 4					# syscall 4: print_string
	la	$a0, wrong_board_size_str_2		
	syscall						# printf("and ");

	li	$v0, 1
	li	$a0, MAX_BOARD_SIZE			# printf("%d", MAX_BOARD_SIZE)
	syscall

	li	$v0, 4					# syscall 4: print_string
	la	$a0, wrong_board_size_str_3		
	syscall						# printf("\n");

	j	read_board_size__body

check_even:
	li	$t1, 2					# let t1 = 2
	div	$t0, $t0, $t1 				# $t0 = $t0 / 2
	mfhi 	$s0					# take remainder
	bne 	$s0, $zero, not_even			# if (remainder != 0) goto not_even
	j	read_board_size__epilogue

not_even:
	li	$v0, 4					# syscall 4: print_string
	la	$a0, board_size_must_be_even_str		
	syscall						# printf("Board size must be even.");
	j 	read_board_size__body

read_board_size__epilogue:
	li	$v0, 4					# syscall 4: print_string
	la	$a0, board_size_ok_str		
	syscall						# printf("Ok the board size is... ");

	li	$v0, 1
	lw	$a0, board_size				# printf("%d", board_size)
	syscall

	li	$v0, 11
	la 	$a0, '\n'				# printf("\n")
	syscall

	pop	$s0
	pop 	$ra
	end
	jr	$ra


################################################################################
# .TEXT <initialise_board>
	.text

# Fill the board with all EMPTY

initialise_board:
	# Args:     void
	#
	# Returns:  void
	#
	# Frame:    [$ra]
	# Uses:     [$t1, $t2]
	# Clobbers: [$t0, $t1, $t2, $t3, $t4]
	#
	# Locals:
	#   - $t0: i
	#   - $t2: &board[row][col] 
	#   - $t3: board_size
	#
	# Structure:
	#   initialise_board
	#   -> [prologue]
	#       -> body
	# 	   -> check_board_space
	# 	   -> initialise_board_space
	#   -> [epilogue]

initialise_board__prologue:
	begin
	push	$ra

initialise_board__body:
	li 	$t0, 0					# int i = 0
	la	$t2, board				# let $t2 be a board pointer
	lw	$t3, board_size				# $t3 = board_size
	mul	$t4, $t3, 10		

check_board_space:
	bge 	$t0, 100, initialise_board__epilogue	# while (i < 100) 

initialise_board_space:
	li	$t1, PLAYER_EMPTY	
	sw	$t1, ($t2)				# board[][] = PLAYER_EMPTY
	add	$t2, $t2, 4				# move board index by 1
	addi	$t0, $t0, 1				# i++
	j check_board_space

initialise_board__epilogue:
	pop	$ra
	end
	jr	$ra


################################################################################
# .TEXT <place_initial_pieces>
	.text

# Place the centre four pieces:
#    W B
#    B W

place_initial_pieces:
	# Args:     void
	#
	# Returns:  void
	#
	# Frame:    [$ra]
	# Uses:     [$t1, $t2, $t3, $t4, $t5]
	# Clobbers: [$t1, $t2, $t3, $t4, $t5]
	#
	# Locals:
	#   - $t1: &board[row][col]
	#   - #t2: board_size
	#
	# Structure:
	#   place_initial_pieces
	#   -> [prologue]
	#       -> body
	#          -> white_index_1
	# 	   -> place_white_1
	# 	   -> initial_black_1
	#	   -> initial_black_2
	# 	   -> place_white_2
	# 	   -> correct_index_4
	# 	   -> correct_index_6
	# 	   -> correct_index_8
	# 	   -> correct_index_10
	# 	   -> correct_index_12
	#   -> [epilogue]

place_initial_pieces__prologue:
	begin
	push	$ra

place_initial_pieces__body:
	la	$t1, board				# let $t1 be a board pointer

white_index_1:
	lw	$t2, board_size
	div	$t2, $t2, 2
	sub 	$t2, $t2, 1				# x = board_size/2 - 1
	
	lw	$t3, board_size
	div	$t3, $t3, 2
	sub 	$t3, $t3, 1				# y = board_size/2 - 1

	lw 	$t5, board_size
	mul 	$t4, $t2, $t5				# index = x * board_size
	add 	$t4, $t4, $t3				# index = x * board_size + y

	beq	$t5, 4, correct_index_4
	beq	$t5, 6, correct_index_6
	beq	$t5, 8, correct_index_8
	beq	$t5, 10, correct_index_10
	beq	$t5, 12, correct_index_12

place_white_1:
	add 	$t1, $t1, $t4				# add that index to the array pointer
	li	$t0, PLAYER_WHITE
	sb	$t0, ($t1)				# board[board_size/2 - 1][board_size/2 - 1] = white

initial_black_2:
	add 	$t1, $t1, 1				# add that index to the array pointer
	li	$t0, PLAYER_BLACK
	sb	$t0, ($t1)				# board[board_size/2 ][board_size/2 - 1] = black

initial_black_1:
	add 	$t1, $t1, 11				# add that index to the array pointer
	li	$t0, PLAYER_BLACK
	sb	$t0, ($t1)				# board[board_size/2 - 1][board_size/2] = black

place_white_2:
	add 	$t1, $t1, 1				# add that index to the array pointer
	li	$t0, PLAYER_WHITE
	sb	$t0, ($t1)				# board[board_size/2][board_size/2] = white
	j place_initial_pieces__epilogue

correct_index_4:
	add	$t4, $t4, 8				# offset += 8
	j 	place_white_1

correct_index_6:
	add	$t4, $t4, 12				# offset += 12
	j 	place_white_1

correct_index_8:
	add	$t4, $t4, 12				# offset += 12
	j 	place_white_1

correct_index_10:
	add	$t4, $t4, 8				# offset += 8
	j 	place_white_1

correct_index_12:
	add	$t4, $t4, 0				# offset += 0
	j 	place_white_1

place_initial_pieces__epilogue:
	pop	$ra
	end
	jr	$ra


################################################################################
# .TEXT <play_game>
	.text

# Repeatedly call play_turn until the game is over, then call announce_winner

play_game:
	# Args:     void
	#
	# Returns:  void
	#
	# Frame:    [$ra]
	# Uses:     [$v0]
	# Clobbers: [$v0]
	#
	# Locals:
	#
	# Structure:
	#   play_game
	#   -> [prologue]
	#       -> body
	#   -> [epilogue]

play_game__prologue:
	begin
	push	$ra
	li	$v0, 1

play_game__body:	
	jal	play_turn				# while(play_turn())
	beq	$v0, FALSE, play_game__epilogue		
	j 	play_game__body

play_game__epilogue:
	jal 	announce_winner				# announce_winner()
	pop	$ra
	end
	jr	$ra		# return;


################################################################################
# .TEXT <announce_winner>
	.text

# Count up how many pieces and black and how many are white, and then
# accordingly display the outcome of the game

announce_winner:
	# Args:     void
	#
	# Returns:  void
	#
	# Frame:    [$ra]
	# Uses:     [$a0, $v0, $t0, $t1]
	# Clobbers: [$v0, $t0, $t1]
	#
	# Locals:
	#   - $t0: no of black discs
	#   - $t1: no of white discs
	#
	# Structure:
	#   announce_winner
	#   -> [prologue]
	#       -> body
	# 	-> white_win
	# 	-> black_win
	# 	-> tie
	# 	-> score
	#   -> [epilogue]

announce_winner__prologue:
	begin
	push	$ra

announce_winner__body:
	li	$a0, PLAYER_BLACK
	jal	count_discs				# count_discs(PLAYER_BLACK)
	move	$t0, $v0				# $t0 = no of black discs

	li	$a0, PLAYER_WHITE
	jal	count_discs				# count_discs(PLAYER_WHITE)
	move	$t1, $v0				# $t1 = no of white discs

	bgt	$t0, $t1, black_win			# if (black > white) goto black_win
	bgt 	$t1, $t0, white_win			# if (white > black) goto white_win
	beq	$t0, $t1, tie				# if (white = black) goto tie

white_win:
	li	$v0, 4					# syscall 4: print_string
	la	$a0, white_won_str	
	syscall						# printf("The game is a win for white");

	li	$a0, PLAYER_EMPTY
	jal	count_discs				# count_discs(PLAYER_EMPTY)
	add	$t1, $t1, $v0				# white_count += count_discs(empty)
	j 	score			

black_win:
	li	$v0, 4					# syscall 4: print_string
	la	$a0, black_won_str	
	syscall						# printf("The game is a win for black");

	li	$a0, PLAYER_EMPTY
	jal	count_discs
	add	$t0, $t0, $v0				# black_count += count_discs(PLAYER_EMPTY)
	j 	score

tie:
	li	$v0, 4					# syscall 4: print_string
	la	$a0, tie_str	
	syscall						# printf("The game is a tie! Wow.");
	j score

score:
	li	$v0, 4					# syscall 4: print_string
	la	$a0, final_score_str_1	#
	syscall						# printf("Score for white is:");

	li	$v0, 1	
	move	$a0, $t0				# printf("%d", white_discs)
	syscall

	li	$v0, 4					# syscall 4: print_string
	la	$a0, final_score_str_2	#
	syscall						# printf("Score for black is:);

	li	$v0, 1
	move	$a0, $t1				# printf("%d", black_discs)
	syscall

	li	$v0, 4					# syscall 4: print_string
	la	$a0, final_score_str_3	#
	syscall						# printf("\n");


announce_winner__epilogue:
	pop $ra
	end
	jr	$ra		# return;


################################################################################
# .TEXT <count_discs>
	.text

# Count the number of pieces on the board belonging to a specific player

count_discs:
	# Args:
	#    - $a0: int player
	#
	# Returns:
	#    - $v0: unsigned int
	#
	# Frame:    [$ra, $s0, $s1, $s2, $s3]
	# Uses:     [$ra, $t1, $t2, $t3, $s0, $s1, $s2, $s3]
	# Clobbers: [$t1, $t2, $t3]
	#
	# Locals:
	#   - $s1: board_size
	#   - $t1: row_count
	#   - $t2: disc_count
	#   - $t3: offset
	#
	# Structure:
	#   count_discs
	#   -> [prologue]
	#       -> body
	# 	   -> loop1
	#	   -> loop2
	#	   -> loop2_end
	#	   -> add_count
	#   -> [epilogue]

count_discs__prologue:
	begin
	push	$ra			
	push	$s0
	push	$s1
	push	$s2
	push	$s3

count_discs__body_init:
	lw	$s1, board_size				# pointer to board_size
	move	$s2, $a0				# player

	li	$t1, 0					# int row count
	li	$t2, 0					# int disc count
	li	$t3, 0					# int offset

count_discs_loop1:
	bge	$t1, $s1, count_discs__epilogue		# while (row count < board_size)
	li	$t0, 0					# int col count = 0
	
count_discs_loop2:
	bge	$t0, $s1, count_discs_loop2_end		# while (col count < board_size)
	
	la	$s0, board				# pointer to board start
	mul	$t3, $t1, MAX_BOARD_SIZE		
	add	$t4, $t3, $t0				# offset = (row_count * board_size) + col_count
	add	$s0, $s0, $t4				# add offset to pointer
	add	$t0, $t0, 1				# col count ++

	lb	$t5, ($s0)				# load byte
	beq	$t5, $s2, add_count			# if ( element == player) add count		
	j 	count_discs_loop2

count_discs_loop2_end:
	add	$t1, $t1, 1				# row count++
	j	count_discs_loop1

add_count:
	add	$t2, $t2, 1
	j	count_discs_loop2

count_discs__epilogue:
	move	$v0, $t2				# return  disc count
	pop	$s3
	pop	$s2
	pop	$s1
	pop	$s0
	pop	$ra
	end
	jr	$ra


################################################################################
# .TEXT <play_turn>
	.text

# Attempt to play a single turn.
# Returns TRUE if the game is continuing.
# Otherwise returns FALSE if the game is over

play_turn:
	# Args:     void
	#
	# Returns:
	#    - $v0: int
	#
	# Frame:    [$ra]
	# Uses:     [$v0, $a0, $a1, $t0, $t1, $t2, $t3, $t4, $t5]
	# Clobbers: [$t0, $t1, $t2, $t3, $t4, $t5]
	#
	# Locals:
	#   - $t2: move_row
	#   - $t3: move_col_letter
	#   - $t4: move_col
	#   - $t5: board_size
	#
	# Structure:
	#   play_turn
	#   -> [prologue]
	#       -> body
	# 	   -> no_valid_move
	#	   -> return_true
	#	   -> return_false
	# 	   -> move
	#	   -> invalid_move
	#  	   -> invalid_row
	#  	   -> invalid_col
	#   -> [epilogue]

play_turn__prologue:
	begin
	push	$ra

play_turn__body:
	li	$v0, 4
	la	$a0, whos_turn_str_1
	syscall

	jal 	current_player_str
	move	$a0, $v0
	li	$v0, 4
	syscall

	li	$v0, 4
	la	$a0, whos_turn_str_2
	syscall						# printf("It is players turn")

	jal 	print_board				# print_board()
	
	jal	player_has_a_valid_move			# player_has_a_valid_move()
	move	$t0, $v0			
	beq	$t0, $zero, no_valid_move		# if (!player_has_a_valid_move) goto no_valid_move
	j 	move					# else move

no_valid_move:
	li	$v0, 4
	la	$a0, no_valid_move_str_1
	syscall

	li	$v0, 4
	la	$a0, current_player_str
	syscall

	li	$v0, 4
	la	$a0, no_valid_move_str_2
	syscall						# printf("There are no valid moves for player")

	jal	other_player	
	sw	$v0, current_player			# current_player = other_player()

	jal	player_has_a_valid_move
	beq	$v0, TRUE, return_true			# if(player_has_a_valid_move()) return true
	j 	return_false

return_true:
	li	$v0, TRUE
	jr 	$ra		# return true

return_false:
	li	$v0, 4
	la	$a0, game_over_str_1
	syscall

	jal	current_player_str
	li	$v0, 4
	move	$a0, $v0
	syscall						# printf("There are also no valid moves for player")

	li	$v0, 4
	la	$a0, game_over_str_2
	syscall						# printf("Game over!")

	li	$v0, FALSE
	jr 	$ra					# return false

move:	
	li	$v0, 4
	la	$a0, enter_move_str
	syscall						# printf("Enter move (e.g. A 1): ")

	li	$v0, 12
	syscall
	move	$t3, $v0				# scanf("%d", move_col_letter)
	
	li	$v0, 5
	syscall
	move 	$t2, $v0				# scanf("%d", move_row)
	sub	$t2, $t2, 1				# move_row--
	
	li	$t4, 0					# int move_col
	sub	$t4, $t3, 'A'				# move_col = move_col_letter - 'A'

	lw	$t5, board_size
	blt 	$t2, $zero, invalid_row
	bge	$t2, $t5, invalid_row			# if ( row < 0 | row >= board_size) goto invalid_row
	blt 	$t4, $zero, invalid_col
	bge	$t4, $t5, invalid_col			# if ( col < 0 | col >= board_size) goto invalid_col

	move	$a0, $t2
	move	$a1, $t4
	jal	is_valid_move
	beq	$v0, FALSE, invalid_move		# if (!invalid_move(row, col)) goto invalid_move

	move	$a0, $t2	
	move	$a1, $t4
	jal 	place_move				# place_move(move_row, move_col)
	
	jal	other_player	
	sw	$v0, current_player			# current_player = other_player()
	li	$v0, TRUE				# return TRUE
	j 	play_turn__epilogue	

invalid_row:
	li	$v0, 4
	la	$a0, invalid_row_str			# printf("Invalid row")
	syscall
	li	$v0, TRUE				# return TRUE
	jr	$ra

invalid_col:
	li	$v0, 4
	la	$a0, invalid_column_str 		# printf("Invalid col")
	syscall
	li	$v0, TRUE				# return TRUE
	jr	$ra

invalid_move:
	li	$v0, 4
	la	$a0, invalid_move_str			# printf("Invalid move")
	syscall
	li	$v0, TRUE				# return TRUE
	jr	$ra

play_turn__epilogue:
	pop 	$ra
	end
	jr	$ra	

################################################################################
# .TEXT <place_move>
	.text

# Execute a move by the current player and (move_row, move_col)
place_move:
	# Args:
	#    - $a0: int row
	#    - $a1: int col
	#
	# Returns:  void
	#
	# Frame:    [$ra, $s0, $s1, $s2, $s3, $s4, $s5]
	# Uses:     [$ra, $s0, $s1, $s2, $s3, $s4, $s5, $t0, $t1, $t2, $t3, $t4, $t5, $t6, $t7, $t8, $t8]
	# Clobbers: [$t1, $t2, $t3, $t4, $t5, $t6, $t7, $t8, $t8]
	#
	# Locals:
	# -$s0: move_row
	# -$s1: move_col
	# -$s2: direction
	# -$s3: delta
	# -$s4: row
	# -$s5: col
	# -$t0: capture_amt
	# -$t1: directions
	# -$t2: offset
	# -$t5: index
	#
	# Structure:
	#   place_move
	#   -> [prologue]
	#       -> body
	# 	   -> loop1
	# 	   -> loop2_init
	# 	   -> loop2
	# 	   -> loop2_end
	#   -> [epilogue]

place_move__prologue:
	begin
	push 	$ra
	push	$s0
	push	$s1
	push	$s2
	push	$s3
	push 	$s4
	push	$s5	

	move	$s0, $a0
	move	$s1, $a1
	
place_move__body:
	li	$s2, 0					# int direction = 0

place_move_loop1:
	li 	$t0, NUM_DIRECTIONS
	bge	$s2, $t0, place_move__epilogue 		# while (direction < NUM_DIRECTION)
	
	la	$t1, directions				# pointer to directions
	mul 	$t2, $s2, 8				# int offset = direction * 8
	add 	$s3, $t1, $t2				# delta = directions + offset
	
	move	$a0, $s0
	move	$a1, $s1 
	move	$a2, $s3
	jal	capture_amount_from_direction 		# capture_amount+from_direction(row, col, delta)
	move	$t0, $v0				# int $t0 = capture_amt 

place_move_loop2_init:
	li	$t1, 0					# directions = 0
	
place_move_loop2:
	bgt	$t1, $t0, place_move_loop2_end		# while(i < NUM_DIRECTIONS)
	
	lw	$t2, 0($s3)
	mul	$t9, $t1, $t2
	add	$s4, $s0, $t9				# row = move_row + delta->row
	
	lw	$t2, 4($s3)
	mul	$t9, $t1, $t2
	add	$s5, $s1, $t9				# col = move_col + delta->col
	
	la	$t3, board
	mul	$t4, $s4, MAX_BOARD_SIZE		
	add	$t5, $t4, $s5				# index (row * MAX_ROW_SIZE) + col
	add	$t3, $t3, $t5				# add index to address
	
	lw	$t6, current_player
	sb	$t6, ($t3)				# board[row][col] = current_player
	
	add	$t1, $t1, 1				# direction++
	j 	place_move_loop2
	
place_move_loop2_end:
	add	$s2, $s2, 1				# directions++
	j 	place_move_loop1
	
place_move__epilogue:
	pop	$s5
	pop 	$s4
	pop	$s3
	pop	$s2
	pop	$s1
	pop	$s0
	pop	$ra
	end
	jr	$ra


################################################################################
# .TEXT <player_has_a_valid_move>
	.text

# Return TRUE if the player has ANY possible move, other return FALSE

player_has_a_valid_move:
	# Args:     void
	#
	# Returns:
	#    - $v0: int
	#
	# Frame:    [$ra, $s0, $s1, $s2, $s3]
	# Uses:     [$ra, $s0, $s1, $s2, $s3, $a0, $a1]
	# Clobbers: [$a0, $a1]
	#
	# Locals:
	#   - $s0: board
	#   - $s1: board_size
	#   - $s2: j 
	#   - $s3: i 
	#
	# Structure:
	#   player_has_a_valid_move
	#   -> [prologue]
	#       -> body
	# 	   -> loop1
	# 	   -> loop2
	# 	   -> loop2_end
	# 	   -> return_true
	# 	   -> return_false
	#   -> [epilogue]

player_has_a_valid_move__prologue:
	begin
	push	$ra
	push	$s0
	push	$s1
	push	$s2
	push	$s3

	la 	$s0, board				# Let $s0 be a pointer to the board
	lw	$s1, board_size				# Let $s1 be a pointer to the board size
	li	$s2, 0					# int j = 0


player_has_a_valid_move_loop1:
	bge	$s2, $s1, return_false_valid_move	# if (j >= board_size) return false
	li	$s3, 0					# int i = 0

player_has_a_valid_move_loop2:
	bge	$s3, $s1, player_has_a_valid_move_loop2_end	# while (i < board_size)
	move	$a0, $s2
	move	$a1, $s3
	jal	is_valid_move					
	beq	$v0, TRUE, return_true_valid_move	# if (is_valid_move(row,col)) return true
	addi	$s3, $s3, 1				# i++	
	j 	player_has_a_valid_move_loop2

player_has_a_valid_move_loop2_end:
	addi	$s2, $s2, 1				# j++
	j	player_has_a_valid_move_loop1
	
return_true_valid_move:
	li	$v0, TRUE
	j	player_has_a_valid_move__epilogue	# return TRUE

return_false_valid_move:	
	li	$v0, FALSE				# return FALSE

player_has_a_valid_move__epilogue:
	pop	$s3
	pop	$s2
	pop	$s1
	pop	$s0
	pop	$ra
	end
	jr	$ra	

################################################################################
# .TEXT <is_valid_move>
	.text

# Check if a move at (row, col) is valid, meaning that it's on
# an empty square, and that it captures at least one piece from
# the other player

is_valid_move:
	# Args:
	#    - $a0: int row
	#    - $a1: int col
	#
	# Returns:
	#    - $v0: int
	#
	# Frame:    [$ra, $s0, $s1, $s2, $s3, $s4, $s5]
	# Uses:     [$ra, $s0, $s1, $s2, $s3, $s4, $s5, $t0, $t1, $t2, $t3, $t4, $t5]
	# Clobbers: [$t0, $t1, $t2, $t3, $t4, $t5]
	#
	# Locals:
	#   - $s0: board[row][col]
	#   - $s2: board_size
	#   - $s3: row
	#   - $s4: col
	#   - $s5: direction
	#
	# Structure:
	#   is_valid_move
	#   -> [prologue]
	#       -> body
	# 	   -> loop
	# 	   -> next_direction
	# 	   -> return_false
	# 	   -> return_true
	#   -> [epilogue]

is_valid_move__prologue:
	begin
	push	$ra
	push	$s0	
	push	$s1
	push	$s2
	push	$s3
	push	$s4
	push	$s5
	
	la 	$s0, board				# Let $s0 be a pointer to the board
	lw 	$s2, board_size				# Let $s2 be a pointer to the board_size

	move	$s3, $a0				# int row
	move	$s4, $a1				# int col
	li	$s5, 0					# int direction = 0

is_valid_move__body:
	mul	$t3, $s3, MAX_BOARD_SIZE			# index = row * row_size
	add	$t3, $t3, $s4					# index = (row * row_size) + col
	add	$s0, $s0, $t3					# add index to address

	lb	$t2, ($s0)
	bne	$t2, PLAYER_EMPTY, return_false_is_valid	# if (board[row][col] != PLAYER_EMPTY]) goto return false
	
is_valid_move_loop:
	bge	$s5, NUM_DIRECTIONS, return_false_is_valid	# while (direction < NUM_DIRECTIONS)
	
	la	$s1, directions					# pointer to directions
	mul 	$t5, $s5, 8					# offset = direction * 4
	add 	$s1, $s1, $t5					# directions = directions + offset
	

	move	$a0, $s3
	move	$a1, $s4
	move	$a2, $s1
	jal	capture_amount_from_direction		# capture_amount_from_direction(row, col, directions)

	beq	$v0, FALSE, next_direction		# if (False) continue
	j	return_true_is_valid

next_direction:
	addi	$s5, $s5, 1				# direction++
	j 	is_valid_move_loop

return_false_is_valid:
	li	$v0, FALSE
	pop	$s5
	pop	$s4
	pop	$s3
	pop	$s2
	pop	$s1
	pop	$s0
	pop	$ra
	end
	jr	$ra					# return TRUE

return_true_is_valid:
	li	$v0, TRUE
	pop	$s5
	pop	$s4
	pop	$s3
	pop	$s2
	pop	$s1
	pop	$s0
	pop	$ra
	end
	jr	$ra					# return FALSE

is_valid_move__epilogue:
	li	$v0, FALSE
	pop	$s5
	pop	$s4
	pop	$s3
	pop	$s2
	pop	$s1
	pop	$s0
	pop	$ra
	end
	jr	$ra					# return FALSE;


################################################################################
# .TEXT <capture_amount_from_direction>
	.text

# Returns the number length of the capture line at (row, col) for the
# current player, in the direction of the delta vector. Returns 0 to
# indicate that that there is no captures because the line is invalid

capture_amount_from_direction:
	# Args:
	#    - $a0: int row
	#    - $a1: int col
	#    - $a2: const vector *delta
	#
	# Returns:
	#    - $v0: unsigned int
	#
	# Frame:    [$ra, $s0, $s1, $s2, $s3]
	# Uses:     [$ra, $s0, $s1, $s2, $s3, $t0, $t1, $t2, $t3, $t4, $t5, $t6, $t7]
	# Clobbers: [$t0, $t1, $t2, $t3, $t4, $t5, $t6, $t7]
	#
	# Locals:
	#   - $s0: row
	#   - $s1: col
	#   - $s2: const vector *delta
	#   - $s3: board[row][col]
	#   - $t0: opposite
	#   - $t1: line_length
	#   - $t5: board_index
	#   - $t7: board_size
	#
	# Structure:
	#   capture_amount_from_direction
	#   -> [prologue]
	#       -> body
	#   -> [epilogue]

capture_amount_from_direction__prologue:
	begin
	push	$ra
	push	$s0
	push	$s1
	push	$s2
	push	$s3
	
	move	$s0, $a0				# int row
	move	$s1, $a1				# int col
	move	$s2, $a2				# const vector *delta

	jal	other_player
	move	$t0, $v0				# opposite = other_player()
	li	$t1, 0					# line_length = 0
	
capture_amount_from_direction__body:

	lb	$t2, 0($s2)
	add	$s0, $s0, $t2	# row += delta->row
	lb	$t2, 4($s2)
	add	$s1, $s1, $t2	# col += delta->col

	lw	$t7, board_size
	blt	$s0, $zero, capture_amount_from_direction__epilogue	# if(row < 0) return
	bge 	$s0, $t7, capture_amount_from_direction__epilogue	# if (row >= board_size) return
	blt	$s1, $zero, capture_amount_from_direction__epilogue	# if(col < 0) return
	bge 	$s1, $t7, capture_amount_from_direction__epilogue	# if (col >= board_size) return
	
	la	$s3, board
	mul	$t4, $s0, MAX_BOARD_SIZE		
	add	$t5, $t4, $s1				# index (row * row_size) + col
	add	$s3, $s3, $t5				# add index to the board address
	lb	$t6, ($s3)
	bne	$t6, $t0, capture_amount_from_direction__body2

	add	$t1, $t1, 1				# line_length++

	j capture_amount_from_direction__body

capture_amount_from_direction__body2:
	bne 	$s3, current_player, capture_amount_from_direction__epilogue	# if (board[row][col] != current_player) return 0
	move	$v0, $t1							# else return line_length

capture_amount_from_direction__epilogue:
	pop	$s3
	pop	$s2
	pop	$s1
	pop	$s0
	pop	$ra
	end
	jr	$ra


################################################################################
# .TEXT <other_player>
	.text

# Returns the player which isn't the current player

other_player:
	# Args:     void
	#
	# Returns:
	#    - $v0: int
	#
	# Frame:    [$ra]
	# Uses:     [$ra, $t0, $t1]
	# Clobbers: [$t0, $t1]
	#
	# Locals:
	#   - $t0: current_player
	#
	# Structure:
	#   other_player
	#   -> [prologue]
	#       -> body
	#          -> return_white_other
	# 	   -> return_black_other
	#   -> [epilogue]

other_player__prologue:
	begin
	push	$ra

other_player__body:
	lw	$t0, current_player
	li	$t1, PLAYER_WHITE
	beq	$t0, $t1, return_black_other		# if (current_player = white) return black
	j 	return_white_other			# else return white

return_white_other:
	li	$v0, PLAYER_WHITE			# return white
	j 	current_player_str__epilogue

return_black_other:	
	li	$v0, PLAYER_BLACK			# return black

other_player__epilogue:
	pop	$ra
	end
	jr	$ra


################################################################################
# .TEXT <current_player_str>
	.text

# Returns a string representation of the current player

current_player_str:
	# Args:     void
	#
	# Returns:
	#    - $v0: const char *
	#
	# Frame:    [$ra]
	# Uses:     [$ra, $t0, $t1]
	# Clobbers: [$t0, $t1]
	#
	# Locals:
	#   - $t0: current_player
	#
	# Structure:
	#   current_player_str
	#   -> [prologue]
	#       -> body
	# 	   -> return_white
	#	   -> return_black
	#   -> [epilogue]

current_player_str__prologue:
	begin
	push	$ra

current_player_str__body:
	lw	$t0, current_player			# load current_player into $t0
	li	$t1, PLAYER_WHITE
	beq	$t0, $t1, return_white			# if (current_player = white) return white
	j return_black					# else return black

return_white:
	la	$v0, white_str				# return white
	j current_player_str__epilogue

return_black:
	la	$v0, black_str				# return black
	
current_player_str__epilogue:
	pop	$ra
	end
	jr	$ra					# return;


################################################################################
################################################################################
###                    PROVIDED FUNCTION — DO NOT CHANGE                     ###
################################################################################
################################################################################

################################################################################
# .TEXT <print_board>
# YOU DO NOT NEED TO CHANGE THE print_board FUNCTION
	.text
print_board:
	# Args: void
	#
	# Returns:  void
	#
	# Frame:    [$ra, $s0, $s1]
	# Uses:     [$a0, $v0, $t2, $t3, $t4, $s0, $s1]
	# Clobbers: [$a0, $v0, $t2, $t3, $t4]
	#
	# Locals:
	#   - $s0: col
	#   - $s1: row
	#   - $t2: board_size, row + 1
	#   - $t3: &board[row][col]
	#   - $t4: board[row][col]
	#
	# Structure:
	#   print_board
	#   -> [prologue]
	#   -> body
	#      -> header_loop
	#      -> header_loop__init
	#      -> header_loop__cond
	#      -> header_loop__body
	#      -> header_loop__step
	#      -> header_loop__end
	#      -> for_row
	#      -> for_row__init
	#      -> for_row__cond
	#      -> for_row__body
	#          -> print_row_num
	#          -> for_col
	#          -> for_col__init
	#          -> for_col__cond
	#          -> for_col__body
	#              -> white
	#              -> black
	#              -> possible_move
	#              -> output_cell
	#          -> for_col__step
	#          -> for_col__end
	#      -> for_row__step
	#      -> for_row__end
	#   -> [epilogue]

print_board__prologue:
	begin
	push	$ra
	push	$s0
	push	$s1

print_board__body:
	li	$v0, 4
	la	$a0, board_str
	syscall						# printf("Board:\n   ");

print_board__header_loop:
print_board__header_loop__init:
	li	$s0, 0					# int col = 0;

print_board__header_loop__cond:
	lw	$s1, board_size
	bge	$s0, $s1, print_board__header_loop__end # while (col < board_size) {

print_board__header_loop__body:
	li	$v0, 11
	addi	$a0, $s0, 'A'
	syscall						#     printf("%c", 'A' + col);

	li	$a0, ' '
	syscall						#     putchar(' ');

print_board__header_loop__step:
	addi	$s0, $s0, 1				#     col++;
	b	print_board__header_loop__cond		# }

print_board__header_loop__end:
	li	$v0, 11
	li	$a0, '\n'
	syscall						# printf("\n");

print_board__for_row:
print_board__for_row__init:
	li	$s0, 0					# int row = 0;

print_board__for_row__cond:
	lw	$t2, board_size
	bge	$s0, $t2, print_board__for_row__end	# while (row < board_size) {

print_board__for_row__body:
	addi	$t2, $s0, 1
	bge	$t2, 10, print_board__print_row_num	#     if (row + 1 < 10) {

	li	$v0, 11
	li	$a0, ' '
	syscall						#         printf("%d ", row + 1);

print_board__print_row_num:				#     }
	li	$v0, 1
	move	$a0, $t2
	syscall						#     printf("%d", row + 1);

	li	$v0, 11
	li	$a0, ' '
	syscall						#     putchar(' ');

print_board__for_col:
print_board__for_col__init:
	li	$s1, 0					#     int col = 0;

print_board__for_col__cond:
	lw	$t2, board_size
	bge	$s1, $t2, print_board__for_col__end	#     while (col < board_size) {

print_board__for_col__body:
	mul	$t3, $s0, MAX_BOARD_SIZE		#         &board[row][col] = row * MAX_BOARD_SIZE
	add	$t3, $t3, $s1				#                            + col
	addi	$t3, board				#                            + &board

	lb	$t4, ($t3)				#         char cell = board[row][col];

	beq	$t4, PLAYER_WHITE, print_board__white	#         if (cell == PLAYER_WHITE) goto print_board__white;
	beq	$t4, PLAYER_BLACK, print_board__black	#         if (cell == PLAYER_BLACK) goto print_board__black;

	move	$a0, $s0
	move	$a1, $s1
	jal	is_valid_move
	bnez	$v0, print_board__possible_move		#         if (is_valid_move(row, col)) goto print_board__possible_move;

	li	$a0, EMPTY_CELL_CHAR			#         c = EMPTY_CELL_CHAR;
	b	print_board__output_cell		#         goto print_board__output_cell;

print_board__white:
	li	$a0, WHITE_CHAR				#         c = WHITE_CHAR;
	b	print_board__output_cell		#         goto print_board__output_cell;

print_board__black:
	li	$a0, BLACK_CHAR				#         c = BLACK_CHAR;
	b	print_board__output_cell		#         goto print_board__output_cell;

print_board__possible_move:
	li	$a0, POSSIBLE_MOVE_CHAR			#         c = POSSIBLE_MOVE_CHAR;
	b	print_board__output_cell		#         goto print_board__output_cell;

print_board__output_cell:
	li	$v0, 11
	syscall						#         printf("%c", c);

	li	$a0, ' '
	syscall						#         putchar(' ');

print_board__for_col__step:
	addi	$s1, $s1, 1				#         col++;
	b	print_board__for_col__cond		#     }

print_board__for_col__end:
	li	$v0, 11
	li	$a0, '\n'
	syscall						#     putchar('\n');

print_board__for_row__step:
	addi	$s0, $s0, 1				#     row++;
	b	print_board__for_row__cond		# }

print_board__for_row__end:
print_board__epilogue:
	pop	$s1
	pop	$s0
	pop	$ra
	end

	jr	$ra					# return;
