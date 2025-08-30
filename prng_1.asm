%ifndef prng_1_asm
%define prng_1_asm


seed:dw 01234
a: dw 25
m: dw 7
c: dw 13

curr_pillars_rand_gaps: dw 7,3,11
;prng formula says that X(n+1)=(a*X(n) +c)mod	m

;return value is random number
rand1:
push bp
mov bp,sp
pusha

mov 	ax,[seed]
mov 	bx,[a]
xor 	dx,dx
mul 	bx
add  	ax,[c]
mov 	[seed],ax
and 	ax,[m]
mov 	[bp+4],ax
add 	word[bp+4],1

popa

mov 	sp,bp
pop 	bp
ret 
;only paramter is the pillar number for which the random number is generated
randomize_gap:
push 	bp
mov 	bp,sp
pusha
mov 	bx,[bp+4]
sub 	bx,curr_pillars_starting_columns
sub sp,2
call rand1
pop 	ax
mov 	[cs:curr_pillars_rand_gaps+bx],ax


popa
mov 	sp,bp
pop 	bp
ret 2

%endif