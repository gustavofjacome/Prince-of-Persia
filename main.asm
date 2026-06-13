# ============================================================
# ARQUIVO PRINCIPAL DO JOGO
# ============================================================
# Responsável por:
# - Carregar cenários e sprites
# - Inicializar variáveis globais
# - Iniciar o controle dos cenários
# - Encerrar a execução do programa
# ============================================================

.data

# ============================================================
# INCLUSÃO DOS ARQUIVOS DE CENÁRIO
# ============================================================

.include "cenarios/dummy.asm"      # Cenário fantasma/utilizado como apoio
.include "cenarios/stage0.asm"     # Tela/Menu inicial
.include "cenarios/stage2.asm"     # Cenário 2
.include "cenarios/stage1.asm"     # Cenário 1

# ============================================================
# INCLUSÃO DOS SPRITES
# ============================================================

.include "sprites/prince_idle_right.asm"  # Sprite do príncipe parado olhando para a direita

.data

# ============================================================
# VARIÁVEIS DINÂMICAS DO JOGO
# ============================================================

# ------------------------------------------------------------
# Posição atual do personagem principal
# ------------------------------------------------------------
prince_x:        .word 45      # Coordenada X atual
prince_y:        .word 75      # Coordenada Y atual

# ------------------------------------------------------------
# Última posição do personagem
# Utilizada para apagar o sprite antigo antes de desenhar
# o novo (efeito de "borracha")
# ------------------------------------------------------------
prince_old_x:    .word 45      # Coordenada X anterior
prince_old_y:    .word 75      # Coordenada Y anterior

# ------------------------------------------------------------
# Controle de cenários
# ------------------------------------------------------------
cenario_atual:   .word 1       # Cenário carregado ao iniciar o jogo

# ------------------------------------------------------------
# Controle de atualização da tela
# ------------------------------------------------------------
# Valor = 1 → redesenha o cenário inteiro
# Valor = 0 → utiliza apenas a borracha para apagar o sprite
#             anterior e desenhar o novo
# ------------------------------------------------------------
atualizar_fundo: .word 1

# ============================================================
# INÍCIO DA ÁREA DE CÓDIGO
# ============================================================

.text
.globl main

# ============================================================
# FUNÇÃO PRINCIPAL
# ============================================================
# Ponto de entrada do programa
# ============================================================

main:

    # --------------------------------------------------------
    # Inicialização do jogo
    # --------------------------------------------------------
    # Chama a rotina responsável por controlar os cenários,
    # renderização e lógica principal.
    # --------------------------------------------------------
    jal controlesCenario

# ============================================================
# ENCERRAMENTO DO PROGRAMA
# ============================================================

fim:

    # Serviço 10 = Encerrar execução
    li $v0, 10
    syscall

# ============================================================
# INCLUSÃO DOS MÓDULOS DO PROJETO
# ============================================================

# ------------------------------------------------------------
# Controle de troca de cenários
# ------------------------------------------------------------
.include "util/controle/controlarCenarios.asm"

# ------------------------------------------------------------
# Rotinas responsáveis por desenhar os cenários
# ------------------------------------------------------------
.include "util/renders/renderizarCenario.asm"

# ------------------------------------------------------------
# Rotinas responsáveis por desenhar e atualizar
# o personagem principal
# ------------------------------------------------------------
.include "personagem/renderizarPersonagem.asm"