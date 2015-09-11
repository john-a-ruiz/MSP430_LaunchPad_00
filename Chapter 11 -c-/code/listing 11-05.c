/*
 * The first ADC example in C
 */

#include <msp430g2553.h>

#define LED BIT0

void main(void)
{
	WDTCTL = WDTPW + WDTHOLD;

	P1DIR = LED;
	P1OUT = 0x00;

	ADC10CTL0 = SREF_0 + ADC10SHT_2 + ADC10ON;
	// Vcc and Vss(ground) references, sample for 16 cycles, ADC on

	ADC10CTL1 = INCH_1 + SHS_0 + ADC10DIV_0 + ADC10SSEL_0 + CONSEQ_0;
	// input channel 1 (A1), trigger using ADC10SC bit,
	// use internal ADC clock, single channel and single conversion

	ADC10AE0 = BIT1;
	// enable conversion

	ADC10CTL0 |= ENC;

	while (1)
	{
		ADC10CTL0 |= ADC10SC;
		// trigger new conversion

		while (ADC10CTL1 & ADC10BUSY)
			;
		// wait if ADC10 core is active

		if (ADC10MEM >= 0x0200)		// 0x0200 = 512
			P1OUT = LED;
		else
			P1OUT = 0x00;
	}
}
