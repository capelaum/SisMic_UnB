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
			call 	#MAIOR16				;Chama subrotina MAIOR16
			jmp 	$						;Pausa a execucao

MAIOR16:	mov.b 	#0x00,R7				;Esvazia R7
			mov.b 	#0x00,R6				;Esvazia R6
			mov.b 	@R5,R8					;Copia o tamanho do vetor para R8
			incd 	R5						;Pula 2 posicoes


loop:		mov.w 	#0x00,R9				;Esvazia R9
			add.b	@R5, R9					;Adiciona os primeiro 8 bits para R9
			inc 	R5						;Avan�a metade da palavra
			add.b	@R5, R9					;Adiciona os outros 8 bits da palavra para R9
			inc 	R5						;Proxima palavra
			cmp.w	R9,R6					;Compara R9 a maior soma ja encontrada
			jeq		LB1						;Caso a soma ja exista
			jc	 	LB2						;Caso a soma seja maior que R9
			mov.w	R9,R6					;Copia a soma para R6
			mov.b 	#0x00,R7				;Zerando as ocorrencias

LB1:		inc		R7						;Marca a ocorrencia

LB2:		dec 	R8						;Decrementa o tamanho restante
			jnz		loop					;Se ainda há o que olhar executa a subrotina novamente
			ret

vetor:		.word	6,'LU','IG','I',0

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
            
