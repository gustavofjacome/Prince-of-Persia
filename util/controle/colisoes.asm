.text
.globl checar_colisao

# ============================================================
# FUNÇÃO: checar_colisao
# ============================================================
checar_colisao:
    addiu $sp, $sp, -28
    sw $ra, 24($sp)
    sw $s0, 20($sp)
    sw $s1, 16($sp)
    sw $s2, 12($sp)
    sw $s3, 8($sp)
    sw $s4, 4($sp)
    sw $s5, 0($sp)

    move $s0, $a0  # X base
    move $s1, $a1  # Y base
    li $s2, 0      # Maior colisão encontrada

    # Verificação de 6 pontos (Bounding Box 9x42)
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

    srl $t0, $a0, 4      # tile_X (X / 16)
    srl $t1, $a1, 4      # tile_Y (Y / 16)

    sll $t2, $t1, 5      # tile_Y * 32
    addu $t2, $t2, $t0   # + tile_X
    sll $t2, $t2, 2      # * 4 bytes

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