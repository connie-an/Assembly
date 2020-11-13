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

        adr     x21, iChar
        ldr     w21, [x21]
        adr     x22, lCharCount
        ldr     x22, [x22]
        adr     x23, iInWord
        ldr     w23, [x23]
        adr     x24, lWordCount
        ldr     x24, [x24]
        adr     x25, lLineCount
        ldr     x25, [x25]
        
loop1:
        // if((iChar = getchar()) == EOF) goto endloop1;
        // iChar = (char)getchar()
        bl      getchar
        mov     w21, w0
        cmp     w21, -1
        beq     endloop1

        //lCharCount++;
        add     x22, x22, 1

        //if(!isspace(iChar)) goto else1 ;
        mov     w0, w21
        bl      isspace
        cmp     w0, 0
        beq     else1

        //if(!iInWord) goto endif2 ;
        cmp     x23, 0
        beq     endif2

        //lWordCount++;
        add     x24, x24, 1

        //iInWord = FALSE;
        mov     w23, FALSE
        
endif2:
        b       endif1
else1:
        //if(iInWord) goto endif3;
        cmp     w23, 1
        beq     endif3
     
        //iInWord = TRUE;
        mov     x23, TRUE
        
endif3:
endif1:
        //if(iChar != '\n') goto endif4;
        cmp     w21, 10
        bne     endif4
        
        //lLineCount++;
        add     x25, x25, 1
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
        cmp     w23, 0
        beq     endif5
        //lWordCount++;
        add     x24, x24, 1

endif5:
        
        // printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
        adr     x0, printingStr
        mov     x1, x25
        mov     x2, x24
        mov     x3, x22
        bl      printf
        
        // Epilog and return 0
        mov     w0, 0
        ldr     x30, [sp]
        add     sp, sp, MAIN_STACK_BYTECOUNT
        ret

        .size   main, (. - main)
