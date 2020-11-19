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
        .equ    LARGER_STACK_BYTECOUNT, 64
        
        // Local Variable Registers
        LLARGER  .req x26

        // Parameter Registers
        LLENGTH1 .req x27
        LLENGTH2 .req x28

BigInt_larger:
        // Prolog
        sub     sp, sp, LARGER_STACK_BYTECOUNT
        str     x30, [sp]
        str     x26, [sp, 8]
        str     x27, [sp, 16]
        str     x28, [sp, 24]

        //lLength1 = X0, lLength2 = X1, return address = X30
        mov     LLENGTH1, x0  //lLength1
        mov     LLENGTH2, x1 //lLength2
        
        // if (lLength1 <= lLength2) goto else1;
        cmp     LLENGTH1, LLENGTH2
        ble     else1
        //  lLarger = lLength1;
        mov     LLARGER, LLENGTH1
        b       endif1
else1:
        // lLarger = lLength2;
        mov     LLARGER, LLENGTH2
endif1:
        // return lLarger
        mov     x0, LLARGER
        ldr     x30, [sp] // Restore x30
        ldr     x26, [sp, 8]
        ldr     x27, [sp, 16]
        ldr     x28, [sp, 24]
        
        add     sp, sp, LARGER_STACK_BYTECOUNT
        ret
        .size   BigInt_larger, (. - BigInt_larger)
        
//--------------------------------------------------------------------


// Assign the sum of oAddend1 and oAddend2 to oSum.  oSum should be
// distinct from oAddend1 and oAddend2.  Return 0 (FALSE) if an
// overflow occurred, and 1 (TRUE) otherwise. */

        // Must be a multiple of 16
        .equ    ADD_STACK_BYTECOUNT, 64
        .equ    AULDIGITS, 8
        .equ    SIZE_OF_UNSIGNED_LONG, 8
        .equ    MAX_DIGITS, 32768

        // Parameter Registers
        OADDEND1   .req x19
        OADDEND2   .req x20
        OSUM       .req x21

        // Local Variable Registers
        ULCARRY    .req x22
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
        str     x22, [sp, 32]
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
        mov     x0, OADDEND1 
        ldr     x0, [x0]
        mov     x1, OADDEND2
        ldr     x1, [x1]
        bl      BigInt_larger
        mov     LSUMLENGTH, x0

        // Clear oSum's array if necessary. 
        // if (oSum->lLength <= lSumLength) goto endif2;
        mov     x0, OSUM
        ldr     x0, [x0]
        cmp     x0, LSUMLENGTH
        ble     endif2

        //memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));
        // sizeof(unsigned long);
        mov     x0, SIZE_OF_UNSIGNED_LONG
        mov     x1, MAX_DIGITS
        mul     x0, x0, x1
        mov     x2, x0
        mov     x1, 0
        mov     x0, OSUM
        add     x0, x0, AULDIGITS
        bl      memset
endif2:
      
        // Perform the addition.
        // ulCarry = 0; [sp, 32]
        mov     ULCARRY, 0
        // lIndex = 0;
        mov     LINDEX, 0
loop1:
        
        // if(lIndex >= lSumLength) goto endloop1;
        cmp     LINDEX, LSUMLENGTH
        bge     endloop1
        // ulSum = ulCarry;
        mov     ULSUM, ULCARRY
        // ulCarry = 0;
        mov     ULCARRY, 0
        // ulSum += oAddend1->aulDigits[lIndex];
        mov     x0, OADDEND1
        add     x0, x0, AULDIGITS
        mov     x1, LINDEX
        ldr     x0, [x0, x1, lsl 3]
        add     ULSUM, ULSUM, x0
        
        // if (ulSum >= oAddend1->aulDigits[lIndex]) goto endif3;
        // Check for overflow.
        cmp     ULSUM, x0
        bhs     endif3
        // ulCarry = 1;
        mov     ULCARRY, 1
endif3:
  
        // ulSum += oAddend2->aulDigits[lIndex];
        mov     x0, OADDEND2
        add     x0, x0, AULDIGITS
        mov     x1, LINDEX
        ldr     x0, [x0, x1, lsl 3]
        add     ULSUM, ULSUM, x0
        // if (ulSum >= oAddend2->aulDigits[lIndex]) goto endif4;
        // Check for overflow.
        cmp     ULSUM, x0
        bhs     endif4
        //ulCarry = 1;
        mov     ULCARRY, 1
endif4:
        
        // oSum->aulDigits[lIndex] = ulSum;
        mov     x0, OSUM
        add     x0, x0, AULDIGITS
        mov     x1, LINDEX
        str     ULSUM, [x0, x1, lsl 3]
        
        //lIndex++;
        add     LINDEX, LINDEX, 1
        b       loop1
endloop1:

        // Check for a carry out of the last "column" of the addition. 
        // if (ulCarry != 1) goto endif5;
        cmp     ULCARRY, 1
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
        ldr     x22, [sp, 32]
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
        mov     x0, OSUM
        str     LSUMLENGTH, [x0]
        // return TRUE
        mov     x0, TRUE
        ldr     x30, [sp] // Restore x30
        ldr     x19, [sp, 8]
        ldr     x20, [sp, 16]
        ldr     x21, [sp, 24]
        ldr     x22, [sp, 32]
        ldr     x23, [sp, 40]
        ldr     x24, [sp, 48]
        ldr     x25, [sp, 56]
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret
        .size   BigInt_add, (. - BigInt_add)
        
