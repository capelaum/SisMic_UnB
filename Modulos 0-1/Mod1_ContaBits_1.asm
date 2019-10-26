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
;Conta quantos bit de R5 valem '1'
;R6 -> numero de bits = '1'
;R7 -> numero de bits testados= 16*

NUM			.equ	8			;Indica numero a ser analisado
			mov		#NUM, R5	;R5 = numero a ser analisado
			call 	#conta_bits	;chamaa
			jmp		$			;trava execucao
			nop					;exigido pelo montador (No operation)

conta_bits:
			clr 	R6			;zera contador de bits '1'
			clr 	R7			;zera contador de loops(16 - bits)
			mov		#BITF,R4 	;mascara no MSbit (16-bits | 4-Bytes)

loop:		bit		R4,R5		;testa a mascara em R5
			jnc 	continue	;bit testado = '0'
            inc		R6			;bit testado = '1' -> contador++

continue: 	inc		R7			;contador de loops - quantos bits tao sendo testados?
			rrc		R4			;rotaciona a direita a mascara
			jnc		loop		;equanto o bit rotacionado for '0'

			ret


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
            
