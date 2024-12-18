.MODEL small
.STACK 100h
.DATA
    inputFileName db "input.txt",0      ; Input file name (null-terminated)
	outputFileName db "output.txt", 0     ; output file
    buffer db 1000 dup(0)               ; Buffer to store file content
    tempBuffer db 1000 dup(0)           ; Temporary buffer to hold current line's content
    buffer1 db 1000 dup(0)              ; Buffer 1 to store specific content
    buffer2 db 1000 dup(0)              ; Buffer 2 to store other content
    bytesRead dw 0                      ; Number of bytes read
    lineFeedCount dw 0                  ; Count of line feeds (0Ah)
    var1 dw 2                          ; Target line count for buffer1
    var2 dw 5                           ; Target line count for buffer2
    tempIndex dw 0                      ; Index for tempBuffer
    bufferIndex dw 0                    ; General buffer index for copying lines
	fileErrorMessage db "ERROR",0
	outputFileHandle dw ?
	tempByte db 0  ; Temporary storage for one byte
	count dw 0


.CODE
print_line PROC
    mov lineFeedCount, 0      ; Reset the line feed counter
    mov bufferIndex, 0        ; Reset general buffer index
	mov tempIndex,0
	;Empty the buffer
	mov cx, 1000           ; Number of bytes in the buffer
	lea di, tempBuffer     ; Load the address of the buffer into DI
	mov al, 0              ; Value to clear the buffer (zero)
	rep stosb              ; Repeat store AL at ES:DI for CX times
	
	jmp print_line_main
	
file_error:
    mov ah, 09h               ; DOS function 09h: Print string
    lea dx, fileErrorMessage  ; Load the error message string into DX
    int 21h                   ; Call DOS interrupt
    ret
complete:
    lea si, tempBuffer           ; Load address of tempBuffer into SI
write_loop:
    mov al, [si]              ; Load the current byte from tempBuffer
    cmp al, 0                 ; Check if it's the null terminator
    je complete_exit          ; If null, terminate the loop
	mov ah, 40h             ; Function: Write to file
	mov bx, outputFileHandle; File handle for output
	mov cx, 1               ; Number of bytes to write
	mov dl, [si]            ; Load the byte from tempBuffer into DL
	mov [tempByte],dl
	mov dx, offset tempByte ; Temporarily store the byte to a variable
	int 21h
    inc si                   ; Move to the next byte in tempBuffer
    jmp write_loop            ; Repeat the loop
complete_exit:
    ; Close the file after writing
    mov ah, 3Eh               ; Function 3Eh: Close file
    int 21h                   ; Call DOS interrupt

    ret
	
print_line_main:
    ; Open/Create the output file (INT 21h, Function 3Ch)
    mov ah, 3Ch            ; Function: Create file
    mov cx, 0              ; File attributes: Normal
    mov dx, OFFSET outputFileName ; Address of the null-terminated output file name
    int 21h                ; Call DOS interrupt
    jc file_error          ; Jump if an error occurred
    mov outputFileHandle, ax ; Store the output file handle
		
process_line:
    mov si, count
    mov al, buffer[si]
    cmp al, 0
    je complete
    cmp al, 0Ah               ; Check if it's a line feed (0Ah)
    je check_and_write        ; If it's a line feed, call check_and_write
	
	lea di, tempBuffer    ; Load the address of tempBuffer into DI
    add di, tempIndex     ; Add tempIndex to DI to point to the correct location
    mov [di], al          ; Store AL at the calculated address
	inc tempIndex
    inc count	
    jmp process_line          ; Continue processing the next byte
	
check_and_write:
    ; Increment lineFeedCount and check if it matches var1-1
	inc lineFeedCount
    mov ax, lineFeedCount
    cmp ax, var1              ; Compare lineFeedCount with var1
    je write_buffer1          ; If line number matches, print buffer1
	
	cmp ax,var2
	je write_buffer2
	jmp write_tempbuff
	
call_inc_line:
	inc count
	mov tempIndex,0
	mov cx, 1000          ; Number of bytes in the buffer
	lea di, tempBuffer     ; Load the address of the buffer into DI
	mov al, 0              ; Value to clear the buffer (zero)
	rep stosb              ; Repeat store AL at ES:DI for CX times
	jmp process_line

write_tempbuff:
    lea si, tempBuffer           ; Load address of buffer1 into SI
print_loop0:
    mov al, [si]              ; Load the current byte from buffer1
    cmp al, 0                 ; Check if it's the null terminator
    je call_inc_line           ; If null, terminate the loop
	mov ah, 40h             ; Function: Write to file
	mov bx, outputFileHandle; File handle for output
	mov cx, 1               ; Number of bytes to write
	mov dl, [si]            ; Load the byte from buffer1 into DL
	mov [tempByte],dl
	mov dx, offset tempByte ; Temporarily store the byte to a variable
	int 21h
    inc si                   ; Move to the next byte in buffer1
    jmp print_loop0            ; Repeat the loop	
write_buffer1:
    lea si, buffer1           ; Load address of buffer1 into SI
print_loop1:
    mov al, [si]              ; Load the current byte from buffer1
    cmp al, 0                 ; Check if it's the null terminator
    je call_inc_line           ; If null, terminate the loop
    ; Write the character from buffer1 to the file
	mov ah, 40h             ; Function: Write to file
	mov bx, outputFileHandle; File handle for output
	mov cx, 1               ; Number of bytes to write
	mov dl, [si]            ; Load the byte from buffer1 into DL
	mov [tempByte],dl
	mov dx, offset tempByte ; Temporarily store the byte to a variable
	int 21h
    inc si                    ; Move to the next byte in buffer1
    jmp print_loop1            ; Repeat the loop
write_buffer2:
    lea si, buffer2           ; Load address of buffer1 into SI
print_loop2:
    mov al, [si]              ; Load the current byte from buffer1
    cmp al, 0                 ; Check if it's the null terminator
    je call_inc_line          ; If null, terminate the loop
    ; Write the character from buffer1 to the file
	mov ah, 40h             ; Function: Write to file
	mov bx, outputFileHandle; File handle for output
	mov cx, 1               ; Number of bytes to write
	mov dl, [si]            ; Load the byte from buffer1 into DL
	mov [tempByte],dl
	mov dx, offset tempByte ; Temporarily store the byte to a variable
	int 21h
    inc si                    ; Move to the next byte in buffer1
    jmp print_loop2            ; Repeat the loop

print_line ENDP


swap_values PROC
    ; Step 1: Copy buffer1 to tempBuffer
    lea si, buffer1          ; Load address of buffer1 into SI
    lea di, tempBuffer       ; Load address of tempBuffer into DI

    ; Loop through buffer1 and copy byte by byte until null terminator
copy_buffer1_to_temp:
    mov al, [si]             ; Load byte from buffer1 into AL
    mov [di], al             ; Store byte into tempBuffer
    inc si                   ; Move to next byte in buffer1
    inc di                   ; Move to next byte in tempBuffer
    cmp al, 0                ; Check for null terminator (0x00)
    je copy_buffer1_done     ; If null terminator, stop copying
    jmp copy_buffer1_to_temp ; Continue copying

copy_buffer1_done:

    ; Step 2: Copy buffer2 to buffer1
    lea si, buffer2          ; Load address of buffer2 into SI
    lea di, buffer1          ; Load address of buffer1 into DI

    ; Loop through buffer2 and copy byte by byte until null terminator
copy_buffer2_to_buffer1:
    mov al, [si]             ; Load byte from buffer2 into AL
    mov [di], al             ; Store byte into buffer1
    inc si                   ; Move to next byte in buffer2
    inc di                   ; Move to next byte in buffer1
    cmp al, 0                ; Check for null terminator (0x00)
    je copy_buffer2_done     ; If null terminator, stop copying
    jmp copy_buffer2_to_buffer1 ; Continue copying

copy_buffer2_done:

    ; Step 3: Copy tempBuffer to buffer2
    lea si, tempBuffer       ; Load address of tempBuffer into SI
    lea di, buffer2          ; Load address of buffer2 into DI

    ; Loop through tempBuffer and copy byte by byte until null terminator
copy_temp_to_buffer2:
    mov al, [si]             ; Load byte from tempBuffer into AL
    mov [di], al             ; Store byte into buffer2
    inc si                   ; Move to next byte in tempBuffer
    inc di                   ; Move to next byte in buffer2
    cmp al, 0                ; Check for null terminator (0x00)
    je copy_temp_done        ; If null terminator, stop copying
    jmp copy_temp_to_buffer2 ; Continue copying

copy_temp_done:

    ret
swap_values ENDP
main PROC
    ; Initialize DS
    mov ax, @data
    mov ds, ax

    ; Open the input file
    mov ah, 3Dh            ; Function: Open file
    mov al, 00h            ; Access mode: Read-only
    lea dx, inputFileName  ; Load file name
    int 21h
    ;jc error_exit          ; Jump if an error occurs
    mov bx, ax             ; Save file handle in BX

    ; Read from the file
    lea dx, buffer
    mov ah, 3Fh            ; Function: Read from file
    mov cx, 1000           ; Read up to 1000 bytes
    int 21h
    ;jc error_exit
    mov bytesRead, ax      ; Store bytes read

    ; Initialize variables
    mov si, 0              ; SI points to the start of buffer
    mov tempIndex, 0       ; Reset tempBuffer index
    mov lineFeedCount, 0   ; Reset line feed counter

process_buffer:
    mov al, buffer[si]	; Load the current byte
	mov bufferIndex,si
    cmp al, 0              ; Check if end of file content
    je done                ; If zero (end of content), we're done
    cmp al, 0Ah            ; Check for line feed (0Ah)
    je handle_line_feed    ; If line feed, process the line
    ; Add byte to tempBuffer
    lea di, tempBuffer    ; Load the address of tempBuffer into DI
    add di, tempIndex     ; Add tempIndex to DI to point to the correct location
    mov [di], al          ; Store AL at the calculated address
    inc tempIndex          ; Increment tempBuffer index
    inc si                 ; Move to the next byte in buffer
    jmp process_buffer     ; Continue processing

handle_line_feed:
    inc lineFeedCount      ; Increment line feed counter
    mov al, 0              ; Null-terminate tempBuffer
    lea di, tempBuffer    ; Load the address of tempBuffer into DI
    add di, tempIndex     ; Add tempIndex to DI to point to the correct location
    mov [di], al          ; Store AL at the calculated address

    ; Check if line matches var1 or var2
    mov ax, lineFeedCount
    cmp ax, var1
    je store_in_buffer1
    cmp ax, var2
    je store_in_buffer2

    ; Reset tempBuffer for the next line
    mov tempIndex,0
    inc si                 ; Move to the next byte in buffer
    jmp process_buffer

store_in_buffer1:
    lea si, tempBuffer      ; Load the address of tempBuffer into SI
    lea di, buffer1         ; Load the address of buffer1 into DI
    mov cx, tempIndex       ; CX holds the number of bytes to copy

copy_loop1:
    cmp cx, 0               ; Check if CX (bytes to copy) is 0
    je reset_temp_buffer    ; If 0, finish copying
    mov al, [si]            ; Load a byte from tempBuffer into AL
    mov [di], al            ; Store the byte into buffer1
    inc si                  ; Move to the next byte in tempBuffer
    inc di                  ; Move to the next byte in buffer1
    dec cx                  ; Decrement CX (bytes left to copy)
    jmp copy_loop1          ; Repeat until CX is 0

    jmp reset_temp_buffer   ; Jump to reset tempBuffer after copying
	
store_in_buffer2:
    lea si, tempBuffer      ; Load the address of tempBuffer into SI
    lea di, buffer2         ; Load the address of buffer2 into DI
    mov cx, tempIndex       ; CX holds the number of bytes to copy
copy_loop2:
    cmp cx, 0               ; Check if CX (bytes to copy) is 0
    je reset_temp_buffer    ; If 0, finish copying
    mov al, [si]            ; Load a byte from tempBuffer into AL
    mov [di], al            ; Store the byte into buffer2
    inc si                  ; Move to the next byte in tempBuffer
    inc di                  ; Move to the next byte in buffer2
    dec cx                  ; Decrement CX (bytes left to copy)
    jmp copy_loop2          ; Repeat until CX is 0

    jmp reset_temp_buffer   ; Jump to reset tempBuffer after copying	
done:
    mov si,lineFeedCount
	cmp si,var2
	jl last_line_store
close_file:
    ; Close the file
    mov ah, 3Eh            ; Function: Close file
    mov bx, bx             ; File handle
    int 21h
    call swap_values
    call print_line	
exit:
    ; Exit program
    mov ah, 4Ch            ; DOS terminate program
    int 21h
last_line_store:
	mov al, 0              ; Null-terminate tempBuffer
    lea di, tempBuffer    ; Load the address of tempBuffer into DI
    add di, tempIndex     ; Add tempIndex to DI to point to the correct location
    mov [di], al          ; Store AL at the calculated address
    lea si, tempBuffer      ; Load the address of tempBuffer into SI
    lea di, buffer2         ; Load the address of buffer2 into DI
    mov cx, tempIndex       ; CX holds the number of bytes to copy
copy_loop3:
    cmp cx, 0               ; Check if CX (bytes to copy) is 0
    je close_file    ; If 0, finish copying
    mov al, [si]            ; Load a byte from tempBuffer into AL
    mov [di], al            ; Store the byte into buffer2
    inc si                  ; Move to the next byte in tempBuffer
    inc di                  ; Move to the next byte in buffer2
    dec cx                  ; Decrement CX (bytes left to copy)
    jmp copy_loop3          ; Repeat until CX is 0

reset_temp_buffer:
    mov tempIndex,0	; Reset tempBuffer index
	mov si,bufferIndex
    inc si                   ; Move to the next byte in buffer
    jmp process_buffer

error_exit:
    ; Handle errors
    mov ah, 4Ch            ; Exit with error code
    mov al, 1
    int 21h

main ENDP
END main
