obj-m += nic_probe.o

KDIR ?= /lib/modules/$(shell uname -r)/build

all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean

load: all
	sudo insmod nic_probe.ko
	@sleep 0.2
	dmesg | tail -3

unload:
	sudo rmmod nic_probe

.PHONY: all clean load unload
