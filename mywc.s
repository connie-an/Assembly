//---------------------------------------------------------------------
// mywc.s
// Author: Connie An, Anthony Ng
//---------------------------------------------------------------------

        .section .rodata

printingStr:
        .string "%7ld %7ld %7ld\n"

//---------------------------------------------------------------------

        .section .data

lLineCount:
        .quad 0
lWordCount:
        .quad 0
lCharCount:
        .quad 0
iInWord:
        .word 0

//---------------------------------------------------------------------

        .section .bss

iChar:
        .skip 4

//---------------------------------------------------------------------

        .section .text

        .equ FALSE, 0
        .equ TRUE, 1

// Must be a multiple of 16
        .equ    MAIN_STACK_BYTECOUNT, 16

        .global main
main:
// Write to stdout counts of how many lines, words, and characters
//   are in stdin. A word is a sequence of non-whitespace characters.
//   Whitespace is defined by the isspace() function. Return 0.

// Prolog
        sub     sp, sp, MAIN_STACK_BYTECOUNT
        str     x30, [sp]

loop1:
// if((iChar = getchar()) == EOF) goto endloop1;
// iChar = (char)getchar()
        bl      getchar
        adr     x1, iChar
        str     w0, [x1]
        ldr     w0, [x1]
        cmp     w0, -1
        beq     endloop1

//lCharCount++;
        adr     x1, lCharCount
        ldr     x0, [x1]
        add     x0, x0, 1
        str     x0, [x1]

//if(!isspace(iChar)) goto else1 ;
        adr     x1, iChar
        ldr     w0, [x1]
        bl      isspace
        cmp     w0, FALSE
        beq     else1

//if(!iInWord) goto endif2 ;
        adr     x1, iInWord
        ldr     w0, [x1]
        cmp     w0, FALSE
        beq     endif2

//lWordCount++;
        adr     x1, lWordCount
        ldr     x0, [x1]
        add     x0, x0, 1
        str     x0, [x1]

//iInWord = FALSE;
        adr     x1, iInWord
        mov     w0, FALSE
        str     w0, [x1]

endif2:
        b       endif1
else1:
//if(iInWord) goto endif3;
        adr     x1, iInWord
        ldr     w0, [x1]
        cmp     w0, TRUE
        beq     endif3

//iInWord = TRUE;
        adr     x1, iInWord
        mov     w0, TRUE
        str     w0, [x1]

endif3:
endif1:
//if(iChar != '\n') goto endif4;
        adr     x1, iChar
        ldr     w0, [x1]
        cmp     w0, 10
        bne     endif4

//lLineCount++;
        adr     x1, lLineCount
        ldr     x0, [x1]
        add     x0, x0, 1
        str     x0, [x1]
endif4:
        b       loop1
endloop1:

//if(!iInWord) goto endif5;
        adr     x1, iInWord
        ldr     w0, [x1]
        cmp     w0, FALSE
        beq     endif5
//lWordCount++;
        adr     x1, lWordCount
        ldr     x0, [x1]
        add     x0, x0, 1
        str     x0, [x1]

endif5:

// printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
        adr     x0, printingStr

        adr     x2, lLineCount
        ldr     x1, [x2]

        adr     x3, lWordCount
        ldr     x2, [x3]

        adr     x4, lCharCount
        ldr     x3, [x4]
        bl      printf

// Epilog and return 0
        mov     w0, 0
        ldr     x30, [sp]
        add     sp, sp, MAIN_STACK_BYTECOUNT
        ret

        .size   main, (. - main)
