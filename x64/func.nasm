; vim: ft=nasm

global _start

section .text

println:
	push rbp
	mov rbp, rsp

	mov rax, 1
	mov rdi, 1
	mov rsi, [rbp + 16] ; primeiro argumento
	mov rdx, [rbp + 24] ; segundo argumento
	syscall

	mov rax, 1
	mov rsi, line_break
	mov rdx, 1
	syscall

	mov rsp, rbp
	pop rbp
	ret

_start:
	push 20
	push msg
	call println

	mov rax, 60
	mov rdi, 0
	syscall

section .data
line_break:
	db 0xa
msg:
	db "Oi, isso eh um teste"
