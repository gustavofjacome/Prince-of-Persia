.text

# =========================================
# FUNÇÃO: render_cenario
# a0 = endereço do cenário
# a1 = width (largura)
# a2 = height (altura)
# =========================================

render_cenario:
    addiu $sp, $sp, -16      # --> Abre 16 bytes na pilha (stack) para salvar registradores
    sw $ra, 12($sp)          # --> Salva o endereço de retorno
    sw $t0, 8($sp)           # --> Salva o registrador temporário $t0
    sw $t1, 4($sp)           # --> Salva o registrador temporário $t1
    sw $t2, 0($sp)           # --> Salva o registrador temporário $t2

    li $t0, 0x10010000       # --> Carrega o endereço base do framebuffer (início da memória de vídeo)
    mul $t3, $a1, $a2        # --> Multiplica largura x altura para obter o total de pixels a desenhar

loop_render:
    beqz $t3, end_render     # --> Se o total de pixels chegar a 0, termina a renderização

    lw $t4, 0($a0)           # --> Lê a cor do pixel atual do cenário (memória)

    li $t5, 0xFFFFFFFF       # --> Carrega a cor de transparência (branco) em $t5
    beq $t4, $t5, skip_draw  # --> Se a cor do pixel for igual à transparência, pula o desenho

    sw $t4, 0($t0)           # --> Desenha o pixel na tela (salva no framebuffer)

skip_draw:
    addiu $a0, $a0, 4        # --> Avança para o próximo pixel na memória do cenário (4 bytes)
    addiu $t0, $t0, 4        # --> Avança para o próximo pixel no framebuffer da tela (4 bytes)
    addiu $t3, $t3, -1       # --> Decrementa o contador de pixels restantes
    j loop_render            # --> Volta para desenhar o próximo pixel

end_render:
    lw $ra, 12($sp)          # --> Restaura o endereço de retorno
    lw $t0, 8($sp)           # --> Restaura o registrador $t0
    lw $t1, 4($sp)           # --> Restaura o registrador $t1
    lw $t2, 0($sp)           # --> Restaura o registrador $t2
    addiu $sp, $sp, 16       # --> Libera o espaço alocado na pilha
    jr $ra                   # --> Retorna para quem chamou a função

# =========================================
# FUNÇÃO: espera (ms)
# =========================================
espera:
    li $v0, 32               # --> Syscall 32: Sleep (pausa a execução)
    syscall                  # --> Executa a pausa com o tempo passado em $a0
    jr $ra                   # --> Retorna
    
# =========================================
# RENDERIZAÇÃO POR CONTROLE
# =========================================
    
renderizarCenarioUm:
    # --> 1. Desenha o cenário de fundo
    la $a0, cenario1         # --> Carrega o endereço do arquivo do cenário 1
    lw $a1, cenario1_width   # --> Carrega a largura do cenário 1
    lw $a2, cenario1_height  # --> Carrega a altura do cenário 1
    jal render_cenario       # --> Chama a função para desenhar o cenário na tela

    # --> 2. Desenha o Príncipe por cima do cenário
    la $a0, prince_idle_right # --> Carrega o endereço do sprite do personagem
    li $a1, 45                # --> Define a coordenada X (posição horizontal do boneco)
    li $a2, 75               # --> Define a coordenada Y (posição vertical / chão)
    li $a3, 9                 # --> Define a largura do sprite do Príncipe (9 pixels)
    li $t0, 42                # --> Define a altura do sprite do Príncipe (42 pixels)
    jal renderizar_sprite     # --> Chama a função de renderização do personagem

    j controlesCenario        # --> Volta a ler os comandos do teclado
    
renderizarCenarioDois:
    # --> 1. Desenha o cenário de fundo
    la $a0, cenario_2         # --> Carrega o endereço do arquivo do cenário 2
    lw $a1, cenario_2_width   # --> Carrega a largura do cenário 2
    lw $a2, cenario_2_height  # --> Carrega a altura do cenário 2
    jal render_cenario        # --> Chama a função para desenhar o cenário na tela
    
    # --> 2. Desenha o Príncipe por cima do cenário
    la $a0, prince_idle_right # --> Carrega o endereço do sprite do personagem
    li $a1, 80               # --> Define a coordenada X (posição horizontal do boneco)
    li $a2, 140               # --> Define a coordenada Y (posição vertical / chão)
    li $a3, 9                 # --> Define a largura do sprite do Príncipe (9 pixels)
    li $t0, 42                # --> Define a altura do sprite do Príncipe (42 pixels)
    jal renderizar_sprite     # --> Chama a função de renderização do personagem

    j controlesCenario        # --> Volta a ler os comandos do teclado
    
renderizarCenarioZero:
    la $a0, menu_principal         # --> Carrega o endereço da tela de menu
    lw $a1, menu_principal_width   # --> Carrega a largura do menu
    lw $a2, menu_principal_height  # --> Carrega a altura do menu
    jal render_cenario             # --> Desenha o menu (sem o personagem por cima)
    j controlesCenario             # --> Volta a ler os comandos do teclado
    
