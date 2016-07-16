assume cs:code

data segment
    a db	 45
	b db	   3
data ends

code segment
start:
	mov	ax,	data
	mov ds, ax
	XOR ax,ax
	mov al, a                  
	mov bl, b
	div bl 
	
	mov bl,10
	div bl
	mov bh,ah
	
	mov dl, al
	add dl,30h
	mov ah,2
	int 21h  
	
	mov dl,bh
	add dl,30h
	mov ah,2
	int 21h
	mov ax,004ch
	int 21h
code ends
end start
