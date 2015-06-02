rDATA     SEGMENT
          rINFO DB   "The record is:", 0AH, 0DH, '$'
rDATA     ENDS

rCODE     SEGMENT
  HISCORE PROC      FAR
          ASSUME    CS:rCODE, DS:rDATA
          MOV       AX, rDATA
          MOV       DS, AX

          CLS
          PRINT     rINFO
          GETC
          
          RET
  HISCORE ENDP
rCODE     ENDS
