; 05-gdb-c-interop: mixing assembly with C and debugging with gdb
; Build: make && ./interop
; Debug: make debug   (starts gdb with a breakpoint at my_add)

section .data
    fmt db "my_add(20, 22) = %ld", 10, 0

section .text
global main
extern printf

; long my_add(long x, long y)
; Demonstrates a local variable on the stack and the red zone.
my_add:
    push rbp
    mov rbp, rsp
    sub rsp, 16           ; reserve 16 bytes for locals
    mov [rbp-8], rdi      ; local: x
    mov [rbp-16], rsi     ; local: y
    mov rax, [rbp-8]
    add rax, [rbp-16]
    leave                 ; mov rsp, rbp + pop rbp
    ret

main:
    push rbp
    mov rbp, rsp

    mov rdi, 20
    mov rsi, 22
    call my_add
    mov r12, rax

    lea rdi, [rel fmt]
    mov rsi, 20
    mov rdx, 22
    mov rcx, r12
    xor eax, eax
    call printf

    xor eax, eax
    pop rbp
    ret
