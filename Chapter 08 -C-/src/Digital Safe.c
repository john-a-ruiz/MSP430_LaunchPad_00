/*
 * Digital Safe
 *
 * =================Take off jumpers J5 for program to work correctly===============
 * =====Use 47k Resistor from Vcc to Reset pin on prototype=====
 */

#include <msp430.h>

#define BUTTON1 ((P2IN & 0x02) == 0x00)
#define BUTTON2 ((P2IN & 0x04) == 0x00)
#define BUTTON3 ((P2IN & 0x08) == 0x00)
#define BUTTON4 ((P2IN & 0x10) == 0x00)
#define SWITCH1 (P1IN & 0x10)
#define SWITCH2 (P1IN & 0x20)
#define SWITCH3 (P1IN & 0x40)
#define SWITCH4 (P1IN & 0x80)
#define YellowLedOn (P1OUT |= 0x01)
#define GreenLedOn (P1OUT |= 0x02)
#define RedLedOn (P1OUT |= 0x04)
#define AllLedsOff (P1OUT &= ~0x07)

void main(void)
{
	WDTCTL = WDTPW | WDTHOLD;

	int Control = 0;
	int NewPassword[4] = {0};
	int YourPassword[4] = {0};
	int EnterNewPassword = 0;
	int EnterYourPassword = 0;

	P1SEL = 0x00;
	P2SEL = 0x00;
	P1DIR = 0x0F;
	P2DIR = 0xE1;
	P1REN = 0xF0;
	P2REN = 0x1E;
	P1OUT = 0xF0;
	P2OUT = 0x1E;

	while (1)
	{
		if (Control == 0)
		{
			if (BUTTON1)
			{
				EnterNewPassword = 1;
				RedLedOn;			// my addition
				GreenLedOn;			// my addition
				YellowLedOn;		// my addition
			}

			if (EnterNewPassword == 1)
			{
				NewPassword[0] = SWITCH1;
				NewPassword[1] = SWITCH2;
				NewPassword[2] = SWITCH3;
				NewPassword[3] = SWITCH4;

				if (BUTTON2)
				{
					EnterNewPassword = 0;
					AllLedsOff;			// my addition
					RedLedOn;
					Control = 1;
				}
			}
		}

		if (Control == 1)
		{
			if (BUTTON3)
			{
				EnterYourPassword = 1;
				AllLedsOff;					// my addition
				YellowLedOn;				// my addition
			}

			if (EnterYourPassword == 1)
			{
				YourPassword[0] = SWITCH1;
				YourPassword[1] = SWITCH2;
				YourPassword[2] = SWITCH3;
				YourPassword[3] = SWITCH4;

				if (BUTTON4)
				{
					EnterYourPassword = 0;

					if ((YourPassword[0] == NewPassword[0]) &&
						(YourPassword[1] == NewPassword[1]) &&
						(YourPassword[2] == NewPassword[2]) &&
						(YourPassword[3] == NewPassword[3]))
					{
						AllLedsOff;
						GreenLedOn;
						Control = 0;
					}
					else
					{
						AllLedsOff;
						RedLedOn;
					}
				}
			}
		}
	}
}












































