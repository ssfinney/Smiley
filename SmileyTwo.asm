TITLE Program Smiley Two	(SmileyTwo.asm)

; CSC 322 - Program 7, Smiley Two
; Stephen Finney
; November 28, 2011

; This program will let the user move two smiley
; face characters across the screen in a maze
; of asterisks as walls. Each smiley has its own controls.
; For blue, arrow keys are used. For red, the numbers 2,4,6,8
; for down, left, right, and up respectively.
; The smileys cannot go through walls or each other, but 
; can go through the gates at the top, bottom, and sides. 
; The pellets act as points, and each is worth one. When
; the game is over (when the user quits or the majority of pellets 
; are picked up), the screen is cleared except for the scores, 
; a win message is printed for the winning player, the cursor is restored
; below the message, and the program is terminated.

INCLUDE Irvine32.inc							; The author's library of procedures and macros.
INCLUDE MacroLibrarySmiley2.inc					; This is the macro library for this program.

.data

  ; The maze for the program. This is printed as seen directly on the screen.
  maze  db      "***************************************  ***************************************" 
        db      "* RED SCORE: 000*          *          *  *             *      * BLUE SCORE: 000*" 
        db      "***********************    *     ******  ***********   *    ********************"
        db      "*. . . . . . . . . . . . . *     ...................   * . . . . . . . . . . . *"
        db      "****  . . . . . . . . . . .*     ...................   *  . . . . . . . . . ****"
        db      "                           *     ...................   *                        " 
        db      "**** . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .****"
        db      "*.          *********************************************************         .*"
        db      "*.                                                                            .*"
        db      "*.                               ******** ********                            .*"
        db      "*.                         *     *...............*     *                      .*"
        db      "*.                         *     *...............*     *                      .*"
        db      "*.                         *     *...............*     *                      .*"
        db      "*.                         *     *...............*     *                      .*"
        db      "*.                         *     *...............*     *                      .*"
        db      "*.                               *...............*                            .*"
        db      "*.          *********************************************************         .*"
        db      "*. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . *"
        db      "*. . . . . . . . . . . . . * . . . . . . . . . . . . . *. . . . . . . . . . . .*"
        db      "*. . . . . . . . . . . . . * . . . . . . . . . . . . . * . . . . . . . . . . . *"
        db      "****...................    *  ......................   *  ..................****"
        db      "    ...................    *   *   *       *     *     *  ..................    " 
        db      "****...................    *   * * *  *  * *  *  * *   *  ..................****"
        db      "*......................          *    *  *    *    *      .....................*"
        db      "***************************************  **************************************",0 

	; These will hold the current position on the screen 
	; of the red and the blue smileys respectively. They
	; are initialized to their starting positions.
	redRow db 12
	redCol db 12
	blueRow db 12
	blueCol db 66
	
	
	; Row and column variables used exclusively in the
	; 'clearScreen' procedure used to place spaces everywhere
	; on the screen below the scores.
	row db 0
	col db 0

	; These are direction variables for the program. Each one will
	; hold a '0' by default. If a move is confirmed by the 'CheckRedMove'
	; and 'CheckBlueMove' macros, the direction of the move will be held by
	; moving a '1' into its corresponding direction variable.
	up	  db 0
	down  db 0
	left  db 0
	right db 0
	
	; The score variables will hold the score of each smiley, and
	; will be used to update the score on the screen when a score is made by a smiley.
	redScore  dd 000
	blueScore dd 000
	
	; This will be used exclusively in the 'clearScreen' procedure to 
	; hold the value of ECX before the procedure is called.
	SaveECX dd 0
	
	; This will be used in the 'TestForSmiley' macro. Is set to '1' if
	; the two smiley positions being compared are the same.
	smileyCollision dd 0
	
	; These will be incremented after a move by a smiley on a pellet.
	; Each will be set to '1' when this happens, and are reset after every move.
	incrementRed  dd 0
	incrementBlue dd 0
	
	; These are the messages that will be printed once the game ends,
	; according to who won the game.
	redMsg  db "The Red Smiley wins! Great job!", 0
	blueMsg db "The Blue Smiley wins! Great job!", 0
	tieMsg  db "It is a tie game!", 0
	
.code
main PROC
	call clrscr									; Clear the screen (completely)

	SetColor blue, green						; Set the color to blue-on-green,
	Print maze									; and print the maze on the screen.

	SetColor red, green							; Set the color to red-on-green,
	SetCursor 12, 12							; and set the cursor to row 12, column 12.

	PrintChar 1									; Print a red smiley here.

	SetColor blue, green						; Set the color to blue-on-green,
	SetCursor 12, 66							; and set the cursor to row 12, column 66.

	PrintChar 1									; Print a blue smiley here.
	
Top:											; The 'Top' label will be jumped to after every key press and move.
	ClearDirections								; Clears all direction variables (up, down, etc).
	call readChar								; Read in a character from the user's keyboard.
	
	mov incrementRed, 0							; Clear the variables that determine which score to increment.
	mov incrementBlue, 0
	
	call checkForQuit							; Check to see if the characer is 'q' or 'Q'. If so,
												; it calls 'clearScreen' (NOT clrscr) and terminates.
	
	CheckForRedMove								; Macro to check for a red smiley move (2,4,6,8)
	CheckForBlueMove							; Macro to check for a blue smiley move (arrow keys)
	
	jmp Top										; If the key is not a move or a quit command, 
												; jump back to 'Top'.
	
MoveRedNow:										; This label is called from the 'CheckForRedMove' macro. 
	call moveRed								; If it is reached, call 'moveRed' to begin move.
	call checkForWin							; After the move, check for a win.
	jmp Top										; Jump back to 'Top'.
	
MoveBlueNow:									; This label is called from the 'CheckForBlueMove'
	call moveBlue								; macro. If it is reached, call 'moveBlue' to begin move.
	call checkForWin							; After the move, check for a win.
	jmp Top										; Jump back to 'Top'.
main ENDP

; The procedure for moving the red smiley. It will first check 
; the direction variables. Whichever one has the value of 'one' 
; will be the direction in which the smiley moves. These variables
; are initially set in main. Then, it will find the attempted new 
; position of the smiley, and check it for walls, smileys, and pellets.
; It returns if a wall or other smiley is found. It calls the 'IncBlueScore' 
; procedure if a pellet is found. If no obstacles are in the way, it will 
; then move the smiley by placing a space at its previous position and a 
; smiley at the new one, then it returns.
moveRed PROC
												;;;;;;;;;;;;;;Red Downward move ('2')

	mov smileyCollision, 0						; Clears the value of the 'smileyCollision' variable for the next move.
	cmp down, 1			  						; If the 'down' variable is not '1', 
	jne MoveRedUp								; jump to check the next direction ('MoveRedUp').
												
	pushAD										; Push all registers to save their values.
												
	GetPosition redRow, redCol					; Uses the 'GetPosition' macro to determine the linear position of the smiley.
												; ESI will hold the final position in memory.
												
	inc redRow									
	TestForSmiley blueRow, blueCol, redRow, redCol		; This macro compares the positions of both smileys to see if they are equal.
	dec redRow											; If they are equal, the 'smileyCollision' variable is set to '1'.
														; The new position is calculated before the macro for the sake of the test, 
														; and it is resetted afterward.
														
	cmp smileyCollision, 1						; If there is a collision, do not moce. Jump to the bottom.
	je BottomRed
	
	add esi, 80									; Shifts the current row down to test for the new positon's move validity.

	cmp byte ptr [esi], '*'						; If the new position contains a wall, do nothing and jump
	je BottomRed								; to 'Top'. If it contains a pellet ('.'), the smiley's score... 
	
	cmp byte ptr [esi], '.'						; ...will increase by one. If not, jump straight to
	jne PrintRedDown							; the print commands without calling 'IncRedScore'.
	
	mov byte ptr [esi], ' '						; Prints a space over the previous position of the pellet
												; on the maze, so that the pellet cannot be used again.
	
	inc incrementRed
	call updateScore							; Calls the procedure to increase the red score by '1'.
	
PrintRedDown:
	PrintCharAt ' ', redRow, redCol				; First prints a space in the previous location of the smiley,
	inc redRow									; then moves to the new position.
	
	mov ah, redRow
	mov bh, redCol
	call checkForGates
	mov redRow, ah
	mov redCol, bh
	
	SetColor red, green							; Makes the color red-on-green, prints the new smiley,
	PrintCharAt 1, redRow, redCol				; pops all registers, then returns. 
	popAD
	ret

	; From here on out in the procedure, the code will be
	; almost identical for each direction. The only change
	; will be the change in the row and column variables.
	; For example, in this next section, the row is decresed by one
	; because the smiley is moving up. Above, it was increased because
	; it was moving down. The same goes for the columns later on,
	; increments for right, decrements for left.
MoveRedUp:
	cmp up, 1									;;;;;;;;;;;;;;;;;Red Upward move ('8')
	jne MoveRedLeft

	pushAD
	
	GetPosition redRow, redCol
	dec redRow
	TestForSmiley blueRow, blueCol, redRow, redCol
	inc redRow
	
	cmp smileyCollision, 1
	je BottomRed

	sub esi, 80									; Shifts the current row up

	cmp byte ptr [esi], '*'						; If the new position contains a wall, do nothing and jump
	je BottomRed								; to 'Top'. If it contains a pellet ('.'), the smiley's score... 
	
	cmp byte ptr [esi], '.'						; ...will increase by one. If not, jump straight to
	jne PrintRedUp								; the print commands without calling 'IncRedScore'.
	
	mov byte ptr [esi], ' '						; Prints a space over the previous position of the pellet
												; on the maze, so that the pellet cannot be used again.
	inc incrementRed
	call updateScore
	
	; Prints a space at the current position,
	; then a smiley at the new position. Then,
	; it pops all used registers and returns.
PrintRedUp:
	PrintCharAt ' ', redRow, redCol
	dec redRow
	
	mov ah, redRow
	mov bh, redCol
	call checkForGates
	mov redRow, ah
	mov redCol, bh
	
	SetColor red, green
	PrintCharAt 1, redRow, redCol
	popAD
	ret
	
MoveRedLeft:
	cmp left, 1									;;;;;;;;;;;;;;;;;Red Leftward move ('4')
	jne MoveRedRight
	
	pushAD
	
	GetPosition redRow, redCol
	dec redCol
	TestForSmiley blueRow, blueCol, redRow, redCol
	inc redCol
	
	cmp smileyCollision, 1
	je BottomRed
	
	dec esi										; Shifts the current column left
	
	cmp byte ptr [esi], '*'						; If the new position contains a wall, do nothing and jump
	je BottomRed								; to 'Top'. If it contains a pellet ('.'), the smiley's score...
	
	cmp byte ptr [esi], '.'						; ...will increase by one. If not, jump straight to
	jne PrintRedLeft							; the print commands without calling 'IncRedScore'.

	mov byte ptr [esi], ' '						; Prints a space over the previous position of the pellet
												; on the maze, so that the pellet cannot be used again.
	inc incrementRed
	call updateScore
	
PrintRedLeft:
	PrintCharAt ' ', redRow, redCol
	dec redCol
	
	mov ah, redRow
	mov bh, redCol
	call checkForGates
	mov redRow, ah
	mov redCol, bh
	
	SetColor red, green
	PrintCharAt 1, redRow, redCol
	popAD
	ret
	
MoveRedRight:
													;;;;;;;;;;;;;;;;;Red Rightward move ('6')
	pushAD
	
	GetPosition redRow, redCol
	inc redCol
	TestForSmiley blueRow, blueCol, redRow, redCol
	dec redCol
	
	cmp smileyCollision, 1
	je BottomRed

	inc esi										; Shifts the current column right

	cmp byte ptr [esi], '*'						; If the new position contains a wall, do nothing and jump
	je BottomRed								; to 'Top'. If it contains a pellet ('.'), the smiley's score... 
	
	cmp byte ptr [esi], '.'						; ...will increase by one. If not, jump straight to
	jne PrintRedRight							; the print commands without calling 'IncRedScore'.
	
	mov byte ptr [esi], ' '						; Prints a space over the previous position of the pellet
												; on the maze, so that the pellet cannot be used again.
	inc incrementRed
	call updateScore
	
PrintRedRight:
	PrintCharAt ' ', redRow, redCol
	inc redCol
	
	mov ah, redRow
	mov bh, redCol
	call checkForGates
	mov redRow, ah
	mov redCol, bh
	
	SetColor red, green
	PrintCharAt 1, redRow, redCol
	
BottomRed:
	popAD
	ret
moveRed ENDP


; The procedure for moving the blue smiley. It will first check 
; the direction variables. Whichever one has the value of 'one' 
; will be the direction in which the smiley moves. These variables
; are initially set in main. Then, it will find the attempted new 
; position of the smiley, and check it for walls, smileys, and pellets.
; It returns if a wall or other smiley is found. It calls the 'IncBlueScore' 
; procedure if a pellet is found. If no obstacles are in the way, it will 
; then move the smiley by placing a space at its previous position and a 
; smiley at the new one, then it returns.

; The code for 'moveBlue' is identical to the 'moveRed' procedure,
; except the smiley's variables are blueRow and blueCol and
; the label names have changed to names with 'blue' in them.
moveBlue PROC
	mov smileyCollision, 0						; Clears the value of the 'smileyCollision' variable for the next move.
	cmp down, 1									;;;;;;;;;;;;;;;;Blue, Down arrow key
	jne MoveBlueUp
												; If the move is not downward, jump to next section of code.
	pushAD										; Push all used registers to save their values.
	
	GetPosition blueRow, blueCol
	inc blueRow
	TestForSmiley blueRow, blueCol, redRow, redCol
	dec blueRow
	
	cmp smileyCollision, 1
	je BottomBlue

	add esi, 80									; Shifts the current row down
	
	cmp byte ptr [esi], '*'						; If the new position contains a wall
	je BottomBlue								; or another smiley face, do nothing and
												; jump to 'Top'. If it contains a pellet ('.'),
												; the smiley's score will increase by one.
	cmp byte ptr [esi], '.'
	jne PrintBlueDown
	
	mov byte ptr [esi], ' '						; Prints a space over the previous position of the pellet
												; on the maze, so that the pellet cannot be used again.
	inc incrementBlue
	call updateScore
	
PrintBlueDown:
	PrintCharAt ' ', blueRow, blueCol
	inc blueRow
	
	mov ah, blueRow
	mov bh, blueCol
	call checkForGates
	mov blueRow, ah
	mov blueCol, bh
	
	SetColor blue, green
	PrintCharAt 1, blueRow, blueCol
	popAD
	ret

MoveBlueUp:
	cmp up, 1									;;;;;;;;;;;;;;;;;Blue, Up arrow key
	jne MoveBlueLeft

	pushAD
	
	GetPosition blueRow, blueCol
	dec blueRow
	TestForSmiley blueRow, blueCol, redRow, redCol
	inc blueRow
	
	cmp smileyCollision, 1
	je BottomBlue

	sub esi, 80									; Shifts the current row up
	
	cmp byte ptr [esi], '*'						; If the new position contains a wall
	je BottomBlue								; or another smiley face, do nothing and
												; jump to 'Top'. If it contains a pellet ('.'),
												; the smiley's score will increase by one. If not,
	cmp byte ptr [esi], '.'						; jump straight to the move commands without calling
	jne PrintBlueUp								; 'IncBlueScore'.
	
	mov byte ptr [esi], ' '						; Prints a space over the previous position of the pellet
												; on the maze, so that the pellet cannot be used again.
	inc incrementBlue
	call updateScore
	
	; Prints a space at the current position,
	; then a smiley at the new position. Then,
	; it pops all used registers and returns.
PrintBlueUp:
	PrintCharAt ' ', blueRow, blueCol
	dec blueRow
	
	mov ah, blueRow
	mov bh, blueCol
	call checkForGates
	mov blueRow, ah
	mov blueCol, bh
	
	SetColor blue, green
	PrintCharAt 1, blueRow, blueCol
	popAD
	ret

MoveBlueLeft:
	cmp left, 1									;;;;;;;;;;;;;;;;;Blue, Left arrow key
	jne MoveBlueRight
	
	pushAD
	
	GetPosition blueRow, blueCol
	dec blueCol
	TestForSmiley blueRow, blueCol, redRow, redCol
	inc blueCol
	
	cmp smileyCollision, 1
	je BottomBlue

	dec esi										; Shifts the current column left
	
	cmp byte ptr [esi], '*'						; If the new position contains a wall
	je BottomBlue								; or another smiley face, do nothing and
												; jump to 'Top'. If it contains a pellet ('.'),
												; the smiley's score will increase by one. If not,
	cmp byte ptr [esi], '.'						; jump straight to the move commands without calling
	jne PrintBlueLeft							; 'IncBlueScore'.
	
	mov byte ptr [esi], ' '						; Prints a space over the previous position of the pellet
												; on the maze, so that the pellet cannot be used again.
	inc incrementBlue
	call updateScore
	
PrintBlueLeft:
	PrintCharAt ' ', blueRow, blueCol
	dec blueCol
	
	mov ah, blueRow
	mov bh, blueCol
	call checkForGates
	mov blueRow, ah
	mov blueCol, bh
	
	SetColor blue, green
	PrintCharAt 1, blueRow, blueCol
	popAD
	ret
	
MoveBlueRight:

	pushAD

												;;;;;;;;;;;;;;;;;Blue, Right arrow key	
	GetPosition blueRow, blueCol
	inc blueCol
	TestForSmiley blueRow, blueCol, redRow, redCol
	dec blueCol
	
	cmp smileyCollision, 1
	je BottomBlue

	inc esi										; Shifts the current column right
	
	
	cmp byte ptr [esi], '*'						; If the new position contains a wall
	je BottomBlue								; or another smiley face, do nothing and
												; jump to 'Top'. If it contains a pellet ('.'),
												; the smiley's score will increase by one. If not,
	cmp byte ptr [esi], '.'						; jump straight to the move commands without calling
	jne PrintBlueRight							; 'IncBlueScore'.
	
	mov byte ptr [esi], ' '						; Prints a space over the previous position of the pellet
												; on the maze, so that the pellet cannot be used again.
	inc incrementBlue
	call updateScore
	
PrintBlueRight:
	PrintCharAt ' ', blueRow, blueCol
	inc blueCol
	
	mov ah, blueRow
	mov bh, blueCol
	call checkForGates
	mov blueRow, ah
	mov blueCol, bh
	
	SetColor blue, green
	PrintCharAt 1, blueRow, blueCol
	
BottomBlue:
	popAD										; Pop all registers to restore their values.
	ret
moveBlue ENDP
	
; Increments the smiley's score after a point
; is scored (by eating a pellet). First, the default score
; (000) is cleared by placing a space on those areas. Then,
; the cursor is set at the score area and the score variable
; is placed there, which is incremented after each score. 'WriteDec'
; is called to write the number to the screen.
updateScore PROC
	 cmp incrementBlue, 1						; Tests to see if the smiley that scored 
	 je incBlue									; is the red or blue one. Jumps to their
												; respective labels.
	 cmp incrementRed, 1
	 je incRed
	 
incBlue:
	 PrintCharAt 0, 1, 76						; Clears the default score (000) from the screen
	 PrintCharAt 0, 1, 77						; by placing a space over the characters.
	 PrintCharAt 0, 1, 78
		
	 push eax									; Push register to save its value.
	 inc blueScore								; Increment 'blueScore' variable.
	 SetCursor 1, 76							; Set cursor at the score field at the top for the blue smiley.
	 mov eax, blueScore							; Move the score into EAX.
	 call WriteDec								; Call 'WriteDec' to write the number in the field
	 pop eax									; Pop EAX back to its original value.
	 ret										; Return.
	 
incRed:
	 SetColor blue, green

	 PrintCharAt 0, 1, 13						; Clears the default score (000) from the screen.
	 PrintCharAt 0, 1, 14						; by placing a space over the characters.
	 PrintCharAt 0, 1, 15

	 push eax									; Push register to save its value.
	 inc redScore								; Increment 'blueScore' variable.
	 SetCursor 1, 13							; Set cursor at the score field at the top for the blue smiley.
	 mov eax, redScore							; Move the score into EAX.
	 call WriteDec								; Call 'WriteDec' to write the number in the field
	 pop eax									; Pop EAX back to its original value.
	 ret
updateScore ENDP

; This procedure checks to see if the current key press
; is 'q' or 'Q'. If so, it calls the clearScreen procedure
; and then terminates the program. If not, it returns doing nothing.
checkForQuit PROC
	cmp al, 'q'									; Compare the key to both 'q' and 'Q'.
	je Quit										; If they match, jump to 'Quit' label below.
												; If not, return after both comparisons.
	cmp al, 'Q'
	je Quit
	ret

Quit:											; If there is a match, call the 'clearScreen' procedure.
	call clearScreen							; This will clear the screen below the scoreboard and exit the program.
checkForQuit ENDP

; Checks the new position of a smiley's move for a gate. If the smiley
; is about to go through the gate, it should be moved to the gate position
; directly opposite from it.
; The row and column are passed in as AH and BH respectively.
; The final row and column will also be stored in AH and BH, respectively.
checkForGates PROC

Top1:											; The code for the left lane of the top gate (0, 39).
cmp ah, -1										; Compare the next move to see if it moves outside the maze.
jne Left1										; If the row would not be -1, jump to 'Left1'.

cmp bh, 39										; If the row matches, check for column '39'. If it is not,
jne Top2										; jump to 'Top2'.

mov ah, 24										; If there is a match, move the smiley's row and column to
mov bh, 39										; the corresponding bottom gate (24, 39).
ret												; Return

Top2:											; The code for the right lane of the top gate (0, 40).
cmp bh, 40										; Compare to see if the column is indeed 40. If not,
jne Left1										; jump to 'Left1'.

mov ah, 24										; If there is a match, move the smiley's row and column to 
mov bh, 40										; the corresponding bottom gate (24, 40).
ret												; Return

Left1:											; The code for the first gate on the leftmost wall (5, 0).
cmp ah, 5										; Compare the row and column to row 5, column 0.
jne Left2										; If one of these doesn't match, jump to 'Left2'.
cmp bh, 0
jne Left2

mov bh, 79										; If there is a match, move the smiley's column to 79, which
ret												; is the corresponding right gate (5, 79).

Left2:											; The code for the second gate on the leftmost wall (21, 0).
cmp ah, 21										; Check to see if the smiley's row and column are (21, 0). If
jne Right1										; one of these is not, jump to 'Right1'.
cmp bh, 0
jne Right1

mov bh, 79										; If there is a match, move the smiley's column to 79, which matches
ret												; the corresponding right gate (21, 79).

Right1:											; The code for the first gate on the rightmost wall (5, 79).
cmp ah, 5										; Check to see if the smiley's row and column are (5, 79).
jne Right2										; If one is not, jump to 'Right2'.
cmp bh, 79
jne Right2

mov bh, 0										; If there is a match, move the smiley's column to 0, which
ret												; is the corresponding left gate (5, 0).

Right2:											; The code for the second gate on the rightmost wall (21, 79).
cmp ah, 21										; Check to see if the smiley's row and column are (21, 79). If 
jne Bottom1										; one is not, jump to 'Bottom1'.
cmp bh, 79
jne Bottom1

mov bh, 0										; If there is a match, move the smiley's column to 0, which matches
ret												; the corresponding left gate (21, 0).

Bottom1:										; The code for the left of the bottom gate (24, 39).
cmp ah, 25										; Check to see if the smiley's row and column match (24, 39). If
jne QuitCheck									; the row does not match, there is no gate at the current location.
cmp bh, 39										; Jump to 'QuitCheck'. If the row matches but the column does not,
jne Bottom2										; jump to 'Bottom2'.

mov ah, 0										; If there is a match, move the smiley's row to 0, which will 
ret												; match the corresponding top gate (0, 39).

Bottom2:										; The code for the right of the bottom gate (24, 40).
cmp bh, 40										; Check to see if the smiley's column is 40. If it is not,
jne QuitCheck									; there is no gate at the current location. Jump to 'QuitCheck'.

mov ah, 0										; If there is a match, move the smiley's row to 0. This
ret												; matches the corresponding top gate (0, 40).

QuitCheck:										; This label simply returns to the calling routine.
ret
checkForGates ENDP

; Clears the screen below the scores(the first 3 rows). 
; Calls a procedure to print the win message.
; Sets cursor at row number '5' and terminates the program.
clearScreen PROC
	mov SaveECX, ecx									; 'SaveECX' will save the current value of ECX.
	mov row, 2											; The loop starts at the third row, so row = 2.
	mov ecx, 23											; The outer loop will only run 23 times because of the scores at the top.
	setCursor row, col									; Sets the cursor to its initial position at row 3.
	
	; The outer loop increments the row count when
	; every column in each row has been cleared.
 Outer:
	push ecx											; Pushes the value of ECX (containing the amount of rows) in order
	mov ecx, 80											; to put in it the loop counter for the column loop below (Inner).
	mov col, 0											; Reset the column number for every iteration of the Inner loop.
	
	; The inner loop will first check if the Outer loop
	; is on the last row. If so, jump to 'lastRow', if not,
	; put a space in the current location on the screen (by
	; using the 'printCharAt' macro), increment the column
	; number, and loop again.
 Inner:
	printCharAt 0, row, col								
 	inc col												
	loop Inner
	pop ecx
	
	inc row
	loop Outer
	
	mov ecx, SaveECX
	call printWinMessage								; Call the procedure to print the win message.
	setCursor 5, 0										; place the cursor back at row 3.
	exit
clearScreen ENDP

;;;;;;Extra Credit?;;;;;;
; Checks to see if a majority of the pellets have
; been scored by one player. Compares both scores
; to 269 to determine this, since 269 is the number
; needed to win.
checkForWin PROC
	cmp redScore, 269									; If the red score hits 269, it wins!
	je Win												; Jump to 'Win'.

	cmp blueScore, 269									; If the blue score hits 269, it wins!
	je Win												; Jump to 'Win'.
	
	ret													; If there is no winner, return.

Win:													; If there is a winner, call clearScreen. 
	call clearScreen									; The program will be terminated there.
checkForWin ENDP

;;;;;;Extra Credit?;;;;;;
; Prints a message after the majority of 
; pellets have been scored, informing the user(s)
; of the winner. This is printed after the clearScreen procedure.
printWinMessage PROC
pushAD

mov eax, redScore										; If the game is quit before the majority of pellets
cmp eax, blueScore										; have been scored, this determines the winner.
jg redWins												; If the redScore is less than the blueScore,
														; jump to 'redWins'.

cmp eax, blueScore										; If it is less, jump to 'blueWins'.
jl blueWins

cmp eax, blueScore										; If they are equal, jump to 'Tie'.
je Tie

redWins:
setCursor 3, 28											; Set the cursor to center the message
setColor blue, green									; Reset the colors to blue-on-green
mov edx, offset redMsg									; Move win message into EDX
call WriteString										; Write message
jmp Bottom

blueWins:
setCursor 3, 27											; Set the cursor to center the message
setColor blue, green									; Reset the colors to blue-on-green
mov edx, offset blueMsg									; Move win message into EDX
call WriteString										; Write message
jmp Bottom

Tie:
setCursor 3, 33											; Set the cursor to center the message
setColor blue, green									; Reset the colors to blue-on-green
mov edx, offset tieMsg									; Move win message into EDX
call WriteString										; Write message
jmp Bottom

Bottom:													; The label to jump to after the message has been printed.
	popAD												; Pop all registers and return.
	ret
printWinMessage ENDP
END main