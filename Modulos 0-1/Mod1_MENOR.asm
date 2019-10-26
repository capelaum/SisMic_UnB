;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

			mov.w 	#vetor,R5				;Copia o vetor para R5
			call 	#menor					;Chama a subrotina menor
			jmp 	$						;Pausa a execucao apos a rotina

menor:		mov.b 	#0x00,R7				;zerando R7: contador
			mov.b 	#0xFF,R6				;enchendo R6: guarda menor
			mov.b 	@R5,R8					;copia o tamanho do vetor para R8

loop:		inc 	R5						;ponteiro passa para o proximo elemento de R5
			cmp.b	@R5,R6					;compara o elemento de R5 atual com o de R6
			jeq		FREQ					;se forem iguais pula para FREQ
			jlo 	CONT					;se R6(menor atual) for menor que o elemento de R5 vai para LB2
			mov.b	@R5,R6					;copia o elemento atual de R5 para R6
			mov.b 	#0x00,R7				;Zerando R7(contador)

FREQ:		inc		R7						;Incrementa contador de freq do menor

CONT:		dec 	R8						;Decrementa contador de elementos
			jnz		loop					;se R8 nao for zero volta pra loop
			ret								;Fim da subrotina

vetor:		.byte	12,"LINCOLNBRUNO"

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            
