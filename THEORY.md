# THEORY — How It All Actually Works

Companion to the lessons: the theory behind every layer, with the fun facts
the tutorials skip.

---

## 1. CPU Rings: The Bouncer at the Door

x86 has four privilege rings (0-3), but Linux uses only two: Ring 0 (kernel)
and Ring 3 (user). The ring number lives in the low two bits of the CS segment
selector — it's literally part of the value your `cs` register holds.

**How enforcement works:** every instruction the CPU fetches is checked
against the current privilege level (CPL). Privileged instructions (`lgdt`,
`lidt`, `mov cr0`, `wrmsr`, `hlt`, `in`/`out`) fault with #GP if CPL != 0.
Memory access is checked against page-table U/S bits: a Ring 3 access to a
supervisor page faults. The kernel doesn't "block" you — the silicon does.

> **Did you know?** Rings 1 and 2 were designed for device drivers and
> middleware in the 1980s (OS/2 actually used them). No mainstream OS ever
> adopted them, and modern hypervisors effectively repurposed the idea as
> "ring -1": VT-x/AMD-V add an entirely new privilege level *below* Ring 0
> where the hypervisor lives. Your host kernel is a guest too.

> **Did you know?** The `syscall` instruction was introduced with AMD's
> K6-2+ because the old `int 0x80` path (software interrupt through the IDT)
> was too slow. `int 0x80` still works on x86-64 Linux — it's just ~10x
> slower, and 32-bit only in terms of register usage.

---

## 2. The Syscall Path: The Most Reviewed Assembly on Earth

At boot, `syscall_init()` writes two MSRs:

- `MSR_LSTAR` (0xC0000082): address of `entry_SYSCALL_64`
- `MSR_STAR` (0xC0000081): the Ring 3 and Ring 0 segment selectors the CPU
  loads into CS/SS automatically on syscall/sysret

When user code executes `syscall`, the CPU — in a single atomic step —
saves `rip` into `rcx`, saves `rflags` into `r11`, masks `rflags` (clearing
the trap flag and IF according to `MSR_FMASK`), switches CPL to 0, and jumps
to LSTAR. It does **not** switch stacks: `entry_SYSCALL_64` loads the kernel
stack from per-CPU memory (found via `swapgs` + the GS base register).

The entry stub then builds a `pt_regs` structure — a full snapshot of user
register state — so the C syscall handlers can treat it like any struct
pointer. On return, `sysret` restores `rip` from `rcx` and `rflags` from
`r11` and drops back to Ring 3.

> **Did you know?** `entry_SYSCALL_64` was the target of real attacks:
> register values from user space leaking into kernel space (Register
> Leakage / Spectre-class issues) is why the entry code explicitly zeroes
> callee-clobbered registers before dispatching. Every instruction in that
> file has been audited for side channels.

> **Did you know?** Syscall numbers differ per architecture: `write` is 1 on
> x86-64 but 4 on 32-bit x86, and `mmap` is 9 on x86-64 but 90 on ARM64's
> heritage table. There is no stable syscall ABI across architectures — only
> across kernel versions on one architecture (Linus's famous "we do not break
> userspace" promise).

---

## 3. Page Tables: Why `copy_to_user` Exists

x86-64 uses 4-level paging: a 48-bit virtual address splits into
16 (sign-extension) + 9 + 9 + 9 + 9 + 12 bits. Each 9-bit index selects an
entry in a 4KB table of 8-byte entries: PML4 -> PDPT -> PD -> PT -> page.
The CR3 register points at the PML4.

Each entry carries permission bits: Present, Read/Write, User/Supervisor,
No-eXecute. Kernel pages have U/S=0, so Ring 3 faults on access — this is
what makes kernel memory invisible to your programs. KPTI (the Meltdown
mitigation) goes further: user processes get a *separate* CR3 with almost the
entire kernel unmapped, and the syscall entry stub switches CR3 on the way in.

> **Did you know?** SMAP and SMEP flip the protection direction: SMAP makes
> the *kernel* fault when it touches user pages (preventing accidental
> dereferences of user pointers — a classic exploit primitive), and SMEP
> prevents executing user pages in Ring 0 (kills ret2usr attacks). That's why
> `copy_to_user`/`copy_from_user` exist even though a plain dereference
> "would work" — they handle the SMAP toggle and fault-safety in one call.

> **Did you know?** The top 16 bits of a canonical address must all be copies
> of bit 47. If they aren't, the CPU faults *before* even walking the page
> tables — a general protection fault, not a page fault. That's why kernel
> addresses all start with 0xffff and user addresses with 0x0000.

---

## 4. Hardware Access: MMIO, Port I/O, DMA, and Interrupts

Three ways Ring 0 code talks to a device:

1. **Port I/O** (legacy): `inb`/`outb` on a separate 64KB I/O address space.
   Slow (serial ports, PS/2). Each port access is a few hundred CPU cycles.
2. **MMIO** (modern): device registers mapped into physical memory via a PCI
   BAR. The driver `ioremap`s the physical range and reads/writes with
   `ioread32`/`iowrite32`. These loads/stores are *uncacheable* — the CPU
   routes them to the PCIe controller instead of RAM.
3. **DMA**: the device's own engine reads/writes system RAM directly, no CPU
   involved. The driver only sets up descriptors (RAM-resident records of
   {buffer address, length, status}) and rings a doorbell register.

Interrupts close the loop: instead of the driver polling, the device raises
an interrupt (MSI: a memory *write* to a special address that the chipset
converts into an interrupt — yes, a packet arrival is signaled by writing to
RAM). The CPU vectors through the IDT into the driver's handler.

> **Did you know?** A single 10GbE NIC at line rate delivers ~14.8 million
> packets per second. Interrupt-per-packet would melt the CPU (interrupt
> overhead alone exceeds the packet processing budget), which is why modern
> drivers use interrupt coalescing, NAPI polling, and multi-queue RSS that
> steers flows to different CPUs. High-performance networking is mostly an
> exercise in *avoiding* interrupts.

> **Did you know?** DMA is a security surface: a malicious PCI device with
> bus-master access can read/write all RAM, bypassing the CPU entirely —
> including kernel memory. Thunderbolt attacks ("Thunderclap") exploit this.
> The mitigation is the IOMMU (Intel VT-d / AMD-Vi), which gives devices
> their own page tables. `dma_alloc_coherent` + the IOMMU is why modern
> kernels can safely let you hotplug devices.

---

## 5. The NIC, Register by Register

The e1000's register file (BAR0) is a flat array of 32-bit registers:

| Offset | Register | Purpose |
|---|---|---|
| 0x0000 | CTRL | reset, link speed, loopback |
| 0x0008 | STATUS | link up, speed, duplex, PHY type |
| 0x0014 | EERD | EEPROM read (MAC address lives here) |
| 0x2800-0x2810 | TDBAL/TDBAH/TDLEN/TDH/TDT | TX ring base/length/head/tail |
| 0x2800+0x100 | RDBAL...RDT | RX ring equivalents |
| 0x00C0 | ICR | interrupt cause — one bit per event type |

To transmit: fill a TX descriptor (buffer physaddr + length), write the tail
index (TDT). The chip DMAs the buffer, transmits it, sets the descriptor's
"done" bit, and raises an interrupt. To receive: the reverse — the chip DMAs
incoming frames into pre-posted RX buffers and updates the head index.

> **Did you know?** The e1000's MAC address isn't in a register — it's in an
> EEPROM on the card. The driver must program the EERD register to make the
> chip fetch it, then poll a "done" bit. QEMU fakes this EEPROM in software,
> which is why every QEMU e1000 starts with the same MAC (52:54:00:...).

> **Did you know?** Modern NICs are closer to computers than to chips: an
> Intel 100GbE NIC has its own ARM cores running firmware, hardware flow
> classification, checksum/segmentation offload engines, and PCIe DMA
> engines. DPDK exists because the *kernel* became the bottleneck: it maps
> NIC queues directly into user space so applications do DMA themselves,
> achieving ~80M packets/sec/core — with the kernel completely bypassed.

---

## 6. Putting It Together: One Packet's Journey

1. `send()` in user space (Ring 3) -> `syscall` -> Ring 0
2. Socket layer -> TCP/IP stack builds the frame -> `dev_queue_xmit`
3. Driver picks a free TX descriptor, copies the frame into a DMA buffer,
   writes TDT (one MMIO store)
4. NIC DMAs the frame, appends CRC, pushes it onto the wire
5. Remote NIC DMAs it into *its* RX ring, raises MSI (a memory write!)
6. Remote CPU vectors through IDT -> NAPI polls the ring -> packet goes up
   the stack -> `recv()` syscall returns to Ring 3

Two CPUs, two rings, two DMAs, one memory-write interrupt — and your
assembly from lesson 01 started it all with `mov rax, 1; syscall`.
