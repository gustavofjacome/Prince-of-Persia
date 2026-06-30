# =============================================================================
# testes.asm  -  ponto de entrada principal para testes do jogo
# =============================================================================
# Inclui todos os cenarios e modulos do jogo.
# main: Inicia o loop de controle do cenario (controlesCenario).
# fim: Encerra o programa com syscall 10.
# =============================================================================
.data
.include "cenarios/dummy.asm"
.include "cenarios/stage0.asm"
.include "cenarios/stage2.asm"
.include "cenarios/stage1.asm"
.include "cenarios/alunos_transparente.asm"
.text
.globl main
main:
    j controlesCenario
fim:
   li $v0, 10
   syscall   
.include "util/controle/controlarCenarios.asm"
.include "util/controle/controlarCenariosEspelhado.asm"
.include "util/renders/renderizarCenario.asm"
.include "util/renders/renderizarCenarioEspelhado.asm"
.include "util/formas/linhasRetangulos.asm"
