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
   sub ax,ax     ;ax����
   mov ax,data
   mov ds,ax
   mov es,ax     ;��ʼ��
 
   lea si,string1
   lea di,string2
 
   ;�ַ����Ƚ�
 again:
    mov bl,byte ptr [di]
    cmp [si],bl
    jnz nzero    ;ת��������
    add si,1
    add di,1
    cmp byte ptr [si],'$'
    jnz again
    
    ;���ַ������ڵ����   
    mov dx,offset mess2
    mov ah,09h
    int 21h   
    mov ah,4ch
    int 21h

  ;�����ڵ����
 nzero:
    mov dx,offset mess1
    mov ah,09h
    int 21h   
    mov ah,4ch
    int 21h
 
 code ends
   end start   
