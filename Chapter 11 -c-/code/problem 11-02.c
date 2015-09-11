/*
 *    a battery charge controller
 * 1) battery will be connected between P1.1 and GND
 * 2) use Comparator_A+
 * 3) the control operation will only happen when S2 is pushed
 * 4) system will be in low-power mode during idle times
 * 5) battery above threshold (i.e. .25 * Vcc) green LED
 * 6) battery below threshold (i.e. .25 * Vcc) red LED
 */

#include <msp430g2553.h>

void GPIO_init(void);
void BCS_init(void);
void COMPAR_init(void);

void main(void)
{
	WDTCTL = WDTPW + WDTHOLD;

	GPIO_init();
	BCS_init();
	COMPAR_init();

	_bis_SR_register(GIE);
	LPM3;

	while (1)
	{
		if (CAOUT & CACTL2)
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

		CACTL1 &= ~CAON;
		LPM3;
	}
}

void GPIO_init(void)
{
	/*
	 * Port 1
	 * P1.0 : red LED
	 * P1.1 : copmarator input CA1
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
	if (CALBC1_1MHZ == 0xFF)				// if no calibration, trap
		while (1)
			;

	DCOCTL = 0;								// set DCO to 1 MHz
	BCSCTL1 = CALBC1_1MHZ;
	DCOCTL = CALDCO_1MHZ;

	BCSCTL1 |= XT2OFF + DIVA_0;
	BCSCTL2 = SELM_1 + DIVM_0 + SELS_1 + DIVS_0;// MCLK = DCO, SMCLK = VLO, ACLK = VLO
	BCSCTL3 = XT2S_0 + LFXT1S_2;
}

void COMPAR_init(void)
{
	CACTL1 = CARSEL + CAREF_1;				// Vref = 925mV (- terminal)
	CACTL2 = P2CA4;							// CA1 (+ terminal)
}

#pragma vector = PORT1_VECTOR
__interrupt void PORT1_ISR(void)
{
	CACTL1 |= CAON;
	LPM3_EXIT;

	P1IFG &= ~BIT3;
}



























