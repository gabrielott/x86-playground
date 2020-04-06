# Prints all arguments to stdout

/*
The kernel writes a bunch of useful info to the stack when the program is called.
Using this info, we can get argc and argv. The %esp register will point to the
argument count (argc). Following argc, the address (not the actual value) of the
nth argument will be %esp + n * 4. If we follow that address we get to where the first
character of the nth argument is. As you would expect, the argument is terminated
with a null byte. More detailed info at:
https://www.dreamincode.net/forums/topic/285550-nasm-linux-getting-command-line-parameters/
*/

.global _start

.text
_start:
	# initial setup
	movl %esp, %edi       # save %esp position to %edi
	movl (%edi), %esi     # save argc to %esi
	decl %esi             # argc-- (we'll ignore the first argument since that's just the name of the file)
	addl $0x4, %edi       # move %edi by 4 bytes (again, ignoring the first argument)
	movl $buf, %edx       # save address of the buffer to %edx

	# main loop
	loop1:
	testl %esi, %esi      # set flags according to %esi
	je done               # if argc == 0, jump to done
	addl $0x4, %edi       # move %edi to next argument
	movl (%edi), %ebx     # get address of first char of argument
	loop2:
	movb (%ebx), %al      # save char to %al
	testb %al, %al        # set flags according to %al
	je end_arg            # if char is a null byte, jump to end_arg (we finished reading the argument)
	movb %al, (%edx)      # otherwise, save the char to the buffer
	incl %edx             # point to next byte of the buffer
	incl %ebx             # point to the next char of the argument
	jmp loop2             # jump to loop2
	end_arg:
	movb $0x20, (%edx)    # save space char to the buffer
	incl %edx             # point to next byte of the buffer
	decl %esi             # argc--
	jmp loop1             # jump to loop1
	done:

	movb $0xa, -1(%edx)   # substitute last char of buffer with a '\n'

	# write syscall
	movl $0x4, %eax       # syscall number
	movl $0x1, %ebx       # write to stdout
	movl $buf, %ecx       # write what's in the buffer
	subl $buf, %edx       # number of bytes to write is %edx - $buf
	int $0x80

	# exit syscall
	movl $0x1, %eax       # syscall number
	movl $0, %ebx         # exit successfully
	int $0x80

.bss
	.lcomm buf, 1000      # reserve 1000 bytes
