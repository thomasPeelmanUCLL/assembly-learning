# 08-rings-and-hardware — User Space, Kernel Space, and the Metal

The full path of `write(1, "hello", 6)` on x86-64 Linux:

```
[Ring 3] your asm: mov rax,1; mov rdi,1; syscall
            |
            v  CPU hardware: switch to Ring 0, rip->rcx, rflags->r11,
            |  jump to MSR_LSTAR (set at boot by syscall_init())
[Ring 0] entry_SYSCALL_64 (arch/x86/entry/entry_64.S)
            swapgs, switch CR3 (PTI), load kernel stack,
            build pt_regs, clear leaky registers
            |
            v
         do_syscall_64 -> sys_call_table[rax] -> __x64_sys_write
            -> VFS -> your driver's file_operations.write
            |
            v  hardware access from Ring 0:
         MMIO (ioremap + readl/writel), port I/O (inb/outb),
         DMA (device reads/writes RAM directly), interrupts (IDT)
            |
            v
         sysret: rax = return value, back to Ring 3
```

Key facts:

- The CPU enforces the rings, not the OS: Ring 3 cannot execute privileged
  instructions and user pages are marked non-supervisor in the page tables.
- `syscall` does NOT switch stacks — entry_64.S does that manually.
- 4-level page tables (PML4->PDPT->PD->PT) give kernel/user isolation;
  SMAP/SMEP stop the kernel from touching user pages by accident.
- Syscalls, hardware interrupts, page faults, and int 0x80 all enter through
  different doors but share the same pt_regs machinery.

## Exercises

1. `strace -e write ./01-hello/hello` — count the ring transitions.
2. In gdb, break right after a `syscall` instruction: verify `rcx` holds the
   return address and `r11` holds the old RFLAGS. That is the CPU's fingerprint.
3. Read `entry_SYSCALL_64` on elixir.bootlin.com for your kernel version and
   annotate each instruction group in a comment here:
   ANSWER:
4. Capstone: build a baby kernel (see `baby/`) that sets up its own GDT, IDT,
   and page tables, drops to Ring 3, and comes back via its own syscall
   handler (write MSR_LSTAR yourself with wrmsr).
