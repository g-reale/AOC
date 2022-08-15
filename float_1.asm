.data

#UTILITIES
hello: .asciiz "Bem-vindo a Loja de Computadores UNIFESP!\n\n"
menu: .asciiz "Escolha a categoria de produtos:\n0 - Finalizar compra\n1 - Processador\n2 - Memoria interna\n3 - Memoria externa\n4 - Perifericos\n\nDigite a opcao desejada: "
default_option: .asciiz "voltar"
buy_product: .asciiz "\n\nDigite o numero do modelo do produto desejado: "
buy_amount: .asciiz "Digite a quantidade: "

open: .asciiz " ("
currency: .asciiz "R$ "
close: .asciiz ")"

menu_index: .word j_,k,l,m
	j_: .asciiz "\n0 - "
	k:  .asciiz "\n1 - "
	l:  .asciiz "\n2 - "
	m:  .asciiz "\n3 - "

x: .asciiz "x "
unit: .asciiz "\nValor unitario: "
total: .asciiz "\nValor total: " 
purchase_total: .asciiz "Valor total do pedido: "
nl: .asciiz "\n"
nlnl: .asciiz "\n\n"



#MAIN UI
 
		processor_title: .asciiz "Processadores:"
		processor_values: .float 0.0, 2150.50, 3760.0, 2290.90
		processor_options: .word default_option,a,b_,c
			a:.asciiz "AMD Ryzen 7 4.2GHz" 
			b_:.asciiz "Intel Core i9 5.2GHz"
			c:.asciiz "Intel Core i7 3.8 GHz"
		processor_purchase: .word 0x00000000,0x00000000,0x00000000,0x00000000
	processor: .word processor_title, 4, processor_values, processor_options, processor_purchase
		
		internal_mem_title: .asciiz "Memoria interna:"
		internal_mem_values: .float 0.0, 1299.90
		internal_mem_options: .word default_option,d
			d:.asciiz "DDR5 16GB Kingstone" 
		internal_mem_purchase: .word 0x00000000,0x00000000
	internal_mem: .word internal_mem_title, 2, internal_mem_values, internal_mem_options, internal_mem_purchase
	
		external_mem_title: .asciiz "Memoria externa:"
		external_mem_values: .float 0.0, 440.0, 720.0
		external_mem_options: .word default_option,e,f
			e:.asciiz "HD de 2TB Seagate" 
			f:.asciiz "SSD de 1TB Seagate"
		external_mem_purchase: .word 0x00000000,0x00000000,0x00000000
	external_mem: .word external_mem_title, 3, external_mem_values, external_mem_options, external_mem_purchase
	
		peripheral_title: .asciiz "Perifericos:"
		peripheral_values: .float 0.0, 98.50, 149.90, 300.0
		peripheral_options: .word default_option,g,h,i
			g:.asciiz "Mouse Dell" 
			h:.asciiz "Combo Teclado e Mouse Logitech"
			i:.asciiz "Fone de Ouvido JBL"
		peripheral_purchase: .word 0x00000000,0x00000000,0x00000000,0x00000000
	peripheral: .word peripheral_title, 4, peripheral_values, peripheral_options, peripheral_purchase


ui: .word processor, internal_mem, external_mem, peripheral

#MACROS
.macro PRINT_STRING(%string_label)
	li $v0, 4
	la $a0, %string_label
	syscall
.end_macro

.macro PRINT_STRING_ADR(%string_adr)
	li $v0, 4
	move $a0, %string_adr
	syscall
.end_macro

.macro FORMAT_INT(%int)
	li $v0, 1
	move $a0, %int
	syscall
	
	li $v0, 4
	la $a0, x
	syscall	
.end_macro

.macro PRINT_FLOAT(%float)
	li $v0, 2
	mov.s $f12, %float
	syscall
.end_macro

.macro FORMAT_PRICE(%float)

	li $v0, 4
	la $a0, open
	syscall
	
	la $a0, currency
	syscall
	
	li $v0, 2
	mov.s $f12, %float
	syscall
	
	li $v0, 4
	la $a0, close
	syscall 
.end_macro

.macro READ_INT(%destination)
	li $v0, 5
	syscall
	move %destination, $v0
.end_macro

.macro LOAD_UI(%index, %title_dest, %size_dest, %values_dest, %options_dest, %purchase_dest)
	mul %index, %index, 4
	lw %index, ui(%index)
	lw %title_dest, (%index)
	lw %size_dest,  4(%index)
	lw %values_dest, 8(%index)
	lw %options_dest, 12(%index)
	lw %purchase_dest, 16(%index)
.end_macro

.macro DONE
	li $v0, 10
	syscall
.end_macro


.text
main:
	PRINT_STRING(hello)
	PRINT_STRING(menu)
	READ_INT($a0)
	
	beqz $a0, kill
	jal ui_loop
	j main
	
	kill:
		PRINT_STRING(nl)
		li $s0, 0
		li $s1, 4
		
		main_loop: beq $s0, $s1, final
			move $a0, $s0
			jal display_purchase
			add $s0, $s0, 1
		j main_loop
	
	final:	
		PRINT_STRING(purchase_total)
		PRINT_STRING(currency)
		PRINT_FLOAT($f2)
	DONE
	
ui_loop:
	
	#a0 -> ui to load
	#t0 -> tittle 
	#t1 -> size 
	#t2 -> prices 
	#t3 -> options
	#t4 -> purchace
	
	addi $a0, $a0, -1 
	LOAD_UI($a0, $t0, $t1, $t2, $t3, $t4)
	PRINT_STRING_ADR($t0)
	
	#t5 -> line cursor
	#t6 -> text to print
	#f7 -> t5 max 
	#f0 -> float to print
	
	li $t5, 0 
	mul $t7, $t1, 4
	
	loop: beq $t5, $t7, exit
	
		#print menu index
		lw $t6, menu_index($t5)
		PRINT_STRING_ADR($t6)
		
		#print option
		add $t6, $t5, $t3
		lw $t6, ($t6)
		PRINT_STRING_ADR($t6)
	
		#print price
		beqz $t5, pass
			add $t6, $t2, $t5
			l.s $f0,($t6)
			FORMAT_PRICE($f0)
	pass:
		add $t5, $t5, 4 
		j loop
	exit:
	
	#t5 -> product adress
	#t6 -> product amount
	#t7 -> current amount 
	
	PRINT_STRING(buy_product)
	READ_INT($t5)
	beqz $t5, end
		
	PRINT_STRING(buy_amount)
	READ_INT($t6)
	
	mul $t5, $t5, 4
	add $t5, $t5, $t4
	lw $t7, ($t5)
	add $t6, $t7, $t6
	sw $t6, ($t5)
	
	end: jr $ra

display_purchase:
	
	#a0 -> ui to load
	#t1 -> size 
	#t2 -> prices 
	#t3 -> options
	#t4 -> purchace
	
	LOAD_UI($a0, $t0, $t1, $t2, $t3, $t4)
	
	#t0 -> text to print 
	#t5 -> line cursor
	#t6 -> purchace amount
	#t7 -> t5 max 
	#f0 -> float to print
	#f1 -> t6 casted into a float
	#f2 -> global purchace price
	
	li $t5, 0 
	mul $t7, $t1, 4
	
	price_loop: beq $t5, $t7, price_exit
		
		add $t6, $t5, $t4
		lw $t6, ($t6)
		beqz $t6, price_pass
		
		#print amount 
		FORMAT_INT($t6)
		
		#print option
		add $t0, $t5, $t3
		lw $t0, ($t0)
		PRINT_STRING_ADR($t0)
		
		#prints unitary value
		PRINT_STRING(unit)
		PRINT_STRING(currency)
		add $t0, $t2, $t5
		l.s $f0,($t0)
		PRINT_FLOAT($f0)
		
		#prints the total value
		PRINT_STRING(total)
		PRINT_STRING(currency)
		mtc1 $t6, $f1
		cvt.s.w $f1, $f1
		mul.s $f1,$f1,$f0
		PRINT_FLOAT($f1)
		
		#incrments the global price
		add.s $f2, $f2, $f1
		PRINT_STRING(nlnl)
	price_pass:
		add $t5, $t5, 4
		j price_loop
	price_exit:
		jr $ra
	
	
	
	
		
	
	
