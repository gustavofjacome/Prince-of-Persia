.data

.include "cenarios/dummy.asm"			# Fantasma
.include "cenarios/stage0.asm"			# Local onde está o arquivo do menu inicial
.include "cenarios/stage2.asm" 			# Local onde esta o arquivo do cenario 2
.include "cenarios/stage1.asm" 			# Local onde esta o arquivo do cenario 1
.include "cenarios/alunos_transparente.asm"


.text
.globl main

main:

    # =========================================
    # DESENHO DE RETÂNGULO
    # =========================================

    j controlesCenario

    # =========================================
    # FIM
    # =========================================
    
fim:
   li $v0, 10
   syscall   


.include "util/controle/controlarCenarios.asm"
.include "util/controle/controlarCenariosEspelhado.asm"
.include "util/renders/renderizarCenario.asm"
.include "util/renders/renderizarCenarioEspelhado.asm"
.include "util/formas/linhasRetangulos.asm"
