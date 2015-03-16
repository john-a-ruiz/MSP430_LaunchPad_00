/*
 * chronos.c
 *
 *  Created on: Mar 4, 2015
 *      Author: Me
 */

#include <msp430.h>
#include "lcd.h"

#define STARTSTOP ((P1IFG & 0x01) == 0x01)
#define RESET ((P1IFG & 0X02) == 0x02)

int start = 0;
int secondh = 0;
int secondl = 0;
int minuteh = 0;
int minutel = 0;
char lcdsecondh[1];
char lcdsecondl[1];
char lcdminuteh[1];
char lcdminutel[1];
char lcd[5];

void PinConfig(void);
void TimerConfig(void);
void Write_to_LCD(void);

void main(void)
{
	WDTCTL = WDTPW | WDTHOLD;

	PinConfig();
	TimerConfig();
	lcd_init();
	_enable_interrupts();

	while (1)
	{
		if (start == 1)
		{
			Write_to_LCD();
			TA0CTL |= MC_1;
		}

		if (start == 0)
		{
			Write_to_LCD();
			LPM4;
		}
	}
}

void PinConfig(void)
{
	P2SEL = 0x00;
	P1DIR = 0xFC;
	P2DIR = 0xFF;
	P1REN - 0x03;
	P1OUT = 0x03;
	P2OUT = 0x00;
	P1IE = 0x03;
	P1IES = 0x03;
	P1IFG = 0x00;
}

void TimerConfig(void)
{
	WDTCTL = WDTPW | WDTHOLD;

	BCSCTL3 |= LFXT1S_2;

	TACCTL0 = CCIE;
	TACTL = MC_0 + ID_3 + TASSEL_1 + TACLR;
	TACCR0 = 1499;
}

void Write_to_LCD(void)
{
	itoa(secondh, lcdsecondh, 10);
	itoa(secondl, lcdsecondl, 10);
	itoa(minuteh, lcdminuteh, 10);
	itoa(minutel, lcdminutel, 10);

	lcd[0] = lcdminuteh[0];
	lcd[1] = lcdminutel[0];
	lcd[2] = ':';
	lcd[3] = lcdsecondh[0];
	lcd[4] = lcdsecondl[0];
	lcd_goto(1, 1);
	lcd_writestr(lcd);
}

#pragma vector = TIMER0_A0_VECTOR
__interrupt void int_timer(void)
{
	secondl++;
	if (secondl == 10)
	{
		secondl = 0;
		secondh++;

		if (secondh == 6)
		{
			secondh = 0;
			minutel++;

			if (minutel == 10)
			{
				minutel = 0;
				minuteh++;
			}
		}
	}
}

#pragma vector = PORT1_VECTOR
__interrupt void int_button(void)
{
	LPM4_EXIT;

	if (STARTSTOP)
	{
		start ^= 1;
		P1IFG &= ~0x01;
	}

	if (RESET)
	{
		secondh = 0;
		secondl = 0;
		minuteh = 0;
		minutel = 0;
		start = 0;
		TACTL |= TACLR;
		P1IFG &= ~0x02;
	}
}
