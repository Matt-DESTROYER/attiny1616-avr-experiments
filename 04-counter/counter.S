#include <avr/io.h>

.section .vectors, "ax", @progbits
.global __vectors
__vectors:
	jmp reset

.section .text, "ax", @progbits
.global reset

reset:
	; current number
	ldi r21, 0b00000000

	; set PA4 (SD), PA5 (SRCLK) and PA6 (RCLK) to output mode
	ldi r17, 0b01110000
	sts PORTA_DIRSET, r17
	ldi r17, 0

	; set PA7 to input mode
	ldi r16, 0b10000000
	sts PORTA_DIRCLR, r16

	; force PA7 to HIGH when button released
	ldi r16, PORT_PULLUPEN_bm
	sts PORTA_PIN7CTRL, r16

	; PA7 prev state
	ldi r22, 0

	; initial write
	call write

loop:
	call handle_input
	rjmp loop

next_number:
	inc r21
	cpi r21, 10
	breq back_to_zero
	ret

back_to_zero:
	ldi r21, 0
	ret

number_to_7_segment:
	; 0bABCDEFGH
	; 0b00000000
	;     A
	;    000
	; G 0   0 B
	;   0   0
	;  F 000
	;   0   0
	; E 0   0 C
	;    000  0 H
	;     D
	ldi r24, 0b11111111

	cpi r21, 0
	breq number_0

	cpi r21, 1
	breq number_1

	cpi r21, 2
	breq number_2

	cpi r21, 3
	breq number_3

	cpi r21, 4
	breq number_4

	cpi r21, 5
	breq number_5

	cpi r21, 6
	breq number_6

	cpi r21, 7
	breq number_7

	cpi r21, 8
	breq number_8

	cpi r21, 9
	breq number_9

	ret

number_0:
	ldi r24, 0b00000101
	ret

number_1:
	ldi r24, 0b10011111
	ret

number_2:
	ldi r24, 0b00100011
	ret

number_3:
	ldi r24, 0b00001011
	ret

number_4:
	ldi r24, 0b10011001
	ret

number_5:
	ldi r24, 0b01001001
	ret

number_6:
	ldi r24, 0b01000001
	ret

number_7:
	ldi r24, 0b00011111
	ret

number_8:
	ldi r24, 0b00000001
	ret

number_9:
	ldi r24, 0b00011001
	ret

write:
	ldi r23, 0b00000001 ; current bit

	andi r17, 0b10001111 ; reset SD, SRCLK, RCLK
	sts PORTA_OUT, r17

	call number_to_7_segment
write_loop:
	mov r25, r24
	and r25, r23 ; check the current bit

	; reset SD, SRCLK and RCLK to 0
	andi r17, 0b10001111
	sts PORTA_OUT, r17

	cpi r25, 0
	breq write_zero
	rjmp write_one
write_next:
	andi r17, 0b10011111 ; set SRCLK and RCLK to 0
	sts PORTA_OUT, r17

	cpi r23, 0b10000000 ; final bit
	breq write_finished

	lsl r23 ; next bit (r23 << 1)
	rjmp write_loop

write_zero:
	andi r17, 0b11101111 ; set SD to 0
	sts PORTA_OUT, r17

	ori r17, 0b00100000 ; set SRCLK to 1
	sts PORTA_OUT, r17

	rjmp write_next

write_one:
	ori r17, 0b00010000 ; set SD to 1
	sts PORTA_OUT, r17

	ori r17, 0b00100000 ;  set SRCLK to 1
	sts PORTA_OUT, r17

	rjmp write_next

write_finished:
	andi r17, 0b11011111 ; set SRCLK to 0
	ori r17, 0b01000000 ; set RCLK to 1
	sts PORTA_OUT, r17
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
	call next_number
	call write

	ret

