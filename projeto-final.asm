# Nome: Arthur Santos de Oliveira - Rafael dos Santos Parisi
# RA: 156297 - 148418
        .data
        .align 2
        doinglistarray: .space 200
        todolistarray: .space 200
        donelistarray: .space 200
        
        todolist: .space 2000
        doinglist: .space 2000
        donelist: .space 2000
        
        mensagem: .asciiz "Escolha uma opcao: \n (1) Cadastrar nova tarefa \n (2) Exibir a fazeres. \n (3) Mover tarefa a ser realizada para iniciada \n (4) Mostrar tarefas iniciadas \n (5) Mover tarefa iniciada para terminada. \n (6) Mostrar tarefas feitas. \n"
        msg_mover_feito: .asciiz "Selecione o indice da tarefa ser marcada como feita. \n Caso deseje cancelar a operacao selecione ZERO. \n"
        msg_operacao_cancelada: .asciiz "Operacao cancelada com sucesso! \n"
        msg_sucesso_operacao: .asciiz "Operacao realizada com sucesso! \n"
        msg_remover_tarefa: .asciiz "Selecione o indice da tarefa a ser removida. \n"
        
        msg_erro: .asciiz "Opcao invalida. Escolha uma opcao valida! \n"
        msg_erro_mover_feito: "Indice invalido. Selecione um indice valido \n"
        
        nova_linha: .asciiz "\n"
        separador: .asciiz " - "
        lista_afazeres: .asciiz "\n Lista de afazeres: \n"
        lista_doing: .asciiz "\n Lista de tarefas sendo feitas: \n"
    .text
    .globl main
main:
li $s1, 0
la $s2, todolist
li $s3, 0
la $s4, doinglist
li $s5, 0
la $s6, donelist

# loop principal
loop:
	# Printa mensagem
    	li $v0, 4
    	la $a0, mensagem
    	syscall
    	
    	# Leitura da opcao
    	li $v0,5
    	syscall
    	move $t0,$v0
 
    	# Trata opcao errada
    	bgt $t0, 6, valorInvalido
    	blt $t0, 1, valorInvalido
    	
    	# Opcoes
    	beq $t0, 1, adicionarTarefa
    	beq $t0, 2, exibirListaAfazeres
    	beq $t0, 3, moveParaDoing
    	beq $t0, 4, exibirDoing
    	beq $t0, 5, moveParaDone
    	beq $t0, 6, exibirDone
    	
    	j loop	

adicionarTarefa:
	# Leitura da string
    	move    $a0,$s2
    	li      $a1,20           # 20 e' o tamanho maximo da string
    	li      $v0,8
    	syscall

    	# Guarda ponteiro para string em um array
    	sw      $a0, todolistarray($s1)

    	addi    $s1,$s1,4           # incrementa array de ponteiro
    	addi    $s2,$s2,20          # incrementa local da nova string
    	
	j loop
	
exibirListaAfazeres:
	li $t1, 0
  	li $t3, 1
  	
  	jal cabecalhoListaAfazeres
  	
	while:
    		beq     $t1, $s1, loop
    		lw      $t2, todolistarray($t1)
		
		# exibe indice da tarefa
		jal indiceTarefa
		
    		# exibe tarefa
    		li $v0,4
    		move $a0,$t2
    		syscall

    		addi $t1,$t1,4		# avanca tarefa
    		addi $t3, $t3, 1	# avanca indice da tarefa
    		j while
	
valorInvalido:
	# Printa mensagem de erro
    	li $v0, 4
    	la $a0, msg_erro
    	syscall
    	
    	# Retorna ao loop principal
    	j loop
    	
novaLinha:
	la $a0,nova_linha
    	li $v0,4
    	syscall
    	jr $ra
    	
indiceTarefa:
	# printa indice
	li $v0, 1
    	move $a0, $t3
    	syscall
    	
    	# printa separador
    	la $a0, separador
    	li $v0,4
    	syscall
    	
    	jr $ra
  
cabecalhoListaAfazeres:
	# printa cabecalho
    	la $a0, lista_afazeres
    	li $v0,4
    	syscall
    	
    	jr $ra

moveParaDoing:
	# printa mensagem de comando para mover para feito
    	la $a0, msg_mover_feito
    	li $v0,4
    	syscall
    	
    	# calcula o numero total de tarefas a serem feitas e salva em t2
 	li $t3, 4
 	div $s1, $t3
 	mflo $t2
    	
    	# le o indice escolhido pelo usuario
    	li $v0,5
    	syscall
    	move $t1,$v0
 	
 	# tratamento de excecoes
 	beq $t1, $zero, operacaoCancelada
 	blt $t1, $zero, indiceIncorretoMoverFeito
    	bgt $t1, $t2, indiceIncorretoMoverFeito
    	
    	# copia tarefa para lista de fazendo
    	mult $t1, $t3
    	mflo $t4
    	sub $t4, $t4, $t3
    	lw $t6, todolistarray($t4)
    	
    	jal adicionarDoing
    	
    	# printa mensagem de sucesso na operacao
    	la $a0, msg_sucesso_operacao
    	li $v0,4
    	syscall
    	
	j loop
	
indiceIncorretoMoverFeito:
	# printa mensagem de erro para mover para feito
    	la $a0, msg_erro_mover_feito
    	li $v0,4
    	syscall
    	
    	j moveParaDoing
    	
operacaoCancelada:
	# printa mensagem de operacao cancelada
    	la $a0, msg_operacao_cancelada
    	li $v0,4
    	syscall
    	
    	j loop

adicionarDoing:
    	sw      $s4, doinglistarray($s3)
	move $t0, $t6
	move $t1, $s4
	li $t4, 1
	
copiaCaracter:          
    	lbu  $t2, 0($t0)

    	sb   $t2, 0($t1)

    	addi $t0, $t0, 1
    	addi $t1, $t1, 1
    	addi $t4, $t4, 1
    	bne  $t4, 20, copiaCaracter
    	
    	addi $s4, $s4, 20
    	addi $s3, $s3, 4
	jr $ra

exibirDoing:
	li $t1, 0
  	li $t3, 1
  	
  	jal cabecalhoListaDoing
  	
	whileDoing:
    		beq     $t1, $s3, loop
    		lw      $t2, doinglistarray($t1)
		
		# exibe indice da tarefa
		jal indiceTarefa
		
    		# exibe tarefa
    		li $v0,4
    		move $a0,$t2
    		syscall

    		addi $t1,$t1,4		# avanca tarefa
    		addi $t3, $t3, 1	# avanca indice da tarefa
    		j whileDoing

cabecalhoListaDoing:
	# printa cabecalho
    	la $a0, lista_doing
    	li $v0,4
    	syscall
    	
    	jr $ra

removeTarefa:
	
	# printa mensagem de sucesso na operacao
    	la $a0, msg_remover_tarefa
    	li $v0,4
    	syscall
    	
    	# calcula o numero total de tarefas a serem feitas e salva em t2
 	li $t3, 4
 	div $s1, $t3
 	mflo $t2
    	
    	# le o indice escolhido pelo usuario
    	li $v0,5
    	syscall
    	move $t1,$v0
    	
    	beq $t1, $zero, operacaoCancelada
 	blt $t1, $zero, indiceIncorretoMoverFeito
    	bgt $t1, $t2, indiceIncorretoMoverFeito
    	
    	j loop

moveParaDone:
exibirDone:
	j loop
