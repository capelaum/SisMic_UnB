#include <msp430.h>

//Bits para controle do LCD
#define BIT_RS   BIT0
#define BIT_RW   BIT1
#define BIT_E    BIT2
#define BIT_BL   BIT3
#define BIT_D4   BIT4
#define BIT_D5   BIT5
#define BIT_D6   BIT6
#define BIT_D7   BIT7

void config_I2C();
void config_pinos();

void delay_timer(long tempo);
void delay(long limite);

void PCF_write(char dado);
int  PCF_read ();

void LCD_00();
void LCD_BL_on();
void LCD_BL_off();

// RS = 0
void LCD_rs_rw();
void LCD_rs_RW();

// RS = 1
void LCD_RS_rw();
void LCD_RS_RW();

void LCD_E_low ();
void LCD_E_high();

void LCD_WR_NIB(char valor);
void LCD_WR_BT (char escrita);

void inic_LCD(void);
void LCD_posicao(char posicao);

int porta = 0;                                 //ulitmo valor escrito na porta
char sadd;                  // slave address
int data = 0x42;

void main(void)
{
    WDTCTL = WDTPW | WDTHOLD;                   //Stop watchdog timer


    config_pinos();
    config_I2C();
    inic_LCD();
    LCD_00();

    LCD_BL_on();

    int data = 0x42;

    while(1)
    {

        LCD_WR_BT (data);

    }
}

// Configurar portas
void config_pinos()
{
    P3SEL |=  (BIT0 | BIT1);                             // Usar Modo I2C
    P3REN |=  (BIT0 | BIT1);                             // Habilitar resistor
    P3OUT |=  (BIT0 | BIT1);                             // Pull-up

    P1DIR |= BIT0;                              // LED vermelho
    P1OUT &= ~BIT0;

    P4DIR |= BIT7;                              // LED verde
    P4OUT &= ~BIT7;
}

// Configurar Pinos I2C - UCSB0
// P3.0 --> SDA
// P3.1 --> SCL
void config_I2C()
{
    UCB0CTL1 |= UCSWRST;                        // UCSI B0 em ressete

    UCB0CTL0 = UCSYNC|UCMODE_3|UCMST;           // Sincrono//Modo I2C//Mestre

    UCB0BRW = 100;                              // 10 kHz
    sadd = address();
    UCB0CTL1 = UCSSEL_2;                        // SMCLK e remove ressete
}

void delay(long limite){
    volatile long cont=0;
    while (cont++ < limite) ;
}

// delay com timer
void delay_timer(long tempo)                          // tempo em us (max 65536)
{
   TA0CTL = TASSEL_2 | ID_0 | MC_1 | TACLR;
   TA0CCR0 = tempo;
   TA0CCTL0 &= ~TAIFG;

   while((TA0CCTL0 & TAIFG) == 0);
}

// Escrever dado na porta
void PCF_write(char dado)
{
    UCB0I2CSA = 0x3F;//sadd                           //Endereco do Escravo

    UCB0CTL1 |= UCTR | UCTXSTT;                 //Mestre transmissor//Gerar START e envia endereço

    while ( (UCB0IFG & UCTXIFG) == 0);          //Esperar TXIFG (completar transm.)

    if ( (UCB0IFG & UCNACKIFG) == UCNACKIFG)    //NACK?
    {
        P1OUT |= BIT0;                          //Acender LED Vermelho
        while(1);                               // Trava o MSP caso tenho NACK   //Se NACK, prender
    }

    UCB0TXBUF = dado;                           // Dado a ser escrito

    while ( (UCB0IFG & UCTXIFG) == 0);          // Esperar Transmitir

    UCB0CTL1 |= UCTXSTP;                        // Gerar STOP

    while ( (UCB0CTL1 & UCTXSTP) == UCTXSTP );  // Esperar STOP

    delay(50);                                  // Atraso p/ escravo perceber stop
}

int PCF_read()
{
    int dado = 0;

    UCB0CTL1 &= ~UCTR;                          // Deixa como receptor

    UCB0CTL1 |= UCTXSTT;                        // Ativa o start

    while((UCB0CTL1 & UCTXSTT) == UCTXSTT );    // Caso o start seja 1 ele ativa o Stop
    UCB0CTL1 |= UCTXSTP;

    while ( (UCB0IFG & UCRXIFG) == 0 );         // Enquanto nao  houver interrupçoes pendentes

    dado = UCB0RXBUF;                           // Pega o que esta no buffer de recepçoes coloca na variavel dado

    delay(10000);

    return dado;
}

// Escaneia o endereço que esta no barramento
char address(){
    char data = 0x27;
    while(data != 0x40){
        UCB0I2CSA = data;                           //Endereco do Escravo

        UCB0CTL1 |= UCTR | UCTXSTT;                 //Mestre transmissor//Gerar START e envia endereço

        while ( (UCB0IFG & UCTXIFG) == 0);          //Esperar TXIFG (completar transm.)

        UCB0CTL1 |= UCTXSTP;                        // Gerar STOP

        while ( (UCB0CTL1 & UCTXSTP) == UCTXSTP );  // Esperar STOP

           if ( (UCB0IFG & UCNACKIFG) ==0)    //NACK?
               return data;
           data ++;
        }
    return 0x00;
}

// Zerar toda a porta
void LCD_00()
{
    porta = 0;
    PCF_write(porta);
}

// Ligar Back Light
void LCD_BL_on()
{
  porta = porta | BIT_BL;
  PCF_write(porta);
}

// Desligar Back Light
void LCD_BL_off()
{
  porta = porta & ~BIT_BL;
  PCF_write(porta);
}

// RW = 0 e RS = 0
void LCD_rs_rw()
{
    porta = porta & ~BIT_RS;
    porta = porta & ~BIT_RW;
    PCF_write(porta);
}

// RS = 0 e RW = 1
void LCD_rs_RW()
{
    porta = porta & ~BIT_RS;
    porta = porta | BIT_RW;
    PCF_write(porta);
}

// RS = 1 e RW = 0
void LCD_RS_rw()
{
    porta = porta | BIT_RS;
    porta = porta & ~BIT_RW;
    PCF_write(porta);
}

// RS = 1 e RW = 1
void LCD_RS_RW()
{
    porta = porta | BIT_RS;
    porta = porta | BIT_RW;
    PCF_write(porta);
}

// Enable = 0
void LCD_E_low()
{
    porta = porta & ~BIT_E;
    PCF_write(porta);
}

// Enable = 1
void LCD_E_high()
{
    porta = porta | BIT_E;
    PCF_write(porta);
}

// Write Nibble
void LCD_WR_NIB(char valor)
{
    porta &= 0xF;

    porta |= (valor<<4);

    PCF_write(porta);

    LCD_E_high();

    delay(10);

    LCD_E_low();

    delay(10);
}

// Write Byte
void LCD_WR_BT(char escrita)
{
    LCD_WR_NIB ((escrita >> 4) & 0xF);
    LCD_WR_NIB (escrita & 0xF);
}

// Inicializa LCD
void inic_LCD()
{
    LCD_rs_rw();        // modo escrever em IR

    LCD_WR_NIB(0x3);
    LCD_WR_NIB(0x3);
    LCD_WR_NIB(0x3);
    LCD_WR_NIB(0x2);

    LCD_WR_BT(0x28);
    LCD_WR_BT(0x0c);
    LCD_WR_BT(0x06);
    LCD_WR_BT(0x01);
}

// move cursor do LCD
void LCD_posicao(char posicao)
{
    LCD_rs_rw();                        // Modo instruçao
    int aux = 0;

    aux = (posicao >> 4) & 0xF;         //
    aux |= BIT_BL;                      // aux = 1000

    LCD_WR_NIB (aux);                   // write Nibble = 1000
    LCD_WR_NIB (posicao & 0xF);         //
    LCD_RS_rw  ();                      // Modo Escrever no DR
}
