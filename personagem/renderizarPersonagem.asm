.text

# ============================================================
# FUNÇÃO: renderizar_sprite
# ============================================================
# Descrição:
#   Desenha um sprite sobre o framebuffer (tela).
#   Pixels com valor 0x00000000 são considerados transparentes
#   e não são desenhados.
#
# Parâmetros:
#   $a0 -> Endereço base do sprite
#   $a1 -> Coordenada X onde o sprite será desenhado
#   $a2 -> Coordenada Y onde o sprite será desenhado
#   $a3 -> Largura do sprite (pixels)
#   $t0 -> Altura do sprite (pixels)
#
# Fórmula utilizada:
#   Endereço = BaseFramebuffer + ((Y * 512) + X) * 4
#
# Registradores utilizados:
#   $s0 -> Ponteiro para framebuffer
#   $s1 -> Largura da tela (512)
#   $s2 -> Contador de linhas do sprite
#   $s3 -> Ponteiro do sprite
#   $s4 -> Cor transparente
# ============================================================

.globl renderizar_sprite

renderizar_sprite:

    # --------------------------------------------------------
    # Salva contexto da função na pilha
    # --------------------------------------------------------
    addiu $sp, $sp, -24
    sw $ra, 20($sp)
    sw $s0, 16($sp)
    sw $s1, 12($sp)
    sw $s2, 8($sp)
    sw $s3, 4($sp)
    sw $s4, 0($sp)

    # --------------------------------------------------------
    # Inicializa informações da tela
    # --------------------------------------------------------
    li $s0, 0x10010000          # Endereço base do framebuffer
    li $s1, 512                 # Largura da tela em pixels

    # --------------------------------------------------------
    # Calcula posição inicial do sprite na tela
    #
    # offset = ((Y * larguraTela) + X) * 4
    # --------------------------------------------------------
    mul $s2, $a2, $s1
    addu $s2, $s2, $a1
    sll $s2, $s2, 2
    addu $s0, $s0, $s2

    # --------------------------------------------------------
    # Inicializa variáveis de controle
    # --------------------------------------------------------
    move $s2, $t0               # Altura do sprite
    move $s3, $a0               # Ponteiro do sprite
    li $s4, 0x00000000          # Cor transparente

# ============================================================
# Loop externo (linhas do sprite)
# ============================================================

loop_linha_sprite:

    # Se não restam linhas, termina
    beqz $s2, fim_render_sprite

    move $t1, $a3              # Contador de colunas
    move $t2, $s0              # Ponteiro da linha atual da tela

# ============================================================
# Loop interno (colunas do sprite)
# ============================================================

loop_coluna_sprite:

    # Se terminou a largura da linha
    beqz $t1, proxima_linha_sprite

    # Lê pixel atual do sprite
    lw $t3, 0($s3)

    # Ignora pixels transparentes
    beq $t3, $s4, skip_pixel_sprite

    # Desenha pixel no framebuffer
    sw $t3, 0($t2)

skip_pixel_sprite:

    # Avança para próximo pixel
    addiu $s3, $s3, 4
    addiu $t2, $t2, 4

    # Decrementa contador de colunas
    addiu $t1, $t1, -1

    # Continua na mesma linha
    j loop_coluna_sprite

# ============================================================
# Avança para próxima linha do framebuffer
# ============================================================

proxima_linha_sprite:

    # Calcula tamanho de uma linha inteira da tela
    # 512 pixels * 4 bytes
    sll $t4, $s1, 2

    # Desce uma linha no framebuffer
    addu $s0, $s0, $t4

    # Próxima linha do sprite
    addiu $s2, $s2, -1

    j loop_linha_sprite

# ============================================================
# Finalização da função
# ============================================================

fim_render_sprite:

    # Restaura contexto
    lw $ra, 20($sp)
    lw $s0, 16($sp)
    lw $s1, 12($sp)
    lw $s2, 8($sp)
    lw $s3, 4($sp)
    lw $s4, 0($sp)

    addiu $sp, $sp, 24

    # Retorna ao chamador
    jr $ra


# ============================================================
# FUNÇÃO: restaurar_fundo_sprite
# ============================================================
# Descrição:
#   Remove o rastro deixado pelo sprite restaurando
#   os pixels originais do cenário naquela região.
#
# Parâmetros:
#   $a0 -> Endereço base do cenário
#   $a1 -> X antigo do sprite
#   $a2 -> Y antigo do sprite
#   $a3 -> Largura do sprite
#   $t0 -> Altura do sprite
#
# Funcionamento:
#   Copia os pixels do cenário original para o
#   framebuffer exatamente na área ocupada pelo sprite.
# ============================================================

.globl restaurar_fundo_sprite

restaurar_fundo_sprite:

    # --------------------------------------------------------
    # Salva contexto
    # --------------------------------------------------------
    addiu $sp, $sp, -24

    sw $ra, 20($sp)
    sw $s0, 16($sp)
    sw $s1, 12($sp)
    sw $s2, 8($sp)
    sw $s3, 4($sp)
    sw $s4, 0($sp)

    # --------------------------------------------------------
    # Inicialização
    # --------------------------------------------------------
    li $s0, 0x10010000      # Framebuffer
    move $s1, $a0           # Cenário original
    li $s2, 512             # Largura da tela

    # --------------------------------------------------------
    # Calcula posição inicial da área a restaurar
    #
    # offset = ((Y * 512) + X) * 4
    # --------------------------------------------------------
    mul $t1, $a2, $s2
    addu $t1, $t1, $a1
    sll $t1, $t1, 2

    # Posiciona framebuffer e cenário
    addu $s0, $s0, $t1
    addu $s1, $s1, $t1

    # Altura do sprite
    move $s3, $t0

# ============================================================
# Loop das linhas
# ============================================================

loop_linha_restaura:

    beqz $s3, fim_restaura

    move $t2, $a3      # Largura
    move $t3, $s0      # Ponteiro framebuffer
    move $t4, $s1      # Ponteiro cenário

# ============================================================
# Loop das colunas
# ============================================================

loop_coluna_restaura:

    beqz $t2, proxima_linha_restaura

    # Copia pixel do cenário para a tela
    lw $t5, 0($t4)
    sw $t5, 0($t3)

    # Próximo pixel
    addiu $t4, $t4, 4
    addiu $t3, $t3, 4

    # Decrementa largura restante
    addiu $t2, $t2, -1

    j loop_coluna_restaura

# ============================================================
# Próxima linha
# ============================================================

proxima_linha_restaura:

    # Avança uma linha completa
    sll $t6, $s2, 2

    addu $s0, $s0, $t6
    addu $s1, $s1, $t6

    # Próxima linha do bloco
    addiu $s3, $s3, -1

    j loop_linha_restaura

# ============================================================
# Finalização
# ============================================================

fim_restaura:

    # Restaura contexto
    lw $ra, 20($sp)
    lw $s0, 16($sp)
    lw $s1, 12($sp)
    lw $s2, 8($sp)
    lw $s3, 4($sp)
    lw $s4, 0($sp)

    addiu $sp, $sp, 24

    # Retorna ao chamador
    jr $ra