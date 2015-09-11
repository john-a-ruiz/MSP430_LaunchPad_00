/*
 * the second adc example in C. store voltage value in votage variable
 */

#include <msp430g2553.h>

void main(void)
{
	WDTCTL = WDTPW + WDTHOLD;

	volatile float voltage;

	P1DIR = BIT4;

	ADC10CTL0 = SREF_0 + ADC10SHT_2 + ADC10ON;
	// Vcc and Vss references, sample for 16 cycles, ADC on

	ADC10CTL1 = INCH_1 + SHS_0 + ADC10DIV_0 + ADC10SSEL_0 + CONSEQ_0;
	// A1 input channel, SC bit, ADC10OSC / 1, single channel single conversion


	ADC10AE0 = BIT1;
	// enable A1 as analog input

	ADC10CTL0 |= ENC;

	while (1)
	{
		ADC10CTL0 |= ADC10SC;

		while (ADC10CTL1 & ADC10BUSY)
			; // wait until ADC is done

		voltage = ((ADC10MEM * 3.55) / 0x03FF);
	}
}

