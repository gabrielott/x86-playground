/*
 * This is a polish notation (prefix notation) calculator.
 * It supports the four basic operations and works with any 32-bit integer.
 * There's no support for floating point numbers.
 * The expression to be calculated should be sent as command line arguments,
 * the answer will be written to stdout.
 *
 * Examples of how an expression should be written:
 * 10 + 10 --> ./calc + 10 10
 * 2 * 4 --> ./calc \* 2 4 (the '*' operator must be escaped)
 * (5 + 10) / (2 * 7) --> ./calc / + 5 10 + 2 7
 * 10 + 10 + 10 --> ./calc + + 10 10 10
 *
 * There's not a lot of input checking so if you input something that doesn't
 * make sense, you'll most likely get an answer that doesn't make sense.
 */

.global _start

.text

/*
 * Converts a signed integer to a string.
 * Receives two 4-byte argments: the integer to convert and a pointer to where the string should be written.
 * Returns the number of bytes written.
 * Uses caller-save registers %eax and %edx.
 */
int_to_str:
	# stack setup
	pushl %ebp
	movl %esp, %ebp

	# save callee-save registers
	pushl %ebx
	pushl %esi
	pushl %edi

	# initial setup
	movl 8(%ebp), %ebx       # load output address
	movl 12(%ebp), %eax      # load number
	testl %eax, %eax
	jns int_to_str__pos      # jump to positive if signal flag isn't set
	movl $0x1, %esi          # start counter at 1 (because of '-')
	neg %eax                 # %eax = -%eax
	jmp int_to_str__neg
	int_to_str__pos:
	movl $0, %esi            # start counter at 0
	int_to_str__neg:
	movl $0xa, %edi          # argument to divl (you can't just use an immediate value apparently)

	# main loop
	int_to_str__loop:
	movl $0, %edx
	divl %edi
	addl $0x30, %edx         # add '0' to remainder
	movb %dl, (%ebx)         # write char to output
	movl $0, %edx            # reset %edx to 0
	incl %esi                # counter++
	incl %ebx                # move output to next byte
	testl %eax, %eax
	jne int_to_str__loop     # jump to loop if zero flag isn't set (since we still have quotient != 0)

	# add minus sign
	movl 12(%ebp), %eax      # load number again
	testl %eax, %eax
	jns int_to_str__no_sign  # jump to no_sign if signal flag isn't set
	movb $0x2d, (%ebx)       # write '-' to output
	int_to_str__no_sign:

	# invert string
	pushl 8(%ebp)            # address to invert
	pushl %esi               # number of bytes to invert
	call inv_bytes
	addl $0x8, %esp          # shrink stack by 8 bytes

	# write return value
	movl %esi, %eax

	# restore callee-save registers
	popl %edi
	popl %esi
	popl %ebx

	# restore stack and return
	movl %ebp, %esp
	popl %ebp
	ret

/*
 * Converts a string to a signed integer.
 * Receives two 4-byte arguments: a pointer to the string and the length of the string.
 * Returns the string converted to a signed integer.
 * Uses no caller-save registers (besides %eax, which is used for the return value).
 */
str_to_int:
	# stack setup
	pushl %ebp
	movl %esp, %ebp

	# save callee-save registers
	pushl %edi
	pushl %esi
	pushl %ebx

	# initial setup
	movl 8(%ebp), %esi       # get length
	movl 12(%ebp), %edi      # get string
	movl $0, %eax            # start num at 0

	movb (%edi), %bl         # load char
	cmpb $0x2d, %bl
	jne str_to_int__loop     # if char != '-' jump to loop
	incl %edi                # point to next char
	decl %esi                # length--

	str_to_int__loop:
	movb (%edi), %bl         # load char
	subb $0x30, %bl          # char -= '0'
	imull $0xa, %eax         # num *= 10
	movzbl %bl, %ebx         # pad char with zeros
	addl %ebx, %eax          # num += char
	decl %esi                # length--
	incl %edi                # point to next char
	cmpl $0, %esi
	ja str_to_int__loop      # if length > 0, jump to loop

	movl 12(%ebp), %edi      # get string again
	movb (%edi), %bl         # get first char
	cmpb $0x2d, %bl
	jne str_to_int__done     # if char != '-', jump to done
	neg %eax                 # num = -num
	str_to_int__done:

	# restore callee-save registers
	popl %ebx
	popl %esi
	popl %edi

	# restore stack and return
	movl %ebp, %esp
	popl %ebp
	ret

/*
 * Inverts the order of a byte sequence.
 * Receives two 4-byte arguments: A pointer to the first byte of the sequence and the length of the sequence.
 * Doesn't return anything.
 * Uses no caller-save registers.
 */
inv_bytes:
	# stack setup
	pushl %ebp
	movl %esp, %ebp

	# save callee-save registers
	pushl %esi
	pushl %edi
	pushl %ebx

	# initial setup
	movl 8(%ebp), %edi        # load length
	movl 12(%ebp), %esi       # load address
	leal -1(%esi, %edi), %edi # load end address

	# main loop
	inv_bytes__loop:
	cmpl %edi, %esi
	jae inv_bytes__done      # if address >= last address, jump to done
	# swap bytes
	movb (%esi), %bh
	movb (%edi), %bl
	movb %bh, (%edi)
	movb %bl, (%esi)
	incl %esi
	decl %edi
	jmp inv_bytes__loop
	inv_bytes__done:

	# restore callee-save registers
	popl %ebx
	popl %edi
	popl %esi

	# restore stack and return
	movl %ebp, %esp
	popl %ebp
	ret

/*
 * Gets a command line argument.
 * Receives three 4-byte arguments: a pointer to the start of argv, the index of the argument (starting at 0) and a pointer to where the argument should be written.
 * Returns the length of the argument.
 * Uses no caller-save registers (besides %eax, which is used for the return value).
 */
argv:
	# stack setup
	pushl %ebp
	movl %esp, %ebp

	# save callee-save registers
	pushl %edi
	pushl %esi
	pushl %ebx

	# initial setup
	movl 8(%ebp), %esi       # load output address
	movl 12(%ebp), %ebx      # load argv index
	movl 16(%ebp), %edi      # load argv start address
	leal (%edi, %ebx, 4), %edi # move %ebx to the index requested
	movl (%edi), %edi        # get arg address
	movl $0, %eax            # start counter at 0

	# main loop
	argv__loop:
	movb (%edi), %bl         # get argument char
	testb %bl, %bl
	je argv__done            # go to done if char is a null byte
	movb %bl, (%esi)         # save char to output
	incl %edi                # point to next byte of arg
	incl %esi                # point to next byte of output
	incl %eax                # counter++
	jmp argv__loop           # jump to start of the loop
	argv__done:

	# restore callee-save registers
	popl %ebx
	popl %esi
	popl %edi

	# restore stack and return
	movl %ebp, %esp
	popl %ebp
	ret

/*
 * Prints a string to stdout with a newline char at the end.
 * Receives two 4-byte arguments: a pointer to the start of the string and the length of the string.
 * Returns whatever the write() syscall returned when writing to stdout.
 * Uses caller-save registers %eax, %ecx and %edx.
 */
println:
	# stack setup
	pushl %ebp
	movl %esp, %ebp

	# save callee-save registers
	pushl %ebx

	# add '\n' to end of string
	movl 8(%ebp), %edx
	movl 12(%ebp), %ecx
	movl $0xa, (%ecx, %edx)
	incl %edx

	# write syscall
	movl $0x4, %eax
	movl $0x1, %ebx
	int $0x80

	# restore callee-save registers
	popl %ebx

	# restore stack and return
	movl %ebp, %esp
	popl %ebp
	ret

/*
 * Checks whether a string is a number.
 * Receives two 4-byte arguments: a pointer to the start of the string and the length of the string.
 * Returns 1 if the string is a number or 0 otherwise.
 * Uses no caller-save registers (besides %eax, which is used for the return value).
 */
is_number:
	# stack setup
	pushl %ebp
	movl %esp, %ebp

	# save callee-save registers
	pushl %edi
	pushl %esi
	pushl %ebx

	movl 8(%ebp), %edi       # get length
	movl 12(%ebp), %esi      # get string

	# if string has length one, skip sign check
	cmpl $0x1, %edi
	je is_number__loop

	# check if first char is '-'
	movb (%esi), %bl
	cmpb $0x2d, %bl
	jne is_number__loop
	incl %esi
	decl %edi
	
	# check if any char of string is not a digit
	is_number__loop:
	movb (%esi), %bl
	cmpb $0x30, %bl
	jb is_number__no
	cmpb $0x39, %bl
	ja is_number__no
	incl %esi
	decl %edi
	cmpl $0, %edi
	jne is_number__loop

	# set return value
	movl $0x1, %eax
	jmp is_number__yes
	is_number__no:
	movl $0, %eax
	is_number__yes:

	# restore callee-save registers
	popl %ebx
	popl %esi
	popl %edi

	# restore stack and return
	movl %ebp, %esp
	popl %ebp
	ret
	
_start:
	movl %esp, init_esp      # save %esp
	movl (%esp), %edi        # start arg counter at argc
	movl $0, %esi            # start operand count at 0

	main__loop:
	# check if all args were read
	decl %edi
	cmpl $0x1, %edi
	jb main__done

	# get next arg
	movl init_esp, %eax
	leal 4(%eax), %eax
	pushl %eax
	pushl %edi
	pushl $buf
	call argv
	addl $0xc, %esp
	movl %eax, %ebx          # save arg size

	# check if arg is a number
	pushl $buf
	pushl %ebx
	call is_number
	addl $0x8, %esp
	cmp $0x1, %eax
	jne main__operator

	# convert to integer and push to stack
	pushl $buf
	pushl %ebx
	call str_to_int
	addl $0x8, %esp
	pushl %eax
	incl %esi
	jmp main__loop

	main__operator:
	# check if there are two operands on the stack
	cmpl $0x2, %esi
	jb main__err_operand
	decl %esi
	
	popl %eax                # get first operand
	popl %ebx                # get second operand
	movzbl buf, %ecx         # get operator

	# jump to the chosen operation or jump to error if operator doesn't exist
	subl $0x2a, %ecx
	cmpl $0x5, %ecx
	ja main__err_operator
	jmp *op_table(, %ecx, 4)

	main__op_mul:
	imull %ebx, %eax
	pushl %eax
	jmp main__loop

	main__op_add:
	addl %ebx, %eax
	pushl %eax
	jmp main__loop

	main__op_sub:
	subl %ebx, %eax
	pushl %eax
	jmp main__loop

	main__op_div:
	movl $0, %edx
	idivl %ebx
	pushl %eax
	jmp main__loop

	main__done:
	# convert result to a string
	pushl $buf
	call int_to_str
	addl $0x8, %esp

	# print result
	pushl $buf
	pushl %eax
	call println
	addl $0x8, %esp
	jmp main__exit

	main__err_operator:
	pushl $err_operator
	pushl $0x11
	call println
	addl $0x8, %esp
	jmp main__exit

	main__err_operand:
	pushl $err_operand
	pushl $0x25
	call println
	addl $0x8, %esp

	main__exit:
	# exit syscall
	movl $0x1, %eax          # syscall number
	movl $0, %ebx            # exit succesfully
	int $0x80

.data
op_table:
	.long main__op_mul       # 2a
	.long main__op_add       # 2b
	.long main__err_operator # 2c
	.long main__op_sub       # 2d
	.long main__err_operator # 2e
	.long main__op_div       # 2f
err_operator:
	.ascii "Invalid operator."
err_operand:
	.ascii "Each operator must have two operands."

.bss
.lcomm buf, 1000         # buffer used to read arguments
.lcomm init_esp, 4       # used to save the initial %esp
