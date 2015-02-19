/*
 * Usage of the WDT+ in timer mode in c
 * The red and green LEDs toggle every 256ms by using the SMCLK/8
 * the DCO is set to 1MHz:
 * 	> WDT_MDLY_32 assumes 1MHz clock = 32ms interval
 * 	> SMCLK = 1MHz/8 so since WDT hits less frequenty interval = 32*8: ~256ms
 *
 */

#include <msp430.h>

#define RedLED BIT0
#define GreenLED BIT6
#define ToggleLeds (P1OUT ^= RedLED | GreenLED)

void main(void)
{
	BCSCTL2 |= DIVS_3;
//	SELM = 00 : MCLK is DCO
//	DIVM = 00 : MCLK / 1
//	SELS = 0  : SMCLK is DCO
//	DIVS = 11 : SMCLK / 8

	WDTCTL = WDT_MDLY_32;
//	WDTPW	  1 : password
//	WDTHOLD	  0 : WDT = not stopped
//	WDTNMIES  0 : edge select = NMI on rising edge
//	WDTNMI    0 : RST/NMI pin = RESET
//	WDTTMSEL  1 : timer mode = interval timer
//	WDTCNTCL  1 : count clear
//  WDTSSEL	  0 : WDT source = SMCLK
//  WDTIS1	  0 : *see below
//  WDTIS0    0 : interval select bits = 00 (clock source / 32768)

	IE1 |= WDTIE;
//	NMIIE	0 : NMI not enabled
//	WDTIE   1 : WDTIFG enabled for interval timer mode

	P1DIR = RedLED | GreenLED;
	P1OUT = RedLED;

	_enable_interrupts();

	LPM1;
//	CPU, MCLK are disabled
//	DCO and DC generator are diabled if the DCO is not used for SMCLK
//	SMCLK, ACLK are active
}

#pragma vector = WDT_VECTOR
__interrupt void WDT(void)
{
	ToggleLeds;
}
