# =============================================================================
# controlarCenariosEspelhado.asm  -  controle de cenario modo espelhado
# =============================================================================
# controlesCenarioEspelhado:
#   Loop de controle do cenario no modo espelhado (horizontal).
#   Mapeia teclas: 'j'(106)=cenario1, 'k'(107)=cenario2, 'r'(114)=menu,
#   'x'(120)=sair.
# -----------------------------------------------------------------------------
# existeCaracterEspelhado:
#   Verifica se um caractere foi pressionado no hardware.
#   Retorna: v0=1 se houve tecla, 0 senao.
# -----------------------------------------------------------------------------
# acionarCaracterEspelhado:
#   Espera ate que uma tecla seja pressionada e retorna seu codigo.
#   Retorna: v0=codigo da tecla pressionada.
# =============================================================================
.text
controlesCenarioEspelhado:
    li $s2, 106
    li $s3, 107
    li $s4, 114
    li $s5, 120
    jal acionarCaracterEspelhado
    beq $v0, $s4, renderizarCenarioZeroEspelhado
    beq $v0, $s2, renderizarCenarioUmEspelhado
    beq $v0, $s3, renderizarCenarioDoisEspelhado
    beq $v0, $s5, fim
    j controlesCenarioEspelhado
existeCaracterEspelhado:
    lui $t0, 0xFFFF
    lw $t1, 0($t0)
    and $v0, $t1, 1
    jr $ra
acionarCaracterEspelhado:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    li $v0, 0
    acionarCaracterLoopEspelhado:
    jal existeCaracter
    beq $v0, $zero, acionarCaracterLoopEspelhado
    lui $t0, 0xFFFF
    lw $v0, 4($t0)
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
