# =============================================================================
# sons.asm  -  efeitos sonoros do jogo (syscall 31/33)
# =============================================================================
# play_som_ataque:
#   Som de ataque. Nota: D5 (72), duracao: 50ms, instrumento: 127, volume: 127
# -----------------------------------------------------------------------------
# play_som_pulo:
#   Som de pulo. Nota: G4 (67), duracao: 100ms, instrumento: 123, volume: 90
# -----------------------------------------------------------------------------
# play_som_morte:
#   Som de morte. Nota: C2 (36), duracao: 400ms, instrumento: 127, volume: 120
# -----------------------------------------------------------------------------
# play_som_acerto_inimigo:
#   Som de acerto no inimigo. Nota: C4 (60), duracao: 60ms, inst: 122, vol: 100
# -----------------------------------------------------------------------------
# play_som_inimigo_morto:
#   Som de inimigo morto. Duas notas: E4 (64, 120ms, inst:61) e
#   G4 (71, 200ms, inst:61)
# -----------------------------------------------------------------------------
# play_som_fase_completa:
#   Melodia de fase completa. Sequencia: C4(60), E4(64), G4(67), C5(72)
#   cada uma 150ms, ultima 300ms, instrumento:63
# -----------------------------------------------------------------------------
# play_som_pouso:
#   Som de pouso. Nota: C3 (48), duracao: 80ms, instrumento: 117, volume: 80
# -----------------------------------------------------------------------------
# play_som_transicao:
#   Som de transicao. Duas notas: C5(72) e C4(60), 100ms, inst:80, vol:90
# -----------------------------------------------------------------------------
# play_som_menu:
#   Som de menu. Sequencia: C4(60), E4(64), G4(67), 100ms, inst:54, vol:80
# =============================================================================
.text
.globl play_som_ataque
play_som_ataque:
    li $a0, 72
    li $a1, 50
    li $a2, 127
    li $a3, 127
    li $v0, 31
    syscall
    jr $ra
.globl play_som_pulo
play_som_pulo:
    li $a0, 67
    li $a1, 100
    li $a2, 123
    li $a3, 90
    li $v0, 31
    syscall
    jr $ra
.globl play_som_morte
play_som_morte:
    li $a0, 36
    li $a1, 400
    li $a2, 127
    li $a3, 120
    li $v0, 31
    syscall
    jr $ra
.globl play_som_acerto_inimigo
play_som_acerto_inimigo:
    li $a0, 60
    li $a1, 60
    li $a2, 122
    li $a3, 100
    li $v0, 31
    syscall
    jr $ra
.globl play_som_inimigo_morto
play_som_inimigo_morto:
    li $a0, 64
    li $a1, 120
    li $a2, 61
    li $a3, 110
    li $v0, 31
    syscall
    li $a0, 71
    li $a1, 200
    li $a2, 61
    li $a3, 120
    li $v0, 31
    syscall
    jr $ra
.globl play_som_fase_completa
play_som_fase_completa:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    li $a0, 60
    li $a1, 150
    li $a2, 63
    li $a3, 110
    li $v0, 33
    syscall
    li $a0, 64
    li $a1, 150
    li $a2, 63
    li $a3, 110
    li $v0, 33
    syscall
    li $a0, 67
    li $a1, 150
    li $a2, 63
    li $a3, 110
    li $v0, 33
    syscall
    li $a0, 72
    li $a1, 300
    li $a2, 63
    li $a3, 120
    li $v0, 33
    syscall
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra
.globl play_som_pouso
play_som_pouso:
    li $a0, 48
    li $a1, 80
    li $a2, 117
    li $a3, 80
    li $v0, 31
    syscall
    jr $ra
.globl play_som_transicao
play_som_transicao:
    li $a0, 72
    li $a1, 100
    li $a2, 80
    li $a3, 90
    li $v0, 31
    syscall
    li $a0, 60
    li $a1, 100
    li $a2, 80
    li $a3, 90
    li $v0, 31
    syscall
    jr $ra
.globl play_som_menu
play_som_menu:
    li $a0, 60
    li $a1, 100
    li $a2, 54
    li $a3, 80
    li $v0, 31
    syscall
    li $a0, 64
    li $a1, 100
    li $a2, 54
    li $a3, 80
    li $v0, 31
    syscall
    li $a0, 67
    li $a1, 100
    li $a2, 54
    li $a3, 80
    li $v0, 31
    syscall
    jr $ra
