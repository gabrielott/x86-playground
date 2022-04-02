# x86-playground

Small basic programs I wrote to get the hang of x86 assembly. Every line is commented, so it might be useful to people who are learning too.


## x86
The `.s` files on the root of the repository
are written in `gas` x86 (32-bit) assembly (AT&T syntax).

### How to assemble/run:
I'll assume you're running some flavor of Unix, since these programs won't run without modification on anything else.

* Assemble with `as --32 -o filename.o filename.s`
* Link with `ld -m elf_i386 -o filename filename.o`
* Run with `./filename`

You should replace 'filename' with the actual filename.

## x64
The `.nasm` files on the `x64` directory
are written in `nasm` x64 (64-bit) assembly (Intel syntax).

### How to assemble/run:

* Assemble with `nasm -f elf64 filename.nasm`
* Link with `ld -o filename filename.o`
* Run with `./filename`

You should replace 'filename' with the actual filename.
