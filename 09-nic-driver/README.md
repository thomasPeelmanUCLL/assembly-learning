# 09-nic-driver — Talking to the Ethernet Chip

How a NIC actually works, from the driver's point of view:

```
      driver (Ring 0)                    NIC hardware
      --------------                    ------------
  pci_iomap(BAR0)  ----------------> register file (MMIO)
  write TDT register  ------------> "fetch TX descriptor"
                                        |
                                   DMA: chip reads packet
                                   buffer straight from RAM
                                        |
  RX interrupt  <----------------  "packet received"
  driver reads RDT/RX descriptors, hands packet up the stack
```

## The three mechanisms

1. **MMIO registers**: BAR0 maps the chip's control registers into physical
   memory. The driver `ioremap`s them and reads/writes with `ioread32`/
   `iowrite32`. Key e1000 registers: CTRL (0x0000), STATUS (0x0008),
   TDBAL/TDBAH/TDT (transmit ring), RDBAL/RDT (receive ring).
2. **DMA rings**: packets never pass through registers. The driver allocates
   *descriptor rings* in RAM — arrays of {buffer address, length, status} —
   and hands the NIC their physical addresses. The chip DMAs packets into and
   out of RAM on its own. This is why `pci_set_master` matters.
3. **Interrupts**: the NIC raises an MSI/INTx when work completes; the driver
   registers a handler with `request_irq` (or polls, in a baby kernel).

## What's in this lesson

- `nic_probe.c` — a loadable PCI driver that finds the e1000 (VID 0x8086,
  DID 0x100e — QEMU's default NIC), maps BAR0, and reads the STATUS register
  to report link state. Run it in a VM with `-device e1000,netdev=n0`.

## Where to go next

- **Real transmit/receive**: MIT's xv6 networking lab walks you through
  implementing `e1000_transmit()` and `e1000_recv()` against a QEMU e1000 —
  the best guided NIC exercise available.
- **Full Linux network driver**: bootlin's network-drivers lab builds a
  complete driver with `dma_alloc_coherent` rings and `netif_start_queue`.
- **Kernel source**: `drivers/net/ethernet/intel/e1000e/` is the production
  driver — read `e1000e_up()` to see the ring setup in the real world.

## Exercises

1. Run `lspci -vv` on your NIC (or the QEMU e1000). Find BAR0's type (MMIO vs
   I/O ports) and size. Compare with what `nic_probe` reports.
2. Extend `nic_probe` to read the MAC address: it lives in the EEPROM;
   trigger a read by writing the EEPROM address to offset 0x0014 (EERD) and
   polling bit 4, then read the result at 0x0014+4.
3. Add a TX ring: allocate one descriptor with `dma_alloc_coherent`, build a
   raw Ethernet frame in it, set TDBAL/TDBAH/TDL, write TDT, and watch the
   packet appear on the wire (tcpdump on the host bridge interface!).
4. In the baby kernel (lesson 08), port the e1000 init from the xv6 lab and
   send an ARP request. Receiving the reply means you've spoken to hardware
   with no OS in between.
