source ../env.sh

avr-gcc -mmcu=attiny1616 \
	-I"$AVR_LIBC/include" \
	-x assembler-with-cpp \
	-c button-switch.S -o button-switch.o

avr-gcc -mmcu=attiny1616 \
	-nostdlib -nostartfiles \
	-B"$AVR_LIBC/lib/avrxmega3/" \
	-L"$AVR_LIBC/lib/avrxmega3/" \
	-Wl,-Map=button-switch.map \
	button-switch.o -o button-switch.elf

