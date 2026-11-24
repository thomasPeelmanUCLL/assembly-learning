; 02-arithmetic: basic math and flag behavior
section .data
    a   dq 15
    b   dq 4
    fmt db "a=%ld b=%ld sum=%ld diff=%ld prod=%ld quot=%ld rem=%ld", 10, 0

section .text
global main
extern printf

main:
    push rbp
    mov rbp, rsp

    mov rax, [a]
    mov rbx, [b]

    ; sum: a + b
    mov r12, rax
    add r12, rbx          ; r12 = 19

    ; diff: a - b
    mov r13, rax
    sub r13, rbx          ; r13 = 11

    ; product: a * b (imul for signed 64-bit)
    mov r14, rax
    imul r14, rbx         ; r14 = 60

    ; division: rdx:rax / rbx -> quotient rax, remainder rdx
    mov r15, rax
    xor rdx, rdx          ; MUST zero rdx before div
    div rbx               ; rax = 3, rdx = 3 (remainder)
    mov r8, rax           ; quotient
    mov r9, rdx           ; remainder

    lea rdi, [rel fmt]
    mov rsi, [a]
    mov rdx, [b]
    mov rcx, r12
    mov r10, r13
    mov r11, r14
    push r9
    push r8
    xor eax, eax          ; required: no vector args
    call printf
    add rsp, 16

    xor eax, eax
    pop rbp
    ret
