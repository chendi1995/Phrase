data segment
   string1 db 'This is the first string.','$'
   string2 db 'This is the second string.','$'
   mess1 db 'NO MATCH',13,10,'$'
   mess2 db 'MATCH',13,10,'$'
 data ends
 
 code segment
   assume cs:code,ds:data,es:data
 start:
   push ds
   sub ax,ax     ;ax清零
   mov ax,data
   mov ds,ax
   mov es,ax     ;初始化
 
   lea si,string1
   lea di,string2
 
   ;字符串比较
 again:
    mov bl,byte ptr [di]
    cmp [si],bl
    jnz nzero    ;转到不等于
    add si,1
    add di,1
    cmp byte ptr [si],'$'
    jnz again
    
    ;两字符串等于的输出   
    mov dx,offset mess2
    mov ah,09h
    int 21h   
    mov ah,4ch
    int 21h

  ;不等于的输出
 nzero:
    mov dx,offset mess1
    mov ah,09h
    int 21h   
    mov ah,4ch
    int 21h
 
 code ends
   end start   
