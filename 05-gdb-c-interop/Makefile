NASM := nasm
NASMFLAGS := -f elf64 -g -F dwarf
CC := gcc

TARGET := interop
OBJS := $(TARGET).o

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(OBJS) -o $(TARGET) -no-pie

%.o: %.asm
	$(NASM) $(NASMFLAGS) $< -o $@

debug: $(TARGET)
	gdb -ex "break my_add" -ex run ./$(TARGET)

clean:
	rm -f $(TARGET) $(OBJS)

.PHONY: all clean debug
