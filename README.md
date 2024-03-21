# Project 6 (Proj6_shielkel.asm)

## Overview

This assembly language program implements two macros for string processing. One macro receives strings of signed decimal integers from the user as input, and the other macro displays strings of signed decimal integers as output. The program contains several procedures that invoke these macros. One procedure collects 10 signed decimal integer strings, converts them to their numeric representation, and performs validation to ensure they fit within a 32-bit register. Another procedure converts these numeric representations back to ASCII values to display them back to the user. Additionally, the program contains procedures to calculate the sum and the truncated average of the numeric representation, which are also displayed to the user in their ASCII form.

## Usage

To run the program:

1. Assemble the assembly code using an x86 architecture emulator or assembler (e.g., MASM, NASM).
2. Execute the compiled program.

```bash
nasm -f elf Proj6_shielkel.asm
ld -m elf_i386 -s -o Proj6_shielkel Proj6_shielkel.o
./Proj6_shielkel
```

## Macros

1. mGetString
Allows user inputs to be collected; prompts the user to enter using WriteString, collects input (as strings) using ReadString, and stores the string value and size of the string in memory offsets.

2. mDisplayString
Allows strings to be displayed to the console using WriteString.

## Requirements
Irvine32 Library: This program utilizes procedures from the Irvine32 library for various functionalities.
