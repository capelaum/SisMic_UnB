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

			mov.w 	#vetor, R5				;Copia o vetor para R5
			call 	#M2M4					;Chama subrotina M2M4
			jmp 	$						;Pausa a execuçao

M2M4: 		mov.b	@R5,R8					;coloca no R8 (contador) o tamanho do vetor
			mov		#0,R6					;zera o contador de multiplos de 2
			mov		#0,R7					;zera o contador de multiplos de 4

loop: 		inc		R5						;Avanca para o proximo elemnto do vetor
			mov.b	#0x1,R9					;Marca R9 como 1
			and.b	@R5,R9					;dado de R5 + R9 -> R9
			jnz		nm						;se nao for zero, nao e multiplo de 2
			inc		R6						;eh multiplo de 2
			mov.b	#0x3,R9					;Marca R9 como 3
			and.b	@R5,R9
			jnz		nm						;se nao for zero, nao e multiplo de 4
			inc		R7						;eh multiplo de 4

nm:			dec 	R8						;Decrementa o tamanho restante
			jnz		loop					;Se ainda tem o que olhar executa a subrotina novamente
			ret
                                            
;-------------------------------------------------------------------------------
; Segmento de dados inicializados (0x2400)
;-------------------------------------------------------------------------------
			.data

;Declarar vetor com 5 elementos [4, 7, 3, 2, 2]
vetor		.byte	0x05, 0x04, 0x07, 0x03, 0x02, 0x02
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
            
