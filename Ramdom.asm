MOV AH,0                
    INT 1AH               ;读时钟计数器值到DX   
    MOV AX,DX               
    AND AH,3              ;清高6位   
    MOV DL,9               
    DIV DL                ;除9，产生0~9余数   
    MOV BL,AH        ;BL中放余数