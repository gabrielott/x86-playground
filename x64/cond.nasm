; vim: ft=nasm

global _start

NUM equ 5

section .text
_start:
	mov rax, 1
	mov rdi, 1

	mov rbx, NUM
	cmp rbx, 5
	jge true

false:
	mov rsi, msg_false
	mov rdx, 6
	syscall
	jmp end

true:
	mov rsi, msg_true
	mov rdx, 5
	syscall

end:
	mov rax, 60
	mov rdi, 0
	syscall

section .data
msg_true:
	db "True", 0xa
msg_false:
	db "False", 0xa
