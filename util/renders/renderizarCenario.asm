# =============================================================================
# renderizarCenario.asm  -  renderizacao de cenarios
# =============================================================================
# render_cenario:
#   Desenha um cenario no framebuffer a partir de um buffer de pixels.
#   Pixels com valor 0xFFFFFFFF sao ignorados (transparentes).
#   Argumentos: a0=endereco, a1=largura, a2=altura
# -----------------------------------------------------------------------------
# espera:
#   Pausa a execucao por um numero de milissegundos (syscall 32).
#   Argumento: a0=milissegundos
# -----------------------------------------------------------------------------
# renderizarCenarioUm:
#   Renderiza o cenario 1 com logica de atualizacao de fundo,
#   restauracao e desenho do principe (idle, pulo ou ataque).
# -----------------------------------------------------------------------------
# renderizarCenarioDois:
#   Renderiza o cenario 2, similar ao Um mas com logica de inimigo.
# -----------------------------------------------------------------------------
# renderizarCenarioZero:
#   Renderiza o menu principal (cenario 0).
# =============================================================================
.text
render_cenario:
    addiu $sp, $sp, -16
    sw $ra, 12($sp)
    sw $t0, 8($sp)
    sw $t1, 4($sp)
    sw $t2, 0($sp)
    li $t0, 0x10010000
    mul $t3, $a1, $a2
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
espera:
    li $v0, 32
    syscall
    jr $ra
renderizarCenarioUm:
    lw $t0, atualizar_fundo
    beqz $t0, skip_fundo_um
    la $a0, cenario1
    lw $a1, cenario1_width
    lw $a2, cenario1_height
    jal render_cenario
    li $t0, 0
    sw $t0, atualizar_fundo
    j desenhar_principe_um
skip_fundo_um:
    lw $t0, prince_x
    lw $t1, prince_old_x
    bne $t0, $t1, restaurar_um
    lw $t0, prince_y
    lw $t1, prince_old_y
    bne $t0, $t1, restaurar_um
    lw $t0, atacando
    bnez $t0, restaurar_um
    j desenhar_principe_um
restaurar_um:
    la $a0, cenario1
    lw $a1, prince_old_x
    lw $a2, prince_old_y
    li $a3, 65
    li $t0, 42
    jal restaurar_fundo_sprite
desenhar_principe_um:
    lw $t1, atacando
    bgtz $t1, ataque_um
    lw $t1, no_chao
    bnez $t1, sprite_idle_um
    lw $t2, direcao
    li $t3, 1
    beq $t2, $t3, pulo_dir_um
    la $a0, prince_jump_left
    li $a3, 50
    li $t0, 30
    j pos_principe_um
pulo_dir_um:
    la $a0, prince_jump_right
    li $a3, 50
    li $t0, 30
    j pos_principe_um
sprite_idle_um:
    lw $t2, direcao
    li $t3, 1
    beq $t2, $t3, idle_dir_um
    la $a0, prince_idle_left
    li $a3, 9
    li $t0, 42
    j pos_principe_um
idle_dir_um:
    la $a0, prince_idle_right
    li $a3, 9
    li $t0, 42
    j pos_principe_um
ataque_um:
    lw $t2, direcao
    li $t3, 1
    beq $t2, $t3, atk_dir_um
    la $a0, prince_attack_sword_left
    li $a3, 65
    li $t0, 32
    lw $a1, prince_x
    addiu $a1, $a1, -56
    lw $a2, prince_y
    jal renderizar_sprite
    j depois_render_um
atk_dir_um:
    la $a0, prince_attack_sword_right
    li $a3, 65
    li $t0, 32
    lw $a1, prince_x
    lw $a2, prince_y
    jal renderizar_sprite
    j depois_render_um
pos_principe_um:
    lw $a1, prince_x
    lw $a2, prince_y
    jal renderizar_sprite
depois_render_um:
    lw $t0, prince_x
    sw $t0, prince_old_x
    lw $t1, prince_y
    sw $t1, prince_old_y
    li $a0, 15
    jal espera
    j controlesCenario
renderizarCenarioDois:
    lw $t0, atualizar_fundo
    beqz $t0, skip_fundo_dois
    la $a0, cenario_2
    lw $a1, cenario_2_width
    lw $a2, cenario_2_height
    jal render_cenario
    li $t0, 0
    sw $t0, atualizar_fundo
    j desenhar_principe_dois
skip_fundo_dois:
    lw $t0, prince_x
    lw $t1, prince_old_x
    bne $t0, $t1, restaurar_dois
    lw $t0, prince_y
    lw $t1, prince_old_y
    bne $t0, $t1, restaurar_dois
    lw $t0, atacando
    bnez $t0, restaurar_dois
    j desenhar_principe_dois
restaurar_dois:
    la $a0, cenario_2
    lw $a1, prince_old_x
    lw $a2, prince_old_y
    li $a3, 65
    li $t0, 42
    jal restaurar_fundo_sprite
desenhar_principe_dois:
    lw $t1, atacando
    bgtz $t1, ataque_dois
    lw $t1, no_chao
    bnez $t1, sprite_idle_dois
    lw $t2, direcao
    li $t3, 1
    beq $t2, $t3, pulo_dir_dois
    la $a0, prince_jump_left
    li $a3, 50
    li $t0, 30
    j pos_principe_dois
pulo_dir_dois:
    la $a0, prince_jump_right
    li $a3, 50
    li $t0, 30
    j pos_principe_dois
sprite_idle_dois:
    lw $t2, direcao
    li $t3, 1
    beq $t2, $t3, idle_dir_dois
    la $a0, prince_idle_left
    li $a3, 9
    li $t0, 42
    j pos_principe_dois
idle_dir_dois:
    la $a0, prince_idle_right
    li $a3, 9
    li $t0, 42
    j pos_principe_dois
ataque_dois:
    lw $t2, direcao
    li $t3, 1
    beq $t2, $t3, atk_dir_dois
    la $a0, prince_attack_sword_left
    li $a3, 65
    li $t0, 32
    lw $a1, prince_x
    addiu $a1, $a1, -56
    lw $a2, prince_y
    jal renderizar_sprite
    j depois_render_dois
atk_dir_dois:
    la $a0, prince_attack_sword_right
    li $a3, 65
    li $t0, 32
    lw $a1, prince_x
    lw $a2, prince_y
    jal renderizar_sprite
    j depois_render_dois
pos_principe_dois:
    lw $a1, prince_x
    lw $a2, prince_y
    jal renderizar_sprite
depois_render_dois:
    lw $t0, prince_x
    sw $t0, prince_old_x
    lw $t1, prince_y
    sw $t1, prince_old_y
    lw $t0, inimigo_vivo
    beqz $t0, skip_inimigo
    la $a0, cenario_2
    lw $a1, inimigo_old_x
    lw $a2, inimigo_old_y
    li $a3, 39
    li $t0, 50
    jal restaurar_fundo_sprite
    jal atualizar_inimigos
    la $a0, inimigo_frame1
    lw $a1, inimigo_x
    lw $a2, inimigo_y
    li $a3, 39
    li $t0, 50
    jal renderizar_sprite
skip_inimigo:
    li $a0, 15
    jal espera
    j controlesCenario
renderizarCenarioZero:
    la $a0, menu_principal
    lw $a1, menu_principal_width
    lw $a2, menu_principal_height
    jal render_cenario
    j controlesCenario