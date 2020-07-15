TITLE LOW LEVEL PROCEDURES     (lindmax_program_6.asm)

; Author: Max Lind
; OSU email address: lindmax@oregonstate.edu
; Course number/section: CS 271 - 400
; Project Number: Programming Assignment #6            
; Due Date: 06/07/2020 
; Description: This program will create two procedures for both reading and writing signed integers. It will prompt the user for 10 strings, the readVal procedure will take those strings and convert them
;			   to intgers and store in an array. The arrLoop procedure will loop through that array of integers and call the writeVal procedure to display those integers as strings again. the arrLoop
;				procedure will also calculate the sum and average and agai nutilize writeVal to display those integers as strings.

INCLUDE Irvine32.inc

displayString MACRO string_address
	push	edx
	mov		edx, string_address
	call	WriteString
	pop		edx
ENDM

getString MACRO usr_prompt, entered_string
	push	ecx
	push	edx
	mov		edx, usr_prompt
	call	WriteString
	mov		edx, entered_string
	mov		ecx, 25
	call	ReadString
	pop		edx
	pop		ecx
ENDM

.data
; Displays
prog_title		BYTE		"Program 6: Designing Low-Level I/O Procedures", 0
author			BYTE		"Programmed by: Max Lind", 0
instruction		BYTE		"Please provide 10 signed decimal integers.", 0
int_req			BYTE		"Each number must be small enough to fit inside a 32 bit register.", 0
description		BYTE		"After all 10 numbers have been entered, a list will be displayed with their sum and average.", 0
prompt_usr		BYTE		"Please enter a signed number: ", 0
err_msg			BYTE		"ERROR: Number is outside of 32 bit range or not a signed integer", 0
nums_msg		BYTE		"You entered the following numbers: ", 0
sum_msg			BYTE		"The sum of these numbers is: ", 0
avg_msg			BYTE		"The rounded average is: ", 0

; Variables
store_string	BYTE		50 DUP (?)
user_array		BYTE		10 DUP (?)
user_num		SDWORD		0
num_array		SDWORD		10 DUP (?)
pos_neg			DWORD		0
store_num		SDWORD		0
final_num		SDWORD		0
count			DWORD		10
sum				DWORD		?
avg				DWORD		?
back_str		BYTE		10 DUP (?)
for_str			BYTE		10 DUP (?)
digits			DWORD		0
curr_num		DWORD		?

.code
main PROC	

	push OFFSET prog_title
	push OFFSET author
	push OFFSET instruction
	push OFFSET int_req
	push OFFSET description
	call introduction

	push digits
	push final_num
	push OFFSET num_array
	push OFFSET store_string
	push OFFSET user_array
	push user_num
	push pos_neg
	push store_num
	push OFFSET prompt_usr
	push OFFSET err_msg
	push count
	call readVal

	push digits
	push pos_neg
	push OFFSET for_str
	push OFFSET back_str
	push curr_num
	push avg
	push OFFSET avg_msg
	push OFFSET sum_msg
	push OFFSET nums_msg
	push sum
	push count
	push OFFSET num_array
	call arrLoop

	exit	; exit to operating system
main ENDP



; Procedure to display introduction, which includes the title, programmer name, and program instructions
; receives: 
;	[ebp + 24] = program title
;	[ebp + 20] = author
;	[ebp + 16] = instructions
;	[ebp + 12] = requirements
;	[ebp + 8] = description
; returns: outputs title and desciption to user
; preconditions: none
; registers changed: none
introduction PROC
	push	ebp
	mov		ebp, esp

	displayString [ebp + 24]

	call	Crlf

	displayString [ebp + 20]

	call	Crlf
	call	Crlf

	displayString [ebp + 16]
	call	Crlf
	displayString [ebp + 12]
	call	Crlf
	displayString [ebp + 8]

	call	Crlf
	call	Crlf

	pop		ebp
	ret		4
introduction ENDP


; Procedure to prompt user for 10 strings, convert strings to signed integers and store in an array. 
; The procedure will validate that the strings are numbers and whether they are within the 32 bit signed range
; receives:
;		count = [ebp + 8]
;		err_msg = [ebp + 12]
;		prompt_usr = [ebp + 16]
;		store_num = [ebp + 20]
;		pos_neg = [ebp + 24]
;		user_num = [ebp + 28]
;		user_array = [ebp + 32]
;		store_string = [ebp + 36]
;		num_array = [ebp + 40]
;		digits = [ebp + 44]
; returns: an array with 10 integers
; preconditions: none
; registers changed: edi, esi, ecx, eax, ebx, al


readVal PROC
	push	ebp
	mov		ebp, esp

	mov		edi, [ebp + 40]							; sets edi to the array to store integers
	mov		ecx, [ebp + 8]
	jmp		L1
error:												; block to handle errors
	displayString [ebp + 12]
	
	mov		eax, 0
	mov		[ebp + 28], eax							; resets current number to 0
	mov		ecx, [ebp + 8]							; resets the loop counter
	
	call	Crlf
	jmp		L1
negative:											; turns digit into negative based on value in pos_neg. 1 Being negative and 0 being positive
	mov		eax, [ebp + 24]
	add		eax, 1
	mov		[ebp + 24], eax
	sub		ecx, 1
	jmp		L2

positive:											; if positive sign is in front of number decrement loop counter and get next digit
	sub		ecx, 1
	jmp		L2

subtract:											; subtracts digit from 0 if negative
	
	mov		eax, 0
	sub		eax, [ebp + 28]
	mov		[ebp + 28], eax
	mov		ebx, 0
	mov		[ebp + 24], ebx
	jmp		store
addition:											; adds digit to 0 if positive
	
	mov		eax, 0
	add		eax, [ebp + 28]
	mov		[ebp + 28], eax
	jmp		store

check_over:											; checks the 32 bit range
	add		eax, [ebp + 20]
	jo		error
	sub		eax, [ebp + 20]
	cmp		ecx, 10									; checks if number is greater than 10 digits (max number of digits for 32 bit range)
	jg		error
	jmp		return_over

check_dig:											; checks that the string is a string of digits
	cmp		al, 48
	jl		error
	cmp		al, 57
	jg		error
	jmp		return_dig

L1:
	mov		[ebp + 8], ecx
	getString [ebp + 16], [ebp + 36]
	mov		edx, [ebp + 36]							; get string from user, move the length of the string into loop counter, set esi to address of string
	mov		ecx, eax		
	mov		esi, edx								
	cld
L2:
	
	lodsb											; load next byte in string and move byte into al
	cmp		al, 45									; check for positive or negative signs and 
	je		negative								; for negative and positive subtract ecx by 1 and return to L2. For negative, set pos_neg to 1 to indicate that it is negative
	cmp		al, 43
	je		positive
	jmp		check_dig
return_dig:
	sub		al, 48									; converts string digit from ASCII number to it's respective digit
	mov		[ebp + 20], al

	mov		eax, [ebp + 28]
	mov		ebx, 10									; multiplies integer by 10 
	imul	ebx
	jmp		check_over
return_over:
	add		eax, [ebp + 20]							; adds next integer
	mov		[ebp + 28], eax
	loop	L2
	mov		ebx, [ebp + 24]
	cmp		ebx,  1
	je		subtract
	jmp		addition
store:												; stores the number in the array after all checks have been completed
	mov		eax, [ebp + 28]
	stosd
	mov		eax, 0
	mov		[ebp + 28], eax
	
	mov		ecx, [ebp + 8]
	
	loop	L1										; remprompts user for next string
	
	pop		ebp
	ret		4	
readVal ENDP


; Procedure loops through array of numbers and show prompts. Procedure makes calls to writeVal to convert and display, calculates sum and average and display those as well
; receives: 
;		num_array [ebp + 8]
;		count = [ebp + 12]
;		sum = [ebp  + 16]
;		nums_msg = [ebp + 20]
;		sum_msg = [ebp + 24]
;		avg = [ebp + 32]
;		curr_num = [ebp + 36]
;		back_str = [ebp + 40]
;		for_str = [ebp + 44]
;		digits = [ebp + 48]
;		pos_neg = [ebp + 52]
; returns: Displays messages to user
; preconditions: none
; registers changed: eax, esi, ebx, edx

arrLoop PROC
	push	ebp
	mov		ebp, esp
	call	Crlf
	displayString [ebp + 20]			
	mov		esi, [ebp + 8]						; sets integer array to esi
	mov		ecx, [ebp + 12]						; loop counter to number of integers being entered
	cld
L3:
	lodsd


	add		[ebp + 16], eax						; adds current integer to sum
	mov		[ebp + 36], eax						; sets current integer


	push	[ebp + 52]
	push	[ebp + 48]
	push	[ebp + 44]
	push	[ebp + 40]
	push	[ebp + 36]
	call	writeVal							; pushes on the stack the necessary variables to convert numbers in array back to string and display

	loop	L3									; get next number in array

	call	Crlf
	call	Crlf

	displayString [ebp + 24]			
	
	push	[ebp + 52]
	push	[ebp + 48]
	push	[ebp + 44]
	push	[ebp + 40]
	push	[ebp + 16]
	call writeVal								; pushes on the stack the necessary variables to convert the sum to a string and display

	call	Crlf
	call	Crlf

												; calculate average
	mov		edx, 0
	mov		eax, [ebp + 16]
	mov		ebx, [ebp + 12]
	idiv	ebx
	mov		[ebp + 32], eax
	
	displayString [ebp + 28]

	push	[ebp + 52]
	push	[ebp + 48]
	push	[ebp + 44]
	push	[ebp + 40]
	push	[ebp + 32]
	call	writeVal							; pushes on the stack the necessary variables to convert the average to a string and display

	call	Crlf
	pop		ebp
	ret		48
arrLoop ENDP


; Procedure to convert integers to strings and display them
; receives:
;		[ebp + 8] = curr_num for array display
;		[ebp + 8] = sum to display sum
;		[ebp + 8] = avg to display avg
;		[ebp + 12] = backwards string
;		[ebp + 16] = forward string
;		[ebp + 20] = digits
;		[ebp + 24] = pos_neg
; returns: displays desireed integers as strings
; preconditions: none
; registers changes: edi, esi, ecx, eax, ebx, edx, al, dl

writeVal PROC
	push	ebp
	mov		ebp, esp
	push	ecx								; save loop counter
	push	esi								; save initial address 
	push	eax								; save intitial number
	mov		edi, [ebp + 12]					; move backward string to destination pointer
	cld
	mov		eax, [ebp + 8]					; move number to eax
	cmp		eax, 0
	jl		negate							; negate if negative so as not to display two's compliment
	jmp		L4
negate:
	neg		eax
	mov		[ebp + 8], eax
	mov		edx, 1
	mov		[ebp + 24], edx					; set pos_neg to 1 to indicate it is negative
L4:
	mov		eax, 1
	add		[ebp + 20], eax					; inc digits and divide number by 10
	mov		eax, [ebp + 8]
	mov		edx, 0
	mov		ebx, 10
	idiv	ebx
	cmp		eax, 0							; compare value in eax to 0 to indicate we have reached final digit
	je		int_done
	mov		[ebp + 8], eax					; set new curr_num so when looping the quotient gets divided again
	add		dl, 48
	mov		al, dl
	stosb									; store remainder in backwards array
	
	jmp		L4
int_done:
	add		dl, 48							; store final remainder in 
	mov		al, dl
	stosb

	mov		esi, [ebp + 12]					; set esi to backwards string
	add		esi, [ebp + 20]					; add to esi the number of digits and subtract 1 for null byte
	sub		esi, 1
	mov		edi, [ebp + 16]					; set edi to forward string
	mov		ecx, [ebp + 20]					; set ecx to number of digits

	mov		eax, [ebp + 24]					; check if number is negative and add negativesign if so
	cmp		eax, 1
	je		add_sign
	jmp		L5
add_sign:
	mov		al, 45							
	stosb
L5:
	std										; set the direction flag to move backwards through our string and load the number into eax
	lodsb
	cld										; clear direction flag to sore number in forwards string
	stosb
	loop	L5								; since initial array is backwards we go to the end and store the each byte in backwards order to display forwards to user


	mov		al, 32							; add a space to end of string
	stosb
	mov		al, 0							; add null terminating byte
	stosb

	displayString [ebp + 16]				; display intege as string

	pop		eax
	pop		esi
	pop		ecx
	pop		ebp
	ret		20
writeVal ENDP

END main