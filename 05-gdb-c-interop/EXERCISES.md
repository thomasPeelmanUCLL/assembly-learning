# 05-gdb-c-interop — Debugging Cheat Sheet

## gdb workflow

```bash
make debug          # builds with debug symbols and starts gdb
```

Inside gdb:

| Command | What it does |
|---|---|
| `break my_add` | stop at function entry |
| `run` | start the program |
| `info registers` | dump all registers |
| `x/4gx $rsp` | examine 4 quadwords at the stack top |
| `x/s $rdi` | interpret rdi as a string (great for printf args) |
| `stepi` / `nexti` | step one instruction / over calls |
| `disassemble` | show the current function's instructions |
| `p/d $rax` | print rax as a signed decimal |

## Key ideas in this lesson

- **Locals live at negative offsets from rbp**: `[rbp-8]`, `[rbp-16]`, ...
- **`leave`** = `mov rsp, rbp` + `pop rbp` — the standard epilogue.
- **The red zone**: leaf functions may use the 128 bytes below `rsp` without
  adjusting it. `my_add` adjusts anyway so you can see the pattern.
- **Calling C from asm and asm from C** use the same convention — try writing
  a `main.c` that calls `my_add` directly (declare it `extern long my_add(long, long);`).

## Exercises

1. Write `main.c` that calls `my_add` and prints the result. Link with `gcc main.c interop.o`.
2. In gdb, break on `my_add`, then `x/2gx $rbp-16` — what do you see and why?
3. Intentionally corrupt the stack (write past `[rbp-16]`) and observe the crash.
   Explain the segfault address in a comment in `EXERCISES.md`:
   ANSWER:
