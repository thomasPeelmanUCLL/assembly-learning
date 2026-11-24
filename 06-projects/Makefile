NASM := nasm
NASMFLAGS := -f elf64 -g -F dwarf

all: reverse rpn_calc

reverse: reverse.o
	ld reverse.o -o reverse

rpn_calc: rpn_calc.o
	gcc rpn_calc.o -o rpn_calc -no-pie

%.o: %.asm
	$(NASM) $(NASMFLAGS) $< -o $@

clean:
	rm -f reverse rpn_calc *.o

.PHONY: all clean
