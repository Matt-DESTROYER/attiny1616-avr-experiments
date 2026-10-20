source ../env.sh

avr-gcc -mmcu=attiny1616 \
	-I"$AVR_LIBC/include" \
	-x assembler-with-cpp \
	-c blink.S -o blink.o

avr-gcc -mmcu=attiny1616 \
	-nostdlib -nostartfiles \
	-B"$AVR_LIBC/lib/avrxmega3/" \
	-L"$AVR_LIBC/lib/avrxmega3/" \
	-Wl,-Map=blink.map \
	blink.o -o blink.elf

