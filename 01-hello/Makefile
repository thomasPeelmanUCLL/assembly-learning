NASM := nasm
NASMFLAGS := -f elf64 -g -F dwarf
LD := ld

TARGET := hello
OBJS := $(TARGET).o

all: $(TARGET)

$(TARGET): $(OBJS)
	$(LD) $(OBJS) -o $(TARGET)

%.o: %.asm
	$(NASM) $(NASMFLAGS) $< -o $@

clean:
	rm -f $(TARGET) $(OBJS)

.PHONY: all clean
