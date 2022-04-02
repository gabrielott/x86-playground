; vim: ft=nasm

global _start
section .text

_start:
	xor rdi, rdi
	mov rax, buf
loop:
	inc rdi
	mov byte [rax + rdi], 0x61
	cmp rdi, 99
	jl loop

	mov byte [rax + rdi], 0xa

	mov rax, 1
	mov rdi, 1
	mov rsi, buf
	mov rdx, 100
	syscall

	mov rax, 60
	mov rdi, 0
	syscall

section .data

section .bss
buf: resb 100
