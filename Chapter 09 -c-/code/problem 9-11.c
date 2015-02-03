/*
 * initialize two global integer arrays x[10] and y[10]
 * when S2 us pushed an ISR will:
 * 	-calculate y[n] = 2*x[n] - x[n-1]
 */

#include <msp430.h>

int x[10] = {5, 3, 7, 10, 4, 9, 2, 12, 7 ,8};
int y[10] = {0};

void main(void)
{
	WDTCTL = WDTPW | WDTHOLD;

	P1OUT = 0x00;
	P1SEL = 0x00;
	P1DIR = 0xF7;
	P1REN = 0x00;

	P1IES = BIT3;
	P1IFG = 0x00;
	P1IE = BIT3;

	_enable_interrupt();

	while(1);
}

#pragma vector = PORT1_VECTOR
__interrupt void PORT1_ISR(void)
{
	static int n = 0;

	if (n == 0)
		y[n] = 2*x[n];
	else if (n < 10)
		y[n] = 2*x[n] - x[n-1];

	n++;
	P1IFG &= ~BIT3;
}
