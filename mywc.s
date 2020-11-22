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
        .equ    MAIN_STACK_BYTECOUNT, 48

        .equ ICHAR, 8
        .equ LCHARCOUNT, 16
        .equ IINWORD, 24
        .equ LWORDCOUNT, 32
        .equ LLINECOUNT, 40
        
        .global main
main:  
// Write to stdout counts of how many lines, words, and characters
//   are in stdin. A word is a sequence of non-whitespace characters.
//   Whitespace is defined by the isspace() function. Return 0. 

        // Prolog
        sub     sp, sp, MAIN_STACK_BYTECOUNT
        str     x30, [sp]

        adr     x0, iChar
        ldr     w0, [x0]
        str     w0, [sp, ICHAR]
        
        adr     x0, lCharCount
        ldr     x0, [x0]
        str     x0, [sp, LCHARCOUNT]
        
        adr     x0, iInWord
        ldr     w0, [x0]
        str     w0, [sp, IINWORD]
        
        adr     x0, lWordCount
        ldr     x0, [x0]
        str     x0, [sp, LWORDCOUNT]

        adr     x0, lLineCount
        ldr     x0, [x0]
        str     x0, [sp, LLINECOUNT]
        
loop1:
        // if((iChar = getchar()) == EOF) goto endloop1;
        // iChar = (char)getchar()
        bl      getchar
        str     w0, [sp, ICHAR]
        ldr     w0, [sp, ICHAR]
        cmp     w0, -1
        beq     endloop1

        //lCharCount++;
        ldr     x0, [sp, LCHARCOUNT]
        add     x0, x0, 1
        str     x0, [sp, LCHARCOUNT]

        //if(!isspace(iChar)) goto else1 ;
        ldr     w0, [sp, ICHAR]
        bl      isspace
        cmp     w0, FALSE
        beq     else1

        //if(!iInWord) goto endif2 ;
        ldr     w0, [sp, IINWORD]
        cmp     w0, FALSE
        beq     endif2

        //lWordCount++;
        ldr     x0, [sp, LWORDCOUNT]
        add     x0, x0, 1
        str     x0, [sp, LWORDCOUNT]

        //iInWord = FALSE;
        mov     w0, FALSE
        str     w0, [sp, IINWORD]
        
endif2:
        b       endif1
else1:
        //if(iInWord) goto endif3;
        ldr     w0, [sp, IINWORD]
        cmp     w0, TRUE
        beq     endif3
     
        //iInWord = TRUE;
        mov     w0, TRUE
        str     w0, [sp, IINWORD]
        
endif3:
endif1:
        //if(iChar != '\n') goto endif4;
        ldr     w0, [sp, ICHAR]
        cmp     w0, 10
        bne     endif4
        
        //lLineCount++;
        ldr     x0, [sp, LLINECOUNT]
        add     x0, x0, 1
        str     x0, [sp, LLINECOUNT]
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
        ldr     w0, [sp, IINWORD]
        cmp     w0, FALSE
        beq     endif5
        //lWordCount++;
        ldr     x0, [sp, LWORDCOUNT]
        add     x0, x0, 1
        str     x0, [sp, LWORDCOUNT]

endif5:
        
        // printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
        adr     x0, printingStr
        ldr     x1, [sp, LLINECOUNT]
        ldr     x2, [sp, LWORDCOUNT]
        ldr     x3, [sp, LCHARCOUNT]
        bl      printf
        
        // Epilog and return 0
        mov     w0, 0
        ldr     x30, [sp]
        add     sp, sp, MAIN_STACK_BYTECOUNT
        ret

        .size   main, (. - main)
