; 04-functions: the stack, call/ret, and the System V calling convention
; Convention: integer args go in rdi, rsi, rdx, rcx, r8, r9;
; rax = return value; rbx, rbp, r12-r15 are callee-saved.

section .data
    fmt db "square(%ld) = %ld, cube(%ld) = %ld", 10, 0

section .text
global main
extern printf

; long square(long x) -> x * x
square:
    mov rax, rdi
    imul rax, rdi
    ret

; long cube(long x) -> x * x * x  (demonstrates calling another function)
cube:
    push rbp
    mov rbp, rsp
    call square           ; rax = x*x
    imul rax, rdi         ; rax = x*x*x
    pop rbp
    ret

main:
    push rbp
    mov rbp, rsp

    mov rdi, 7
    call square
    mov r12, rax          ; save before next call clobbers rax

    mov rdi, 7
    call cube
    mov r13, rax

    lea rdi, [rel fmt]
    mov rsi, 7
    mov rdx, r12
    mov rcx, 7
    mov r8, r13
    xor eax, eax
    call printf

    xor eax, eax
    pop rbp
    ret
