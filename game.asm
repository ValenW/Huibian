gDATA     SEGMENT
          CLT   EQU   0AH, 0DH
          gINFO DB    "Use w/s/a/d to move, Q to quit to the main menu", CLT, '$'
          VIEW  DB    "+-----+-----+-----+-----+", CLT
                DB    "+     +     +     +     +", CLT
                DB    "+     +     +     +     +", CLT
                DB    "+     +     +     +     +", CLT
                DB    "+-----+-----+-----+-----+", CLT
                DB    "+     +     +     +     +", CLT
                DB    "+     +     +     +     +", CLT
                DB    "+     +     +     +     +", CLT
                DB    "+-----+-----+-----+-----+", CLT
                DB    "+     +     +     +     +", CLT
                DB    "+     +     +     +     +", CLT
                DB    "+     +     +     +     +", CLT
                DB    "+-----+-----+-----+-----+", CLT
                DB    "+     +     +     +     +", CLT
                DB    "+     +     +     +     +", CLT
                DB    "+     +     +     +     +", CLT
                DB    "+-----+-----+-----+-----+", CLT, '$'
          VPIT  DW    0301H, 0307H, 030DH, 0313H
                DW    0701H, 0707H, 070DH, 0713H
                DW    0B01H, 0B07H, 0B0DH, 0B13H
                DW    0F01H, 0F07H, 0F0DH, 0F13H
                DW    1200H
          VTB   DB    "       2    4    8   16   32   64   128  256  512 1024 2048 4096 8192 ", '$'
          MODE  DB    10H DUP(0)
          QINFO DB    "Congratulations! Your score is ", '$'
          RECO  DW    0000H
          RECI  DW    0000H
          HISC  DB    01H
gDATA     ENDS

gCODE     SEGMENT

  RELIN   PROC
            ASSUME    CS:gCODE, DS:gDATA, ES:gDATA
            PUSH  DI
            PUSH  DX
            MOV   SI, DI

    lSTA:   CMP   DI, BX
            JE    lRE
            ADD   DI, RECI
            CMP   MODE[DI], 00H
            JE    lSTA
            CMP   MODE[SI], 00H
            JE    SWAP
            MOV   DL, MODE[SI]
            CMP   DL, MODE[DI]
            JE    COMB
            JMP   lRE

    SWAP:   MOV   DL, MODE[SI]
            XCHG  DL, MODE[DI]
            MOV   MODE[SI], DL
            JMP   lSTA

    COMB:   INC   DL
            MOV   MODE[SI], DL
            MOV   MODE[DI], 00H
            CMP   DL, HISC
            JNA   lSTA
            MOV   HISC, DL
            JMP   lSTA

    lRE:    POP   DX
            POP   DI
            RET
  RELIN   ENDP

  PUT1    PROC
            ASSUME    CS:gCODE, DS:gDATA, ES:gDATA
            MOV   CX, 0              ;CX初始为0
            MOV   AH, 0
            INT   1AH                ;读时钟计数器值到DX
            MOV   AX, DX
            AND   AH, 3              ;清高6位
            MOV   DL, 10H
            DIV   DL                 ;除16，产生0~15余数
            MOV   BX, 0FFFFH         ;BX初始化为-1
            ADD   AH, 01H
            MOV   CL, AH             ;CL中放余数

    AGAIN:  INC   BX
            CMP   BX, 000FH
            JA    TOOUT
            CMP   MODE[BX], 00H
            JNE   AGAIN
            LOOP  AGAIN
            MOV   MODE[BX], 01H
            JMP   RE

    TOOUT:  CMP   CL ,AH
            JE    RE
            MOV   BX, 0FFFFH
            JMP   AGAIN

    RE:     RET
  PUT1    ENDP

  REMOD   PROC
            ASSUME    CS:gCODE, DS:gDATA, ES:gDATA
            MOV       CX, 0004H
    STA:    PUSH      DI
            MOV       BX, DI
            ADD       BX, RECI
            ADD       BX, RECI
            ADD       BX, RECI
    REL:    CALL      RELIN
            ADD       DI, RECI
            CMP       DI, BX
            JNE       REL
            POP       DI
            ADD       DI, RECO
            LOOP      STA

            RET
  REMOD   ENDP

  PRVIE   PROC        FAR
            PUSH      DS
            PUSH      ES
            ASSUME    CS:gCODE, DS:gDATA, ES:gDATA
            MOV       CX, gDATA
            MOV       DS, CX
            
            PUSH      SI
            MOV       SI, 0000H
            CBW
            ADD       SI, AX
            SHL       AL, 1
            SHL       AL, 1           ;SI += AX * 5
            ADD       SI, AX          ;定位到输出字符串的头地址

            MOV       AH, 02H
            MOV       CX, 05H
    PRIL:   MOV       DL, VTB[SI]
            INT       21H             ;重复5次输出单个字符
            INC       SI
            LOOP      PRIL
            POP       SI

            POP       ES
            POP       DS
            RET
  PRVIE   ENDP

  REVEW   PROC
            ASSUME    CS:gCODE, DS:gDATA, ES:gDATA
            MOV       SI, 0000H
    vSTA:   MOV       AH, 02H
            MOV       BH, 00H
            MOV       BP, SI
            MOV       DX, VPIT[BP][SI]
            INT       10H             ;鼠标定位

            MOV       AL, MODE[SI]
            CALL      PRVIE
            INC       SI
            CMP       SI, 0010H
            JB        vSTA
            MOV       AH, 02H
            MOV       BH, 00H
            MOV       BP, SI
            MOV       DX, VPIT[BP][SI]
            INT       10H

            RET
  REVEW   ENDP

  GAME    PROC      FAR
            PUSH      DS
            PUSH      ES
            ASSUME    CS:gCODE, DS:gDATA, ES:gDATA
            MOV       AX, gDATA
            MOV       DS, AX
            MOV       ES, AX

            MOV       AL, 00H
            LEA       DI, MODE
            CLD
            MOV       CX, 0010H
            REP       STOSB
            MOV       HISC, 01H

            CLS
            PRINT     gINFO
            PRINT     VIEW
            
    START:  CALL      PUT1
            CALL      REVEW
    WIT:    GETC
            CMP       AL, 'w'
            JE        UP
            CMP       AL, 's'
            JE        DOWN
            CMP       AL, 'a'
            JE        LEFT
            CMP       AL, 'd'
            JE        RIGHT
            CMP       AL, 'W'
            JE        UP
            CMP       AL, 'S'
            JE        DOWN
            CMP       AL, 'A'
            JE        LEFT
            CMP       AL, 'D'
            JE        RIGHT
            CMP       AL, 'Q'
            JE        QUIT
            JMP       WIT
            
    UP:     MOV       DI, 0000H
            MOV       RECI, 0004H
            MOV       RECO, 0001H
            JMP       RENEW
            
    RIGHT:  MOV       DI, 000FH
            MOV       RECI, 0FFFFH
            MOV       RECO, 0FFFCH
            JMP       RENEW
            
    DOWN:   MOV       DI, 000FH
            MOV       RECI, 0FFFCH
            MOV       RECO, 0FFFFH
            JMP       RENEW
            
    LEFT:   MOV       DI, 0000H
            MOV       RECI, 0001H
            MOV       RECO, 0004H
            
    RENEW:  CALL      REMOD
            JMP       START
            
    QUIT:   PRINT     QINFO
            MOV       AL, HISC
            CALL      PRVIE
            MOV       AL, HISC
            CALL      SAVSCR
            POP       ES
            POP       DS
            DELY
            DELY
            
    EXT:    RET
  GAME    ENDP

gCODE     ENDS
