; 06-projects: string reverser
; Reads a hardcoded string, reverses it in place, prints it.
; Stretch goal: rewrite it to read from stdin instead.

section .data
    msg  db "assembly is fun", 0
    len  equ $ - msg - 1        ; exclude the NUL

section .bss
    out  resb 64

section .text
global _start

_start:
    lea rsi, [rel msg]
    lea rdi, [rel out]
    add rdi, len - 1        ; point at last output slot
    mov rcx, len

.reverse:
    mov al, [rsi]
    mov [rdi], al
    inc rsi
    dec rdi
    dec rcx
    jnz .reverse

    ; print the reversed string
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel out]
    mov rdx, len
    syscall

    ; newline
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel nl]
    mov rdx, 1
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall

section .data
    nl db 10
