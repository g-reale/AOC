.data
	prompt: .asciiz "Enter the number: "

.text
.globl main
 
main:
	#prompts the user
	li $v0, 4 
	la $a0, prompt
	syscall
	
	#user input -> v0
	li $v0, 5
	syscall
	
	#a0 = v0 + v0
	add $t0, $v0, $v0
	
	#t0 = a0, printf(t0)
	move $a0,$t0  
	li $v0, 1
	syscall
	  
