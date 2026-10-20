#include <avr/io.h>

.section .vectors, "ax", @progbits
.global __vectors
__vectors:
	jmp reset

.section .text, "ax", @progbits
.global reset

reset:
	; set PC0 to output mode
	ldi r16, 1
	sts PORTC_OUTSET, r16
	sts PORTC_DIRSET, r16

	; set PC0 to low (LED on)
	sts PORTC_OUTCLR, r16

loop:
	; toggle PC0 (LED on/off)
	sts PORTC_OUTTGL, r16

	ldi r18, 10

delay_outer:
	ldi r19, 255

delay_middle:
	ldi r20, 255

delay_inner:
	dec r20
	brne delay_inner

	dec r19
	brne delay_middle

	dec r18
	brne delay_outer

	rjmp loop

