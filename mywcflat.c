/*--------------------------------------------------------------------*/
/* mywc.c                                                             */
/* Author: Bob Dondero                                                */
/*--------------------------------------------------------------------*/

#include <stdio.h>
#include <ctype.h>

/*--------------------------------------------------------------------*/

/* In lieu of a boolean data type. */
enum {FALSE, TRUE};

/*--------------------------------------------------------------------*/

static long lLineCount = 0;      /* Bad style. */
static long lWordCount = 0;      /* Bad style. */
static long lCharCount = 0;      /* Bad style. */
static int iChar;                /* Bad style. */
static int iInWord = FALSE;      /* Bad style. */

/*--------------------------------------------------------------------*/

/* Write to stdout counts of how many lines, words, and characters
   are in stdin. A word is a sequence of non-whitespace characters.
   Whitespace is defined by the isspace() function. Return 0. */

int main(void)
{
  loop1:
   /* while ((iChar = getchar()) != EOF)*/
   if((iChar = getChar()) == EOF) goto endloop1;
   lCharCount++;
/*
   if (isspace(iChar))
    {
       if (iInWord)
       {
          lWordCount++;
          iInWord = FALSE;
       }
    }
   else
   {
      if (! iInWord)
         iInWord = TRUE;
   }
*/
   if(!isspace(ichar)) goto else1;
   if(!iInWord) goto endif2;
   lWordCount++;
   iInWord = FALSE;
  endif2:
   
  endif1:
   if (iChar == '\n')
      lLineCount++;
  endloop1:

/*   if (iInWord)
      lWordCount++;
*/
   if(!iInWord) goto endif6;
   lWordCount++;
  endif6:
   
   printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
   return 0;
}
