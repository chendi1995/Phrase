SSEG SEGMENT PARA STACK 'stack'
    dw 100h dup(0) ;Resize the stack by changing the number '100'
SSEG ENDS

DSEG SEGMENT;TO DO: Add your program's data here
INFO1 DB 0DH,0AH,'--------------------------',0DH,0AH,'THERE ARE 3 SONGS:',0DH,0AH,0DH,0AH,'$'
INFO2 DB '1.HAPPY BIRTHDAY',0DH,0AH,'$'
INFO3 DB '2.SHEEP',0DH,0AH,'$'
INFO4 DB '3.RIVER',0DH,0AH,'$'
INFO5 DB '0.EXIT',0DH,0AH,'$'
INFO6 DB 'YOU HAVE CHOSEN :$'
INFO7 DB 'THANK YOU FOR YOUR USE',0DH,0AH,'$'
INFO8 DB '---------------------------',0DH,0AH,'PRESS THE KEY TO SELECT SONG!',0DH,0AH,'$'
INFO9 DB  0DH,0AH,'-------------------',0DH,0AH,'|INVALID SELECTION|',0DH,0AH,'-------------------',0DH,0AH,'$'
FREG1 DW  2 dup(262),294,262,349,262,262,294,262,392,249,262,262,523,440,349   ;曲1的频率
	DW  330,294,466,266,440,349,392,349,-1
TIME1 DW   1,1,2,2,2,4,1,1,2,2,2,4,1,1,2,2,2,2,4,1,1,2,2,2,4                   ;曲1的时间
FREG2 DW  330,294,262,294,3 DUP(330)                                 ;曲2的频率
	DW  3 DUP(294),330,392,392
	DW  330,294,262,294,4 DUP(330)
	DW  294,294,330,294,262, -1
TIME2 DW  6 DUP(1),2                                                 ;曲2的时间
	DW  2 DUP(1,1,2)
	DW 12 DUP(1),4
FREG3 DW  330,392,330,294,330,392,330,294,330,330,392,330,294,262,294,330,392,294 ;曲3的频率
	DW  262,262,220,196,220,262,294,332,262, -1
TIME3 DW  3 DUP(2),1,1,2,1,1,4                                          ;曲3的时间
	DW  2 DUP(2,2,1,1),4
	DW  3 DUP(2,1,1,1),4
DSEG ENDS

CSEG SEGMENT
  assume  cs:CSEG, ds:DSEG, es:DSEG, ss:SSEG
  
  INIT PROC ;Initialize procedure
  	mov ax, dseg
	mov ds, ax
	mov es, ax
	;TO DO: Add your initialize code here (as your requirement)

	ret    ;return to the MAIN procedure
  INIT ENDP

  MAIN PROC   ;Here is your program entry point
  	call INIT ;call the INIT procedure to initialize the program
  	;**TO DO: Add your main code here**
  RE: MOV DX,28BH        ;关闭扬声器
	MOV AL,89H
	OUT DX,AL
	MOV DX,28AH
	IN  AL,DX
	MOV DX,288H
	OUT DX,AL            
    
  	LEA DX,INFO1      ;输出说明信息
	MOV AH,09H
	INT 21H
	LEA DX,INFO2
	INT 21H
	LEA DX,INFO3
	INT 21H
	LEA DX,INFO4
	INT 21H
	LEA DX,INFO5
	INT 21H
	LEA DX,INFO8
	INT 21H

	MOV AH,01H       ;读取按键
	INT 21H
	CMP AL,'1'       ;根据不同的按键播放不同的曲子
	JE MUSIC1
	CMP AL,'2'
	JE MUSIC2
	CMP AL,'3'
	JE MUSIC3
	CMP AL,'0'
	JE EXIT

	LEA DX,INFO9        ;无效选择，输出错误提示
	MOV AH,09H
	INT 21H
	JMP RE
 
MUSIC1:
	MOV SI,OFFSET FREG1      ;指向曲1的表
	MOV BP,OFFSET TIME1
	CALL PLAY
	JMP RE
MUSIC2:
	MOV SI,OFFSET FREG2       ;指向曲2的表
	MOV BP,OFFSET TIME2
	CALL PLAY
	JMP RE
MUSIC3:
	MOV SI,OFFSET FREG3       ;指向曲3的表
	MOV BP,OFFSET TIME3
	CALL PLAY
	JMP RE
EXIT:
	MOV DX,28BH              ;关闭扬声器
	MOV AL,89H
	OUT DX,AL

	MOV DX,28AH
	IN  AL,DX
	MOV DX,288H
	OUT DX,AL

	LEA DX,INFO7            ;输出欢迎使用信息，增加界面友好度
	MOV AH,09H
	INT 21H
	mov ax, 4c00h  ;The end of the program, return to the system
  	int 21h
  MAIN ENDP
  ;TO DO: Add other procedures(PROC) here (as your requirement)
  ;THE PROGRAMME OF PLAYING THE MUSIC

  PLAY PROC                ;PLAY子程序，功能上面介绍过
  L1:	MOV BX,DS:[SI]    ;取频率
  	CMP BX,-1              ;看是否有效
  	JE L0                  ;无效就退出
  	MOV CX,DS:[BP]         ;读取时间
     MOV DL,CL              ;保存时间
     ADD DL,30H             
      MOV AH,02H
      INT 21H
      
      MOV DX,0FH            ;计算计数初值，1M的十六进制为0F4240H
      MOV AX,4240H
      DIV BX
      MOV BX,AX
      MOV DX,283H           ;设置计数器工作方式
      MOV AL,36H
      OUT DX,AL
      MOV DX,280H           ;输入计数初值
      MOV AX,BX
      OUT DX,AL
      MOV AL,AH
      OUT DX,AL
      
      MOV DX,28BH          ;开扬声器
	MOV AL,89H
	OUT DX,AL
	MOV DX,28AH
	IN  AL,DX
	NOT AL
	MOV DX,288H
	OUT DX,AL
  ROD:CALL DELAY          ;延时
  	LOOP ROD
    	MOV DX,28BH          ;关扬声器
	MOV AL,89H
	OUT DX,AL
	MOV DX,28AH
	IN  AL,DX
	MOV DX,288H
	OUT DX,AL
	CALL DELAY_OFF       ;音节间延时
  	ADD SI,2
  	ADD BP,2
  	JMP L1
  L0:	RET
  PLAY ENDP
  
    DELAY PROC                   ;延时子程序
  	PUSH AX
  	PUSH BX
  	PUSH CX
  	PUSH DX
    	MOV BX,09FH
LL1:	MOV CX,0FFFFH             ;循环这么多次
LOP:  LOOP LOP
	DEC BX
	JNZ LL1
	POP DX
  	POP CX
  	POP BX
  	POP AX
  	RET
  DELAY ENDP
  
  DELAY_OFF PROC
  		PUSH AX
  	PUSH BX
  	PUSH CX
  	PUSH DX
  
  	MOV BX,0FH
LL2:	MOV CX,0CFFFH
LOP2:  LOOP LOP2
	DEC BX
	JNZ LL2
	POP DX
  	POP CX
  	POP BX
  	POP AX
  	RET
DELAY_OFF ENDP
CSEG ENDS
;TO DO: Add other segments here (as your requirement)

END MAIN
