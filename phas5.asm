;Bilal Kashif 23L-0757
;Mohammad Hamza Iqbal 23L-0848
[org 0x0100]
JMP start

;variables for the bird
bird_increment:dw 1
bird_col: dw 15
bird_row: dw 10
bird_size: dw 8,3 ; 5 is max length and 3 is height 
bird_up_interval: dw 0
;the array below needs to be in sorted fashion(ascending order)
bird_check_coords:dw -158,-146,16,336,496,480;these are 6, their number is hardcoded


;random dots in ground (generated from chrome) in range 1  to 240
random_dots: dw 109,233,3,51,120,142,85,105,240,116,162,238,235,161,222,188,175,182,103,213

;variables for pillars
curr_pillars_starting_columns: dw 33,72,111;max 2 pillars at once in screen  
gap_length: dw 10

; buffer to hold original ISRs
old_kbisr:dw 0,0
old_timer: dd 0

;flags
keep_running: dw 1
collision: dw 0

;for use in collision detection 
bg_colors: dw 0x30
bg_colors_length:dw 1

;score variable
score_var:dw 0

;process control block
		; ax,bx,cx,dx,ip,cs,flags storage area
pcb:	dw 0, 0, 0,0,0,0, 0 ; task0 regs[cs:pcb + 0]
		dw 0, 0, 0,0,0,0, 0 ; task1 regs start at [cs:pcb + 10]
		dw 0, 0, 0,0,0, 0, 0 ; task2 regs start at [cs:pcb + 20]

current:	dw 0 ; index of current task
;chars:		db '\|/-' ; shapes to form a bar


;animation loop in start
;functions:
;print_bg
;print_pillars
;print_bird
;print_ground_static
;delay

;this file includes the user interfaces for start screen instructions screen and end screen
 %include "UI_5.asm"
 %include "prng_1.asm"
 ;mus.asm included at end

start:
	

	xor 	ax,ax
	mov 	es,ax
	
	
	mov 	ax,[es:9*4]
	mov 	[old_kbisr],ax
	mov 	ax,[es:9*4+2]
	mov 	[old_kbisr+2],ax
	
	
	mov 	ax,[es:8*4]
	mov 	[old_timer],ax
	mov 	ax,[es:8*4+2]
	mov 	[old_timer+2],ax
	
	cli
	mov 	word[es:9*4],up_interrupt
	mov 	[es:9*4+2],cs
	mov 	word[es:8*4],timer_interrupt
	mov 	[es:8*4+2],cs
	sti

	
			mov word [cs:pcb+14+8], music			; initialize ip
			mov [cs:pcb+14+10], cs						; initialize cs
			mov word [cs:pcb+14+12], 0x0200				; initialize flags

			; mov word [cs:pcb+20+4], music			; initialize ip
			; mov [cs:pcb+20+6], cs						; initialize cs
			; mov word [cs:pcb+20+8], 0x0200				; initialize flags

			mov byte [cs:current], 0						; set current task index
			xor ax, ax
			mov es, ax									
			
			
			
mov ax, 600
out 0x40, al
mov al, ah
out 0x40, al

my_game:
	
	call 	startScr
take_input:
	mov 	ax,0x1
	int 	0x16
	cmp 	al,13
	je 	game_start
	xor 	ax,ax
	jmp take_input
game_start:	
	call instructions_screen
	mov 	ax,0x00
	int 	0x16
	
	mov 	ax,0xb800
	mov 	es,ax
	call print_static_screen
	
	mov 	ax,0x1
	 int 	0x16
	 jmp 	l1

	resumed:
	mov 	word[cs:keep_running],1

	l1:
		call play_animation
		push 3
		call delay
		cmp word[cs:keep_running],1
		jne 	before_wait
		cmp word[cs:collision],0
		jne terminate_game
		jmp l1
		
before_wait:
;push 	0x71
	call 	pause_screen
	;pop 	ax
	;cmp 	ax,0x71
	;je 	terminate_game
	;call pause_screen
wait_for_key:	
	
	mov 	ax,0x1
	int 	0x16
	cmp 	al,'y'
	je 		terminate_game
	cmp 	al,'n'
	je 		resumed 
	XOR 	ax,ax
	jmp 	wait_for_key
terminate_game:
;will we need to make bird fall on ground only if it has collided 	
	call fall_on_ground_wrapper
	
	push 8
	call delay
	call make_end_screen_buffer
	
	; call print_end_screen
	mov 	ax,0x00
	int 	0x16
	push 	0x0
	pop 	es
	cli
	push ax
	mov 	ax,word[cs:old_kbisr]
	mov 	word[es:9*4],ax
	mov 	ax,word[cs:old_kbisr+2]
	mov 	word[es:9*4+2],ax
	;NOT unhooking the interrupt below led to issue when launching 
	;game again after quiting it once
	mov 	ax,word[cs:old_timer]
	mov 	[es:8*4],ax
	mov		ax,word[cs:old_timer+2]
	mov 	[es:8*4+2],ax
	pop 	ax
	sti
	
	
	
	mov 	ax,0x4c00
	int 	0x21
;======================================================	
delay:
push 	bp
mov 	bp,sp
push 	si
push 	cx

mov 	si,[bp+4]
loop1:
mov 	cx,0x8fff
		delay1:
			dec cx
			jnz delay1
		dec si
		jnz loop1
		
pop 	cx
pop 	si
mov 	sp,bp
pop 	bp
ret 2
;===========================================
print_bg:
	pusha
	
	push 	0xb800
	pop 	es
	
	mov 	di,0;
	mov 	ax,0x3020;foreground is 0, blue background
	cld
	
	mov 	cx,1760;sky, leaving space for ground
	rep 	stosw

	

	
	popa
	ret 
;==============================================	
up_interrupt:
	push 	ax
	push 	bx
	push 	es
	
	
	in 		al,0x60
	cmp 	al,0x48
	jne 	not_up_key
;		mov 	word[bird_increment],-1
		mov word[cs:bird_increment],-1
		mov word[cs:bird_up_interval],1000
;		mov word[cs:bird_increment_arr],-26
		jmp end_kbisr
	not_up_key:
	cmp al,0x1
	jne end_kbisr
	wait_for_input:
		mov word[cs:keep_running],0
	
	
;		mov 	al,0x20
;		out 	0x20,al
end_kbisr:
	pop 	es
	pop 	bx
	pop 	ax
	jmp far[cs:old_kbisr]	
;========================================================
timer_interrupt:

	cmp word[cs:bird_up_interval],0
	je 	move_down
		dec 	word[cs:bird_up_interval]
		cmp 	word[cs:bird_up_interval],150
		ja 		end_timer_interr
			mov 	word[bird_increment],0
			jmp 	end_timer_interr
	move_down:
	mov 	word[cs:bird_increment],1
	end_timer_interr:
	
			push ax
			push bx
			push cx
			push dx

			mov bl, [cs:current]				; read index of current task ... bl = 0
			mov ax, 14							; space used by one task
			mul bl								; multiply to get start of task.. 10x0 = 0
			mov bx, ax							; load start of task in bx....... bx = 0
			
			pop ax								; read original value of bx
			mov [cs:pcb+bx+6], ax				; space for current task's DX

			pop ax								; read original value of bx
			mov [cs:pcb+bx+4], ax				; space for current task's CX

			pop ax								; read original value of bx
			mov [cs:pcb+bx+2], ax				; space for current task's BX

			pop ax								; read original value of ax
			mov [cs:pcb+bx+0], ax				; space for current task's AX

			pop ax								; read original value of ip
			mov [cs:pcb+bx+8], ax				; space for current task

			pop ax								; read original value of cs
			mov [cs:pcb+bx+10], ax				; space for current task

			pop ax								; read original value of flags
			mov [cs:pcb+bx+12], ax					; space for current task

			inc byte [cs:current]				; update current task index...1
			cmp byte [cs:current], 2			; is task index out of range
			jne skipreset						; no, proceed
			mov byte [cs:current], 0			; yes, reset to task 0

skipreset:	mov bl, [cs:current]				; read index of current task
			mov ax, 14							; space used by one task
			mul bl								; multiply to get start of task
			mov bx, ax							; load start of task in bx... 10
			
			mov al, 0x20
			out 0x20, al						; send EOI to PIC

			push word [cs:pcb+bx+12]				; flags of new task... pcb+10+8
			push word [cs:pcb+bx+10]				; cs of new task ... pcb+10+6
			push word [cs:pcb+bx+8]				; ip of new task... pcb+10+4
			mov ax, [cs:pcb+bx+0]				; ax of new task...pcb+10+0
			mov cx, [cs:pcb+bx+4]				; ax of new task...pcb+10+0
			mov dx, [cs:pcb+bx+6]				; ax of new task...pcb+10+0
			mov bx, [cs:pcb+bx+2]				; bx of new task...pcb+10+2
			

			iret								; return to new task

;	jmp far[cs:old_timer]
;=====================================================
print_pillars:
	;this func needs to give exact width of pillar
	;assuming that es is pointing at 0xb800
	;[bp+8] is the starting column of pillar
	;[bp+6] this the starting row of gap
	;[bp+4] this is the length of gap
	push 	bp
	mov 	bp,sp	
	sub 	sp,2;this local variable stores the width of the pillars 	
	push 	0;[bp-4] is the number of columns to be skipped
	
	push 	ax
	push	es
	
	mov 	ax,0xb800
	mov 	es,ax
	
	mov 	ax,[bp+8]
	cmp 	ax,0
	jg 		not_fading_out
		not 	ax;taking 2's comp of starting column number
		inc 	ax
		mov 	[bp-4],ax
	
	not_fading_out:
	cmp 	ax,72;if starting column is more than 72 then pillar will be shortened 
	jbe 	full_width
		mov 	word[bp-2],80;
		sub 	word[bp-2],ax	
		jmp 	not_full_width
	full_width:
		mov 	word[bp-2],8
	not_full_width:
	mov 	ax,[bp-4]
	sub 	[bp-2],ax; in the case of fading out, this 
	;step ensures that columns to be skipped+ printed width= 8(normal width)
	
	sub 	sp,2
	push 	0
	push 	word[bp+8]
	call 	calculate_index
	
	;push di not needed because calculate index returned di
	push 	word[bp-4]
	push 	word[bp-2]
	push 	word[bp+6]
	call 	draw_single_pillars
	
	mov 	ax,[bp+6]
	add 	ax,[bp+4]
	
	sub 	sp,2
	push 	ax
	push 	word[bp+8]
	call 	calculate_index
	
	;push di not needed because calculate index returned di
	push 	word[bp-4]
	push 	word[bp-2]
	not 	ax;two's comp of ax
	add 	ax,1
	add 	ax,22
	push 	ax
	call 	draw_single_pillars
	
	pop 	es
	pop 	ax
	mov 	sp,bp
	pop 	bp
	
	ret 6
;=================================================
	;es needs to be at 0xb800
	;the first parameter is  starting row
	;the second parameter is starting column
	;max length is 5 cells
	;max height is 3 cells 
print_bird:
	push 	bp
	mov 	bp,sp
	pusha
	

;calculating di below
	sub sp,2
	push word[bp+6]
	push word[bp+4]
	call calculate_index
	pop 	di
	push 	di
	
	; add		di,6	; this takes di to the head
	
	; mov 	ax,[es:di];this stores the background color in ax

	; mov 	word[es:di],0x4007;the eye
; ;	mov 	byte[es:di+1],ah
	; add 	di,2
	; mov 	byte[es:di],0x10
	; mov 	byte[es:di+1],ah;the beak
	; ;add 	byte[es:di+1],5
	; ;add 	byte[es:di+1],2
	; add		di,152
	; mov 	byte[es:di],0x11
	; mov    	byte[es:di+1],ah
	; and 	byte[es:di+1],0xf0
	; add 	byte[es:di+1],4
	; add 	di,2
	; mov 	word[es:di],0x05b1
	; add 	di,2
	; mov 	word[es:di],0x4720
	; add 	di,2
	; mov 	word[es:di],0x4720
	; add		di,156
	; mov 	byte[es:di],0xe2;0x021f
	; mov 	byte[es:di+1],ah
	; add 	di,4
	; mov 	byte[es:di],0xe2
	; mov 	byte[es:di+1],ah
	mov si,3
	mov ax,0x55b1
	rectang:
		mov cx,8
		rep stosw
		add di,144
	dec si
	jnz rectang
	
	
	pop di
	;the eye is drawn below
	
	mov word[es:di+10],0x7020
	mov word[es:di+12],0x7020
	mov word[es:di+14],0x7020
	mov word[es:di+170],0x7020
	mov word[es:di+172],0x0020
	mov word[es:di+174],0x0707
	
	;the wing is drawn below
	mov word[es:di+166],0x5db1
	mov word[es:di+322],0x5db1
	mov word[es:di+324],0x5db1
	mov word[es:di+326],0x5db1

	popa
	
	mov 	sp,bp
	pop 	bp
	
ret     4
;=================================================
;es needs to be set at video gallery 
print_ground_static:
	push 	ax
	push 	cx
	push 	di
	push 	si
	push 	ds
	push 	es
	
	push 	0xb800
	pop 	es
	
	mov 	di,1760;starting at fourth last row
	shl 	di,1
	mov 	ax,0x6020;foreground is 0, brown ground
	cld
	
	mov 	cx,240;
	rep 	stosw
	
	;this piece of code below prints the checkerboard pattern
	mov 	ax,0x6eb1
	mov 	di,3522
	mov cx,24
	checker_board_pattern1:
		stosw 
		add di,2
		loop checker_board_pattern1
	add di,66
	mov cx,24	
	checker_board_pattern2:
		stosw 
		add di,2
		loop checker_board_pattern2
	add di,62
	mov cx,24
	checker_board_pattern3:
		stosw 
		add di,2
		loop checker_board_pattern3
	
	
	mov 	ax,0x6e30
	mov 	di,3620
	mov cx,15
	zero_pattern1:
		stosw 
		add di,2
		loop zero_pattern1
	add di,102
	mov cx,16	
	zero_pattern2:
		stosw 
		add di,2
		loop zero_pattern2
	add di,94
	mov cx,15
	zero_pattern3:
		stosw 
		add di,2
		loop zero_pattern3
	
		mov word [es:3842], 0x6eb1

	 ;mov 	cx,20
	
	; mov di,3520
	; put_zeros1:
		; mov 	cx,15
		; rep 	stosw 
		; add 	di,130
		; cmp 	di,4000
		; jb 	put_zeros1
		
	; mov di,3650
	
		
	; put_dots_randomly:
		; mov 	di,[random_dots+si]
		; shl 	di,1
		; add 	di,3520
		; stosw
		; ;mov 	[es:di],ax
		; add 	si,2
		; loop 	put_dots_randomly
	;109,233,3,51,120,142,85,105,240,116,162,238,235,161,222
	
	
	pop 	es
	pop 	ds
	pop 	si
	pop 	di
	pop 	cx
	pop 	ax
	ret 
;=================================================
;return value is in di	
;bp+6 is rows	
;bp+4 is columns
calculate_index:
push 	bp
mov 	bp,sp
push 	ax
push 	di
mov 	di,80
mov 	ax,[bp+6]
mul 	di
add 	ax,[bp+4]
shl 	ax,1
mov 	[bp+8],ax

pop 	di
pop 	ax
mov 	sp,bp
pop 	bp
ret 4

;=====================================================
;bp+10 is di starting
;bp+8 is number of columns to be skipped(for fade out)
;bp+6 	is width( will be lesser than 8 for fade in)
;bp+4 is length
draw_single_pillars:

push 	bp
mov 	bp,sp
	
	; push 	0x2200
	; push 	0x2200
	; push 	0x2200
	; push 	0x2200
	; push 	0x2200
	push 	0x28b1;these are the shades of green that i shall use
	push 	0x20b1;local variables
	push 	0x2220
	push 	0x2ab1
	; ;mov 	word[bp-8],0x0ab1;character b1(hex) is somewhat of a mesh that gives a blend of the background and foreground
	push 	0x7ab1
	push 	1;pushing the width that each shade occupies
	push 	1;this would save me from making multiple loops 
	push 	3
	push 	2
	push 	1
	
	sub sp,2;this is local variable storing counter for number of columns to be skipped
	
	push 	cx
	push 	bx
	push 	ax
	push 	di
	push 	si
	
	
	
	mov 	di,[bp+10]
;	mov 	ax,0x2220;green
	mov 	bx,[bp+4];number of iterations of outerloop
	;sub 	bx,1; sub 1 for the black outline
	; cmp 	word[bp+6],0
	; jl		fade_out
		; mov 	dx,[bp+6]
		; add 	dx,0x0800
		; mov 	[bp-22],dx
		; jmp 	fade_in_case
	; fade_out:
		; mov 	dx,[bp+6]
		; not 	dx;2's complement
		; add 	dx,1
		; shl 	dx,4;putting width in dh
		; add 	dl,8
		; mov 	[bp-22],dx
;	fade_in_case:
	mov 	dx,[bp+8]
	mov 	[bp-22],dx

	move_next_row:
			mov 	dx,[bp+6]
			xor 	si,si
			
			next_shade:
				mov 	ax,[bp+si-10]
				mov 	cx,[bp+si-20]
			next_cell:
					cmp 	word[bp-22],0
					je		no_skipping
						dec 	word[bp-22]
						add 	di,2;move to next cell
						jmp 	column_skipped
					no_skipping:
					stosw;fills cells of a single shade
					column_skipped:
					dec 	dx
					jz 		terminate_l2
					loop	next_cell
				add 	si,2
				cmp 	si,10;total shades=5 5*2=10
				jb 	next_shade
		; mov 	word[es:di],0x720
		; add 	di,2
	terminate_l2:
		mov 	dx,[bp+8]
		mov 	[bp-22],dx
		mov 	dx,[bp+6]
		shl 	dx,1
		add 	di,160;points to next row 130=160-30
		sub 	di,dx
		dec 	bx
		jnz 	move_next_row
		
	pop 	si
	pop 	di
	pop 	ax
	pop 	bx
	pop 	cx

mov 	sp,bp
pop 	bp

ret 8

;============================================================
;bp+6 is starting row
;bp+4 is number of rows
rotate_left:
	push 	bp
	mov 	bp,sp
	push 	ax
	push 	bx
	push 	cx
	push 	di
	push 	si
	push 	ds
	push 	es

	sub 	sp,2
	push 	word[bp+6]
	push 	0
	call 	calculate_index

	pop 	di
	mov 	bx,[bp+4]

	mov 	ax,0xb800
	mov 	es,ax
	mov 	ds,ax
	mov 	si,di

	rotate_each_row:
		push 	word[es:di]
		add 	si,2
		mov 	cx,79

		cld
		rep 	movsw
		pop 	word[es:di]
		add di,2

		dec 	bx
		jnz 	rotate_each_row

	pop 	es
	pop 	ds
	pop 	si
	pop 	di
	pop 	cx
	pop 	bx
	pop 	ax

	mov 	sp,bp
	pop 	bp
ret 	4

;=========================================================
print_static_screen:

	call print_bg
	call print_ground_static
	call play_animation
	
ret
;==========================================================
;bp+8 is the width of pillar
;bp+6 is the starting column of bird
;bp+4 is the address of array of pillars
increment_score:
push bp
mov bp,sp
pusha

mov bx,[bp+4]
mov cx,3

each_pillar:
	mov ax,[bx]
	add ax,9
	cmp ax,[bp+6]
	jne no_increment
		inc 	word[cs:score_var]
	no_increment:
	add bx,2	
loop each_pillar

popa
mov sp,bp
pop bp
ret 6
;=========================================================
;bp+12 is the number of background_colors
;bp+10 is the background color array
;bp+8 is the length of the array of points
;bp+6 is array of relative points to be checked
;bp+4 is current bird di
collision_2:
push 	bp
mov 	bp,sp

sub sp,2;this will serve as flag for inner loop, it is 0 when color matched

pusha

mov 	bx,[bp+6]
mov cx,[bp+8]
cmp 	word[bp+4],160
jnb 	not_first_row

	jump_to_positive:
		cmp word[cs:bx],0
		jnl not_first_row
		add bx,2
		loop jump_to_positive

not_first_row:
push 	0xb800
pop 	es


mov 	si,[bp+10]; background_color array
;mov 	bx,[bp+6];array of relative points to be checked,it has been set before
;mov 	cx,[bp+8];number of total points to be checked
each_point:
	mov 	dx,[bp+12];number of colors available for background
	mov 	word[bp-2],1;assuming that collision is there at start
	each_color3:
		mov 	di,[bp+4]
		add 	di,[cs:bx]
		mov 	ax,[es:di]
		cmp 	ah,[cs:si]
		jne 	no_match_yet
			mov word[bp-2],0
			jmp no_collision_yet
		no_match_yet:
		add si,2
		dec dx
	jnz 	each_color3
;	cmp 	word[bp-2],1
;	jne 	no_collision_yet
		mov 	word[cs:collision],1;this code will only run when no color matched
		jmp 	end_of_collision_2
	no_collision_yet:
add 	bx,2
loop 	each_point

end_of_collision_2:

popa
mov 	sp,bp
pop 	bp
ret 	10


;=====================================================
fall_onto_ground:

	pusha
 call print_bg
 
 
;code for printing pillars 
 mov 	bx,curr_pillars_starting_columns
 mov 	di,curr_pillars_rand_gaps
 mov 	cx,3
	print_pillars_in_animation1:
	
	cmp 	word[cs:bx],79
	jg 		not_this_pillar1
		 push word[cs:bx]
		 push word[cs:di]
		 push word[cs:gap_length]
		 call 	print_pillars
	
	not_this_pillar1: 
	 add di,2
	 add bx,2
	 loop print_pillars_in_animation1
	
	 ;code for printing bird below

	 inc 	word[cs:bird_row]
	 
	mov ax,22
	sub ax,[cs:bird_size+2]
	cmp word[cs:bird_row],ax
	 jng 	above_ground1
		mov 	word[cs:bird_row],19
		jmp 	normal_range1
	above_ground1:
	 cmp 	word[cs:bird_row],0	
	 jnl 	normal_range1
		mov 	word[cs:bird_row],0
	normal_range1:
	 push word[cs:bird_row]
	 push word[cs:bird_col]
	 call print_bird


 
 popa
ret

;========================================================
fall_on_ground_wrapper:
push ax
	inc word[cs:curr_pillars_starting_columns]
	inc word[cs:curr_pillars_starting_columns+2]
	inc word[cs:curr_pillars_starting_columns+4]
	mov word[cs:bird_up_interval],0
hit_ground:	
	mov ax,22
	sub ax,[cs:bird_size+2]
	cmp word[cs:bird_row],ax
	jnb on_ground
	push 	3
	call 	delay
	call fall_onto_ground
	jmp hit_ground
	on_ground:

pop ax
ret

;=============================================================
;bp+14 is length of gap
;bp+12 is the starting column of the bird
;bp+10 is the starting row of gap(value)
;bp+8 is the current bird_row
;bp+6 is the address of bird_size
;bp+4 is address of the array of pillars
detect_collision:
;since original game does not end when bird collides with the border of sky i have 
;not checked for that either
;only use signed jumps( jg or jl) because pillar coordinates can go to negative too
push 	bp
mov 	bp,sp

pusha

mov 	bx,[bp+4]
mov 	si,[bp+6]
;check if bird is colliding with ground
mov 	ax,[bp+8]
add 	ax,[cs:si+2];calculating the last row that bird occupies
dec 	ax;reason for this: starting row has the first cell of 
;bird so we need to sub 1 to ensure not counting it twice

cmp 	ax,21
jl 		not_touching_ground

	mov 	word[cs:collision],1
	jmp 	end_of_collision_detect
not_touching_ground:
mov 	ax,[bp+12]
add 	ax,[cs:si];ax has the last column occupied by the bird
dec 	ax

mov 	cx,3;size of array of pillars
check_all_pillars_head_on_collision:
cmp 	ax,[cs:bx]
jne 	not_adjacent 
	call check_rows
	cmp 	word[cs:collision],1
	je 		end_of_collision_detect
not_adjacent:
add 	bx,2
loop 	check_all_pillars_head_on_collision

mov 	ax,[bp+12]
mov 	bx,[bp+4]
mov 	si,[bp+6]
mov 	cx,3
check_above_and_below:
mov 	dx,[cs:bx]
sub		dx,[cs:si]
inc 	dx
cmp 	ax,dx
jbe 	increment_statment
mov 	dx,[cs:bx]
add 	dx,8;this is width of pillar 
cmp 	ax,dx
jnb 	increment_statment
	call check_rows2
	cmp 	word[cs:collision],1
	je 		end_of_collision_detect
increment_statment:
add 	bx,2
loop 	check_above_and_below



end_of_collision_detect:
popa

mov 	sp,bp
pop 	bp
ret 	12


check_rows:
push 	ax
push 	di
push 	dx

mov 	ax,[bp+8];ax has first row occupied
mov 	di,ax
add 	di,[cs:si+2];bx has last row occupied


cmp 	ax,[bp+10]
jg 		not_hitting_upper_pillar 		
	mov 	word[cs:collision],1
	jmp 	end_of_check_rows
not_hitting_upper_pillar:
mov 	dx,[bp+10]
add 	dx,[bp+14];this has the first row of lower pillar
cmp 	di,dx
jng 	end_of_check_rows
	mov 	word[cs:collision],1
end_of_check_rows:
pop 	dx
pop 	di
pop 	ax
ret

check_rows2:
push 	ax
push 	di
push 	dx

mov 	ax,[bp+8];ax has first row occupied
mov 	di,ax
add 	di,[cs:si+2];bx has last row occupied


cmp 	ax,[bp+10]
jne 		not_colliding_upper		
	mov 	word[cs:collision],1
	jmp 	end_of_check_rows2
not_colliding_upper:
mov 	dx,[bp+10]
add 	dx,[bp+14];this has the first row of lower pillar
cmp 	di,dx
jne 	end_of_check_rows2
	mov 	word[cs:collision],1
end_of_check_rows2:
pop 	dx
pop 	di
pop 	ax
ret


;bp+6 is the starting row of gap between pillars
;bp+4 is length of gap
play_animation:
 
 push 	bp
 mov 	bp,sp
 sub 	sp,2

 pusha
  
 call print_bg
 ;code for printing bird below
 mov 	ax,word[cs:bird_increment]
 add 	word[cs:bird_row],ax
 
 mov ax,22
	sub ax,[cs:bird_size+2]
	cmp word[cs:bird_row],ax
 jng 	above_ground
	mov 	word[cs:bird_row],19
	jmp 	normal_range
above_ground:
 cmp 	word[cs:bird_row],0	
 jnl 	normal_range
	mov 	word[cs:bird_row],0
normal_range:
 push word[cs:bird_row]
 push word[cs:bird_col]
 call print_bird
 
;code for printing pillars 
 mov 	bx,curr_pillars_starting_columns
 mov 	di,curr_pillars_rand_gaps
 mov 	cx,3
	print_pillars_in_animation:
	
	cmp 	word[cs:bx],79
	jg 		not_this_pillar
		 push word[cs:bx]
		 push word[cs:di]
		 push word[cs:gap_length]
		 call 	print_pillars
	
	not_this_pillar: 
	dec 	word[cs:bx]
	 cmp 	word[cs:bx],-7
	 jg 	no_wraparound
		push bx
		call randomize_gap
		mov word[cs:bx],111
	 no_wraparound:
	 add di,2
	 add bx,2
	 loop print_pillars_in_animation


 push 22
 push 3
 call 	rotate_left

 ; push word[cs:gap_length]
 ; push word[cs:bird_col]
 ; push 7
 ; push 	word[cs:bird_row]
 ; push 	 bird_size
 ; push 	curr_pillars_starting_columns
 ; call 	detect_collision
 
 push word[cs:bg_colors_length]
 push bg_colors
 push 6
 push bird_check_coords
 sub sp,2
 push word[cs:bird_row]
 push word[cs:bird_col]
 call calculate_index
 call collision_2
	
 push 8;width of pillars
 push word[cs:bird_col]
 push curr_pillars_starting_columns
 call increment_score
 
 push word[cs:score_var]
 call print_score
 
 popa
 mov 	sp,bp
 pop 	bp
 ret
 
; %include "EndScr.asm"

;only a few functions use the global variables 
;this includes the play_animation, print_ground_static,print_start_screen,and hooked interrupts
;print pillars, rotate left,check_collision assume that ground takes last 3 rows
;
 %include"mus.asm"