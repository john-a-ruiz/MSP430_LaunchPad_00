/*
 * Going through the DCO frequencies using calibration and RSEL and DCO bits.
 */

#include <msp430g2553.h>

void GPIO_init(void);
void BCS_init(void);

void main(void)
{
	WDTCTL = WDTPW + WDTHOLD;

	GPIO_init();
	BCS_init();

	_enable_interrupts();

	while (1)
	{
		;
	}
}

void GPIO_init(void)
{
	// Port 1
	P1OUT = 0x00;
	P1SEL = 0x10;
	P1DIR = 0xF7;
	P1REN = 0x00;
	P1IES = 0x08;
	P1IFG = 0x00;
	P1IE = 0x08;

	// Port 2
	P2OUT = 0x00;
	P2SEL = 0x00;
	P2DIR = 0xFF;
	P2REN = 0x00;
	P2IES = 0x00;
	P2IFG = 0x00;
	P2IE = 0x00;
}

void BCS_init(void)
{
	BCSCTL2 = SELM_0 + DIVM_0 + SELS_0 + DIVS_0;

//	if (CALBC1_1MHZ == 0xFF)				// if calibration constants erased trap cpu
//		while (1);
//	else
//	{
//		DCOCTL = 0;
//		BCSCTL1 = CALBC1_1MHZ;
//		DCOCTL = CALDCO_1MHZ;
//	}

	BCSCTL1 |= XT2OFF + DIVA_0;

	BCSCTL3 = XT2S_0 + LFXT1S_2;
}

//#pragma vector = PORT1_VECTOR
//__interrupt void PORT1_ISR(void)
//{
//	static int speed = 1;
//
//	if (speed == 1)
//	{
//		if (CALBC1_1MHZ == 0xFF)
//			while (1);
//
//		DCOCTL = 0;
//		BCSCTL1 = CALBC1_1MHZ;
//		DCOCTL = CALDCO_1MHZ;
//
//		speed = 8;
//	}
//	else if (speed == 8)
//	{
//		if (CALBC1_8MHZ == 0xFF)
//			while(1);
//
//		DCOCTL = 0;
//		BCSCTL1 = CALBC1_8MHZ;
//		DCOCTL = CALDCO_8MHZ;
//
//		speed = 12;
//	}
//	else if (speed == 12)
//	{
//		if (CALBC1_12MHZ == 0xFF)
//			while (1);
//
//		DCOCTL = 0;
//		BCSCTL1 = CALBC1_12MHZ;
//		DCOCTL = CALDCO_12MHZ;
//
//		speed = 16;
//	}
//	else if (speed == 16)
//	{
//		if (CALBC1_16MHZ == 0xFF)
//			while (1);
//
//		DCOCTL = 0;
//		BCSCTL1 = CALBC1_16MHZ;
//		DCOCTL = CALDCO_16MHZ;
//
//		speed = 1;
//	}
//
//	BCSCTL1 |= XT2OFF + DIVA_0;
//	P1IFG &= ~BIT3;
//}

#pragma vector = PORT1_VECTOR
__interrupt void PORT1_ISR(void)
{
	static int rsel = 0;
	static int dco = 0;

	DCOCTL = (DCOCTL & ~0xE0) | (dco++ << 5);
	BCSCTL1 = XT2OFF + DIVA_0 + rsel;

	if (dco == 8)
	{
		dco = 0;
		rsel++;
	}

	if (rsel == 16)
		rsel = 0;

	P1IFG &= ~BIT3;
}




































