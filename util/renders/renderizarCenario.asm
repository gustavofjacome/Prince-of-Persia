.text

# =========================================
# FUNÇÃO: render_cenario
# a0 = endereço do cenário
# a1 = width
# a2 = height
# =========================================

render_cenario:

    addiu $sp, $sp, -16
    sw $ra, 12($sp)
    sw $t0, 8($sp)
    sw $t1, 4($sp)
    sw $t2, 0($sp)

    li $t0, 0x10010000   # framebuffer
    mul $t3, $a1, $a2    # total pixels

loop_render:

    beqz $t3, end_render

    lw $t4, 0($a0)

    li $t5, 0xFFFFFFFF
    beq $t4, $t5, skip_draw

    sw $t4, 0($t0)

skip_draw:

    addiu $a0, $a0, 4
    addiu $t0, $t0, 4
    addiu $t3, $t3, -1

    j loop_render


end_render:

    lw $ra, 12($sp)
    lw $t0, 8($sp)
    lw $t1, 4($sp)
    lw $t2, 0($sp)
    addiu $sp, $sp, 16

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
    # RENDERIZAÇÃO POR CONTROLE
    # =========================================
    
renderizarCenarioUm:

    la $a0, cenario1
    lw $a1, cenario1_width
    lw $a2, cenario1_height

    jal render_cenario

    j controlesCenario
    
renderizarCenarioDois:

    la $a0, cenario_2
    lw $a1, cenario_2_width
    lw $a2, cenario_2_height

    jal render_cenario
    
    j controlesCenario
    
renderizarCenarioZero:

    la $a0, menu_principal
    lw $a1, menu_principal_width
    lw $a2, menu_principal_height
    
    jal render_cenario
    
    j controlesCenario
    
renderizarAlunos:

    la $a0, alunos
    lw $a1, alunos_width
    lw $a2, alunos_height
    
    jal render_cenario
    
    j controlesCenario      
    
                                        
