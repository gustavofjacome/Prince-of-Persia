.text
.globl controlesCenario

# ============================================================
# FUNÇÃO: controlesCenario
# ============================================================
# Descrição:
#   Responsável por controlar toda a lógica principal do jogo:
#
#   - Leitura do teclado
#   - Movimentação do personagem
#   - Troca de cenários
#   - Reinício do jogo
#   - Encerramento da execução
#
# Teclas disponíveis:
#   W -> Move para cima
#   A -> Move para esquerda
#   S -> Move para baixo
#   D -> Move para direita
#   R -> Reinicia o jogo
#   X -> Encerra o jogo
#
# Fluxo:
#   Ler tecla -> Atualizar posição -> Verificar limites
#   -> Trocar cenário (se necessário)
#   -> Renderizar cenário atual
# ============================================================

controlesCenario:

    # --------------------------------------------------------
    # Lê teclado (não bloqueante)
    # Retorna ASCII da tecla em $v0
    # --------------------------------------------------------
    jal acionarCaracter

# ============================================================
# VERIFICAÇÃO DAS TECLAS DE SISTEMA
# ============================================================

    # --------------------------------------------------------
    # Tecla R -> Reiniciar jogo
    # --------------------------------------------------------
    li $t0, 114               # ASCII 'r'
    beq $v0, $t0, reset_jogo

    # --------------------------------------------------------
    # Tecla X -> Encerrar jogo
    # --------------------------------------------------------
    li $t0, 120               # ASCII 'x'
    beq $v0, $t0, fim_jogo

# ============================================================
# CARREGA POSIÇÃO ATUAL DO PERSONAGEM
# ============================================================

    lw $t1, prince_x          # X atual
    lw $t2, prince_y          # Y atual

    li $t3, 15                # Velocidade de movimento

# ============================================================
# VERIFICAÇÃO DAS TECLAS DE MOVIMENTO
# ============================================================

    # W -> Cima
    li $t0, 119               # ASCII 'w'
    beq $v0, $t0, move_w

    # S -> Baixo
    li $t0, 115               # ASCII 's'
    beq $v0, $t0, move_s

    # A -> Esquerda
    li $t0, 97                # ASCII 'a'
    beq $v0, $t0, move_a

    # D -> Direita
    li $t0, 100               # ASCII 'd'
    beq $v0, $t0, move_d

    # Nenhuma tecla pressionada
    j verifica_limites


# ============================================================
# MOVIMENTAÇÃO DO PERSONAGEM
# ============================================================

move_w:

    # Move para cima
    subu $t2, $t2, $t3
    sw $t2, prince_y

    j verifica_limites


move_s:

    # Move para baixo
    addu $t2, $t2, $t3
    sw $t2, prince_y

    j verifica_limites


move_a:

    # Move para esquerda
    subu $t1, $t1, $t3
    sw $t1, prince_x

    j verifica_limites


move_d:

    # Move para direita
    addu $t1, $t1, $t3
    sw $t1, prince_x

    j verifica_limites


# ============================================================
# CONTROLE DE LIMITES DA TELA
# ============================================================
# Impede que o personagem saia da tela.
# Também controla a mudança entre cenários.
# ============================================================

verifica_limites:

    # Carrega posição X atualizada
    lw $t1, prince_x

    # --------------------------------------------------------
    # Parede esquerda
    # --------------------------------------------------------
    li $t4, 0

    blt $t1, $t4, trava_esquerda

    # --------------------------------------------------------
    # Parede direita
    # --------------------------------------------------------
    li $t4, 500

    bge $t1, $t4, transicao_direita

    j redirecionar_cenario


# ============================================================
# TRAVA DA PAREDE ESQUERDA
# ============================================================

trava_esquerda:

    # Impede X negativo
    li $t1, 0

    sw $t1, prince_x

    j redirecionar_cenario


# ============================================================
# TRANSIÇÃO ENTRE CENÁRIOS
# ============================================================

transicao_direita:

    # Descobre qual cenário está ativo
    lw $t0, cenario_atual

    # --------------------------------------------------------
    # Cenário 1 -> Cenário 2
    # --------------------------------------------------------
    li $t4, 1
    beq $t0, $t4, vai_para_cenario_2

    # --------------------------------------------------------
    # Cenário 2 -> Menu Final
    # --------------------------------------------------------
    li $t4, 2
    beq $t0, $t4, vai_para_cenario_0

    j redirecionar_cenario


# ============================================================
# TRANSIÇÃO PARA O CENÁRIO 2
# ============================================================

vai_para_cenario_2:

    # Atualiza estado do jogo
    li $t0, 2
    sw $t0, cenario_atual

    # Força redesenho completo do cenário
    li $t0, 1
    sw $t0, atualizar_fundo

    # Posiciona personagem no início da nova tela
    li $t1, 10
    sw $t1, prince_x

    j renderizarCenarioDois


# ============================================================
# TRANSIÇÃO PARA O MENU FINAL
# ============================================================

vai_para_cenario_0:

    # Define cenário atual
    li $t0, 0
    sw $t0, cenario_atual

    # Força redesenho completo
    li $t0, 1
    sw $t0, atualizar_fundo

    j renderizarCenarioZero


# ============================================================
# REINICIAR JOGO
# ============================================================
# Retorna ao estado inicial:
#   Cenário 1
#   Posição inicial do personagem
# ============================================================

reset_jogo:

    # Cenário inicial
    li $t0, 1
    sw $t0, cenario_atual

    # Força renderização completa
    li $t0, 1
    sw $t0, atualizar_fundo

    # Coordenada X inicial
    li $t1, 45
    sw $t1, prince_x

    # Coordenada Y inicial
    li $t2, 75
    sw $t2, prince_y

    j renderizarCenarioUm


# ============================================================
# REDIRECIONADOR DE CENÁRIOS
# ============================================================
# Escolhe qual rotina de renderização deve ser chamada
# conforme o valor de cenario_atual.
# ============================================================

redirecionar_cenario:

    lw $t0, cenario_atual

    # Cenário 1
    li $t1, 1
    beq $t0, $t1, renderizarCenarioUm

    # Cenário 2
    li $t1, 2
    beq $t0, $t1, renderizarCenarioDois

    # Menu principal
    j renderizarCenarioZero


# ============================================================
# ENCERRAMENTO DO JOGO
# ============================================================

fim_jogo:

    li $v0, 10
    syscall


# ============================================================
# FUNÇÃO: existeCaracter
# ============================================================
# Descrição:
#   Verifica se existe uma tecla disponível no
#   dispositivo MMIO do teclado.
#
# Retorno:
#   $v0 = 1 -> Existe tecla
#   $v0 = 0 -> Não existe tecla
#
# Endereço MMIO:
#   0xFFFF0000 -> Controle do teclado
# ============================================================

existeCaracter:

    lui $t0, 0xFFFF

    lw $t1, 0($t0)

    and $v0, $t1, 1

    jr $ra


# ============================================================
# FUNÇÃO: acionarCaracter
# ============================================================
# Descrição:
#   Realiza leitura não bloqueante do teclado.
#
# Retorno:
#   $v0 = Código ASCII da tecla pressionada
#   $v0 = 0 caso nenhuma tecla esteja disponível
#
# Endereços MMIO:
#   0xFFFF0000 -> Status do teclado
#   0xFFFF0004 -> Dado do teclado
# ============================================================

acionarCaracter:

    # Salva endereço de retorno
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # Verifica se existe tecla disponível
    jal existeCaracter

    # Nenhuma tecla pressionada
    beq $v0, $zero, sem_tecla

    # Lê caractere digitado
    lui $t0, 0xFFFF
    lw $v0, 4($t0)

    j fim_acionar


# ============================================================
# Nenhuma tecla disponível
# ============================================================

sem_tecla:

    li $v0, 0


# ============================================================
# Finalização da leitura
# ============================================================

fim_acionar:

    # Restaura endereço de retorno
    lw $ra, 0($sp)
    addi $sp, $sp, 4

    jr $ra