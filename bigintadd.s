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

BigInt_larger:
        // Prolog
        sub     sp, sp, GCD_STACK_BYTECOUNT
        str     x30, [sp]

        //lLength1 = X0, lLength2 = X1, return address = X30
        str     x30, [sp]
        str     x0, [sp, 8]  //lLength1
        str     x1, [sp, 16] //lLength2
        str     x2, [sp, 24] //lLarger
        
        // if (lLength1 <= lLength2) goto else1;
        cmp     x0, x1
        ble     else1
        //  lLarger = lLength1;
        mov     [sp, 24], x0
        b       endif1
else1:
        // lLarger = lLength2;
        mov     [sp, 24], x1
endif1:
        // return lLarger
        mov     x0, [sp, 24]
        ldr     x30, [sp] // Restore x30
        add     sp, sp, LARGER_STACK_BYTECOUNT
        ret
//--------------------------------------------------------------------


// Assign the sum of oAddend1 and oAddend2 to oSum.  oSum should be
// distinct from oAddend1 and oAddend2.  Return 0 (FALSE) if an
// overflow occurred, and 1 (TRUE) otherwise. */

        // Must be a multiple of 16
        .equ    ADD_STACK_BYTECOUNT, 64
        
BigInt_add:

        // Prolog
        sub     sp, sp, ADD_STACK_BYTECOUNT
        str     x30, [sp]

        // x0 = BigInt_T oAddend1, x1 = BigInt_T oAddend2,
        // x2 = BigInt_T oSum
        str     x30, [sp]
        str     x0, [sp, 8]  // oAddend1
        str     x1, [sp, 16] // oAddend2
        str     x2, [sp, 24] // oSum
      
        // unsigned long ulCarry;  [sp, 32]
        // unsigned long ulSum;    [sp, 40]
        // long lIndex;            [sp, 48]
        // long lSumLength;        [sp, 56]

        // Determine the larger length. 
        // lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);
        ldr     x0, [sp, 8]  //idk man
        ldr     x1, [sp, 16]
        bl      BigInt_Larger
        mov     x0, [sp, 56]

        // Clear oSum's array if necessary. 
        // if (oSum->lLength <= lSumLength) goto endif2;
        cmp     [sp, 32], [sp, 56]
        ble     endif2

        //memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));
        // sizeof(unsigned long);
        mov     x0, 
        bl      sizeof
        mul     x0,x0, MAX_DIGITS
        mov     x2, x0
        mov     x1, zr
        mov     x0, [sp, 24]
        bl      memset
endif2:
      
        // Perform the addition.
        // ulCarry = 0; [sp, 32]
        mov     [sp, 32], 0
        // lIndex = 0;
        mov     [sp, 48], 0
loop1:
        
        // if(lIndex >= lSumLength) goto endloop1;
        cmp     [sp, 48], [sp, 56]
        bge      endloop1
        // ulSum = ulCarry;
        mov     [sp, 40], [sp, 32]
        // ulCarry = 0;
        mov     [sp, 32], zr
        // ulSum += oAddend1->aulDigits[lIndex];
        idk
        // if (ulSum >= oAddend1->aulDigits[lIndex]) goto endif3;  /* Check for overflow. */
        idk
        // ulCarry = 1;
        mov     [sp, 32], 1
        // goto loop1;
        b       loop1
endif3:
  
        // ulSum += oAddend2->aulDigits[lIndex];
        idk
        // if (ulSum >= oAddend2->aulDigits[lIndex]) goto endif4; /* Check for overflow. */
        idk
        //ulCarry = 1;
        mov     [sp, 32], 1
endif4:
        
        // oSum->aulDigits[lIndex] = ulSum;
        idk
        //lIndex++;
        add     [sp, 48], [sp,48], 1 
endloop1:

        // Check for a carry out of the last "column" of the addition. 
        // if (ulCarry != 1) goto endif5;
        cmp     [sp, 32], 1
        bne     endif5
        // if (lSumLength != MAX_DIGITS) goto endif6;
        cmp     [sp, 56], MAX_DIGITS
        bne     endif6
        // return FALSE;
        mov     x0, FALSE
        ldr     x30, [sp] // Restore x30
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret
endif6:
        // oSum->aulDigits[lSumLength] = 1;
        idk
        //lSumLength++;
        add     [sp, 56], [sp, 56], 1
endif5:
        // Set the length of the sum. 
        // oSum->lLength = lSumLength;
        idk
        // return TRUE
        mov     x0, TRUE
        ldr     x30, [sp] // Restore x30
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret
