	
	; Macros for Stephen Finney's Smiley Two
	
	SetCursor Macro r, c						; Takes the passed-in parameters
	push dx										; for the desired row and column on the screen,
	mov dh, r									; and places the cursor at that location using
	mov dl, c									; the 'GoToXY' procedure.
	call GoToXY
	pop dx
	ENDM
	
	GetPosition Macro row, col					; Finds the linear position in memory on the screen.
	push eax									; It's passed in a row and column for the position.
	push ebx									; Uses ESI to hold the final position.
	push edx									; Pushes and pops all used registers except ESI.
	
	mov al, row									; Move the row to AL.
	mov dl, 80									; Move the number of characters (80) on the screen to DL to get its position.
	mul dl										; Multiply AL and DL to get the linear character position 
												; (row only) on the screen, which is then stored in EAX.
	
	mov esi, offset maze						; ESI holds the complete location. (i.e. the attempted new position 
												; of the smiley in the program).
	add esi, eax								; Put the maze's offset in ESI and add the multiplied value above to it.
	movzx ebx, col								; Move the column number into EBX.
	add esi, ebx								; Add that number to the final position in ESI.	
	pop eax
	pop ebx
	pop edx
	ENDM
	
	CheckForRedMove Macro						; This macro will compare a pressed key(passed in through 
	inc up										; the AH register) to a certain regular (not extended) key 
	cmp al, '8'									; whose character code is passed in as 'key'. It will jump 
	je MoveRedNow								; to the label that calls 'MoveRed' if the key is identical 
	dec up										; to the pressed key, or will do nothing if it is not.
	
	inc down									; Each time a compare is done, the direction's variable
	cmp al, '2'									; is incremented just in case there is a match. If there
	je MoveRedNow								; is no match, the variable is decremented back to '0'.
	dec down
	
	inc left
	cmp al, '4'
	je MoveRedNow
	dec left
	
	inc right
	cmp al, '6'
	je MoveRedNow
	dec right
	ENDM
	
	CheckForBlueMove Macro						; This macro will check the pressed key for a blue smiley move.
	cmp al, 0									; First, it checks to see if the key is an extended key (like
	jne Top										; an arrow key). If it is not, it jumps back to 'Top'. 
	
	inc up										; If so, it checks each arrow key code for a match. 
	cmp ah, 48h									; Each key's corresponding direction variable is incremented.
	je MoveBlueNow								; If a match is found on a key, it jumps to 'MoveBlue'. Else, the														
	dec up										; the direction key is reset back to normal. This happens for each arrow
												; key code.														
	inc down
	cmp ah, 50h
	je MoveBlueNow
	dec down
	
	inc left
	cmp ah, 4Bh
	je MoveBlueNow
	dec left
	
	inc right
	cmp ah, 4Dh
	je MoveBlueNow								; No decrement is needed if the key isn't the right arrow key, because
												; the program returns to 'Top' where the direction variables are reset.
	ENDM				

	TestForSmiley Macro row1, col1, row2, col2	; Tests the rows and columns of two different smiley positions to	
	pushAD										; see if they are the same. If so, sets the 'smileyCollision' variable to 1.	
												; Pushes and pops all registers.									
	movzx eax, row1								
	movzx ebx, row2
	cmp eax, ebx								
	jne @f
	
	movzx eax, col1
	movzx ebx, col2
	cmp eax, ebx
	jne @f
	
	mov smileyCollision, 1
	
@@:												; A local label. Since this macro is used many times, this label is
	popAD										; needed more than once. The '@f' above is the command to jump to
	ENDM										; the closest forward '@@' label.									
	
	ClearDirections Macro						; Clears the value of each of the variables that determine the
	mov up, 0									; direction of a smiley's move. This is used after every key press, near
	mov down, 0									; the 'Top' label.
	mov left, 0
	mov right, 0
	ENDM															
													
	Print Macro msg								; Prints the passed-in message 'msg'
	push edx									; using the 'WriteString' procedure.
	mov edx, offset msg
	call WriteString
	pop edx
	ENDM
	
	SetColor Macro foreColor, backColor			; Sets the foreground and background colors for the
	push eax									; screen using the parameters for the color's respective
	mov eax, foreColor							; codes. Utilizes the 'SetTextColor' procedure to actually
	add eax, backColor * 16						; set the colors.
	call SetTextColor
	pop eax
	ENDM
	
	PrintChar Macro character					; This macro prints the passed-in character code
	push ax										; at the current position on the screen using the
	mov al, character							; 'WriteChar' procedure.
	call WriteChar
	pop ax
	ENDM
	
	PrintCharAt Macro character, row, col		; Prints a character at a certain x, y location on the screen. 
	SetCursor row, col							; Both the character and the position are passed in as parameters.
	PrintChar character
	ENDM