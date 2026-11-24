; 06-projects: reverse-polish notation (RPN) calculator
; Evaluates a hardcoded RPN expression: "5 3 + 2 *" -> (5+3)*2 = 16
; The stack IS the data structure — very natural in assembly.
; Stretch goals: parse from argv, support subtraction and division.

section .data
    fmt db "result = %ld", 10, 0

section .text
global main
extern printf

main:
    push rbp
    mov rbp, rsp

    ; push operands
    mov rax, 5
    push rax
    mov rax, 3
    push rax

    ; '+' : pop two, add, push result
    pop rbx
    pop rax
    add rax, rbx
    push rax

    ; push 2
    mov rax, 2
    push rax

    ; '*' : pop two, multiply, push result
    pop rbx
    pop rax
    imul rax, rbx
    push rax

    ; final result
    pop rax

    lea rdi, [rel fmt]
    mov rsi, rax
    xor eax, eax
    call printf

    xor eax, eax
    pop rbp
    ret
