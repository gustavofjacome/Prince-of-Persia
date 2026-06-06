.data

.include "cenarios/dummy.asm"
.include "cenarios/stage0.asm"		# Local onde está o arquivo do menu inicial
.include "cenarios/stage2.asm" 		#local onde esta o arquivo do cenario 2
.include "cenarios/stage1.asm" 			#local onde esta o arquivo do cenario 1


.text
.globl main

main:

    
   
    # =========================================
    # INICIO DO MAPEAMENTO DE TECLAS J, K, R, X
    # =========================================
    
controlesCenario:

     li $t0, 0			# --> Inicializa o caractér com zero
     li $s2, 106		# --> ASCII de 'j' --> Cenário 1
     li $s3, 107		# --> ASCII de 'k' --> Cenário 2
     li $s4, 114		# --> ASCII de 'r' --> Cenário 0
     li $s5, 120		# --> ASCII de 'x' --> Encerrar programa
     
     jal acionarCaracter
     
     beq $v0, $s4, renderizarCenarioZero
     beq $v0, $s2, renderizarCenarioUm
     beq $v0, $s3, renderizarCenarioDois
     beq $v0, $s5, fim
     
     j controlesCenario
     
existeCaracter:

    lui $t0, 0xFFFF	# --> Vai olhar para o registrador 0xFFFF0000
    			#     Receiver Control (onde fica o endereço de controle em MIPS)
    lw $t1, 0($t0)	# --> Lê o endereço de $t0 e coloca em $t1
    and $v0, $t1, 1	# --> Operação AND entre o valor de $t1 e 1. Se o resultado
    			#     vier 1 é porque há um caractér
    jr $ra
    					
acionarCaracter:

    addi $sp, $sp, -4	# --> Abre 4 bytes na memória. (4 bytes = 1 word)
    sw $ra, 0($sp)	# --> Salva o endereço de retorno
    li $v0, 0		# --> Zera o registrador
    
    acionarCaracterLoop:
    	jal existeCaracter
    checarCaracter:	
    
    	beq $v0, $zero, acionarCaracterLoop	# --> Se não vier nenhum caractér, volta ao looping
    	lui $t0, 0xFFFF		# --> Carrega a parte superior do endereço base 0xFFFF0000
    	lw $v0, 4($t0)		# --> Rereive Data: Lê a word do endereço 0xFFFF0004 (endereço base + deslocamento).
    				#     Aqui ficará o valor ASCII da tecla apertada. O valor é lido e colocado no $v0
    	lw $ra, 0($sp)		# --> Restaura o valor do retorno
    	addi $sp, $sp, 4	# --> Libera a memória usada
    	jr $ra			# --> Retorna para a main
    	
    # =========================================
    # FIM DO MAPEAMENTO J, K, R, X
    # =========================================
    
renderizarCenarioUm:

    la $a0, cenario1
    lw $a1, cenario1_width
    lw $a2, cenario1_height

    jal render_cenario_espelhado

    j controlesCenario
    
renderizarCenarioDois:

    la $a0, cenario_2
    lw $a1, cenario_2_width
    lw $a2, cenario_2_height

    jal render_cenario_espelhado
    
    j controlesCenario
    
renderizarCenarioZero:

    la $a0, menu_principal
    lw $a1, menu_principal_width
    lw $a2, menu_principal_height
    
    jal render_cenario_espelhado
    
    j controlesCenario
       

    # =========================================
    # DESENHO DE RETÂNGULO
    # =========================================

    # li $t6, 100
    # add $t3, $zero, $t6
    # li $t7, 125
    # li $t8, 0xFFFFFF
    # li $s7, 50
    # add $s6, $zero $s7
    # li $t4, 10
    
    # jal desenhar_retangulo

    # =========================================
    # FIM
    # =========================================

fim:
    li $v0, 10
    syscall


# =========================================
# FUNÇÃO: render_cenario_espelhado
# a0 = endereço do cenário
# a1 = width
# a2 = height
# =========================================

render_cenario_espelhado:

    addiu $sp, $sp, -32     # 8 slots de 4 bytes
    sw $ra, 28($sp)
    sw $t1, 20($sp)
    sw $t2, 16($sp)
    sw $t3, 12($sp)
    sw $s0, 8($sp)
    sw $a1, 4($sp)          # ← Guardado na pilha
    sw $a2, 0($sp)          # ← Guardado na pilha

    li $t0, 0x10010000
    li $t1, 0

loop_altura_esp:
    beq $t1, $a2, end_render_esp

    mul $t3, $t1, $a1
    sll $t3, $t3, 2
    addu $t3, $a0, $t3

    # --- CORREÇÃO PONTUAL AQUI ---
    # Para ir ao último pixel da linha, calculamos: (largura - 1) * 4
    addi $t4, $a1, -1       # Subtrai 1 da largura antes de converter para bytes
    sll $t4, $t4, 2         # Multiplica por 4
    addu $t3, $t3, $t4      # Agora $t3 aponta exatamente para o último pixel válido da linha
    # -----------------------------

    li $t2, 0

loop_largura_esp:
    beq $t2, $a1, proxima_linha_esp

    lw $s0, 0($t3)
    li $t4, 0xFFFFFFFF
    beq $s0, $t4, skip_draw_esp
    sw $s0, 0($t0)

skip_draw_esp:
    addiu $t0, $t0, 4
    addiu $t3, $t3, -4
    addiu $t2, $t2, 1
    j loop_largura_esp

proxima_linha_esp:
    addiu $t1, $t1, 1
    j loop_altura_esp

end_render_esp:
    lw $ra, 28($sp)

    lw $t1, 20($sp)
    lw $t2, 16($sp)
    lw $t3, 12($sp)
    lw $s0, 8($sp)
    addiu $sp, $sp, 32

    jr $ra


# =========================================
# FUNÇÃO: espera (ms)
# a0 = tempo em ms
# =========================================

espera:

    li $v0, 32
    syscall
    jr $ra
    
# =========================================
# FUNÇÃO: posicionar_pixel
# s0 = área da memória
# t6 = coordenada X
# t7 = coordenada Y
# t8 = cor
# t9 = calcular o endereço onde o pixel 
#      vai ser desenhado na tela
#      E = Base + (Y * Largura + X) * 4
# =========================================    

posicionar_pixel:

    lui $s0, 0x1001

    sll $t9, $t7, 9
    addu $t9, $t6, $t9
    sll $t9, $t9, 2
    addu $t9, $t9, $s0

    sw $t8, 0($t9)
    jr $ra

    

desenhar_linha:

    addiu $sp, $sp, -8  # Reserva 8 bytes na pilha
    sw    $ra, 4($sp)   # Guarda o endereço de retorno da main
    sw    $s7, 0($sp)   # Guarda o valor original do contador
        
for_linha:

   jal posicionar_pixel
  
   addi $s7, $s7, -1
   addi $t6, $t6, 1  

   bnez $s7, for_linha

   lw $s7, 0($sp)   # Restaura o contador
   lw $ra, 4($sp)   # Restaura o endereço de retorno da main
   addiu $sp, $sp, 8   # Libera a pilha

   jr $ra 
   
desenhar_retangulo:

    addiu $sp, $sp, -8  # Reserva 8 bytes na pilha
    sw    $ra, 4($sp)   # Guarda o endereço de retorno da main
    sw    $s7, 0($sp)   # Guarda o valor original do contador
    
for_retangulo:

   jal desenhar_linha
   add $t6, $zero, $t3
   addi $t7, $t7, 1
   addi $t4, $t4, -1
   
   bnez $t4, for_retangulo
   
   lw $s7, 0($sp)   # Restaura o contador
   lw $ra, 4($sp)   # Restaura o endereço de retorno da main
   addiu $sp, $sp, 8   # Libera a pilha

   jr $ra 
   
