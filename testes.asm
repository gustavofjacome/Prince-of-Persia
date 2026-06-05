.data

.include "cenarios/stage0.asm"		# Local onde está o arquivo do menu inicial
.include "cenarios/stage1.asm" 			#local onde esta o arquivo do cenario 1
.include "cenarios/stage2.asm" 		#local onde esta o arquivo do cenario 2


.text
.globl main

main:

    li $t6, 100
    add $t3, $zero, $t6
    li $t7, 125
    li $t8, 0xFFFFFF
    li $s7, 50
    add $s6, $zero $s7
    li $t4, 10
    
    jal desenhar_retangulo

    # =========================================
    # STAGE 0
    # =========================================
    
    la $a0, menu_principal
    lw $a1, menu_principal_width
    lw $a2, menu_principal_height
    
    jal render_cenario_espelhado
    li $a0, 5000
    jal espera

    # =========================================
    # STAGE 1
    # =========================================

    la $a0, cenario1
    lw $a1, cenario1_width
    lw $a2, cenario1_height

    jal render_cenario_espelhado

    li $a0, 5000
    jal espera


    # =========================================
    # STAGE 2
    # =========================================

    la $a0, cenario_2
    lw $a1, cenario_2_width
    lw $a2, cenario_2_height

    jal render_cenario_espelhado

    li $a0, 5000
    jal espera


    # =========================================
    # FIM
    # =========================================

    li $v0, 10
    syscall


# =========================================
# FUNÇÃO: render_cenario_espelhado
# a0 = endereço do cenário
# a1 = width
# a2 = height
# =========================================

render_cenario_espelhado:

    addiu $sp, $sp, -24
    sw $ra, 20($sp)
    sw $t0, 16($sp)
    sw $t1, 12($sp) # Contador de altura Y
    sw $t2, 8($sp)  # Contador de largura X
    sw $t3, 4($sp)  # Ponteiro de leitura da linha atual
    sw $s0, 0($sp)

    li $t0, 0x10010000     # Início do framebuffer

    li $t1, 0               # y = 0
loop_altura_esp:
    beq $t1, $a2, end_render_esp # Se y == height, termina

    # Cálculo: endereço do início desta linha no cenário
    # Posição = base + (y * width * 4)
    mul $t3, $t1, $a1
    sll $t3, $t3, 2
    addu $t3, $a0, $t3

    # Cálculo: endereço do ÚLTIMO pixel desta linha
    # End_Final = (Inicio_Linha) + (width * 4) - 4
    sll $t4, $a1, 2
    addu $t3, $t3, $t4
    addiu $t3, $t3, -4      # $t3 agora aponta para o último pixel da linha atual

    li $t2, 0               # x = 0
loop_largura_esp:
    beq $t2, $a1, proxima_linha_esp 

    lw $s0, 0($t3)  

    li $t4, 0xFFFFFFFF
    beq $s0, $t4, skip_draw_esp

    sw $s0, 0($t0)          # Escreve no framebuffer

skip_draw_esp:
    addiu $t0, $t0, 4       # Avança FB
    addiu $t3, $t3, -4      # Retrocede no cenário (dentro da linha)
    addiu $t2, $t2, 1       # x++
    j loop_largura_esp

proxima_linha_esp:
    addiu $t1, $t1, 1       # y++
    j loop_altura_esp

end_render_esp:
    lw $ra, 20($sp)
    lw $t0, 16($sp)
    lw $t1, 12($sp)
    lw $t2, 8($sp)
    lw $t3, 4($sp)
    lw $s0, 0($sp)
    addiu $sp, $sp, 24

    jr $ra


# =========================================
# FUNÇÃO: espera (ms)
# a0 = tempo em ms
# =========================================

espera:

    li $v0, 32
    syscall
    jr $ra
    
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

   jr $ra 
   