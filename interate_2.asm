.data
	
	#encode/decode maps
	byte_encode: .byte 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 48, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 32, 65, 82, 69, 79, 77, 72, 76, 83, 80, 58, 59, 60, 61, 62, 63, 64, 49, 66, 67, 68, 51, 70, 71, 54, 73, 74, 75, 55, 53, 78, 52, 57, 81, 50, 56, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 49, 98, 99, 100, 51, 102, 103, 54, 105, 106, 107, 55, 53, 110, 52, 57, 113, 50, 56, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127 
	
	#password value
	password: .word 159753
	
	#UI messages 
	prompt:	 .asciiz "Insira a mensagem: "
	n_msg: 	 .asciiz "Numero total de caracteres: "
	str_msg: .asciiz "\nMensagem Criptografada: "
	password_prompt:	.asciiz "\nInsira a senha: "
	pasasword_fail_prompt:	.asciiz "Senha incorreta."
	password_sucess_prompt:	.asciiz "Mensagem Original: "	
	
	#decoded/encoded memory origin adress
	bgn: .byte 0

.text
main:
	###########################################	PART 1
	# prompt user, get string, encode string, print encoded value and size 

	#initalizes the registers
	li $a0, 0	#char counter
	li $t1, 0	#mapped value
	
	la $t2, bgn	#tail memory adress
	la $t5, bgn	#head memory adress
	
	#prompts the user
	li $v0, 4
	la $a0, prompt
	syscall
	
	while:
		#reads a value
		li $v0, 12
		syscall  	
		
		#exits if value(v0) == ENTER(10)
		beq $v0, 10, exit
		
		#maps the value into t1
		lbu $t1, byte_encode($v0)
		
		#saves the maped value, and increments the memory pointer
		sb $t1, ($t2)
		addi $t2, $t2, 1
		
		j while	
	exit:
	
	#prints n_msg
	li $v0,  4
	la $a0, n_msg
	syscall
	
	#prints the number of elements 
	sub $a0, $t2, $t5	#n + 1 = tail - head
	#subi $a0, $a0, 1
	li $v0, 1
	syscall
	
	#prints str_msg
	li $v0,  4
	la $a0, str_msg
	syscall
	
	#"null-terminates" the string
	li $t1, 0
	sb $t1, ($t2) 

	#prints the encoded string
	move $a0, $t5
	syscall
	
	
	###########################################	PART 2
	# prompt user, get password, check password, print decoded if needed, exit  
	
	#prompts the user
	li $v0, 4
	la $a0, password_prompt
	syscall
	
	#get the integer
	li $v0, 5
	syscall
	
	#loads the password into t1, and checks it 
	lw $t1, password
	beq $t1, $v0, sucess
	
	#wrong password
		
		#fail prompt
		li $v0, 4
		la $a0, pasasword_fail_prompt
		syscall
		
		#exits
		li $v0, 10
		syscall
	
	#correct password
	sucess:
	
		#re - initalizes the registers
		li $t1, 0	#mapped value
		la $t2, bgn	#tail memory adress
		la $t5, bgn	#head memory adress
	
		
		while_decode:
		
			#reads a value 
			lbu $t0, ($t2)
			
			#exits if value(t0) == NULL(0, /0)
			beq $t0, 0, exit_decode
		
			#maps the value into t1
			lbu $t1, byte_encode($t0)
		
			#saves the maped value, and increments the memory pointer
			sb $t1, ($t2)
			addi $t2, $t2, 1
		
			j while_decode
		
		exit_decode:
	
		#prints the sucess prompt and decoded string
		li $v0, 4
		la $a0, password_sucess_prompt
		syscall
		move $a0, $t5
		syscall

		# exits 
		li $v0 10 
		syscall 
