/*
 * caclucate number of zeros and ones in an array.
 * if 0's > 1's then red LED. if 1's > 0's then green LED
 */

#include <msp430.h>

#define SIZE 10

void main(void)
{
	WDTCTL = WDTPW | WDTHOLD;

	P1SEL = 0x00;		// P1 is set to all i/o
	P1DIR = 0xFF;		// P1 is set to all out
	P1OUT = 0x00;		// P1 is set to output 0

	P2SEL = 0x00;		// P2 set to i/0
	P2DIR = 0xFF;		// P2 set to output
	P2OUT = 0x00;		// P2 output set to 0

	int array[] = {1,1,1,1,1,0,0,0,0,1};
	int ones = 0, zeros = 0;
	int i;

	for (i = 0; i < SIZE; i++)
		if (array[i] == 0)
			zeros += 1;
		else
			ones += 1;

	if (zeros > ones)
		P1OUT = BIT0;
	if (ones > zeros)
		P1OUT = BIT6;
}
