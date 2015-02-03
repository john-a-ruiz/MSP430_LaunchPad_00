/*
 * compute the average of 10 float using pointer arithmatic
 * if average > 0 then red led
 * if average < 0 then green led
 */

#include <msp430.h>

#define SIZE 10
#define RED_ON (P1OUT |= BIT0)
#define GREEN_ON (P1OUT |= BIT6)

void main(void)
{
	WDTCTL = WDTPW | WDTHOLD;

	P1SEL = 0x00;
	P1DIR = 0xFF;
	P1OUT = 0x00;

	float array[SIZE] = {2.1, -4.3, 1.6, 33.45, -56.22, 6, -12, 0, .022, 155.33};
	float average = 0, *number = &array[0];
	float *end = number+SIZE;

	for (number = array; number < end; number++)
		average += *number;

	average /= SIZE;

	if (average >= 0)
		RED_ON;
	else
		GREEN_ON;
}
