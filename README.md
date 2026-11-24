# assembly-learning

My journey learning **x86-64 assembly** with NASM on Linux — exercises, notes, and mini projects.

## Roadmap

- [ ] 01-hello — syscalls, registers, `mov`, `syscall`
- [ ] 02-arithmetic — `add`, `sub`, `imul`, `xor`, shifts, flags
- [ ] 03-control-flow — `cmp`, `jmp`, conditional jumps, loops
- [ ] 04-functions — stack, `push`/`pop`, `call`/`ret`, calling conventions
- [ ] 05-c-interfacing — linking with gcc, calling `printf`, debugging with gdb
- [ ] 06-projects — calculator, string reverser, tiny bytecode VM

## Build

Each folder has its own `Makefile`:

```bash
cd 01-hello
make
./hello
```

Dependencies: `nasm` and `ld` (binutils). On NixOS: `nix-shell -p nasm binutils`.

## References

- [LMU NASM Tutorial](https://cs.lmu.edu/~ray/notes/nasmtutorial/)
- [x64-roadmap](https://github.com/yds12/x64-roadmap)
- [x86-64 assembly from scratch](https://www.conradk.com/x86-64-assembly-from-scratch/)
