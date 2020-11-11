
#include <stdlib.h>
#include <stdio.h>

int main (void) {

   int counter = 0;
   int randInt;
   int randIntQuot;

   while (counter <= 300) {
      randInt = rand();
      randIntQuot = randInt/(0x7F);
      randInt = randInt - randIntQuot*0x7F;

      if (randInt == 0x09 || randInt == 0x0A
          || (randInt >= 0x20 && randInt <= 0x7E)) {

         counter++;
         printf("%c", randInt);
         
      }

   }

   return 0;
   
}
