; vim: ft=nasm

global _start
section .text

_start:
	mov rsi, [rsp + 16]
	xor rdx, rdx

loop:
	mov bl, [rsi + rdx]
	inc rdx
	test bl, bl
	jnz loop

	mov rax, 1
	mov rdi, 1
	syscall

	mov rax, 1
	mov rsi, line_break
	mov rdx, 1
	syscall

	mov rax, 60
	mov rdi, 0
	syscall

section .data
line_break:
	db 0xa
