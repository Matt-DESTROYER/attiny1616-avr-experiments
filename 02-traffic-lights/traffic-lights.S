#include <avr/io.h>

.section .vectors, "ax", @progbits
.global __vectors
__vectors:
	jmp reset

.section .text, "ax", @progbits
.global reset

reset:
	; currently activated LED (0 = none, 1 = red, 2 = yellow, 3 = green)
	ldi r21, 3

	; set PA4, PA5 and PA6 to output mode
	ldi r16, 0b01110000
	sts PORTA_DIRSET, r16

loop:
	; turn on/off LEDs
	call write_out

	; counter 1
	ldi r18, 10

	call light_delay

delay_outer:
	; counter 2
	ldi r19, 255

delay_middle:
	; counter 3
	ldi r20, 255

delay_inner:
	dec r20
	brne delay_inner

	dec r19
	brne delay_middle

	dec r18
	brne delay_outer

	call next_light

	rjmp loop

next_light:
	dec r21
	breq back_to_green
	ret

back_to_green:
	ldi r21, 4
	rjmp next_light

write_out:
	; green (PA4)
	ldi r16, 0b00010000
	cpi r21, 3
	breq select_light

	; yellow (PA5)
	ldi r16, 0b00100000
	cpi r21, 2
	breq select_light

	; red (PA6)
	ldi r16, 0b01000000

select_light:
	sts PORTA_OUT, r16
	ret

light_delay:
	cpi r21, 3
	breq green_delay

	cpi r21, 2
	breq yellow_delay

	rjmp red_delay

green_delay:
	; 10 extra iterations of delay
	ldi r22, 10
	add r18, r22
	ret

yellow_delay:
	; 5 extra iterations of delay
	ldi r22, 5
	add r18, r22
	ret

red_delay:
	; 20 extra iterations of delay
	ldi r22, 20
	add r18, r22
	ret

