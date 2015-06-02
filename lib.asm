PRINT MACRO A
      PUSH  DX
      PUSH  AX
      LEA   DX, A
      MOV   AH, 09H
      INT   21H
      POP   AX
      POP   DX
      ENDM
      
DELY  MACRO
      LOCAL DLY1, DLY2
      MOV   CX, 0FFFH
DLY1: PUSH  CX
      MOV   CX, 0FFFFH
DLY2: AND   CX, CX
      LOOP  DLY2
      POP   CX
      LOOP  DLY1
      ENDM

CRLF  MACRO
      PUSH  AX
      PUSH  DX
      MOV   AH, 02H
      MOV   DL, 0AH
      INT   21H
      MOV   DL, 0DH
      INT   21H
      POP   DX
      POP   AX
      ENDM

GETC  MACRO
      PUSH  BX
      MOV   BH, AH
      MOV   AH, 08H
      INT   21H
      MOV   AH, BH
      POP   BX
      ENDM

CLS   MACRO
      PUSH  AX
      PUSH  BX
      PUSH  CX
      PUSH  DX
      MOV   AH, 06H      ;开始调用6号功能清屏
      MOV   AL, 00H      ;AL=00H 全屏
      MOV   BH, 07H      ;BH=07H 黑底白字
      MOV   CX, 00H      ;CX=00H 从0，0开始
      MOV   DX, 184FH    ;DX=184FH 到24, 79
      INT   10H
      MOV   AH, 02H      ;调用2号功能重置光标位置
      MOV   BH, 00H      ;BH=00H 0页
      MOV   DX, 00H      ;DX=00H 0, 0位置
      INT   10H
      POP   DX
      POP   CX
      POP   BX
      POP   AX
      ENDM