.text
    
    # =========================================
    # INICIO DO MAPEAMENTO DE TECLAS J, K, R, X
    # =========================================
    
controlesCenario:

     li $t0, 0			# --> Inicializa o caractér com zero
     li $s2, 106		# --> ASCII de 'j' --> Cenário 1
     li $s3, 107		# --> ASCII de 'k' --> Cenário 2
     li $s4, 114		# --> ASCII de 'r' --> Cenário 0
     li $s5, 120		# --> ASCII de 'x' --> Encerrar programa
     li $s6, 97			# --> ASCII DE 'a' --> desenhar a tela branca com nomes cursivos
     
     jal acionarCaracter
     
     beq $v0, $s4, renderizarCenarioZero
     beq $v0, $s2, renderizarCenarioUm
     beq $v0, $s3, renderizarCenarioDois
     beq $v0, $s6, tela_branca
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
