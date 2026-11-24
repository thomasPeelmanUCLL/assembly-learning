; 03-control-flow: comparisons, jumps, and loops
section .data
    nums     dq 8, 3, 15, 4, 42, 1, 23
    n        equ 7
    fmt_max  db "max=%ld", 10, 0
    fmt_sum  db "sum=%ld", 10, 0

section .text
global main
extern printf

main:
    push rbp
    mov rbp, rsp

    ; --- find the maximum ---
    lea rsi, [rel nums]
    mov rcx, n
    mov rax, [rsi]        ; rax = current max
.max_loop:
    cmp [rsi], rax
    jle .not_bigger       ; skip if nums[i] <= max
    mov rax, [rsi]
.not_bigger:
    add rsi, 8            ; next qword
    dec rcx
    jnz .max_loop

    lea rdi, [rel fmt_max]
    mov rsi, rax
    xor eax, eax
    call printf

    ; --- sum with a loop ---
    lea rsi, [rel nums]
    mov rcx, n
    xor rdx, rdx
.sum_loop:
    add rdx, [rsi]
    add rsi, 8
    loop .sum_loop        ; loop = dec rcx + jnz combined

    lea rdi, [rel fmt_sum]
    mov rsi, rdx
    xor eax, eax
    call printf

    xor eax, eax
    pop rbp
    ret
