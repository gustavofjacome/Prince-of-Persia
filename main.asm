.data 

.include "cenarios/dummy.asm"            # Fantasma 
.include "cenarios/stage0.asm"           # Local onde está o arquivo do menu inicial
.include "cenarios/stage2.asm"           # Local onde esta o arquivo do cenario 2 
.include "cenarios/stage1.asm"           # Local onde esta o arquivo do cenario 1 

.include "sprites/prince_idle_right.asm"

.text 
.globl main 

main:
    # ========================================= 
    # COMEÇO 
    # =========================================
    jal controlesCenario

    # ========================================= 
    # FIM 
    # ========================================= 
fim: 
    li $v0, 10 
    syscall

.include "util/controle/controlarCenarios.asm" 
.include "util/renders/renderizarCenario.asm" 
#.include "util/formas/linhasRetangulos.asm" 

# Inclusão da lógica de renderização
.include "personagem/renderizarPersonagem.asm"