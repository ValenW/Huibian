INCLUDE   lib.asm
INCLUDE   game.asm
INCLUDE   rank.asm

STACK     SEGMENT   STACK
          DB        40H DUP(?)
STACK     ENDS

DATA      SEGMENT
          CLT       EQU    0AH, 0DH
          INFO      DB "Welcome to Valen's 1024!", CLT, CLT
                    DB "Pelease select one to continue:", CLT
                    DB "G(g)  -- To play 1024", CLT
                    DB "R(r)  -- To see the rank", CLT
                    DB "E(e)  -- exit", CLT, CLT, '$'
          EXINFO    DB "Thanks for using!", CLT, '$'
DATA      ENDS

CODE      SEGMENT
          ASSUME    CS:CODE, DS:DATA, SS:STACK
  MAIN:   MOV       AX, DATA
          MOV       DS, AX
          PRINT     INFO
  START:  GETC
          CMP       AL, 'G'
          JE        PLAY
          CMP       AL, 'g'
          JE        PLAY
          CMP       AL, 'R'
          JE        RANK
          CMP       AL, 'r'
          JE        RANK
          CMP       AL, 'E'
          JE        EXIT
          CMP       AL, 'e'
          JE        EXIT
          JMP       START
  PLAY:   CALL      GAME
          CLS
          JMP       MAIN
  RANK:   CALL      HISCORE
          CLS
          JMP       MAIN

  EXIT:   PRINT     EXINFO
          DELY

          MOV       AH, 4CH
          INT       21H
CODE      ENDS
          END       MAIN
