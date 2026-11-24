# 06-projects — Mini Projects

Two starter projects to consolidate everything:

## 1. String reverser (`reverse.asm`)

Reverses a hardcoded string in a buffer using a byte-by-byte loop.

```bash
make reverse && ./reverse
# expected: nuf si ylbmessa
```

**Stretch goals:**
- Read input from stdin with the `read` syscall (syscall 0) instead of a hardcoded string.
- Detect palindromes: compare the string against its reverse.

## 2. RPN calculator (`rpn_calc.asm`)

Evaluates `5 3 + 2 *` = 16 using the CPU stack directly as the RPN stack.

```bash
make rpn_calc && ./rpn_calc
# expected: result = 16
```

**Stretch goals:**
- Support `-` and `/` (careful with operand order when popping).
- Parse numbers and operators from `argv` (they arrive on the stack at `_start` —
  research how argc/argv are laid out).
- Add error handling for stack underflow.

## Exercises

1. Extend the reverser to reverse in place (no second buffer). Hint: swap ends
   moving two pointers toward the middle.
2. Make the RPN calculator handle `15 4 -` correctly. Which operand is which
   after two pops?
3. Combine both: read an RPN expression from stdin and evaluate it.
   This is the capstone — paste your solution link here when done:
   ANSWER:
