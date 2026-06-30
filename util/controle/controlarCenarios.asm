.text
.globl controlesCenario

# ===========================================================================
# controlesCenario: laco principal de controle do personagem
# Le a tecla pressionada e despacha para o movimento/fisica apropriados
# ===========================================================================
controlesCenario:
    jal acionarCaracter
    li $t0, 114
    beq $v0, $t0, reset_jogo
    li $t0, 120
    beq $v0, $t0, fim_jogo
    lw $t1, prince_x
    lw $t2, prince_y
    li $t3, 10
    li $t0, 113
    beq $v0, $t0, pulo_esquerda
    li $t0, 119
    beq $v0, $t0, iniciar_pulo
    li $t0, 101
    beq $v0, $t0, pulo_direita
    li $t0, 115
    beq $v0, $t0, iniciar_ataque
    li $t0, 97
    beq $v0, $t0, move_a
    li $t0, 100
    beq $v0, $t0, move_d
    j aplicar_fisica

# -----------------------------------------------------------------------
# iniciar_pulo: inicia um pulo vertical (tecla W)
# Soh pula se o personagem estiver no chao
# -----------------------------------------------------------------------
iniciar_pulo:
    lw $t0, no_chao
    beqz $t0, aplicar_fisica
    li $t0, -16
    sw $t0, velocidade_y
    sw $zero, velocidade_x
    li $t0, 0
    sw $t0, no_chao
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    jal play_som_pulo
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    j aplicar_fisica

# -----------------------------------------------------------------------
# pulo_esquerda: inicia um pulo diagonal para a esquerda (tecla Q)
# -----------------------------------------------------------------------
pulo_esquerda:
    lw $t0, no_chao
    beqz $t0, aplicar_fisica
    li $t0, -16
    sw $t0, velocidade_y
    li $t0, -5
    sw $t0, velocidade_x
    li $t0, 0
    sw $t0, no_chao
    li $t0, -1
    sw $t0, direcao
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    jal play_som_pulo
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    j aplicar_fisica

# -----------------------------------------------------------------------
# pulo_direita: inicia um pulo diagonal para a direita (tecla E)
# -----------------------------------------------------------------------
pulo_direita:
    lw $t0, no_chao
    beqz $t0, aplicar_fisica
    li $t0, -16
    sw $t0, velocidade_y
    li $t0, 5
    sw $t0, velocidade_x
    li $t0, 0
    sw $t0, no_chao
    li $t0, 1
    sw $t0, direcao
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    jal play_som_pulo
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    j aplicar_fisica

# -----------------------------------------------------------------------
# iniciar_ataque: executa um ataque (tecla S)
# Verifica cooldown e direcao, monta a hitbox e checa colisao com inimigo
# -----------------------------------------------------------------------
iniciar_ataque:
    lw $t0, atacando
    bnez $t0, aplicar_fisica
    lw $t0, ataque_cooldown
    bnez $t0, aplicar_fisica
    li $t0, 5
    sw $t0, atacando
    li $t0, 10
    sw $t0, ataque_cooldown
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    jal play_som_ataque
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    lw $t0, cenario_atual
    li $t1, 2
    bne $t0, $t1, aplicar_fisica
    lw $t0, direcao
    li $t1, 1
    beq $t0, $t1, atk_hitbox_dir
    lw $t2, prince_x
    lw $t3, prince_y
    addiu $t4, $t3, 32
    addiu $t5, $t2, -56
    addiu $t6, $t2, 9
    j check_atk_inimigo

# -----------------------------------------------------------------------
# atk_hitbox_dir: define a hitbox do ataque quando o personagem
# esta virado para a direita
# -----------------------------------------------------------------------
atk_hitbox_dir:
    lw $t2, prince_x
    lw $t3, prince_y
    addiu $t4, $t3, 32
    move $t5, $t2
    addiu $t6, $t2, 65

# -----------------------------------------------------------------------
# check_atk_inimigo: verifica se a hitbox do ataque colide com o inimigo
# Se colidir, decrementa a vida do inimigo
# -----------------------------------------------------------------------
check_atk_inimigo:
    lw $t0, inimigo_vivo
    beqz $t0, aplicar_fisica
    lw $t7, inimigo_x
    addiu $t9, $t7, 39
    blt $t6, $t7, aplicar_fisica
    bgt $t5, $t9, aplicar_fisica
    lw $t7, inimigo_y
    blt $t4, $t7, aplicar_fisica
    lw $t7, inimigo_y
    addiu $t7, $t7, 50
    bgt $t3, $t7, aplicar_fisica
    lw $t0, inimigo_vida
    addiu $t0, $t0, -1
    sw $t0, inimigo_vida
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    bgtz $t0, inimigo_atingido
    jal play_som_inimigo_morto
    j fim_som_golpe

# -----------------------------------------------------------------------
# inimigo_atingido: toca som de inimigo ferido (ainda vivo)
# -----------------------------------------------------------------------
inimigo_atingido:
    jal play_som_acerto_inimigo

# -----------------------------------------------------------------------
# fim_som_golpe: retorno apos tocar o som do golpe
# -----------------------------------------------------------------------
fim_som_golpe:
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    bgtz $t0, aplicar_fisica
    li $t0, 0
    sw $t0, inimigo_vivo
    li $t0, 1
    sw $t0, atualizar_fundo

# -----------------------------------------------------------------------
# move_a: move o personagem para a esquerda (tecla A)
# Checa colisao antes de atualizar a posicao X
# -----------------------------------------------------------------------
move_a:
    subu $t4, $t1, $t3           
    move $a0, $t4                
    move $a1, $t2                
    addiu $sp, $sp, -4
    sw $t4, 0($sp)
    jal checar_colisao
    lw $t4, 0($sp)
    addiu $sp, $sp, 4
    li $t5, 2
    beq $v0, $t5, morte_personagem
    li $t5, 1
    beq $v0, $t5, aplicar_fisica
    sw $t4, prince_x
    li $t0, -1
    sw $t0, direcao
    j aplicar_fisica

# -----------------------------------------------------------------------
# move_d: move o personagem para a direita (tecla D)
# Checa colisao antes de atualizar a posicao X
# -----------------------------------------------------------------------
move_d:
    addu $t4, $t1, $t3           
    move $a0, $t4
    move $a1, $t2
    addiu $sp, $sp, -4
    sw $t4, 0($sp)
    jal checar_colisao
    lw $t4, 0($sp)
    addiu $sp, $sp, 4
    li $t5, 2
    beq $v0, $t5, morte_personagem
    li $t5, 1
    beq $v0, $t5, aplicar_fisica
    sw $t4, prince_x
    li $t0, 1
    sw $t0, direcao
    j aplicar_fisica

# ===========================================================================
# aplicar_fisica: aplica as leis de fisica do jogo
# (gravidade, colisao com objetos, deriva horizontal)
# ===========================================================================
aplicar_fisica:
    lw $t0, no_chao
    bnez $t0, verificar_chao
    j aplicar_gravidade

# -----------------------------------------------------------------------
# verificar_chao: verifica se o personagem esta pisando no chao
# Se nao houver colisao abaixo, remove o estado no_chao
# -----------------------------------------------------------------------
verificar_chao:
    lw $a0, prince_x
    lw $a1, prince_y
    addiu $a1, $a1, 1
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    jal checar_colisao
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    li $t5, 2
    beq $v0, $t5, morte_personagem
    bnez $v0, depois_fisica
    li $t0, 0
    sw $t0, no_chao
    sw $t0, velocidade_y

# -----------------------------------------------------------------------
# aplicar_gravidade: aplica a forca gravitacional, calcula nova posicao Y
# e checa colisao vertical com objetos e plataformas
# -----------------------------------------------------------------------
aplicar_gravidade:
    lw $t1, velocidade_y
    addiu $t1, $t1, 1
    sw $t1, velocidade_y
    lw $t2, prince_y
    addu $t3, $t2, $t1
    lw $a0, prince_x
    move $a1, $t3
    addiu $sp, $sp, -12
    sw $ra, 8($sp)
    sw $t1, 4($sp)
    sw $t3, 0($sp)
    jal checar_colisao
    lw $t1, 4($sp)
    lw $t3, 0($sp)
    lw $ra, 8($sp)
    addiu $sp, $sp, 12
    li $t4, 2
    beq $v0, $t4, morte_personagem
    li $t4, 1
    beq $v0, $t4, bateu_objeto
    sw $t3, prince_y
    j depois_drift

# -----------------------------------------------------------------------
# bateu_objeto: o personagem colidiu com um objeto durante a queda
# Se estiver caindo (velocidade_y >= 0), faz pousar no chao
# -----------------------------------------------------------------------
bateu_objeto:
    bgez $t1, pousar_chao
    li $t1, 0
    sw $t1, velocidade_y
    j depois_drift

# -----------------------------------------------------------------------
# pousar_chao: ajusta a posicao Y para o topo da plataforma,
# zera as velocidades e marca como no_chao
# -----------------------------------------------------------------------
pousar_chao:
    addu $t5, $t3, 41
    srl $t5, $t5, 4
    sll $t5, $t5, 4
    addiu $t5, $t5, -42
    sw $t5, prince_y
    li $t1, 0
    sw $t1, velocidade_y
    sw $zero, velocidade_x
    li $t1, 1
    sw $t1, no_chao
    li $t1, 1
    sw $t1, atualizar_fundo
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    jal play_som_pouso
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    j depois_drift

# -----------------------------------------------------------------------
# depois_drift: aplica a deriva horizontal apos um pulo
# (velocidade_x residual durante o salto)
# -----------------------------------------------------------------------
depois_drift:
    lw $t0, velocidade_x
    beqz $t0, depois_fisica
    lw $t1, prince_x
    addu $t2, $t1, $t0
    move $a0, $t2
    lw $a1, prince_y
    addiu $sp, $sp, -12
    sw $ra, 8($sp)
    sw $t0, 4($sp)
    sw $t2, 0($sp)
    jal checar_colisao
    lw $t0, 4($sp)
    lw $t2, 0($sp)
    lw $ra, 8($sp)
    addiu $sp, $sp, 12
    li $t3, 2
    beq $v0, $t3, morte_personagem
    li $t3, 1
    beq $v0, $t3, parar_drift_x
    sw $t2, prince_x
    j depois_fisica

# -----------------------------------------------------------------------
# parar_drift_x: interrompe a deriva horizontal ao colidir com objeto
# -----------------------------------------------------------------------
parar_drift_x:
    sw $zero, velocidade_x
    j depois_fisica

# ===========================================================================
# depois_fisica: processa atualizacoes apos a fisica
# Decrementa contadores de ataque e verifica cenario/inimigo
# ===========================================================================
depois_fisica:
    lw $t0, atacando
    beqz $t0, dec_cooldown
    addiu $t0, $t0, -1
    sw $t0, atacando
    bnez $t0, dec_cooldown
    li $t0, 1
    sw $t0, atualizar_fundo

# -----------------------------------------------------------------------
# dec_cooldown: decrementa o contador de cooldown do ataque
# -----------------------------------------------------------------------
dec_cooldown:
    lw $t0, ataque_cooldown
    beqz $t0, check_cenario
    addiu $t0, $t0, -1
    sw $t0, ataque_cooldown

# -----------------------------------------------------------------------
# check_cenario: verifica qual cenario esta ativo para decidir se
# deve checar colisao com inimigo ou apenas limites da tela
# -----------------------------------------------------------------------
check_cenario:
    lw $t0, cenario_atual
    li $t1, 2
    beq $t0, $t1, verificar_inimigo
    j verifica_limites

# -----------------------------------------------------------------------
# verificar_inimigo: checa colisao entre o personagem e o inimigo
# Se houver contato, o personagem morre
# -----------------------------------------------------------------------
verificar_inimigo:
    lw $t0, inimigo_vivo
    beqz $t0, depois_inimigo
    lw $t0, prince_x
    lw $t1, inimigo_x
    addiu $t1, $t1, 38
    bge $t0, $t1, depois_inimigo
    lw $t0, prince_x
    addiu $t0, $t0, 8
    lw $t1, inimigo_x
    blt $t0, $t1, depois_inimigo
    lw $t0, prince_y
    lw $t1, inimigo_y
    addiu $t1, $t1, 49
    bge $t0, $t1, depois_inimigo
    lw $t0, prince_y
    addiu $t0, $t0, 41
    lw $t1, inimigo_y
    blt $t0, $t1, depois_inimigo
    j morte_personagem

# -----------------------------------------------------------------------
# depois_inimigo: segue para verificacao de limites apos processar inimigo
# -----------------------------------------------------------------------
depois_inimigo:
    j verifica_limites

# ===========================================================================
# morte_personagem: trata a morte do principe
# Reseta posicao, status e volta para o menu (cenario 0)
# ===========================================================================
morte_personagem:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    jal play_som_morte
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    li $t1, 45
    sw $t1, prince_x
    li $t2, 54
    sw $t2, prince_y
    li $t3, 0
    sw $t3, velocidade_y
    li $t3, 1
    sw $t3, no_chao
    sw $zero, atacando
    sw $zero, ataque_cooldown
    j vai_para_cenario_0

# ===========================================================================
# verifica_limites: verifica os limites horizontais da tela
# Se o personagem sair pela esquerda ou direita, toma acao apropriada
# ===========================================================================
verifica_limites:
    lw $t1, prince_x
    li $t4, 0
    blt $t1, $t4, trava_esquerda
    li $t4, 491
    bge $t1, $t4, transicao_direita
    j redirecionar_cenario

# -----------------------------------------------------------------------
# trava_esquerda: prende o personagem no limite esquerdo da tela
# -----------------------------------------------------------------------
trava_esquerda:
    li $t1, 0
    sw $t1, prince_x
    j redirecionar_cenario

# -----------------------------------------------------------------------
# transicao_direita: transita para o proximo cenario ou completa a fase
# -----------------------------------------------------------------------
transicao_direita:
    lw $t0, cenario_atual
    li $t4, 1
    beq $t0, $t4, vai_para_cenario_2
    li $t4, 2
    beq $t0, $t4, completou_fase
    j redirecionar_cenario

# -----------------------------------------------------------------------
# completou_fase: o jogador completou a fase com sucesso
# Toca som de vitoria e retorna ao menu
# -----------------------------------------------------------------------
completou_fase:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    jal play_som_fase_completa
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    j vai_para_cenario_0

# -----------------------------------------------------------------------
# vai_para_cenario_2: configura o estado para o cenario 2 (fase 2)
# Inicializa posicao do personagem e atributos do inimigo
# -----------------------------------------------------------------------
vai_para_cenario_2:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    jal play_som_transicao
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    li $t0, 2
    sw $t0, cenario_atual
    li $t0, 1
    sw $t0, atualizar_fundo
    li $t1, 10
    sw $t1, prince_x
    li $t2, 54
    sw $t2, prince_y
    li $t3, 0
    sw $t3, velocidade_y
    li $t3, 1
    sw $t3, no_chao
    sw $zero, atacando
    sw $zero, ataque_cooldown
    li $t3, 3
    sw $t3, inimigo_vida
    li $t3, 1
    sw $t3, inimigo_vivo
    j redirecionar_cenario

# -----------------------------------------------------------------------
# vai_para_cenario_0: retorna para o menu principal (cenario 0)
# -----------------------------------------------------------------------
vai_para_cenario_0:
    li $t0, 0
    sw $t0, cenario_atual
    li $t0, 1
    sw $t0, atualizar_fundo
    j redirecionar_cenario

# -----------------------------------------------------------------------
# reset_jogo: reseta o estado do jogo para o cenario 1 (tecla R)
# Reinicia posicao, vida do inimigo e status do personagem
# -----------------------------------------------------------------------
reset_jogo:
    li $t0, 1
    sw $t0, cenario_atual
    li $t0, 1
    sw $t0, atualizar_fundo
    li $t1, 45
    sw $t1, prince_x
    li $t2, 54
    sw $t2, prince_y
    li $t3, 0
    sw $t3, velocidade_y
    li $t3, 1
    sw $t3, no_chao
    sw $zero, atacando
    sw $zero, ataque_cooldown
    li $t3, 3
    sw $t3, inimigo_vida
    li $t3, 1
    sw $t3, inimigo_vivo
    j redirecionar_cenario

# ===========================================================================
# redirecionar_cenario: despacha para a funcao de renderizacao
# adequada com base no cenario_atual (0=menu, 1=fase1, 2=fase2)
# ===========================================================================
redirecionar_cenario:
    lw $t0, cenario_atual
    li $t1, 1
    beq $t0, $t1, renderizarCenarioUm
    li $t1, 2
    beq $t0, $t1, renderizarCenarioDois
    j renderizarCenarioZero
fim_jogo:
    li $v0, 10
    syscall

# ===========================================================================
# existeCaracter: verifica se uma tecla foi pressionada (polling MMIO)
# Retorna 1 em $v0 se houver tecla, 0 caso contrario
# ===========================================================================
existeCaracter:
    lui $t0, 0xFFFF
    lw $t1, 0($t0)
    and $v0, $t1, 1
    jr $ra

# ===========================================================================
# acionarCaracter: le a tecla pressionada via MMIO
# Se nenhuma tecla foi pressionada, retorna 0 em $v0
# ===========================================================================
acionarCaracter:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal existeCaracter
    beq $v0, $zero, sem_tecla
    lui $t0, 0xFFFF
    lw $v0, 4($t0)
    j fim_acionar

# -----------------------------------------------------------------------
# sem_tecla: nenhuma tecla foi pressionada, retorna 0
# -----------------------------------------------------------------------
sem_tecla:
    li $v0, 0

# -----------------------------------------------------------------------
# fim_acionar: retorna da leitura de tecla
# -----------------------------------------------------------------------
fim_acionar:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra