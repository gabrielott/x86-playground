; vim: ft=nasm

global _start

section .text

_start:
	mov rax, 1
	mov rdi, 1
	mov rsi, msg
	mov rdx, 14
	syscall

	mov rax, 60
	mov rdi, 0
	syscall

section .data
msg:
	db "Hello, world!", 0xa
