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
;Subrotina  INSTR	OP,OP			; Comentarios
;R6 -> menor

main:		MOV 	#vetor,R5		; Move o vetor para R5
			CALL 	#menor 			; Chama subrotina
			JMP		$				; Trava a execução num loop infinito

menor:		MOV.B 	@R5,R8 			; Move tamanho p/R8
			MOV.B 	#0xFF,R6 		; Atribui 255 = 2^8-1 para R6
			CLR 	R7 				; Atribui 0 para R7

loop:		INC.W 	R5 				; Incrementa R5
			CMP.B	R6,0(R5) 		; Compara R6 com primeiro elemento de R5
			JLO 	menorQR6 		; Jump if lower than R6
			JEQ 	igualAR6 		; Jump if equal R6

maiorQR6: 	JMP 	continue		; Jump to continue

menorQR6:	MOV.B 	@R5,R6			; Move conteudo de R5 para R6
			MOV.B 	#1,R7			; Move 1 para R7
			jmp 	continue		; Jump to continue

igualAR6:	INC.B 	R7				;incrementa R7: frequencia

continue:	DEC.B 	R8				; Decrementa R8
			JNZ 	loop			; Se diferente de zero, ir para o loop
			RET						; Retornar

;----------------------------------------------------------------------------
; Segmento de dados inicializados (0x2400)
;----------------------------------------------------------------------------

			.data

; Declarar vetor com 5 elementos [4, 2, 3, 9, 2]
vetor: 		.byte 	0x05, 0x04, 0x02, 0x03, 0x09, 0x02
                                            
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
            

