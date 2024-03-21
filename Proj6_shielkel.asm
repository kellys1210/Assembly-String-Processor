TITLE Project 6    (Proj6_shielkel.asm)

; Author: Kelly Shields
; Last Modified: 03/06/2024
; OSU email address: shielkel@oregonstate.edu
; Course number/section: CS271 Section 402
; Project Number:  6   Due Date: 03/17/2024
; Description: 

; This program will implement two macros for string processing; one to receive strings of signed decimal integers from the user as input, 
; and one to display strings of signed decimal integers as output. This program contains several procedures which will invoke these macros.
; One procedure will collect the 10 signed decimal integer strings, convert to their numeric representation, and perform validation on these 
; values to ensure they fit within a 32-bit register.
;Another procedure will then convert these numeric representations back to ASCII value in order to display them back to the user.
; Also contains procedures to calculate the sum and the truncated average of the numeric representation, which too will be displayed to the user
; in their ascii form.


INCLUDE Irvine32.inc

; --- Name: mGetString ---
; Allows user inputs to be collected; prompts user to enter using WriteString, collects input (as strings) using ReadString,
; stores string value and size of string in memory offsets. Invoked by ReadVal to collect 10 integers from user.
; Preconditions: Prompt strings offset pushed in calling procedure as well as offsets to hold inputNumber, byteCount, and bufferSize
; Receives: 
; - promptString - holds offset for prompt
; - stringSize - offset for byteCount
; - inputNum - offset for userInput
; - buffSize - value for bufferSize  (12)
; Returns: edx to inputNum, eax to byteCount
; -------------------------------

mGetString MACRO promptString:REQ, stringSize:REQ, inputNum:REQ, buffSize: REQ

	pushad

	; display prompt and allow user to enter number
	call crlf
	mov  edx, promptString
	call writestring  
	mov  edx, inputNum
	mov  ecx, bufferSize
	call readstring 
	
	; Move size of string to memory location (# of bytes). ReadString returns size in EAX
	mov   ebx, stringSize
	mov  [ebx], eax

	popad

ENDM


; --- Name: mDisplayString ---
; Allows strings to be displayed to console using WriteString
; Preconditions: memory offsets for all strings pushed to calling parameter and stored in register, same register used in macro invocation
; Receives: 
; - outputString: holds offset for display strings
; -------------------------------
mDisplayString MACRO outputString:REQ
	push edx
	mov  edx, outputString
	call writestring
	pop  edx
ENDM


; Min/Max numbers that will fit into 32-bit register.
MIN_VALUE  =  2147483648   
MAX_VALUE  =  2147483647
ARRAY_SIZE =  10

.data

; Intro and instructions
programName        BYTE    "Designing, Implementing, and Calling Low-Level I/O Procedures and Macros", 0
programAuthor      BYTE	   " By Kelly Shields", 13, 10, 13, 10, 0
instructions1      BYTE    "Please provide 10 signed decimal integers.", 13, 10, 13, 10, 0
instructions2      BYTE	   "Each number provided must be small enough to fit inside a 32-bit register. Once you have completed this,"
				   BYTE    " I will show you a list of your integers, their sum, and their average value. ", 13, 10, 0

; Prompts
prompt             BYTE    "Please enter a signed number: ", 0
errorMsg           BYTE	   "ERROR: The number you have entered is either unsigned, too big, or nothing was entered. Please try again.", 0

; User input
userInput          BYTE     13 DUP (?)            ; Will hold the string of integers input by user
bufferSize         DWORD    13
byteCount          DWORD    ? 
sign               DWORD    0                     ; Set to 1 if negative, 0 if positive


; Calculations
avgNum			   SDWORD   ?
sumNum             SDWORD   0

; Conversions
convertedNum       SDWORD   0
numArray           SDWORD   ARRAY_SIZE DUP (?)   
stringArray        BYTE     13 DUP (?)           
revStringArray     BYTE     13 DUP (?)

; Display
displayEnteredNums BYTE    "You entered the following numbers:", 13, 10, 0
displaySum         BYTE	   "The sum of the numbers you entered is: ", 13, 10, 0
displayAvg         BYTE	   "The truncated average of the numbers you entered is: ", 13, 10, 0
spacer             BYTE    " ", 0
negSign            BYTE    "-", 0

; Exit
goodbyeDisplay     BYTE	   "Thank you for playing! Goodbye!", 13, 10, 0


.code
main PROC

	; call intro
	push  offset programName
	push  offset programAuthor
	push  offset instructions1
	push  offset instructions2
	call  introduction

	; call readVal
	mov   edi, offset NumArray
	mov   ecx, ARRAY_SIZE          ; ARRAY_SIZE = 10, loops to generate 10 inputs
_loopreadVal:
	push  offset prompt
	push  offset byteCount
	push  offset userInput
	push  bufferSize        
	push  edi             
	push  offset sign
	push  offset convertedNum
	push  offset errorMsg
	call  readval
	add   edi, 4		           ; increments numArray
	mov   sign, 0                  ; resets sign bit
	loop  _loopreadVal

	; call numSumAvg
	push offset numArray
	push offset sumNum
	push offset avgNum
	call numSumAvg

	call crlf

	; display displayEnteredNums message
	mDisplayString offset displayEnteredNums

	; call writeVal for: displaying full list of integers as strings
	mov   esi, offset numArray
	push  [esi]
	mov   ecx, ARRAY_SIZE
_loopWriteVal:
	push  offset stringArray
	push  offset sign
	push  offset revStringArray
	push  offset negSign
	call  writeval
	add   esi, 4                     ; increments numArray
	mDisplayString offset spacer
	mov   sign, 0                    ; resets sign
	loop _loopWriteVal

	call  crlf
	call  crlf

	; display displaySum message
	mDisplayString offset displaySum

	; call writeVal for: displaying sum
	mov   esi, offset sumNum
	push  esi
	push  offset stringArray
	push  offset sign
	push  offset revStringArray
	push  offset negSign
	call  writeval

	call  crlf
	call  crlf

	; display displayAvg message
	mDisplayString offset displayAvg

	; call writeVal for: displaying avg
	mov   esi, offset avgNum
	push  esi
	push  offset stringArray
	push  offset sign
	push  offset revStringArray
	push  offset negSign
	call  writeval

	call  crlf

	; call goodbye
	push  offset goodbyeDisplay
	call  goodbye

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; -- introduction --
; Procedure to introduce user to program and display instructions. Invokes mDisplayString macro to display all information to console.
; preconditions: programName, programAuthor, instructions1 and instructions2 all strings created in data label,
; pushed to stack by memory offsets. mDisplayString macro in place to display all messages to console.
; receives: 
;	programName offset   : [ebp + 20]
;	programAuthor offset : [ebp + 16]
;	instructions1  ofset : [ebp + 12]
;	instructions2 offset : [ebp + 8]
; -------------------------------
introduction PROC
	push           ebp
	mov            ebp, esp
	pushad

	mDisplayString [ebp + 20]   ; programName
	mDisplayString [ebp + 16]   ; programAuthor
	mDisplayString [ebp + 12]   ; instructions1
	mDisplayString [ebp + 8]    ; instructions2

	popad
	pop            ebp
	ret            16
introduction ENDP

; -- readVal --
; Procedure to collect a string of signed integers from user (via invoking mGetString), validates to check if string contains a +/-, is empty,
; contains any non-digits, or will fit into a 32-bit register. Displays error message (via invoking mDisplayString) if invalid. Then converts
; all ascii characters to their numeric form, contains them in a variable convertedNum, and adds them to numArray. This procedure will loop
; 10 times through main to gain 10 inputs from user.
; preconditions: Offsets for prompt, byteCount, userInput, bufferSize, numArray (which is moved to ESI in main), sign, convertedNum, and 
; errorMsg pushed in main. User input must be collected via invoking mGetString where it is stored into userInput. ARRAY_SIZE (10) used as loop
; counter and moved in ECX in main. numArray moved into ESI in main, ESI incremented before loop in order to properly store nums in array. Sign 
; bit reset to 0 in ebx in main for each loop.
; postconditions: numArray contains 10 signed integers, all registers restored before return
; receives: 
;	prompt offset:       [ebp + 36]
;   byteCount offset:    [ebp + 32]
;	userInput offset :   [ebp + 28]
;	bufferSize value:    [ebp + 24]
;	numArray offset:     [ebp + 20]
;   sign offset:         [ebp + 16]
;   convertedNum offset: [ebp + 12]
;   errorMsg offset:     [ebp + 8]
; returns: numArray with 10 signed integers 
; -------------------------------
readVal PROC
	push   ebp
	mov    ebp,  esp
	pushad
	mov    ebx, [ebp + 16]   ; sign
	mov    edx, [ebp + 12]   ; convertedNum
	mov    edx, [edx]
	mov    eax, 0            ; clears out EAX 

_getInput:
	; invokes mGetString to collect number from user. Sends prompt, byteCount, userInput, and bufferSize as arguments
	mGetString [ebp + 36], [ebp + 32], [ebp + 28], [ebp + 24]

	; begin number validation
	mov  ecx, [ebp + 32]     ; byteCount
	mov  ecx, [ecx]
	cld 

	; loads first byte into AL
	mov  esi, [ebp + 28] ; userInput string
	lodsb

	; compares AL to + (43) and - (45) to determine sign. If neither, jumps to validate if it is a valid digit
	cmp   al, 43
	je    _makePos			 
	cmp   al, 45
	je    _makeNeg
	jmp   _validateDigit     

_makePos:					     ; if symbol is 43, num is positive, changes sign variable to pos (0)
	push  edx
	mov   ebx,   0
	mov   edx,   [ebp + 16]      ; sign
	mov   [edx], ebx
	pop   edx
	loop  _loadNextByte

_makeNeg:					     ; if symbol is 45, num is negative, changes sign variable to neg (1)
	push  edx
	mov   ebx,   1
	mov   edx,   [ebp + 16]      ; sign
	mov   [edx], ebx
	pop   edx
	loop  _loadNextByte

_loadNextByte:
	mov   eax, 0                 ; clears register to not interfere with AL values
	lodsb					    
		
	cmp   ecx, 0
	je    _endOfString		     ; ECX reaches 0 when end of string is reached


	; checks against ascii values to determine if input is a digit or symbol
_validateDigit:
	cmp   al, 57
	ja    _invalidChar
	cmp   al, 48
	jb    _invalidChar

	; converts ascii value to numeric, adds to convertedNum to get final numeric integer. convertedNum intialized to 0;
	; convertedNum * 10 + (user input number - 48), accumulates in convertedNum until end of string is reached
	sub   eax, 48
	push  eax
	mov   eax, edx             ; edx: convertedNum
	mov   ebx, 10
	mul   ebx  
	mov   ebx, eax
	pop   eax
	add   eax, ebx
	add   edx, eax
	loop  _loadNextByte
	jmp   _endOfString
	
_invalidChar:
	call  crlf
	mDisplayString [ebp + 8]  ; errorMsg, displays error message if invalid character or no character is entered
	jmp _getInput

	
_endOfString:
	; check sign, make neg if necessary. MIN_VALUE is set as positive and neg number is checked against that before making number neg, 
	; as changing my number to neg and then checking against was causing the value to seem too large to fit, if that makes sense! 
	mov  ebx, [ebp + 16] ; sign
	mov  ebx, [ebx]
	cmp  ebx, 1
	jne  _checkMax
	cmp  edx, MIN_VALUE
	ja   _invalidChar  
	neg  edx
	jmp  _addToArray
	
_checkMax:
	; to ensure pos num fits in 32-bit register
	cmp  edx, MAX_VALUE
	ja   _invalidChar

_addToArray:
	; add to numArray
	mov  [edi], edx

	popad
	pop  ebp
	ret  32

readVal ENDP

; -- writeVal --
; Procedure to receive signed integers from numArray (passed by value, one by one). Each integer is converted to its ASCII form and placed
; into a string array. mDisplayString is invoked on each string. Will be called to display all integers entered by user, the sum, and the
; of those numbers.
; preconditions: EDX cleared to 0 for mul, numArray, sumNum and AvnNum values moved to esi and pushed on stack, stringArray, sign, revString
; Array, negSign offsets all created, registers preserved as all registers used for this procedure, sign variable cleared prior to evaluating
; parity of integer from numarray,  ECX preserved prior to beginning ascii conversion loop
; postconditions: revStringArray contains reverse of stringArray
; receives:
;	- numArray/sumNum/AvgNum by value in ESI
;	- stringArry offset:     [ebp +20]
;	- sign offset:           [ebp +16]
;	- revStringArray offset: [ebp + 12]
;	- negSign offset:       [ebp + 18]
; returns: revStringArray with reverse of stringArray
; -------------------------------
writeVal PROC

	push   ebp
	mov    ebp, esp
	pushad

	mov  eax, 0             ; clear eax
	mov  edi, [ebp + 20]    ; stringArray
	mov  eax, [esi] 
	mov  ebx, 0             ; clears sign variable

	; check if neg or pos - move 1 to sign if neg
	cmp  eax, 0
	js   _negative

	push ecx
	mov  ecx, 0            ; preserves ECX and clears for ascii conversion loop

	; convert to ascii by dividing integer by 10 and storing remainder in string until quotient becomes 0, increments ecx
	; each jump to be used as string length counter, loads into string array in reverse order
_convertAscii:
	cmp  eax, 0
	je   _reverseString
	mov  edx, 0
	mov  ebx, 10
	div  ebx
	push eax
	mov  al, dl           ; moves remainder into AL, adding 'O' turns type from int to char
	add  al, '0' 

	cld
	stosb
	pop   eax
	inc   ecx
	jmp   _convertAscii

_reverseString:
    push esi			  ; to preserve numArray/sumNum/avgNum
	mov  esi, [ebp + 20]  ; stringArray
	add  esi, ecx		  ; ecx = # of characters in string; adding to esi moves pointer to end of string
	inc  ecx
	dec  esi			  ; removes null terminator 
	mov  edi, [ebp + 12]  ; revStringArray

_reverseLoop:				
	std
	lodsb
	cld
	stosb				  ; stores characters in revStringArray
	loop _reverseLoop

	pop esi
	pop ecx

	; check sign variable to parity; if positive, displays string to console
	mov ebx, [ebp + 16]  ; sign
	mov ebx, [ebx]
	cmp ebx, 1
	je  _printNeg
	
	mDisplayString [ebp + 12]
	jmp _retWriteVal

	; prints '-' prior to printing string
_printNeg:
	mDisplayString [ebp + 8]
	mDisplayString [ebp + 12]
	jmp _retWriteVal

	; turns negative integers back to positive, turns sign to 1 so '-' can be added during display
_negative:
	neg   eax               
	push  edx
	mov   ebx,  1
	mov   edx,  [ebp + 16]     ; sign
	mov   [edx], ebx
	pop   edx
	push  ecx
	mov   ecx, 0
	jmp   _convertAscii

_retWriteVal:

	popad
	pop   ebp
	ret   20

writeVal ENDP


; -- numSumAvg --
; Procedure to calculate sum of all signed integers in numArray, then uses sum to find truncated average of nums in numArray
; preconditions: x10 signed integers converted to numeric form and moved into numArray. Offset for numArray pushed onto stack. EAX must be
; sign extended into EDX for IDIV. 
; Variable created for numSum and avgSum and initialized to 0, offsets pushed to stack.
; postconditions: All registers restored
; receives: 
;	numArray offet: [ebp + 16]
;	numSum offset : [ebp + 12]
;   avgNum offset : [ebp + 8]
; returns: sumNum, avgNum
; -------------------------------
numSumAvg PROC

	push   ebp
	mov    ebp, esp
	pushad

	mov ecx, ARRAY_SIZE   ; 10
	mov eax, [ebp + 12]   ; sumNum
	mov eax, [eax]
	mov esi, [ebp + 16]

	; Calculate sum, move sum to sumNum
_sumLoop:
	add   eax, [esi]
	add   esi,  4
	loop  _sumLoop

	mov   ebx,  [ebp + 12]  ; sumNum
	mov  [ebx], eax

	; Calculate average (truncated), move avg to avgNum
	cdq
	mov   ebx,  2
	idiv  ebx
	mov   ebx, [ebp + 8]  ; avgNum
	mov  [ebx], eax


	popad
	pop ebp
	ret 12

numSumAvg ENDP


; -- goodbye --
; Procedure to display goodbye message to user to signal end of program. Invokes mDisplayString macro to display message to console.
; preconditions: goodbyeDisplay created as a string in data label and memory offset pushed to stack. mDisplayString macro in place, to
; be invoked to display message to console.
; postconditions: EDX changed.
; receives: goodbyeDisplay memory offset

; -------------------------------
goodbye PROC
	push     ebp
	mov      ebp, esp
	push     edx
	mov      edx, [ebp + 8]  ; goodbyeDisplay
	call     crlf
	mDisplayString edx

	pop      edx
	pop      ebp
	ret      4
goodbye ENDP

END main
