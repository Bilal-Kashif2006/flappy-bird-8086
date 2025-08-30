%ifndef UI_5_asm
%define UI_5_asm


;start screen buffer below 
line1:  db '  ______ _               _____  _______     __  ____ _____ _____  _____   ',0
line2:   db' |  ____| |        /\   |  __ \|  __ \ \   / / |  _ \_   _|  __ \|  __ \   ',0
line3:  db ' | |__  | |       /  \  | |__) | |__) \ \_/ /  | |_) || | | |__) | |  | | ',0
line4:  db ' |  __| | |      / /\ \ |  ___/|  ___/ \   /   |  _ < | | |  _  /| |  | | ',0
line5:  db ' | |    | |____ / ____ \| |    | |      | |    | |_) || |_| | \ \| |__| | ',0
line6:  db ' |_|    |______/_/    \_\_|    |_|      |_|    |____/_____|_|  \_\_____/  ',0
line7:  db '   Press Enter to Start   ',0
line8:  db ' A Game by: ', 0
line9:  db ' Bilal Kashif         23L-0757 ', 0
line10: db ' Mohammad Hamza Iqbal 23L-0848 ', 0
line11: db ' FALL 2024 ', 0
start_screen_lines_2Darr: dw line1,line2,line3,line4,line5,line6,line7,line8,line9,line10,line11
start_screen_lines_di: dw 0x0603,0x0703,0x803,0x0903,0x0a03,0x0b03,0x0d1e,0x0f23,0x101a,0x111a,0x1223
;instructions screen buffer below
line.1 :db 'Press any key to start the game.',0
line.2 :db 'Use the up arrow key to make the bird flap.',0
line.3 :db 'Guide the birds through the pipes without hitting them.',0
line.4 :db 'If the bird hits a pipe or the ground, the game ends.',0
line.5 :db 'Each time the bird passes through the pipes, you earn a point.',0
line.6 :db 'Try to get the highest score possible',0
scoreline :db 'Instructions',0


ins_screen_lines_2Darr:dw line.1,line.2,line.3,line.4,line.5,line.6,scoreline
ins_screen_lines_coords: dw 0x0702, 0x0902,0x0b02,0x0d02,0xf02,0x1102,0x422
;end screen buffer below
line_1 dw 982
 db '   _____          __  __ ______ ______      ________ _____  ', 0
line_2 dw 1142
 db '  / ____|   /\   |  \/  |  ____/ __ \ \    / /  ____|  __ \ ', 0
line_3 dw 1302
 db ' | |  __   /  \  | \  / | |__ | |  | \ \  / /| |__  | |__) |', 0
line_4 dw 1462 
db ' | | |_ | / /\ \ | |\/| |  __|| |  | |\ \/ / |  __| |  _  / ', 0
line_5 dw 1622
 db ' | |__| |/ ____ \| |  | | |___| |__| | \  /  | |____| | \ \ ', 0
line_6 dw 1782
 db '  \_____/_/    \_\_|  |_|______\____/   \/   |______|_|  \_\', 0
scoreline_ dw 2154
 db 'Score:', 0

end_screen_lines_2Darr:dw line_1,line_2, line_3,line_4,line_5,line_6,scoreline_
end_screen_lines_coords: dw 0x060b,0x070b,0x080b,0x090b,0x0a0b,0x0b0b,0xd25

end_screen_buffer: times 2000 dw 0

;pause screen  buffer below
p_line1: db 'Game paused$',0
p_line2: db "press 'y' to quit the game$",0
p_line3: db "press 'n' to resume the game$",0
pause_screen_lines_2Darr: dw p_line1,p_line2,p_line3
pause_screen_coordinates: dw 0x0a20,0x0c17,0x0d17

counter2: dw 0



ins_clrscr:
	push 	bp
	mov 	bp,sp

    push ES
    push AX
    push DI
    mov ax, [bp+6]
    mov es, ax
    mov cx, 4000          
    mov di, [bp+4]              
    mov al, 0x20           
    mov ah, 0x00           
clear_loop:
    mov [es:di], ax       
    add di, 2              
    loop clear_loop
    pop DI
    pop AX
    pop ES
	
	mov 	sp,bp
	pop 	bp
 ret	4
	


	
border:
	push 	bp
	mov 	bp,sp
    push ax
    push es
    push di
    push cx
    mov ax,[bp+6]
    mov es,ax

      mov ah, 0x03

   
    mov di,[bp+4]
    mov cx, 40             
borderloop_top:
    mov al, 0x5D           
    mov [es:di], ax
    add di, 2
    mov al, 0x5B          
    mov [es:di], ax
    add di, 2
    loop borderloop_top


    mov cx, 23             
    mov di, 160 
	add di,[bp+4]
borderloop_sides:
    mov al, 0x5D           
    mov [es:di], ax      
    add di, 158            
    mov al, 0x5B           
    mov [es:di], ax        
    sub di, 158           
    add di, 160            
    loop borderloop_sides

    mov cx, 40
    mov di, 3840
	add di,[bp+4]
borderloop_bottom:
    mov al, 0x5D           
    mov [es:di], ax
    add di, 2
    mov al, 0x5B           
    mov [es:di], ax
    add di, 2
    loop borderloop_bottom
	
	pop cx
    pop di
    pop es
    pop ax
	
	mov 	sp,bp
	pop 	bp 
ret		4
	
setscr:
    push ES
    push AX
    push DI
    push cx
    mov ax, 0xb800         
    mov es, ax
    mov cx, 4000          
    mov di, 0              
    mov al, 0x20           
    mov ah, 0x00           
  clear_loop2:
    mov [es:di], ax       
    add di, 2              
    loop clear_loop2
    xor di,di   
    add di,4 
    mov cx,500
    mov ah,0x03
    mov al,206
  li:
    mov [es:di],ax
    add di,8
    loop li    
    pop cx
    pop DI
    pop AX
    pop ES
  ret
	
  

print_screen_from_buffer:
push 	bp
mov 	bp,sp
pusha
mov 	di,[bp+6]
mov 	si,[bp+4]
mov 	ax,[bp+8]
mov 	[cs:counter2],ax
mov 	bx,[bp+10]
xor 	bh,bh
push 	cs
pop 	es
mov 	ah,0x13
mov 	al,0
instruc_print_line:
mov 	dx,[cs:si]
mov 	bp,[cs:di]
push 	bp
call 	strlen
;mov 	dl,cl
int 0x10


add 	di,2
add 	si,2
dec 	word[cs:counter2]
cmp 	word[cs:counter2],0
jg 	instruc_print_line


popa
mov 	sp,bp
pop 	bp
ret    8

;only argument is offset of null terminated string
;returns the length in cx
strlen:
push 	bp
mov 	bp,sp
push 	ax
push 	es
push 	di

push 	cs
pop 	es
mov 	di,[bp+4]

mov 	al,0
mov 	cx,0xffff
	repne 	scasb
mov 	ax,0xffff
sub 	ax,cx
mov 	cx,ax
dec 	cx;to exclude the 0 counted 

pop 	di
pop 	es
pop 	ax
mov 	sp,bp
pop 	bp
ret 2


startScr:
    call setscr
    ;call startscreen
	push 	0x0e
	push 	11
	push 	start_screen_lines_2Darr
	push 	start_screen_lines_di
	call 	print_screen_from_buffer
ret

instructions_screen:
	push 	0xb800
	push 	0
	call ins_clrscr
	push 	0xb800
	push 	0
	call border
	push 	0x0e
	push 	7
	push 	ins_screen_lines_2Darr
	push 	ins_screen_lines_coords
	call print_screen_from_buffer
ret

pause_screen:
	

	call 	pause_clrscr
	push 	3
	push 	pause_screen_lines_2Darr
	push 	pause_screen_coordinates
	call 	print_pause
	; push 	0x70
	; push 	3
	; push 	pause_screen_lines_2Darr
	; push 	pause_screen_coordinates
	; call 	print_screen_from_buffer
	
	
		
	
	
ret

print_pause:
push 	bp
mov 	bp,sp
pusha

mov 	si,[bp+6]
mov 	di,[bp+4]
mov 	cx,[bp+8]
xor 	bh,bh
each_instruction:
	mov 	dx,[di]
	mov 	ah,0x2
	int 	0x10
	mov 	dx,[si]
	mov 	ah,0x9
	int 	0x21

	add 	si,2
	add 	di,2
loop each_instruction
	mov 	dx,0x1700
	mov 	ah,0x2
	int 	0x10


popa
mov 	sp,bp
pop 	bp
ret 6

pause_clrscr:
	push 	AX
	push 	cx
	push 	ES
	push 	DI
	push 	si

	push 	0xb800
	pop 	es
	sub 	sp,2
	push 0x0a
	push 0x12
	call calculate_index
	pop 	di
	mov 	ax,0x7020
	mov		si,5
	color_each_row:	
		mov 	cx,40
				rep stosw
		add 	di,80
		dec 	si
		jnz 	color_each_row
	pop 	si
	pop 	di
	pop 	es
	pop 	cx
	pop 	ax
	
ret
;the function below is not used anymore see make_end_screen_buffer
print_end_screen:
	push 0xb800
	push 0
    call ins_clrscr
	push 0xb800
	push 0
    call border
	push 	0x0e
    push 	7
	push 	end_screen_lines_2Darr
	push 	end_screen_lines_coords
	call print_screen_from_buffer
ret

make_end_screen_buffer:
	push cs 
	push end_screen_buffer
    call ins_clrscr
	push cs
	push end_screen_buffer
    call border
	push 	end_screen_buffer
	push 	0x0e
    push 	7
	push 	end_screen_lines_2Darr
	call print_screen_in_buffer
	push end_screen_buffer
	call end_scr_curtain
	push 0x0e00
	push word[cs:score_var]
	push 2168
	call print_num
ret

print_screen_in_buffer:
push 	bp
mov 	bp,sp
pusha
mov 	bx,[bp+4]

mov 	ax,[bp+6]
mov 	[cs:counter2],ax

push 	cs
pop 	es

push 	cs
pop 	ds

mov 	ax,[bp+8]
instruc_print_line2:
mov 	si,[cs:bx]
mov 	di,[cs:si]
add 	di,[bp+10]
add 	si,2
push 	si
call 	strlen
	each_line3:
		movsb
		stosb 	
		
		
		loop 	each_line3
add 	bx,2
dec 	word[cs:counter2]
cmp 	word[cs:counter2],0
jg 	instruc_print_line2


popa
mov 	sp,bp
pop 	bp
ret    8

;only parameter is offset
end_scr_curtain:
push 	bp
mov bp,sp
pusha
mov cx,0
push 0xb800
pop ES

push cs
pop ds

pair_of_columns:
	mov si,cx
	shl si,1
	mov di,cx
	shl di,1
	add si,[bp+4]
	mov dx,25
	left_column:
		cld
		movsw
		add si,158
		add di,158
		dec dx
		jnz left_column
	mov si,79
	sub si,cx
	shl si,1
	add si,[bp+4]

	mov di,79
	sub	di,cx
	shl di,1
	mov dx,25
	right_column:
		cld
		movsw
		add si,158
		add di,158
		dec dx
		jnz right_column
		
		push 2
		call delay
		
inc cx
cmp cx,40
jb 	pair_of_columns
	


popa
mov sp,bp
pop bp
ret 2
;=================================================
;bp+8 has the attribute
;bp+6 is the number(score)
;bp+4 is the di startong
print_num:
push bp
mov 	bp,sp
pusha

mov 	ax,[bp+6]
mov 	bx,10
xor 	dx,dx
xor 	cx,cx
push_in_stack:
	div 	bx
	add 	dx,'0'
	push 	dx
	xor 	dx,dx
	inc 	cx
	cmp ax,0
	ja 	push_in_stack

push 0xb800
pop 	ES
mov 	di,[bp+4]
mov 	si,[bp+8]
;shl 	si,4
print_each_digit:
	pop 	Ax
;	add 	ah,0x0e
	xor 	ah,ah
	add 	ax,si
	stosw 
	loop print_each_digit


popa
mov sp,bp
pop bp

ret 6
;=============================================================
print_score:
push bp
mov bp,sp
pusha


mov ax,0x5720
push 0xb800
pop ES
mov di,152
mov bx,3
each_row3:
	mov cx,4
	rep stosw
	add di,152
	dec bx
	jnz  each_row3
push 0x5e00
push word[bp+4]
push 314
call print_num

	

popa
mov sp,bp
pop bp
ret 2


%endif 