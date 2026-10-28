.global delay_100_cycles
.global delay_1_ms
.global delay_ms

; delay by approximately 5 microseconds (us), assuming 20MHz
delay_100_cycles:
	ldi r16, 0
delay_100_cycles_loop:
	inc r16
	cpi r16, 25
	brne delay_100_cycles_loop
	ret

; delay by approximately 1 millisecond (ms) assuming 20MHz
delay_1_ms:
	ldi r18, 0
delay_1_ms_loop:
	rcall delay_100_cycles
	inc r18
	cpi r18, 200
	brne delay_1_ms_loop
	ret

; delay by the number of milliseconds stored in r17
delay_ms:
	rcall delay_1_ms
	dec r17
	cpi r17, 0
	brne delay_ms
	ret

