; vim: ft=nasm

; Reads a single line from stdin and writes it to a file
; called 'myfile.txt' located on the current directory.

global _start
section .text

_start:
	xor rdi, rdi          ; sets the fd of read() to 0 (stdin)
	xor rbx, rbx          ; rbx will count how many bytes we read
	mov rdx, 1            ; sets the count of read() to 1

loop:
	xor rax, rax          ; read() syscall
	lea rsi, [line + rbx] ; sets the buffer of read()
	syscall               ; calls read() to read a single character

	mov al, [rsi]         ; moves the character read to al
	inc rbx               ; increases the counter by 1
	cmp al, 0xa           ; compares the character to 0xa (\n)
	jne loop              ; jumps if we didn't read a line break

	mov rax, 2            ; open() syscall
	mov rdi, filename     ; sets the filename of open()
	mov rsi, 101          ; sets the flag of open() (O_CREAT and O_WRONLY)
	mov rdx, 400          ; sets the mode of open() (S_IRUSR)
	syscall               ; calls open()

	mov rdi, rax          ; sets the fd of write() using the return of open()
	mov rax, 1            ; write() syscall
	mov rsi, line         ; sets the buffer of write()
	mov rdx, rbx          ; sets the count of write()
	syscall               ; calls write()

	mov rax, 3            ; close() syscall
	syscall               ; calls close()

	mov rax, 60           ; exit() syscall
	xor rdi, rdi          ; exit code
	syscall               ; calls exit()

section .data
filename:
	db "./myfile.txt", 0

section .bss
line:
	resb 100
