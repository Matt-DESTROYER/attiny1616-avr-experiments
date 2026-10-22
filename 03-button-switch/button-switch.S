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

	; set PA7 to input mode
	ldi r16, 0b10000000
	sts PORTA_DIRCLR, r16

	; force PA7 to HIGH when button released
	ldi r16, PORT_PULLUPEN_bm
	sts PORTA_PIN7CTRL, r16

	; PA7 prev state
	ldi r22, 0

loop:
	; turn on/off LEDs
	call write_out
	call handle_input
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

handle_input:
	; load state of PA7
	lds r16, PORTA_IN
	andi r16, 0b10000000

	call detect_edge

	ret

; if PA7's state has changed, call edge_detected
detect_edge:
	cp r16, r22
	brne edge_detected

	ret

; if PA7 is not 0, call falling_edge
edge_detected:
	mov r22, r16

	cpi r16, 0
	breq falling_edge

	ret


falling_edge:
	call next_light

	ret

