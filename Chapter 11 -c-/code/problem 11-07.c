/*
 *    a battery charge controller
 * 1) battery will be connected between P1.1 and GND
 * 2) use ADC10
 * 3) the control operation will only happen when S2 is pushed
 * 4) system will be in low-power mode during idle times
 * 5) battery above threshold (i.e. .32 * Vcc) green LED
 * 6) battery below threshold (i.e. .32 * Vcc) red LED
 * 7) the DTC module to take 16 samples and calculate the average
 */

#include <msp430g2553.h>

void GPIO_init(void);
void BCS_init(void);
void ADC_init(void);

void main(void)
{
	WDTCTL = WDTPW + WDTHOLD;

	unsigned int voltage[16] = {0};
	int i = 0;
	float average = 0;

	GPIO_init();
	BCS_init();
	ADC_init();

	_bis_SR_register(GIE);
	LPM3;

	while (1)
	{
		while (ADC10CTL1 & ADC10BUSY)
			;

		ADC10SA = (unsigned int) voltage;
		ADC10CTL0 |= ADC10ON + ENC + ADC10SC;

		for (i = 0; i < 16; i++)
			average += voltage[i];

		average /= 16;

		if (average > 0x005C)
		{
			P1OUT |= BIT6;
			__delay_cycles(500000);
			P1OUT &= ~BIT6;
		}
		else
		{
			P1OUT |= BIT0;
			_delay_cycles(500000);
			P1OUT &= ~BIT0;
		}

		ADC10CTL0 &= ~(ADC10ON + ENC);
		average = 0;
		LPM3;
	}


}

void GPIO_init(void)
{
	/*
	 * Port 1
	 * P1.0 : red LED
	 * P1.1 : ADC input A1
	 * P1.3 : push-button S2
	 * P1.6 : green LED
	 */
	P1OUT = 0x00;
	P1SEL = 0x00;
	P1DIR = 0xF7;
	P1REN = 0x00;
	P1IES = 0x08;
	P1IFG = 0x00;
	P1IE  = 0x08;

	/*
	 * Port 2
	 */
	P2OUT = 0x00;
	P2SEL = 0x00;
	P2DIR = 0xFF;
	P2REN = 0x00;
	P2IES = 0x00;
	P2IFG = 0x00;
	P2IE  = 0x00;
}

void BCS_init(void)
{
	if (CALBC1_1MHZ == 0xFF)				// if no calibration then trap
		while(1)
			;

	DCOCTL = 0;								// set DCO to 1 MHz calibrated
	BCSCTL1 = CALBC1_1MHZ;
	DCOCTL = CALDCO_1MHZ;

	// MCLK = DCO, SMCLK = VLO, ACLK = VLO
	BCSCTL1 |= XT2OFF + DIVA_0;
	BCSCTL2 = SELM_1 + DIVM_0 + SELS_1 + DIVS_0;
	BCSCTL3 = XT2S_0 + LFXT1S_2;
}

void ADC_init(void)
{
	ADC10CTL0 = SREF_0 + ADC10SHT_2 + MSC;
	ADC10CTL1 = INCH_1 + SHS_0 + ADC10SSEL_0 + CONSEQ_2;
	ADC10AE0 = BIT1;
	ADC10DTC1 = 16;
}

#pragma vector = PORT1_VECTOR
__interrupt void PORT1_ISR(void)
{
	ADC10CTL0 &= ~ADC10ON;
	LPM3_EXIT;
	P1IFG &= ~BIT3;
}




































