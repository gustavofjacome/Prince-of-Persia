# =============================================================================
# linhasRetangulos.asm  -  funcoes graficas basicas
# =============================================================================
# tela_branca:
#   Preenche toda a tela com a cor branca (0xFFFFFF).
#   Chama desenhar_retangulo com as dimensoes da tela (512x256).
# -----------------------------------------------------------------------------
# posicionar_pixel:
#   Desenha um pixel na posicao (t6, t7) com a cor t8.
#   t6=x, t7=y, t8=cor
# -----------------------------------------------------------------------------
# desenhar_linha:
#   Desenha uma linha horizontal a partir de (t6, t7).
#   s7 = comprimento da linha.
# -----------------------------------------------------------------------------
# desenhar_retangulo:
#   Desenha um retangulo preenchido usando desenhar_linha.
#   t3=x_inicial, t7=y_inicial, s7=largura, t4=altura, t8=cor
# =============================================================================
.text
tela_branca:
    li $t6, 0
    add $t3, $zero, $t6
    li $t7, 0
    li $t8, 0xFFFFFF
    li $s7, 512
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
    addiu $sp, $sp, -8
    sw $ra, 4($sp)
    sw $s7, 0($sp)
for_linha:
    jal posicionar_pixel
    addi $s7, $s7, -1
    addi $t6, $t6, 1
    bnez $s7, for_linha
    lw $s7, 0($sp)
    lw $ra, 4($sp)
    addiu $sp, $sp, 8
    jr $ra
desenhar_retangulo:
    addiu $sp, $sp, -8
    sw $ra, 4($sp)
    sw $s7, 0($sp)
for_retangulo:
    jal desenhar_linha
    add $t6, $zero, $t3
    addi $t7, $t7, 1
    addi $t4, $t4, -1
    bnez $t4, for_retangulo
    lw $s7, 0($sp)
    lw $ra, 4($sp)
    addiu $sp, $sp, 8
    j renderizarAlunos
