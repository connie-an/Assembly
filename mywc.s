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
cChar:
        .skip 1

//---------------------------------------------------------------------

        .section .text

        .equ FALSE, 0
        .equ TRUE, 0
        // Must be a multiple of 16
        .equ    MAIN_STACK_BYTECOUNT, 16

        .global main
        
// Write to stdout counts of how many lines, words, and characters
//   are in stdin. A word is a sequence of non-whitespace characters.
//   Whitespace is defined by the isspace() function. Return 0. 

        // Prolog
        sub     sp, sp, MAIN_STACK_BYTECOUNT
        str     x30, [sp]

        adr     w1, iChar
        ldr     w1, [w1]
        adr     x2, lCharCount
        ldr     x2, [x2]
        adr     w3, iInWord
        ldr     w3, [w3]
        adr     x4, lWordCount
        ldr     x4, [w4]
        adr     x5, lLineCount
        ldr     x5, [x5]
        
loop1:
        // if((iChar = getchar()) == EOF) goto endloop1;
        // iChar = (char)getchar()
        bl      getchar
        str     w1, w0
        cmp     w1, -1
        beq     endloop1

        //lCharCount++;
        add     x2, x2, 1

        //if(!isspace(iChar)) goto else1 ;
        mov     x0, x1
        bl      isSpace
        cmp     x0, 0
        beq     else1

        //if(!iInWord) goto endif2 ;
        cmp     x3, 0
        beq     endif2

        //lWordCount++;
        add     x4, x4, 1

        //iInWord = FALSE;
        mov     w3, FALSE
        
endif2:
        b       endif1
else1:
        //if(iInWord) goto endif3;
        cmp     w3, 1
        beq     endif3
     
        //iInWord = TRUE;
        mov     iInWord, TRUE
        
endif3:
endif1:
        //if(iChar != '\n') goto endif4;
        cmp     w1, 10
        bne     endif4
        
        //lLineCount++;
        add     x5, x5, 1
endif4:
        b       loop1
endloop1:
        
/*
int main(void)
{
  loop1:
   
   if((iChar = getchar()) == EOF) goto endloop1;
   lCharCount++;

   if(!isspace(iChar)) goto else1;
   if(!iInWord) goto endif2;
   lWordCount++;
   iInWord = FALSE;
  endif2:
   goto endif1;
  else1: 
   if(iInWord) goto endif3;
   iInWord = TRUE;
  endif3:
  endif1:

 if(iChar != '\n') goto endif4;
   lLineCount++;
  endif4:
   goto loop1;
  endloop1:

   if(!iInWord) goto endif5;
   lWordCount++;
  endif5:
   
   printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
   return 0;
}
        */
        //if(!iInWord) goto endif5;
        cmp     w3, 0
        beq     endif5
        //lWordCount++;
        add     x4, x4, 1

        str     x2, lCharCount
        str     x4, lWordCount
        str     x5, lLineCount
endif5: 
        // printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
        adr     x0, printingString
        adr     x1, lLineCount
        ldr     x1, [x1]
        adr     x2, lWordCount
        ldr     x2, [x2]
        adr     x3, lCharCount
        ldr     x3, [x3]
        bl      printf
        
        // Epilog and return 0
        mov     w0, 0
        ldr     x30, [sp]
        add     sp, sp, MAIN_STACK_BYTECOUNT
        ret

        .size   main, (. - main)
