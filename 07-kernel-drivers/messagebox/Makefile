obj-m += messagebox.o

KDIR ?= /lib/modules/$(shell uname -r)/build

all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean

load: all
	sudo insmod messagebox.ko
	@sleep 0.2
	dmesg | tail -2

unload:
	sudo rmmod messagebox
	dmesg | tail -2

.PHONY: all clean load unload
