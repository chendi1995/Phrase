data segment
	a db 05H
	b db 04H
data ends

code segment
assume cs:code,ds:data
start:	

mov ax,a
mov cx,b
add ax,cx
add al,30H
mov ah,02H
int 21h
code ends
end start
