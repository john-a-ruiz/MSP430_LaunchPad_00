/*
 *  MSP430 LCD interface
 *
 *             |      LCD       |
 * LCD Pin #   |    Function    |   MSP Pin #
 *--------------------------------------------
 * PIN 4       |      RS        |    P1.0
 * PIN 5       |      RW        |    GND
 * PIN 6       |      EN        |    P1.1
 * PIN 11      |      DB4       |    P1.4
 * PIN 12      |      DB5       |    P1.5
 * PIN 13      |      DB6       |    P1.6
 * PIN 14      |      DB7       |    P1.7
 */

#include <msp430.h>

#define	RS		BIT0
#define EN		BIT1
#define CLEAR 	(~(BIT7 + BIT6 + BIT5 + BIT4 + RS))

#define DATA 	1
#define INSTR	0

void GPIO_init(void);
void LCD_init(void);
void enable(void);
void send(char byte, char type);
void print(char *text);

void main(void)
{
	WDTCTL = WDTPW + WDTHOLD;
	GPIO_init();
	LCD_init();

	send(0x48, DATA);
	send('I', DATA);
	send('T', DATA);
	send('A', DATA);
	send('A'+2, DATA);
	send(*"H", DATA);
	send('I', DATA);

//	send(0x07, INSTR);					// shift display after write
//	send(' ', DATA);

	send(0xC0, INSTR);
	print("MICROLO");

	send(0x10, INSTR);
	send(0x10, INSTR);
	send('C', DATA);
	send(0x14, INSTR);
	send('M', DATA);

	send(0x0C, INSTR);
	send(0x02, INSTR);

}

void GPIO_init(void)
{
	P1OUT = 0x00;
	P1SEL = 0x00;
	P1DIR = 0xFF;
	P1REN = 0x00;

	P1IES = 0xFF;
	P1IFG = 0x00;
	P1IE = 0x00;
}

void LCD_init(void)
{
	__delay_cycles(100000);				// let the display warm up
	P1OUT = 0x20;
	enable();

	send(0x28, INSTR);
	send(0x0E, INSTR);
	send(0x06, INSTR);
	send(0x01, INSTR);
	send(0x02, INSTR);
}

void enable(void)
{
	P1OUT |= EN;
	__delay_cycles(400);

	P1OUT &= ~EN;
	__delay_cycles(200);
}

void send(char byte, char type)
{
    P1OUT |= (RS & type);

    P1OUT |= (byte & 0xF0);
    enable();

    P1OUT = (P1OUT & ~0xF0) | (byte << 4);
    enable();

    P1OUT &= CLEAR;
    __delay_cycles(175000);
}

void print(char *text)
{
    while (*text != '\0')
        send(*(text++), DATA);
}
