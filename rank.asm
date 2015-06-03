rDATA     SEGMENT
          rINFO DB  "The record is: ", '$'
          rNOHI DB  "(No record now)", 0AH, 0DH, '$'
          RECOD DB  512 DUP(0)
          FNAME DB  'HI1024', 0                         ;存储最高分的文件名
          FCODE DW  ?                                   ;存储文件代号
          FLEN  DW  0001H                               ;存储文件长度
          CLSER DB  "CLOSE FILE ERROR!!", '$'
          nfER  DB  "SAVE FILE ERROR!!", '$'
rDATA     ENDS

rCODE     SEGMENT
  HISCORE PROC        FAR
            ASSUME    CS:rCODE, DS:rDATA
            MOV       AX, rDATA
            MOV       DS, AX

            CLS
            PRINT     rINFO
            CALL      GESCR
            CMP       RECOD, 00H
            JE        NORCD
            MOV       AL, RECOD
            CALL      PRVIE
            CRLF
            JMP       hiRE

    NORCD:  PRINT     rNOHI

    hiRE:   GETC
            RET
  HISCORE ENDP

  GESCR   PROC
            ASSUME    CS:rCODE, DS:rDATA
            CALL      OPFIL

            MOV       AH, 3FH                           ;读文件
            MOV       BX, FCODE
            MOV       CX, FLEN
            LEA       DX, RECOD
            INT       21H

            CALL      CLSFIL
            RET
  GESCR   ENDP

  SAVSCR  PROC      FAR
          PUSH      DS
          ASSUME    CS:rCODE, DS:rDATA
          MOV       CX, rDATA
          MOV       DS, CX

          PUSH      AX
          CALL      GESCR
          POP       BX
          CMP       RECOD, BL
          JNB       ssRE
          MOV       RECOD, BL
          CALL      OPFIL
          MOV       AH, 40H
          MOV       BX, FCODE
          MOV       CX, 0001H
          LEA       DX, RECOD
          INT       21H
          CALL      CLSFIL

    ssRE: POP       DS
          RET
  SAVSCR  ENDP

  OPFIL   PROC
    opST:   ASSUME    CS:rCODE, DS:rDATA
            MOV       AH, 3DH                           ;打开文件
            MOV       AL, 02H                           ;访问方式为读写文件
            LEA       DX, FNAME
            INT       21H
            JNC       SUC                               ;打开成功
            CALL      NEWFIL
            JMP       opST
            
    SUC:    MOV       FCODE, AX                         ;保存文件代号
            MOV       AX, 4202H                         ;移动文件指针为尾指针
            MOV       BX, FCODE
            MOV       CX, 00H
            MOV       DX, 00H
            INT       21H

            ADD       AX, 01H                           ;计算文件长度
            ADC       DX, 00H               
            MOV       FLEN, AX
            MOV       FLEN + 2, DX
            MOV       AX, 4200H                         ;移动文件指针为头指针
            MOV       BX, FCODE
            MOV       CX, 00H
            MOV       DX, 00H
            INT       21H
          
    opRE:   RET
  OPFIL   ENDP

  NEWFIL  PROC
            ASSUME    CS:rCODE, DS:rDATA
            
            MOV       AH, 3CH                           ;新建文件
            MOV       CX, 0000H                         ;设置文件属性
            LEA       DX, FNAME
            INT       21H
            JNC       nfSC
            LEA       DX, nfER
            MOV       AH, 09H
            INT       21H
            JMP       neRE

    nfSC:   MOV       FCODE, AX                         ;保存文件代号
            MOV       AH, 40H                           ;写文件
            MOV       BX, FCODE
            MOV       CX, FLEN
            LEA       DX, RECOD
            INT       21H
            
            CALL      CLSFIL
    neRE:   RET
  NEWFIL  ENDP

  CLSFIL  PROC
            ASSUME    CS:rCODE, DS:rDATA
            MOV       AH, 3EH                           ;关闭文件
            MOV       BX, FCODE
            INT       21H
            JNC       clRE
            LEA       DX, CLSER
            MOV       AH, 09H
            INT       21H
    clRE:   RET
  CLSFIL  ENDP

rCODE     ENDS
