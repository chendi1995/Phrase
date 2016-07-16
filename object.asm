data segment
mm db 4
x db 10
y db 5
f db 2
z db ?
buf db 'zzzzzz$'
data ends
code segment
assume cs:code,ds:data
start:
mov ax,data
mov ds,ax
xor ax,ax
mov al,y
mov bl,x
mul bl
mov z,al
xor ax,ax
mov al,z
mov bl,mm
div bl
mov z,al
xor ax,ax
mov al,z
mov bl,f
add ax,bx
mov z,al
lea dx,buf
mov ah,9
INT 21H
xor ax,ax
mov al,z
mov bl,10
div bl
mov bh,ah
mov dl,al
add dl,30h
mov ah,2
int 21h
mov dl,bh
add dl,30h
mov ah,2
int 21h
mov ah,4ch
int 21h
code ends
end start
