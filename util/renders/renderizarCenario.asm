.text

# ============================================================
# FUNÇÃO: render_cenario
# ============================================================
# Descrição:
#   Renderiza um cenário completo no framebuffer.
#
# Parâmetros:
#   $a0 -> Endereço base do cenário
#   $a1 -> Largura do cenário
#   $a2 -> Altura do cenário
#
# Funcionamento:
#   Percorre todos os pixels do cenário e copia para
#   o framebuffer. Pixels com valor 0xFFFFFFFF são
#   considerados transparentes e não são desenhados.
# ============================================================

render_cenario:

    # --------------------------------------------------------
    # Salva registradores utilizados pela função
    # --------------------------------------------------------
    addiu $sp, $sp, -16
    sw $ra, 12($sp)
    sw $t0, 8($sp)
    sw $t1, 4($sp)
    sw $t2, 0($sp)

    # --------------------------------------------------------
    # Inicializa framebuffer
    # --------------------------------------------------------
    li $t0, 0x10010000      # Endereço base da memória de vídeo

    # --------------------------------------------------------
    # Calcula quantidade total de pixels
    # total_pixels = largura × altura
    # --------------------------------------------------------
    mul $t3, $a1, $a2

# ============================================================
# Loop principal de renderização
# ============================================================

loop_render:

    # Se não existem mais pixels para desenhar
    beqz $t3, end_render

    # Lê pixel atual do cenário
    lw $t4, 0($a0)

    # Cor usada como transparência
    li $t5, 0xFFFFFFFF

    # Se o pixel for transparente não desenha
    beq $t4, $t5, skip_draw

    # Copia pixel para o framebuffer
    sw $t4, 0($t0)

skip_draw:

    # Avança para o próximo pixel do cenário
    addiu $a0, $a0, 4

    # Avança para o próximo pixel da tela
    addiu $t0, $t0, 4

    # Diminui contador de pixels restantes
    addiu $t3, $t3, -1

    j loop_render

# ============================================================
# Finalização da função
# ============================================================

end_render:

    # Restaura registradores
    lw $ra, 12($sp)
    lw $t0, 8($sp)
    lw $t1, 4($sp)
    lw $t2, 0($sp)

    addiu $sp, $sp, 16

    # Retorna ao chamador
    jr $ra


# ============================================================
# FUNÇÃO: espera
# ============================================================
# Descrição:
#   Pausa a execução do programa por um período
#   especificado em milissegundos.
#
# Parâmetros:
#   $a0 -> Tempo em milissegundos
#
# Syscall utilizada:
#   32 = Sleep
# ============================================================

espera:

    li $v0, 32
    syscall

    jr $ra


# ============================================================
# FUNÇÃO: renderizarCenarioUm
# ============================================================
# Descrição:
#   Responsável por atualizar e desenhar o cenário 1.
#
# Estratégia:
#   - Primeiro frame: desenha cenário completo.
#   - Próximos frames: restaura apenas a região onde
#     o personagem estava anteriormente.
#   - Desenha o personagem na nova posição.
# ============================================================

renderizarCenarioUm:

    # Verifica se o cenário precisa ser redesenhado
    lw $t0, atualizar_fundo
    beqz $t0, skip_fundo_um

    # --------------------------------------------------------
    # Desenha cenário completo
    # --------------------------------------------------------
    la $a0, cenario1
    lw $a1, cenario1_width
    lw $a2, cenario1_height

    jal render_cenario

    # Marca que o fundo já foi desenhado
    li $t0, 0
    sw $t0, atualizar_fundo

    j desenhar_principe_um

skip_fundo_um:

    # --------------------------------------------------------
    # Restaura apenas a área antiga do personagem
    # --------------------------------------------------------
    la $a0, cenario1

    lw $a1, prince_old_x
    lw $a2, prince_old_y

    li $a3, 9
    li $t0, 42

    jal restaurar_fundo_sprite

desenhar_principe_um:

    # --------------------------------------------------------
    # Desenha personagem na posição atual
    # --------------------------------------------------------
    la $a0, prince_idle_right

    lw $a1, prince_x
    lw $a2, prince_y

    li $a3, 9
    li $t0, 42

    jal renderizar_sprite

    # --------------------------------------------------------
    # Atualiza posição anterior
    # --------------------------------------------------------
    lw $t0, prince_x
    sw $t0, prince_old_x

    lw $t1, prince_y
    sw $t1, prince_old_y

    # Pequena pausa do game loop
    li $a0, 15
    jal espera

    # Retorna ao controle principal
    j controlesCenario


# ============================================================
# FUNÇÃO: renderizarCenarioDois
# ============================================================
# Descrição:
#   Responsável pela renderização do cenário 2.
#   Utiliza exatamente a mesma lógica do cenário 1, 
#   adicionando o inimigo autônomo.
# ============================================================

renderizarCenarioDois:

    lw $t0, atualizar_fundo
    beqz $t0, skip_fundo_dois

    # --------------------------------------------------------
    # Desenha cenário completo
    # --------------------------------------------------------
    la $a0, cenario_2

    lw $a1, cenario_2_width
    lw $a2, cenario_2_height

    jal render_cenario

    li $t0, 0
    sw $t0, atualizar_fundo

    j desenhar_principe_dois

skip_fundo_dois:

    # --------------------------------------------------------
    # Remove rastro do personagem
    # --------------------------------------------------------
    la $a0, cenario_2

    lw $a1, prince_old_x
    lw $a2, prince_old_y

    li $a3, 9
    li $t0, 42

    jal restaurar_fundo_sprite

desenhar_principe_dois:

    # --------------------------------------------------------
    # Desenha personagem
    # --------------------------------------------------------
    la $a0, prince_idle_right

    lw $a1, prince_x
    lw $a2, prince_y

    li $a3, 9
    li $t0, 42

    jal renderizar_sprite

    # --------------------------------------------------------
    # Atualiza posição anterior do Príncipe
    # --------------------------------------------------------
    lw $t0, prince_x
    sw $t0, prince_old_x

    lw $t1, prince_y
    sw $t1, prince_old_y

    # ============================================================
    # LÓGICA DO INIMIGO AUTÔNOMO
    # ============================================================

    # 1. Restaura apenas a área antiga do inimigo (Dirty Rectangle)
    la $a0, cenario_2
    lw $a1, inimigo_old_x
    lw $a2, inimigo_old_y
    li $a3, 39                  # Largura exata do inimigo
    li $t0, 50                  # Altura exata do inimigo
    jal restaurar_fundo_sprite

    # 2. Chama a física autônoma (faz o Y subir ou descer)
    jal atualizar_inimigos

    # 3. Desenha o inimigo na nova posição
    la $a0, inimigo_frame1
    lw $a1, inimigo_x
    lw $a2, inimigo_y
    li $a3, 39
    li $t0, 50
    jal renderizar_sprite

    # ============================================================
    # FIM DA LÓGICA DO INIMIGO
    # ============================================================

    # Delay do game loop
    li $a0, 15
    jal espera

    # Retorna ao controle principal
    j controlesCenario


# ============================================================
# FUNÇÃO: renderizarCenarioZero
# ============================================================
# Descrição:
#   Renderiza o menu principal do jogo.
#
# Não utiliza sistema de restauração porque o menu
# é uma tela estática.
# ============================================================

renderizarCenarioZero:

    # Carrega imagem do menu principal
    la $a0, menu_principal

    lw $a1, menu_principal_width
    lw $a2, menu_principal_height

    # Desenha o menu
    jal render_cenario

    # Retorna para o controlador principal
    j controlesCenario