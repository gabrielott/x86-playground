# Reads from stdin, then writes what was read to stdout

.global _start

.text
_start:
	movl $buf, %edi   # load initial address of the buffer
	movl $0x1, %esi   # start counter at 1 (because of the '\n' we'll add at the end)

	loop:
	# read syscall
	movl $0x3, %eax   # syscall number
	movl $0, %ebx     # read from stdin
	movl %edi, %ecx   # write to the address in %edi
	movl $0x1, %edx   # read only one byte
	int $0x80

	# The read syscall will write its return value to %eax. If it read succefully it will
	# return the number of bytes read. If it reached end-of-file, it will return 0. If some
	# error occurs it will return -1. You can read the manual with the command 'man 2 read'.

	incl %esi         # counter++
	incl %edi         # increase address by 1
	cmpl $0, %eax     # set flags according to %eax - 0 (apparently you can only use an immediate value on the left argument)
	jg loop           # if %eax > 0 (if the syscall was able to read successfully), jump to loop
	movl $0xa, (%edi) # write '\n' to the buffer

	# write syscall
	movl $0x4, %eax   # syscall number
	movl $0x1, %ebx   # write to stdout
	movl $buf, %ecx   # write what's in the buffer
	movl %esi, %edx   # write the number of bytes in the counter
	int $0x80

	# exit syscall
	movl $0x1, %eax   # syscall number
	movl $0, %ebx     # exit succesfully
	int $0x80

.bss
	.lcomm buf, 1000  # reserve 1000 bytes
