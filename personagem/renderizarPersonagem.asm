# =============================================================================
# renderizarPersonagem.asm  -  funcoes de renderizacao do personagem
# =============================================================================
# renderizar_sprite:
#   Desenha um sprite na tela com transparencia.
#   Pixels com valor 0x00000000 sao ignorados (transparentes).
#   Argumentos: a0=endereco do sprite, a1=x, a2=y, a3=largura, t0=altura
# -----------------------------------------------------------------------------
# restaurar_fundo_sprite:
#   Restaura o fundo do cenario na area ocupada pelo sprite.
#   Copia pixels do buffer do cenario de volta para o framebuffer.
#   Argumentos: a0=endereco do cenario, a1=x, a2=y, a3=largura, t0=altura
# =============================================================================
.text
.globl renderizar_sprite
renderizar_sprite:
    addiu $sp, $sp, -24
    sw $ra, 20($sp)
    sw $s0, 16($sp)
    sw $s1, 12($sp)
    sw $s2, 8($sp)
    sw $s3, 4($sp)
    sw $s4, 0($sp)
    li $s0, 0x10010000
    li $s1, 512
    mul $s2, $a2, $s1
    addu $s2, $s2, $a1
    sll $s2, $s2, 2
    addu $s0, $s0, $s2
    move $s2, $t0
    move $s3, $a0
    li $s4, 0x00000000
loop_linha_sprite:
    beqz $s2, fim_render_sprite
    move $t1, $a3
    move $t2, $s0
loop_coluna_sprite:
    beqz $t1, proxima_linha_sprite
    lw $t3, 0($s3)
    beq $t3, $s4, skip_pixel_sprite
    sw $t3, 0($t2)
skip_pixel_sprite:
    addiu $s3, $s3, 4
    addiu $t2, $t2, 4
    addiu $t1, $t1, -1
    j loop_coluna_sprite
proxima_linha_sprite:
    sll $t4, $s1, 2
    addu $s0, $s0, $t4
    addiu $s2, $s2, -1
    j loop_linha_sprite
fim_render_sprite:
    lw $ra, 20($sp)
    lw $s0, 16($sp)
    lw $s1, 12($sp)
    lw $s2, 8($sp)
    lw $s3, 4($sp)
    lw $s4, 0($sp)
    addiu $sp, $sp, 24
    jr $ra
.globl restaurar_fundo_sprite
restaurar_fundo_sprite:
    addiu $sp, $sp, -24
    sw $ra, 20($sp)
    sw $s0, 16($sp)
    sw $s1, 12($sp)
    sw $s2, 8($sp)
    sw $s3, 4($sp)
    sw $s4, 0($sp)
    li $s0, 0x10010000
    move $s1, $a0
    li $s2, 512
    mul $t1, $a2, $s2
    addu $t1, $t1, $a1
    sll $t1, $t1, 2
    addu $s0, $s0, $t1
    addu $s1, $s1, $t1
    move $s3, $t0
loop_linha_restaura:
    beqz $s3, fim_restaura
    move $t2, $a3
    move $t3, $s0
    move $t4, $s1
loop_coluna_restaura:
    beqz $t2, proxima_linha_restaura
    lw $t5, 0($t4)
    sw $t5, 0($t3)
    addiu $t4, $t4, 4
    addiu $t3, $t3, 4
    addiu $t2, $t2, -1
    j loop_coluna_restaura
proxima_linha_restaura:
    sll $t6, $s2, 2
    addu $s0, $s0, $t6
    addu $s1, $s1, $t6
    addiu $s3, $s3, -1
    j loop_linha_restaura
fim_restaura:
    lw $ra, 20($sp)
    lw $s0, 16($sp)
    lw $s1, 12($sp)
    lw $s2, 8($sp)
    lw $s3, 4($sp)
    lw $s4, 0($sp)
    addiu $sp, $sp, 24
    jr $ra