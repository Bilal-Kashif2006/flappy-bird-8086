%ifndef mus_asm
%define mus_asm

; Play PCM sound through Sound Blaster using Direct Mode
; Modified to use no stack and no function calls.


music:

    ; Print 'A' on the screen
    mov ah, 0eh
    mov al, 'A'
    int 10h

l11:

    ; Send DSP Command 10h
    mov dx, 22ch
.busy_dsp_command:
    in al, dx
    test al, 10000000b
    jnz .busy_dsp_command
    mov al, 10h
    out dx, al

    ; Send byte audio sample
    mov bx, [cs:sound_index]
    mov al, [cs:sound_data + bx]
.busy_dsp_sample:
    in al, dx
    test al, 10000000b
    jnz .busy_dsp_sample
    mov al, [cs:sound_data + bx]
    out dx, al

    ; Delay loop
    mov cx, 200 ; <-- change this value according to the speed of your computer
.loop_delay:
    nop
    loop .loop_delay

    ; Increment sound index and check if done
    inc word [cs:sound_index]
    ; cmp word [sound_index], 32768
    cmp word [cs:sound_index], 0xda00
    jb l11

    ; Return to DOS

	mov word[cs:sound_index],0
	jmp l11

;section .data

sound_index dw 0

sound_data:
    ; incbin "8BitMelodyModified.wav" ; 51,529 bytes
    ; incbin "fake abdullah bhai.wav" ; 51,529 bytes
    ; incbin "fake abdullah bhai.wav" ; 51,529 bytes
;    incbin "YAAR ABDULLAH BHAI.wav" ; 51,529 bytes
	;incbin "houdini 1.wav"
	;incbin "houdini 2.wav"
	incbin "houdini 3.wav"
	;incbin "houdini 4.wav"
	
%endif