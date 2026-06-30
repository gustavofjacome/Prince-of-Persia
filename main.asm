# =============================================================================
# main.asm - Arquivo principal do jogo Prince of Persia (MIPS Assembly)
# =============================================================================
# Define as variaveis globais e o game loop infinito.
# Inicia no cenario 0 (menu/tela final). Pressione 'r' para comecar.
# =============================================================================

.data
# Buffer dummy para restauracao de fundo
.include "cenarios/dummy.asm"
# Menu principal (tela inicial/final): 512x256 pixels
.include "cenarios/stage0.asm"
# Cenario do Stage 1: 512x256 pixels
.include "cenarios/stage1.asm"
# Cenario do Stage 2: 512x256 pixels
.include "cenarios/stage2.asm"
# Mapa de tiles do Stage 1: 32 colunas x 16 linhas (0=ar, 1=piso, 2=perigo)
.include "tiles/stage1.asm"
# Mapa de tiles do Stage 2
.include "tiles/stage2.asm"
# Sprite do principe parado (direita)
.include "sprites/prince_idle_right.asm"
# Sprite do principe parado (esquerda)
.include "sprites/prince_idle_left.asm"
# Sprite do principe pulando (direita)
.include "sprites/prince_jump_right.asm"
# Sprite do principe pulando (esquerda)
.include "sprites/prince_jump_left.asm"
# Sprite do principe atacando (direita)
.include "sprites/prince_attack_sword_right.asm"
# Sprite do principe atacando (esquerda)
.include "sprites/prince_attack_sword_left.asm"
# Sprite do inimigo (frame 1)
.include "sprites/inimigo1-frame1.asm"

# --- Variaveis globais do estado do jogo ---

# Posicao atual do principe (pixels, frame buffer 512x256)
prince_x:            .word 45
prince_y:            .word 54
# Posicao anterior (para restaurar fundo)
prince_old_x:        .word 45
prince_old_y:        .word 54
# Posicao do inimigo
inimigo_x:           .word 400
inimigo_y:           .word 142
inimigo_old_x:       .word 400
inimigo_old_y:       .word 142
# Direcao do salto do inimigo (1 = sobe, -1 = desce)
inimigo_jump_dir:    .word 1
# Contador de frames do salto
inimigo_jump_count:  .word 0

# ID do cenario atual (0 = menu, 1 = stage1, 2 = stage2)
cenario_atual:       .word 0
# Flag: 1 = precisa redesenhar o fundo
atualizar_fundo:     .word 1

# Velocidade vertical (gravidade)
velocidade_y:        .word 0
# Velocidade horizontal (drift do pulo)
velocidade_x:        .word 0
# Flag: 1 = principe esta no chao
no_chao:             .word 1
# Direcao (1 = direita, -1 = esquerda)
direcao:             .word 1

# Vida do inimigo
inimigo_vida:        .word 3
# Flag: 1 = inimigo vivo
inimigo_vivo:        .word 1
# Contador de frames de ataque (0 = nao atacando)
atacando:            .word 0
# Cooldown entre ataques
ataque_cooldown:     .word 0

.text
.globl main
# =============================================================================
# main: ponto de entrada do programa
# Game loop infinito: controlesCenario -> render -> loop
# =============================================================================
main:
game_loop:
    jal controlesCenario
    j game_loop
fim:
    li $v0, 10
    syscall

.include "util/controle/controlarCenarios.asm"
.include "util/controle/colisoes.asm"
.include "util/renders/renderizarCenario.asm"
.include "personagem/renderizarPersonagem.asm"
.include "inimigo/atualizarInimigo.asm"
.include "util/som/sons.asm"