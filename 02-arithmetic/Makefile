NASM := nasm
NASMFLAGS := -f elf64 -g -F dwarf
CC := gcc

TARGET := math
OBJS := $(TARGET).o

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(OBJS) -o $(TARGET) -no-pie

%.o: %.asm
	$(NASM) $(NASMFLAGS) $< -o $@

clean:
	rm -f $(TARGET) $(OBJS)

.PHONY: all clean
