# =============================================================================
# colisoes.asm  -  deteccao de colisoes com o cenario
# =============================================================================
# checar_colisao:
#   Verifica colisao em 6 pontos ao redor do personagem.
#   Chama obter_tile para cada ponto e atualiza o maior valor de colisao.
#   Argumentos: a0=x, a1=y  |  Retorna: v0=tipo de tile mais alto
# -----------------------------------------------------------------------------
# obter_tile:
#   Obtem o tipo de tile do mapa do cenario para uma dada coordenada.
#   Coordenadas fora dos limites retornam 1 (parede).
#   Argumentos: a0=x, a1=y  |  Retorna: v0=0(ar), 1(solido), 2(morte)
# -----------------------------------------------------------------------------
# atualizar_max_colisao:
#   Mantem em s2 o maior valor de colisao encontrado.
#   Argumento: v0=valor do tile  |  Saida: s2=max(s2, v0)
# =============================================================================
.text
.globl checar_colisao
checar_colisao:
    addiu $sp, $sp, -28
    sw $ra, 24($sp)
    sw $s0, 20($sp)
    sw $s1, 16($sp)
    sw $s2, 12($sp)
    sw $s3, 8($sp)
    sw $s4, 4($sp)
    sw $s5, 0($sp)
    move $s0, $a0
    move $s1, $a1
    li $s2, 0
    move $a0, $s0
    move $a1, $s1
    jal obter_tile
    jal atualizar_max_colisao
    addiu $a0, $s0, 8
    move $a1, $s1
    jal obter_tile
    jal atualizar_max_colisao
    move $a0, $s0
    addiu $a1, $s1, 21
    jal obter_tile
    jal atualizar_max_colisao
    addiu $a0, $s0, 8
    addiu $a1, $s1, 21
    jal obter_tile
    jal atualizar_max_colisao
    move $a0, $s0
    addiu $a1, $s1, 41
    jal obter_tile
    jal atualizar_max_colisao
    addiu $a0, $s0, 8
    addiu $a1, $s1, 41
    jal obter_tile
    jal atualizar_max_colisao
    move $v0, $s2
    lw $ra, 24($sp)
    lw $s0, 20($sp)
    lw $s1, 16($sp)
    lw $s2, 12($sp)
    lw $s3, 8($sp)
    lw $s4, 4($sp)
    lw $s5, 0($sp)
    addiu $sp, $sp, 28
    jr $ra
atualizar_max_colisao:
    bge $s2, $v0, fim_atualizar
    move $s2, $v0
fim_atualizar:
    jr $ra
obter_tile:
    bltz $a0, tile_parede
    bltz $a1, tile_parede
    li $t0, 512
    bge $a0, $t0, tile_parede
    li $t0, 256
    bge $a1, $t0, tile_parede
    srl $t0, $a0, 4
    srl $t1, $a1, 4
    sll $t2, $t1, 5
    addu $t2, $t2, $t0
    sll $t2, $t2, 2
    lw $t3, cenario_atual
    li $t4, 2
    beq $t3, $t4, ler_mapa_2
ler_mapa_1:
    la $t4, stage_map1
    j puxar_da_memoria
ler_mapa_2:
    la $t4, stage_map2
puxar_da_memoria:
    addu $t4, $t4, $t2
    lw $v0, 0($t4)
    jr $ra
tile_parede:
    li $v0, 1
    jr $ra