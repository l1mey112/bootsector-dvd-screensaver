[BITS 16]

%define VGA_WIDTH  (640 / 8)
%define VGA_HEIGHT 480

%define BASEVELOCITY 1

struc rectdef
	.x:      resw 1
	.y:      resw 1
endstruc

mov bp, sp

mov ax, 0011h
int 0x10

push 0xA0000 / 16  ; x86 segment 
pop es             ; to vram

draw_loop:

	; sleep

		mov al, 0
		mov ah, 0x86
		mov dx, 0xAFFF
		mov cx, 0x0
		int 0x15

	; this barely works half of the time

		mov dx, 0x03DA
	.ret1:
		in al, dx
		test al, 8
		jz .ret1
	.ret2:
		in al, dx
		test al, 8
		jnz .ret2

	; clear drawn portion

		mov bl, 0
		call draw_rect

	; add velocities to position

		mov ax, word [velocity.x]
		add word [rect + rectdef.x], ax
		mov ax, word [velocity.y]
		add word [rect + rectdef.y], ax

	; draw image

		mov bl, 1
		call draw_rect

jmp draw_loop

velocity.x: dw BASEVELOCITY
velocity.y: dw BASEVELOCITY * 8

%define IMAGE_SCANLINE_AMT 16
%define SCANLINE_BYTE_LEN 10 ; index by 10 for each x scanline
%define IMAGE_RECT_WIDTH 5

rect:
istruc rectdef
	at rectdef.x,      dw VGA_WIDTH / 2
	at rectdef.y,      dw VGA_HEIGHT / 2
iend


; AX: (*rect)
; BL: clear?
draw_rect:
	mov bp, sp

	mov ax, [rect + rectdef.x]
	add ax, IMAGE_RECT_WIDTH
	push ax
	mov cx, [rect + rectdef.x]
	sub cx, IMAGE_RECT_WIDTH
	push cx

	cmp ax, VGA_WIDTH
	jge .s1
	cmp cx, 0
	jnle .s2
	mov word [velocity.x], BASEVELOCITY
	jmp .s2
	.s1:
	mov word [velocity.x], -BASEVELOCITY
	.s2:

	mov ax, [rect + rectdef.y]
	add ax, IMAGE_SCANLINE_AMT
	push ax
	mov cx, [rect + rectdef.y]
	sub cx, IMAGE_SCANLINE_AMT
	push cx

	cmp ax, VGA_HEIGHT
	jge .s3	
	cmp cx, 0
	jnle .s4
	mov word [velocity.y], (BASEVELOCITY * 8)
	jmp .s4
	.s3:
	mov word [velocity.y], (-BASEVELOCITY * 8)
	.s4:	

	; bp - 2  | x + w
	; bp - 4  | x - w
	; bp - 6  | y + h
	; bp - 8  | y - h

	mov ax, 0
	mov dx, [bp - 8]
	vloop:
		mov di, dx
		imul di, VGA_WIDTH
		add di, [bp - 4]

		imul si, ax, SCANLINE_BYTE_LEN - 1 ; the negative one might cause issues but it's good for now
		add si, image_dvd

	hloop:
		mov cx, SCANLINE_BYTE_LEN - 1

		test bl, bl
		je .zero
		
		rep movsb
		
		jmp .next
	.zero:
		push ax
		mov ax, 0
		rep stosd
		pop ax
	.next:

		inc ax
		inc dx
		cmp dx, [bp - 6]
		jne vloop

	mov sp, bp
	ret

image_dvd: 
incbin "dvd/rawdvdbytes"
image_dvd_end:

%if $-$$ > 512
	%error ----- exeeded 512 bytes ----- 
%endif