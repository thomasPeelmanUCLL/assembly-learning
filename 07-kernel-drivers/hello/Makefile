obj-m += hello.o

KDIR ?= /lib/modules/$(shell uname -r)/build

all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean

load: all
	sudo insmod hello.ko
	@sleep 0.2
	dmesg | tail -2

unload:
	sudo rmmod hello
	dmesg | tail -2

.PHONY: all clean load unload
