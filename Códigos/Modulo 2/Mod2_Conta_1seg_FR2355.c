#include <msp430.h> 

void config() {

    P1DIR |= BIT0;              // P1.0 -> saida
    P1OUT &= ~BIT0;

    P6DIR |= BIT6;              // P6.6 -> saida
    P6OUT &= ~BIT6;

}

// AULA 01/10/2019
// conta de 0 a 0xFFFF (65535) em 1 segundo

// MSP430 FR2355

// Clocks: ACLK @32768 Hz, SMCLK @1048576 Hz, MLCK @16MHz
int main(void)
{
    WDTCTL = WDTPW | WDTHOLD;   // stop watchdog timer
    PM5CTL0 &= ~LOCKLPM5;       // necessario
    config();

    // SSEL = SMCLK
    // D = 16 = ID x IDEX
    // InputDivider = 4
    // IDEXtended = 4
    // MC = Continuous

    // configura timer B0
    TB0CTL = (TBSSEL__SMCLK | ID__4 | MC__CONTINUOUS | TBCLR);

    TB0EX0 = TBIDEX__4;

    while(1){

        // enquanto a flag for 0 -> 1 seg
        while( !(TB0CTL & TBIFG) );

        // zera flag novamente
        TB0CTL &= ~TBIFG;

        // Realiza uma acao a cada 1 segundo
        P6OUT ^= BIT6;
        P1OUT ^= BIT0;
    }

    return 0;
}

