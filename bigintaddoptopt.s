//---------------------------------------------------------------------
// bigintaddoptopt.s
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
               
// Assign the sum of oAddend1 and oAddend2 to oSum.  oSum should be
// distinct from oAddend1 and oAddend2.  Return 0 (FALSE) if an
// overflow occurred, and 1 (TRUE) otherwise. */

        // Must be a multiple of 16
        .equ    ADD_STACK_BYTECOUNT, 80
        .equ    AULDIGITS, 8
        .equ    SIZE_OF_UNSIGNED_LONG, 8
        .equ    MAX_DIGITS, 32768

        // Parameter Registers
        OADDEND1   .req x19
        OADDEND2   .req x20
        OSUM       .req x21
        // Local Variable Registers
        ULSUM      .req x23
        LINDEX     .req x24
        LSUMLENGTH .req x25
        
        .global BigInt_add
BigInt_add:
        
        // Prolog
        sub     sp, sp, ADD_STACK_BYTECOUNT
        str     x30, [sp]
        str     x19, [sp, 8]
        str     x20, [sp, 16]
        str     x21, [sp, 24]
        str     x23, [sp, 40]
        str     x24, [sp, 48]
        str     x25, [sp, 56]

        // x0 = BigInt_T oAddend1, x1 = BigInt_T oAddend2,
        // x2 = BigInt_T oSum
        mov     OADDEND1, x0  // oAddend1
        mov     OADDEND2, x1 // oAddend2
        mov     OSUM, x2 // oSum
      
        // Determine the larger length. 
        // lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);
        ldr     x0, [x0]
        ldr     x1, [x1]
        // if (lLength1 <= lLength2) goto else1;
        cmp     x0, x1
        ble     else1
        //  lLarger = lLength1;
        mov     LSUMLENGTH, x0
        b       endif1
else1:
        // lLarger = lLength2;
        mov     LSUMLENGTH, x1
endif1:

        // Clear oSum's array if necessary. 
        // if (oSum->lLength <= lSumLength) goto endif2;
        ldr     x0, [OSUM]
        cmp     x0, LSUMLENGTH
        ble     endif2

        //memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));
        // sizeof(unsigned long);
        mov     x2, SIZE_OF_UNSIGNED_LONG
        mov     x1, MAX_DIGITS
        mul     x2, x2, x1
        mov     x1, 0
        mov     x0, OSUM
        add     x0, x0, AULDIGITS
        bl      memset
endif2:
      
        // Perform the addition.
        // ulCarry = 0;
        //mov    x1, 1
        //adds   x1, x1, 0
       
        // lIndex = 0;
        mov     LINDEX, 0

        cmp     LINDEX, LSUMLENGTH
        bge     endif5

        mov     ULSUM, 0
       
loop1:
        
        //if(lIndex >= lSumLength) goto endloop1;
        //cmp     LINDEX, LSUMLENGTH
        //bge     endloop1

        // ulSum = ulCarry;
        
        // ulCarry = 0;
        //mov     x0, 1
        //adds    x0, x0, 0
        // ulSum += oAddend1->aulDigits[lIndex];
        mov     x0, OADDEND1
        add     x0, x0, AULDIGITS
        mov     x1, LINDEX
        ldr     x0, [x0, x1, lsl 3]
        adcs    ULSUM, ULSUM, x0 
        
        // if (ulSum >= oAddend1->aulDigits[lIndex]) goto endif3;
        // Check for overflow.
        // cmp     ULSUM, x0
        // bhs     endif3
        // ulCarry = 1;
        // mov     ULCARRY, 1
endif3: 

        // ulSum += oAddend2->aulDigits[lIndex];
        bcs     yescarry
        mov     x0, OADDEND2
        add     x0, x0, AULDIGITS
        mov     x1, LINDEX
        ldr     x0, [x0, x1, lsl 3]
        adcs    ULSUM, ULSUM, x0
        b       endyescarry
yescarry:
        mov     x0, OADDEND2
        add     x0, x0, AULDIGITS
        mov     x1, LINDEX
        ldr     x0, [x0, x1, lsl 3]
        add     ULSUM, ULSUM, x0
endyescarry:    
        // if (ulSum >= oAddend2->aulDigits[lIndex]) goto endif4;
        // Check for overflow.
        // cmp     ULSUM, x0
        // bhs     endif4
        //ulCarry = 1;
        // mov     ULCARRY, 1
endif4:
        
        // oSum->aulDigits[lIndex] = ulSum;
        mov     x0, OSUM
        add     x0, x0, AULDIGITS
        mov     x1, LINDEX
        str     ULSUM, [x0, x1, lsl 3]
        
        //lIndex++;
        add     LINDEX, LINDEX, 1
        //b       loop1

        // ulsum = ulcarry
        mov     ULSUM, 0
        adcs    ULSUM, ULSUM, xzr
       
        
        cmp     LINDEX, LSUMLENGTH
        blt     loop1
endloop1:

        // Check for a carry out of the last "column" of the addition. 
        // if (ulCarry != 1) goto endif5;
        cmp     ULSUM, 1
        bne     endif5
        // if (lSumLength != MAX_DIGITS) goto endif6;
        cmp     LSUMLENGTH, MAX_DIGITS
        bne     endif6
        // return FALSE;
        mov     x0, FALSE
        ldr     x30, [sp] // Restore x30
        ldr     x19, [sp, 8]
        ldr     x20, [sp, 16]
        ldr     x21, [sp, 24]
        ldr     x23, [sp, 40]
        ldr     x24, [sp, 48]
        ldr     x25, [sp, 56]
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret
       
endif6:
        // oSum->aulDigits[lSumLength] = 1;
        mov     x0, OSUM
        add     x0, x0, AULDIGITS
        mov     x1, LSUMLENGTH
        mov     x2, 1
        str     x2, [x0, x1, lsl 3]
        //lSumLength++;
        add     LSUMLENGTH, LSUMLENGTH, 1
endif5:
        // Set the length of the sum. 
        // oSum->lLength = lSumLength;
        str     LSUMLENGTH, [OSUM]
        // return TRUE
        mov     x0, TRUE
        ldr     x30, [sp] // Restore x30
        ldr     x19, [sp, 8]
        ldr     x20, [sp, 16]
        ldr     x21, [sp, 24]
        ldr     x23, [sp, 40]
        ldr     x24, [sp, 48]
        ldr     x25, [sp, 56]
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret
        .size   BigInt_add, (. - BigInt_add)
        
