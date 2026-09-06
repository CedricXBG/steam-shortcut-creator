NASM = nasm
LD = ld
NASMFLAGS = -f elf64
LDFLAGS = -dynamic-linker /lib64/ld-linux-x86-64.so.2 -lcurl -lc $(shell pkg-config --libs gtk+-3.0)

BUILD_DIR = build
TARGET = $(BUILD_DIR)/steam-shortcut-creator
OBJS = $(BUILD_DIR)/main.o

all: $(TARGET)

$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) $< -o $@

$(BUILD_DIR)/%.o: %.asm | $(BUILD_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean
