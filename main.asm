name "Calculator"   

include 'emu8086.inc'
org 100h
     
    v       dw ?     

    call    leia
    cbw
    mov     v[0], CX
    
    mov     SI, 0
    print   ' '
    mov     AH, 1
    int     21h
    cbw
    mov     v[2], AX
    
    mov     SI, 0
    print   ' '
    call    leia
    cbw
    mov     v[4], CX
    jmp     operacoes

;le
leia:    
    mov     v[10], 0b
le:
    mov     AH, 1
    int     21h
    
    cmp     AL, 2Dh
    jne     continue
    mov     v[10], 1b
    jmp     le 

continue:    
    sub     AL, 48
    cbw
    mov     BX, 100
    mov     AH, 0
    mul     BX
    mov     CX, AX

    mov     AH, 1
    int     21h 
    sub     AL, 48
    mov     BX, 10
    mov     AH, 0
    mul     BX
    add     CX, AX
    
    mov     AH, 1
    int     21h 
    sub     AL, 48
    mov     AH, 0
    add     CX, AX
    
    mov     AX, CX
    
    ;se negativo
    cmp     v[10], 1b
    jne     nada_a_fazer
    xor     CX, 1111111111111111b
    add     CX, 1 

nada_a_fazer:     
ret 

operacoes:

    print   ' = '
    
    cmp     v[2], 2Bh
    jne     negativo
    ;positivo          
    mov     AX, v[0]
    mov     BX, v[4]
    add     AX, BX
    mov     v[6], AX
    mov     v[8], 0b
    jmp     imprimir  
negativo:
    cmp     v[2], 2Dh
    jne     divisao
    mov     AX, v[0]
    mov     BX, v[4]                     
    xor     BX, 1111111111111111b
    add     BX, 1    
    add     AX, BX
    mov     v[6], AX
    mov     v[8], 0b
    jmp     imprimir
    
divisao:     
    cmp     v[2], 2Fh
    jne     multiplicacao
    mov     AX, v[0]
    mov     BX, v[4]
    cmp     v[4], 0
    je      divisaoporzero
    idiv    BL
    mov     BL, AH
    mov     BH, 0  
    mov     v[8], BX
    mov     AH, 0
    cbw 
    mov     v[6], AX  
    cmp     v[4], 0
    jmp    imprimir
divisaoporzero:
    print   'Divisao por zero'
    jmp     FINAL
             
multiplicacao:    
    cmp     v[2], 2Ah
    jne     fim
    mov     AX, v[0]
    mov     BX, v[4]
    imul    BX
    jno     not_over  
    jmp     over
not_over:
    mov     v[6], AX
    mov     v[8], 0b
    jmp     imprimir 

    
imprimir:
    cmp     v[6], 0
    jge     positivo
    mov     AX, v[6]
    xor     AX, 1111111111111111b
    add     AX, 1
    mov     v[6], AX
    print   '-'  
positivo:
    mov     CX, 0
    mov     DX, 0
    mov     AX, v[6]
    ;if ax = 0
looper:
    cmp     AX, 0
    je      printar
    
    ;pegar ultmo digito
    mov     BX, 10
    div     BX
    push    DX
    
    ;loop
    inc     CX
    mov     DX, 0
    jmp     looper
printar:
    ;olhar contador
    cmp     CX, 0
    je      ver_div
        
    pop     DX
    ;passar pro ASCII
    add     DX, 48
    mov     AH, 2
    int     21h
    ;voltar contador
    dec     CX
    jmp     printar
ver_div:
    cmp     v[8], 0h
    je      FINAL
    print   '.'


    mov     AX, v[4]
    cmp     AL, 0
    jge     b_resto
    xor     AX, 1111111111111111b
    add     AX, 1
    mov     v[4], AX
b_resto:        
    ;trata o resto
    mov     AX, v[8]
    cmp     AL, 0
    jge     beleuza
    xor     AX, 1111111111111111b
    add     AX, 1

beleuza:
    mov     BL, 10
    mul     BL
    mov     BX, v[4]
    div    BL
    mov     BH, AH
    
    mov     AH, 2
    mov     DL, AL    
    add     AL, 48
    mov     DL, AL
    int     21h
    
    mov     AL, BH
    mov     BL, 10
    mul     BL
    mov     BX, v[4]
    div     BL
    mov     BH, AH
    
    mov     AH, 2
    mov     DL, AL    
    add     AL, 48
    mov     DL, AL
    int     21h 
    jmp     FINAL




fim:
    printn  'Operacao Desconhecida'
    jmp     FINAL
ret    
over:
    printn  'Nao esta entre -32.768 e 32.767'
    
FINAL:
