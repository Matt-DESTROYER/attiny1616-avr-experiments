#!/bin/bash

source ../env.sh

set -euo pipefail

MCU=attiny1616
NAME="display"

BUILD_DIR="build"

EXE="$BUILD_DIR/$NAME.elf"

SRC=(main i2c display delay)

OBJ=("${SRC[@]/%/.o}")
BUILD_OBJ=("${OBJ[@]/#/$BUILD_DIR/}")

mkdir -p "$BUILD_DIR"

for source in "${SRC[@]}"; do
	avr-gcc -mmcu="$MCU" \
		-I"$AVR_LIBC/include" \
		-x assembler-with-cpp \
		-c "$source.S" -o "$BUILD_DIR/$source.o"
done

avr-gcc -mmcu="$MCU" \
	-nostdlib \
	-nostartfiles \
	-B"$AVR_LIBC/lib/avrxmega3/" \
	-L"$AVR_LIBC/lib/avrxmega3/" \
	-Wl,-Map="$BUILD_DIR/$NAME.map" \
	"${BUILD_OBJ[@]}" \
	-o "$EXE"

echo "Build complete: $EXE"

echo "Attempting to flash driver..."
avrdude \
	-c serialupdi \
	-p t1616 \
	-P /dev/ttyUSB0 \
	-U "flash:w:$EXE:e"

