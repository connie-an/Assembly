//---------------------------------------------------------------------
// bigintadd.s
// Author: Connie An, Anthony Ng
//---------------------------------------------------------------------

        .section .rodata


//---------------------------------------------------------------------

        .section .data

//---------------------------------------------------------------------

        .section .bss

//---------------------------------------------------------------------

        .section .text

        .equ FALSE, 0
        .equ TRUE, 1
        
        // Must be a multiple of 16
        .equ    LARGER_STACK_BYTECOUNT, 32
        .equ    LLENGTH1, 8
        .equ    LLENGTH2, 16
        .equ    LLARGER, 24

BigInt_larger:
        // Prolog
        sub     sp, sp, LARGER_STACK_BYTECOUNT
        str     x30, [sp]

        //lLength1 = X0, lLength2 = X1, return address = X30
        str     x30, [sp]
        str     x0, [sp, LLENGTH1]  //lLength1
        str     x1, [sp, LLENGTH2] //lLength2
        str     x2, [sp, LLARGER] //lLarger
        
        // if (lLength1 <= lLength2) goto else1;
        cmp     x0, x1
        ble     else1
        //  lLarger = lLength1;
        str     x0, [sp, LLARGER]
        b       endif1
else1:
        // lLarger = lLength2;
        str     x1, [sp, LLARGER]
endif1:
        // return lLarger
        ldr     x0, [sp, LLARGER]
        ldr     x30, [sp] // Restore x30
        add     sp, sp, LARGER_STACK_BYTECOUNT
        ret
//--------------------------------------------------------------------


// Assign the sum of oAddend1 and oAddend2 to oSum.  oSum should be
// distinct from oAddend1 and oAddend2.  Return 0 (FALSE) if an
// overflow occurred, and 1 (TRUE) otherwise. */

        // Must be a multiple of 16
        .equ    ADD_STACK_BYTECOUNT, 64
        .equ    OADDEND1, 8
        .equ    OADDEND2, 16
        .equ    OSUM, 24
        .equ    ULCARRY, 32
        .equ    ULSUM, 40
        .equ    LINDEX, 48
        .equ    LSUMLENGTH, 56
        .equ    AULDIGITS, 8
        .equ    SIZE_OF_UNSIGNED_LONG, 8
        .equ    MAX_DIGITS, 32768
        
        .global BigInt_add
BigInt_add:     

        // Prolog
        sub     sp, sp, ADD_STACK_BYTECOUNT
        str     x30, [sp]

        // x0 = BigInt_T oAddend1, x1 = BigInt_T oAddend2,
        // x2 = BigInt_T oSum
        str     x0, [sp, OADDEND1]  // oAddend1
        str     x1, [sp, OADDEND2] // oAddend2
        str     x2, [sp, OSUM] // oSum
      
        // Determine the larger length. 
        // lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);
        ldr     x0, [sp, OADDEND1] 
        ldr     x0, [x0]
        ldr     x1, [sp, OADDEND2]
        ldr     x1, [x1]
        b       BigInt_larger
        str     x0, [sp, LSUMLENGTH]

        // Clear oSum's array if necessary. 
        // if (oSum->lLength <= lSumLength) goto endif2;
        ldr     x0, [sp, OSUM]
        ldr     x0, [x0]
        ldr     x1, [sp, LSUMLENGTH]
        cmp     x0, x1
        ble     endif2

        //memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));
        // sizeof(unsigned long);
        mov     x0, SIZE_OF_UNSIGNED_LONG
        mov     x1, MAX_DIGITS
        mul     x0, x0, x1
        mov     x2, x0
        mov     x1, 0
        ldr     x0, [sp, OSUM]
        ldr     x0, [x0, AULDIGITS]
        bl      memset
endif2:
      
        // Perform the addition.
        // ulCarry = 0; [sp, 32]
        mov     x1, 0
        str     x1, [sp, ULCARRY]
        // lIndex = 0;
        str     x1, [sp, LINDEX]
loop1:
        
        // if(lIndex >= lSumLength) goto endloop1;
        ldr     x0, [sp, LINDEX]
        ldr     x1, [sp, LSUMLENGTH]
        cmp     x0, x1
        bge     endloop1
        // ulSum = ulCarry;
        ldr     x0, [sp, ULCARRY]
        str     x0, [sp, ULSUM]
        // ulCarry = 0;
        mov     x0, 0
        str     x0, [sp, ULCARRY]
        // ulSum += oAddend1->aulDigits[lIndex];
        ldr     x0, [sp, OADDEND1]
        add     x0, x0, AULDIGITS
        str     x1, [sp, LINDEX]
        ldr     x0, [x0, x1, lsl 3]
        ldr     x1, [sp, ULSUM]
        add     x1, x1, x0
        str     x1, [sp, ULSUM]
        
        // if (ulSum >= oAddend1->aulDigits[lIndex]) goto endif3;
        // Check for overflow.
        ldr     x1, [sp, ULSUM]
        cmp     x1, x0
        bhs     endif3
        // ulCarry = 1;
        mov     x0, 1
        str     x0, [sp, ULCARRY]
        // goto loop1;
        b       loop1
endif3:
  
        // ulSum += oAddend2->aulDigits[lIndex];
        ldr     x0, [sp, OADDEND2]
        add     x0, x0, AULDIGITS
        str     x1, [sp, LINDEX]
        ldr     x0, [x0, x1, lsl 3]
        ldr     x1, [sp, ULSUM]
        add     x1, x1, x0
        str     x1, [sp, ULSUM]
        // if (ulSum >= oAddend2->aulDigits[lIndex]) goto endif4;
        // Check for overflow. 
        ldr     x1, [sp, ULSUM]
        cmp     x1, x0
        bhs     endif4
        //ulCarry = 1;
        mov     x0, 1
        str     x0, [sp, ULCARRY]
endif4:
        
        // oSum->aulDigits[lIndex] = ulSum;
        ldr     x0, [sp, OSUM]
        add     x0, x0, AULDIGITS
        ldr     x1, [sp, LINDEX]
        ldr     x2, [sp, ULSUM]
        str     x2, [x0, x1, lsl 3]
        
        //lIndex++;
        ldr     x0, [sp, LINDEX]
        add     x0, x0, 1
        str     x0, [sp, LINDEX]
endloop1:

        // Check for a carry out of the last "column" of the addition. 
        // if (ulCarry != 1) goto endif5;
        ldr     x0, [sp, ULCARRY]
        cmp     x0, 1
        bne     endif5
        // if (lSumLength != MAX_DIGITS) goto endif6;
        ldr     x1, [sp, LSUMLENGTH]
        cmp     x1, MAX_DIGITS
        bne     endif6
        // return FALSE;
        mov     x0, FALSE
        ldr     x30, [sp] // Restore x30
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret
endif6:
        // oSum->aulDigits[lSumLength] = 1;
        ldr     x0, [sp, OSUM]
        add     x0, x0, AULDIGITS
        ldr     x1, [sp, LSUMLENGTH]
        mov     x2, 1
        str     x2, [x0, x1, lsl 3]
         //lSumLength++;
        ldr     x0, [sp, LSUMLENGTH]
        add     x0, x0, 1
        str     x0, [sp, LSUMLENGTH]
endif5:
        // Set the length of the sum. 
        // oSum->lLength = lSumLength;
        ldr     x0, [sp, OSUM]
        ldr     x1, [sp, LSUMLENGTH]
        str     x1, [x0]
        // return TRUE
        mov     x0, TRUE
        ldr     x30, [sp] // Restore x30
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret
