.data
	#text prompts
	hello: .asciiz "Bem-vindo a Loja de Computadores UNIFESP!\n" 
	
	menu: .asciiz "\nEscolha a categoria de produtos:\n0 - Finalizar compra\n1 - Processador\n2 - Memoria interna\n3 - Memoria externa\n4 - Perifericos\n\nDigite a opcao desejada: " 
	processors: .asciiz "\nProcessadores:\n0 - Voltar\n1 - AMD Ryzen 7 4.2GHz?2 - Intel Core i9 5.2GHz?3 - Intel Core i7 3.8 GHz?"
	internal_mem: .asciiz "\nMemoria interna:\n0 - Voltar\n1 - DDR5 16GB Kingstone?"
	external_mem: .asciiz "\nMemoria externa:\n0 - Voltar\n1 - HD de 2TB Seagate?2 - SSD de 1TB Seagate?"
	peripheral: .asciiz "\nPerifericos:\n0 - Voltar\n1 - Mouse Dell?2 - Combo Teclado e Mouse Logitech?3 - Fone de Ouvido JBL?"
	text_map: .word 0, processors, internal_mem, external_mem, peripheral
	
	
	product_prompt: .asciiz "\nDigite o numero do modelo do produto desejado: "
	n_product_prompt:  .asciiz "Digite a quantidade: "
	
	price_format_start: .asciiz "(R$ "
	price_format_end: .asciiz ")\n"
	
	#float value matrix
	processor_values: .float 2150.50, 3760.0, 2290.90
	internal_mem_values: .float 1299.90
	external_mem_values: .float 440.0, 720.0
	peripheral_values: .float 98.50, 149.90, 300.0
	value_map: .word 0, processor_values, internal_mem_values, external_mem_values, peripheral_values
	
	float_zero: .float 0.0
	
	.macro done
	li $v0, 10
	syscall
	.end_macro
	
	.macro char_out(%char_register)
	li $v0, 11
	move $a0, %char_register 
	syscall
	.end_macro
	
	.macro string_out(%string_label)
	li $v0, 4
	la $a0, %string_label
	syscall
	.end_macro
	
	.macro float_out(%float_register)
	li $v0, 2
	mov.s $f12, %float_register
	syscall
	.end_macro
		
	.macro int_in(%destination)
	li $v0, 5
	syscall
	move %destination, $v0
	.end_macro
	 
	.macro pile_up(%register)
	addi $sp, $sp, -4
	sw %register, ($sp)
	.end_macro
	
	.macro pile_down(%register)
	lw %register, ($sp)
	addi $sp, $sp, 4
	.end_macro
	
	.macro set_char_out_code
	li $v0, 11
	.end_macro		
	
	.macro increment(%register,%amount)
	addi %register, %register, %amount 
	.end_macro
.text
	main:
		#inits the purchace using f0 (f0 = 0)
		l.s $f0, float_zero
		
		#inits the context variables s1, s2 to -1
		li $s0, -1
		li $s1, -1  
		
		string_out(hello)
		
		loop: 
			#print the menu
			string_out(menu)
		
			#reads an context_1 option (display section)		
			int_in($s0)
			beqz $s0, end #if context_1 == 0 exists
			move $a0, $s0 
			
			#displays the context_1 option, and reads an context_2 option
			jal display_section
			string_out(product_prompt)
			int_in($s1)
			beqz $s1, loop # if context_2 == 0 restarts
			
			#reads the product amount
			 string_out(n_product_prompt)
			 int_in($s3)
			 
		j loop
		
		end:
			done
		
		
	display_section:
		
		#a0 -> section to display
		
		mul $a0, $a0, 4
		lw $t0, text_map($a0) 
		lw $t1, value_map($a0)
		
		set_char_out_code
		
		while: beqz $a0, exit
			
			lbu $a0, ($t0)	
			beq $a0, 63, subistitute
			
			#a0 != "?", prints the letter
				syscall
				j next	
			
			#a == "?", subistitute ? for price	
			subistitute: 
				l.s $f12, ($t1)
				string_out(price_format_start)
	 			float_out($f12)
	 			string_out(price_format_end)
				increment($t1,4)
				set_char_out_code
			next:
				increment($t0, 1)
			
		j while
		
		exit:
			jr $ra
		
	context_manager:
		
	 	
