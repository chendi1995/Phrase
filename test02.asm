assume cs:code

data segment
    a db	4
	b db	10
	c db	?
data ends

code segment
start:
	mov	ax,	data
	mov ds, ax
	XOR ax,ax
	mov al, a
	mov bl, b
	add ax, bx
	mov c,al
	mov al,c
	mov dl, al
	add dl,30h
	mov ah,2
	int 21h
	mov ax,004ch
	int 21h
code ends
end start
