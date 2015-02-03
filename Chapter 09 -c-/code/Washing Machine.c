/*
 * A washing machine program to learn how to set and use port interrupts. We will be using
 * a stepper motor to drive the washing machine and a 7805 and uln2003 to drive the motor
 */

#include <msp430.h>

#define ONOFF ((P2IFG & 0x40) == 0x40)
#define RSPEED ((P2IFG & 0x04) == 0x04)
#define NWASH ((P2IFG & 0x08) == 0x08)
#define PWASH ((P2IFG & 0x10) == 0x10)
#define FSPIN ((P2IFG & 0x20) == 0x20)
#define REDLEDTOGGLE (P2OUT ^= 0x01)
#define YELLOWLEDTOGGLE (P2OUT ^= 0x02)
#define NORMALWASH 1
#define PREWASH 2
#define FINALSPIN 3

int Program = 0;
int RotationSpeed = 0;
int open = 0;

void delay_ms(int);
void Wash();

void main(void)
{
	WDTCTL = WDTPW | WDTHOLD;

	P2SEL = 0x00;
	P1DIR = 0xFF;
	P2DIR = 0x83;
	P2REN = 0x7C;
	P1OUT = 0x00;
	P2OUT = 0x7C;

	P2IE = 0x7C;
	P2IES = 0x7C;
	P2IFG = 0x00;

	_enable_interrupts();

	while (1)
	{
		if (Program != 0)
			Wash();
	}
}

void delay_ms(int a)
{
	while (a != 0)
	{
		_delay_cycles(2500);  //*
		a--;
	}
}

void Wash()
{
	int speed, turn, fast, slow, Rturn, Lturn, pos;
	volatile unsigned int seqr[4] = {0x08, 0x04, 0x02, 0x01};
	volatile unsigned int seql[4] = {0x01, 0x02, 0x04, 0x08};
	//volatile unsigned int seqr[8] = {0x08, 0x0C, 0x04, 0x06, 0x02, 0x03, 0x01, 0x09};
	//volatile unsigned int seql[8] = {0x09, 0x01, 0x03, 0x02, 0x06, 0x04, 0x0C, 0x08};

	if (Program == 1)
		slow = 5, fast = 1, Rturn = 1000, Lturn = 1000;

	if (Program == 2)
		slow = 5, fast = 1, Rturn = 300, Lturn = 300;

	if (Program == 3)
		slow = 2, fast = 1, Rturn = 500, Lturn = 0;

	if (RotationSpeed == 0)
		speed = fast;
	else
		speed = slow;

	for (turn = 0; turn < Rturn; turn++)
	{
		if (open == 1)
		{
			pos = 0;
			while (pos < 4)  //*
			{
				P1OUT = seqr[pos];
				pos++;
				delay_ms(speed);
			}
			P1OUT = 0x00;
		}
		else
			break;
	}

	for (turn = 0; turn < Lturn; turn++)
	{
		if (open == 1)
		{
			pos = 0;
			while (pos < 4)  //*
			{
				P1OUT = seql[pos];
				pos++;
				delay_ms(speed);
			}
			P1OUT = 0x00;
		}
		else
			break;
	}

	Program = 0;
}

#pragma vector = PORT2_VECTOR
__interrupt void PORT2_ISR(void)
{
	if (ONOFF)
	{
		open ^= 1;
		REDLEDTOGGLE;
		P2IFG &= ~0x40;
	}

	if ((RSPEED) && (open == 1))
	{
		RotationSpeed ^= 1;
		YELLOWLEDTOGGLE;
		P2IFG &= ~0x04;
	}

	if ((NWASH) && (open == 1))
	{
		Program = NORMALWASH;
		P2IFG &= ~0x08;
	}

	if ((PWASH) && (open == 1))
	{
		Program = PREWASH;
		P2IFG &= ~0x10;
	}

	if ((FSPIN) && (open == 1))
	{
		Program = FINALSPIN;
		P2IFG &= ~0x20;
	}

	P2IFG = 0x00;
}
