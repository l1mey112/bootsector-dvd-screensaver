main.elf boot.bin: main.asm $(wildcard *.inc) Makefile dvd/rawdvdbytes dvd/macroout
	nasm -Ovx -g3 -F dwarf -f elf32 main.asm -o main.o $(shell cat dvd/macroout)
	ld -Ttext=0x7c00 -m elf_i386 main.o -o boot.elf

	objcopy --strip-unneeded -O binary boot.elf boot.bin
	wc -c boot.bin
	printf '\x55\xaa' | dd seek=510 bs=1 of=boot.bin

.PHONY: dvd/rawdvdbytes dvd/macroout
dvd/rawdvdbytes: 
	cd dvd && python3 image.py 2> macroout > rawdvdbytes && wc -c rawdvdbytes

.PHONY: run
run: boot.bin
	qemu-system-i386 -display spice-app -hda boot.bin

.PHONY: run-debug
run-debug: boot.bin boot.elf
	qemu-system-i386 -display spice-app \
		-hda boot.bin \
		-s -S &

	gdb boot.elf \
		-ex 'target remote localhost:1234' \
		-ex 'set architecture i8086' \
		-ex 'source stepint.py' \
		-ex 'layout src' \
		-ex 'layout regs' \
		-ex 'hbreak *0x7c00' \
		-ex 'continue'

.PHONY: clean
clean:
	rm *.o *.bin *.elf