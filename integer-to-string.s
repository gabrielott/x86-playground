# Converts the number defined in the .data section to
# a sequence of ASCII characters and prints it to stdout.

.global _start

.text
_start:
	# initial setup
	movl num, %eax    # load number to last bytes (of %edx:%eax, which is what divl uses)
	movl $0, %edx     # write zeros to first bytes
	pushw $0xa        # push '\n' to stack
	testl %eax, %eax  # set flags according to %eax & %eax, which is just %eax
	jns positive      # jump to positive if signal flag isn't set
	neg %eax          # %eax = -%eax (now that we know the number is negative)
	movl $0x2, %esi   # start counter at 2 (because of '\n' and the '-' we'll have to add at the end)
	jmp negative      # now jump to negative
	positive:
	movl $0x1, %esi   # start counter at 1 (because of '\n')
	negative:
	movl $0xa, %ebx   # argument to divl (you can't just use an immediate value apparently)

	# main loop
	loop:
	incl %esi         # counter++
	divl %ebx         # make division
	addl $0x30, %edx  # add '0' to remainder
	pushw %dx         # push result to stack
	movl $0, %edx     # reset first bytes to 0
	testl %eax, %eax  # set flags according to %eax
	jne loop          # jump to loop if zero flag isn't set (since we still have quotient != 0)

	# some extra stuff at the end
	movl num, %eax    # load number again
	testl %eax, %eax  # set flags according to the initial number
	jns no_sign       # jump to no_sign if signal flag isn't set
	pushw $0x2d       # push '-' to stack
	no_sign:
	imull $0x2, %esi  # multiply counter by two (you can't push a byte to the stack, so each character was pushed as a word)

	# write syscall
	movl $0x4, %eax   # syscall number
	movl $0x1, %ebx   # write to stdout
	movl %esp, %ecx   # address to write is the top of the stack
	movl %esi, %edx   # number of bytes to write is the counter
	int $0x80

	# exit syscall
	movl $0x1, %eax   # syscall number
	movl $0, %ebx     # exit succesfully
	int $0x80

.data
	num: .int -293847
