/*
 * program to multiply numbers (no zeros) in an array
 * divide result by the length of the array
 * if result < 1st value then red LED
 * if result is between first two values then green LED
 * if result > 2nd value then both LEDs
 */

#include <msp430.h>

#define SIZE 3
#define RED_ON (P1OUT |= BIT0)
#define GREEN_ON (P1OUT |= BIT6)

int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;

	P1SEL = 0x00;
	P1DIR = 0xFF;
	P1OUT = 0x00;

	unsigned int array[SIZE] = {1, 8, 30};
	unsigned int result = 1, i = 0;

	for (i = 0; i < SIZE; i++)
	{
		if (array[i] == 0)
			continue;
		result = result * array[i];
	}
	result /= SIZE;

	if (result < array[0])
	{
		RED_ON;
		return 1;
	}

	if (result >= array[0] && result <= array[1])
	{
		GREEN_ON;
		return 1;
	}

	if (result > array[1])
	{
		GREEN_ON;
		RED_ON;
		return 1;
	}

	return 0;
}
