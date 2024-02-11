#!/bin/bash
nasm -f elf64 asm_io.asm && 
gcc -m64 -no-pie -std=c17 -c driver.c
nasm -f elf64 $1.asm &&
gcc -m64 -no-pie -std=c17 -o $1 driver.c $1.o asm_io.o &&
# ./$1
time ./$1