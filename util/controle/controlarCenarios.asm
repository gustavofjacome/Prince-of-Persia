.text
.globl controlesCenario

controlesCenario:
    jal acionarCaracter

    li $t0, 114               # ASCII 'r' (Reset)
    beq $v0, $t0, reset_jogo
    li $t0, 120               # ASCII 'x' (Sair)
    beq $v0, $t0, fim_jogo

    lw $t1, prince_x          
    lw $t2, prince_y          
    li $t3, 10                # Velocidade do passo

    li $t0, 113               # ASCII 'q' (Pulo Diagonal Esquerda)
    beq $v0, $t0, pulo_esquerda
    li $t0, 119               # ASCII 'w' (Pulo)
    beq $v0, $t0, iniciar_pulo
    li $t0, 101               # ASCII 'e' (Pulo Diagonal Direita)
    beq $v0, $t0, pulo_direita
    li $t0, 115               # ASCII 's'
    beq $v0, $t0, move_s
    li $t0, 97                # ASCII 'a'
    beq $v0, $t0, move_a
    li $t0, 100               # ASCII 'd'
    beq $v0, $t0, move_d

    j aplicar_fisica

# ============================================================
# LÓGICA DE MOVIMENTO COM PROTEÇÃO DE PILHA (CALLER-SAVED)
# ============================================================

iniciar_pulo:
    lw $t0, no_chao
    beqz $t0, aplicar_fisica
    li $t0, -16
    sw $t0, velocidade_y
    sw $zero, velocidade_x
    li $t0, 0
    sw $t0, no_chao
    j aplicar_fisica

pulo_esquerda:
    lw $t0, no_chao
    beqz $t0, aplicar_fisica
    li $t0, -16
    sw $t0, velocidade_y
    li $t0, -5
    sw $t0, velocidade_x
    li $t0, 0
    sw $t0, no_chao
    li $t0, -1
    sw $t0, direcao
    j aplicar_fisica

pulo_direita:
    lw $t0, no_chao
    beqz $t0, aplicar_fisica
    li $t0, -16
    sw $t0, velocidade_y
    li $t0, 5
    sw $t0, velocidade_x
    li $t0, 0
    sw $t0, no_chao
    li $t0, 1
    sw $t0, direcao
    j aplicar_fisica


move_s:
    addu $t4, $t2, $t3           
    move $a0, $t1
    move $a1, $t4
    
    addiu $sp, $sp, -4
    sw $t4, 0($sp)
    jal checar_colisao
    lw $t4, 0($sp)
    addiu $sp, $sp, 4

    li $t5, 2
    beq $v0, $t5, morte_personagem
    li $t5, 1
    beq $v0, $t5, aplicar_fisica
    sw $t4, prince_y
    j aplicar_fisica


move_a:
    subu $t4, $t1, $t3           
    move $a0, $t4                
    move $a1, $t2                
    
    addiu $sp, $sp, -4
    sw $t4, 0($sp)
    jal checar_colisao
    lw $t4, 0($sp)
    addiu $sp, $sp, 4

    li $t5, 2
    beq $v0, $t5, morte_personagem
    li $t5, 1
    beq $v0, $t5, aplicar_fisica
    sw $t4, prince_x
    li $t0, -1
    sw $t0, direcao
    j aplicar_fisica


move_d:
    addu $t4, $t1, $t3           
    move $a0, $t4
    move $a1, $t2
    
    addiu $sp, $sp, -4
    sw $t4, 0($sp)
    jal checar_colisao
    lw $t4, 0($sp)
    addiu $sp, $sp, 4

    li $t5, 2
    beq $v0, $t5, morte_personagem
    li $t5, 1
    beq $v0, $t5, aplicar_fisica
    sw $t4, prince_x
    li $t0, 1
    sw $t0, direcao
    j aplicar_fisica

# ============================================================
# SISTEMA DE PULO E FÍSICA
# ============================================================

aplicar_fisica:
    lw $t0, no_chao
    bnez $t0, verificar_chao
    j aplicar_gravidade

verificar_chao:
    lw $a0, prince_x
    lw $a1, prince_y
    addiu $a1, $a1, 1
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    jal checar_colisao
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    li $t5, 2
    beq $v0, $t5, morte_personagem
    bnez $v0, depois_fisica

    li $t0, 0
    sw $t0, no_chao
    sw $t0, velocidade_y

aplicar_gravidade:
    lw $t1, velocidade_y
    addiu $t1, $t1, 1
    sw $t1, velocidade_y

    lw $t2, prince_y
    addu $t3, $t2, $t1

    lw $a0, prince_x
    move $a1, $t3
    addiu $sp, $sp, -12
    sw $ra, 8($sp)
    sw $t1, 4($sp)
    sw $t3, 0($sp)
    jal checar_colisao
    lw $t1, 4($sp)
    lw $t3, 0($sp)
    lw $ra, 8($sp)
    addiu $sp, $sp, 12

    li $t4, 2
    beq $v0, $t4, morte_personagem
    li $t4, 1
    beq $v0, $t4, bateu_objeto
    sw $t3, prince_y
    j depois_drift

bateu_objeto:
    bgez $t1, pousar_chao

    li $t1, 0
    sw $t1, velocidade_y
    j depois_drift


pousar_chao:
    addu $t5, $t3, 41
    srl $t5, $t5, 4
    sll $t5, $t5, 4
    addiu $t5, $t5, -42

    sw $t5, prince_y
    li $t1, 0
    sw $t1, velocidade_y
    sw $zero, velocidade_x
    li $t1, 1
    sw $t1, no_chao
    j depois_drift

depois_drift:
    lw $t0, velocidade_x
    beqz $t0, depois_fisica

    lw $t1, prince_x
    addu $t2, $t1, $t0

    move $a0, $t2
    lw $a1, prince_y
    addiu $sp, $sp, -12
    sw $ra, 8($sp)
    sw $t0, 4($sp)
    sw $t2, 0($sp)
    jal checar_colisao
    lw $t0, 4($sp)
    lw $t2, 0($sp)
    lw $ra, 8($sp)
    addiu $sp, $sp, 12

    li $t3, 2
    beq $v0, $t3, morte_personagem
    li $t3, 1
    beq $v0, $t3, parar_drift_x

    sw $t2, prince_x
    j depois_fisica

parar_drift_x:
    sw $zero, velocidade_x
    j depois_fisica

depois_fisica:
    lw $t0, cenario_atual
    li $t1, 2
    beq $t0, $t1, verificar_inimigo
    j verifica_limites

verificar_inimigo:
    lw $t0, prince_x
    lw $t1, inimigo_x
    addiu $t1, $t1, 38
    bge $t0, $t1, depois_inimigo

    lw $t0, prince_x
    addiu $t0, $t0, 8
    lw $t1, inimigo_x
    blt $t0, $t1, depois_inimigo

    lw $t0, prince_y
    lw $t1, inimigo_y
    addiu $t1, $t1, 49
    bge $t0, $t1, depois_inimigo

    lw $t0, prince_y
    addiu $t0, $t0, 41
    lw $t1, inimigo_y
    blt $t0, $t1, depois_inimigo

    j morte_personagem

depois_inimigo:
    j verifica_limites

# ============================================================

morte_personagem:
    li $t1, 45
    sw $t1, prince_x
    li $t2, 54               # Chão Perfeito
    sw $t2, prince_y
    li $t3, 0
    sw $t3, velocidade_y
    li $t3, 1
    sw $t3, no_chao
    j vai_para_cenario_0

verifica_limites:
    lw $t1, prince_x
    li $t4, 0
    blt $t1, $t4, trava_esquerda
    li $t4, 491
    bge $t1, $t4, transicao_direita
    j redirecionar_cenario

trava_esquerda:
    li $t1, 0
    sw $t1, prince_x
    j redirecionar_cenario

transicao_direita:
    lw $t0, cenario_atual
    li $t4, 1
    beq $t0, $t4, vai_para_cenario_2
    li $t4, 2
    beq $t0, $t4, vai_para_cenario_0
    j redirecionar_cenario

vai_para_cenario_2:
    li $t0, 2
    sw $t0, cenario_atual
    li $t0, 1
    sw $t0, atualizar_fundo
    li $t1, 10
    sw $t1, prince_x
    li $t2, 54               # Chão Perfeito (mesma lógica do reset/morte)
    sw $t2, prince_y
    li $t3, 0
    sw $t3, velocidade_y
    li $t3, 1
    sw $t3, no_chao
    j redirecionar_cenario

vai_para_cenario_0:
    li $t0, 0
    sw $t0, cenario_atual
    li $t0, 1
    sw $t0, atualizar_fundo
    j redirecionar_cenario

reset_jogo:
    li $t0, 1
    sw $t0, cenario_atual
    li $t0, 1
    sw $t0, atualizar_fundo
    li $t1, 45
    sw $t1, prince_x
    li $t2, 54               # Chão Perfeito
    sw $t2, prince_y
    li $t3, 0
    sw $t3, velocidade_y
    li $t3, 1
    sw $t3, no_chao
    j redirecionar_cenario

redirecionar_cenario:
    lw $t0, cenario_atual
    li $t1, 1
    beq $t0, $t1, renderizarCenarioUm
    li $t1, 2
    beq $t0, $t1, renderizarCenarioDois
    j renderizarCenarioZero

fim_jogo:
    li $v0, 10
    syscall

existeCaracter:
    lui $t0, 0xFFFF
    lw $t1, 0($t0)
    and $v0, $t1, 1
    jr $ra

acionarCaracter:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal existeCaracter
    beq $v0, $zero, sem_tecla
    lui $t0, 0xFFFF
    lw $v0, 4($t0)
    j fim_acionar

sem_tecla:
    li $v0, 0
fim_acionar:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra