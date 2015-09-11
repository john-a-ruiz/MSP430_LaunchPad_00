/*
 * obtaining 20 temp reading using ADC10 temp module then averaging them
 */

#include <msp430g2553.h>

#define nsamp 20

float avgtemp = 0;

void main(void)
{
	WDTCTL = WDTPW + WDTHOLD;

	int count;
	unsigned int temparr[nsamp];

	ADC10CTL1 = CONSEQ_2 + INCH_10 + ADC10DIV_7;
	// repeat single channel, temp sensor input, ADC10CLK/8

	ADC10CTL0 = SREF_1 + ADC10SHT_3 + REFON + ADC10ON + ADC10IE + MSC;
	// Vref and Vss, sample for 64 cycles, Vref generator on, ADC on,
	// interrupt enabled, multiple samples and conversions, 1.5V = Vref

	ADC10DTC1 = nsamp;		// number of conversions

	while (ADC10CTL1 & ADC10BUSY)
		;	// wait for ADC conversion

	ADC10SA = (unsigned int) temparr;
	// databuffer start address

	ADC10CTL0 |= ENC + ADC10SC;
	// sampling and conversion start

	_enable_interrupts();
	LPM0;	// ADC10_ISR will force exit

	for (count = 0; count < nsamp; count++)
		avgtemp += temparr[count];

	avgtemp = avgtemp / nsamp;
	avgtemp = ((avgtemp - 673) * 423) / 1024;

	while (1)
		;
}

#pragma vector = ADC10_VECTOR
__interrupt void ADC10_ISR(void)
{
	LPM0_EXIT;
}
