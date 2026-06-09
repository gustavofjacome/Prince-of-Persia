.text

# =========================================
# FUNÇÃO: posicionar_pixel
# s0 = área da memória
# t6 = coordenada X
# t7 = coordenada Y
# t8 = cor
# t9 = calcular o endereço onde o pixel 
#      vai ser desenhado na tela
#      E = Base + (Y * Largura + X) * 4
# =========================================    

tela_branca:

    li $t6, 0
    add $t3, $zero, $t6
    li $t7, 0
    li $t8, 0xFFFFFF
    li $s7, 512
    add $s6, $zero $s7
    li $t4, 256
    
    j desenhar_retangulo

posicionar_pixel:

    lui $s0, 0x1001

    sll $t9, $t7, 9
    addu $t9, $t6, $t9
    sll $t9, $t9, 2
    addu $t9, $t9, $s0

    sw $t8, 0($t9)
    jr $ra

    

desenhar_linha:

    addiu $sp, $sp, -8  # Reserva 8 bytes na pilha
    sw    $ra, 4($sp)   # Guarda o endereço de retorno da main
    sw    $s7, 0($sp)   # Guarda o valor original do contador
        
for_linha:

   jal posicionar_pixel
  
   addi $s7, $s7, -1
   addi $t6, $t6, 1  

   bnez $s7, for_linha

   lw $s7, 0($sp)   # Restaura o contador
   lw $ra, 4($sp)   # Restaura o endereço de retorno da main
   addiu $sp, $sp, 8   # Libera a pilha

   jr $ra 
   
desenhar_retangulo:

    addiu $sp, $sp, -8  # Reserva 8 bytes na pilha
    sw    $ra, 4($sp)   # Guarda o endereço de retorno da main
    sw    $s7, 0($sp)   # Guarda o valor original do contador
    
    
for_retangulo:

   jal desenhar_linha
   add $t6, $zero, $t3
   addi $t7, $t7, 1
   addi $t4, $t4, -1
   
   bnez $t4, for_retangulo
   
   lw $s7, 0($sp)   # Restaura o contador
   lw $ra, 4($sp)   # Restaura o endereço de retorno da main
   addiu $sp, $sp, 8   # Libera a pilha

   j renderizarAlunos
   jr $ra 
