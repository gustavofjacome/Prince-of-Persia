# ============================================================
# ARQUIVO PRINCIPAL DO JOGO (main.asm)
# ============================================================

.data

# ------------------------------------------------------------
# 1. INCLUSÃO DE ARQUIVOS DE IMAGEM E MAPAS
# ------------------------------------------------------------
# Cenários (Imagens Gráficas de Fundo)
.include "cenarios/dummy.asm"             # Cenário fantasma
.include "cenarios/stage0.asm"            # Tela/Menu inicial
.include "cenarios/stage1.asm"            # Imagem do Cenário 1 (cenario1, cenario1_width...)
.include "cenarios/stage2.asm"            # Imagem do Cenário 2 (cenario_2, cenario_2_width...)

# Mapas de Colisão (Matrizes Numéricas de Tiles)
.include "tiles/stage1.asm"               # Matriz de tiles do Cenário 1 (stage_map1)
.include "tiles/stage2.asm"               # Matriz de tiles do Cenário 2 (stage_map2)

# Sprites (Personagens)
.include "sprites/prince_idle_right.asm"  # Sprite do príncipe
.include "sprites/inimigo1-frame1.asm"    # Sprite do inimigo

# ------------------------------------------------------------
# 2. VARIÁVEIS DINÂMICAS DO JOGO
# ------------------------------------------------------------
prince_x:            .word 45      # Coordenada X atual
prince_y:            .word 54      # Coordenada Y atual (MUDOU PARA 10)
prince_old_x:        .word 45      # Coordenada X anterior
prince_old_y:        .word 54      # Coordenada Y anterior (MUDOU PARA 10)

inimigo_x:           .word 400     # Lado direito da tela
inimigo_y:           .word 142     # Chão exato
inimigo_old_x:       .word 400     
inimigo_old_y:       .word 142     

inimigo_jump_dir:    .word 1       
inimigo_jump_count:  .word 0       

cenario_atual:       .word 1       # Cenário inicial
atualizar_fundo:     .word 1       # 1 = Redesenha tudo | 0 = Retângulos Sujos

velocidade_y:        .word 0       # Velocidade vertical (neg. = sobe, pos. = desce)
velocidade_x:        .word 0       # Velocidade horizontal do drift (pulo diagonal)
no_chao:             .word 1       # 1 = no chão, 0 = no ar

# ============================================================
# 3. INÍCIO DA ÁREA DE CÓDIGO PRINCIPAL
# ============================================================
.text
.globl main

main:
game_loop:
    jal controlesCenario           # Executa lógica de controles e renderização
    j game_loop                    # Repete o ciclo infinitamente

fim:
    li $v0, 10
    syscall

# ============================================================
# 4. INCLUSÃO DOS MÓDULOS LÓGICOS DO PROJETO (.text)
# ============================================================
.include "util/controle/controlarCenarios.asm"
.include "util/controle/colisoes.asm"
.include "util/renders/renderizarCenario.asm"
.include "personagem/renderizarPersonagem.asm"
.include "inimigo/atualizarInimigo.asm"