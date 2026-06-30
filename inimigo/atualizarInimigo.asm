# =============================================================================
# atualizarInimigo.asm  -  inteligencia artificial basica do inimigo
# =============================================================================
# atualizar_inimigos:
#   Movimenta o inimigo verticalmente (animacao de pulo/bounce).
#   A cada 100 frames a direcao do movimento eh invertida.
#   Variaveis: inimigo_y, inimigo_jump_dir, inimigo_jump_count
#   Se inimigo_jump_dir = 1: sobe (y decrementa)
#   Se inimigo_jump_dir = -1: desce (y incrementa)
# =============================================================================
.text
.globl atualizar_inimigos
atualizar_inimigos:
    lw $t0, inimigo_y
    sw $t0, inimigo_old_y
    lw $t1, inimigo_jump_dir
    lw $t2, inimigo_jump_count
    li $t3, 1
    li $t4, 100
    li $t5, 1
    beq $t1, $t5, inimigo_sobe
inimigo_desce:
    addu $t0, $t0, $t3
    addu $t2, $t2, $t3
    bge $t2, $t4, inverte_para_subir
    j salvar_inimigo
inimigo_sobe:
    subu $t0, $t0, $t3
    addu $t2, $t2, $t3
    bge $t2, $t4, inverte_para_descer
    j salvar_inimigo
inverte_para_subir:
    li $t1, 1
    sw $t1, inimigo_jump_dir
    li $t2, 0
    j salvar_inimigo
inverte_para_descer:
    li $t1, -1
    sw $t1, inimigo_jump_dir
    li $t2, 0
salvar_inimigo:
    sw $t0, inimigo_y
    sw $t2, inimigo_jump_count
    jr $ra