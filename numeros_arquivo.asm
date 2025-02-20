section .data
    nome_arquivo db "arquivo.txt", 0
    newline db 10

section .bss
    buffer resb 3   ; Buffer para armazenar os números lidos
    descritor_arquivo resq 1

section .text
    global _start

_start:
    ; Abrir o arquivo para leitura
    mov rax, 2             ; syscall open
    mov rdi, nome_arquivo  ; Nome do arquivo
    mov rsi, 0             ; Flags: O_RDONLY
    mov rdx, 0             ; Modo (não necessário para leitura)
    syscall

    ; Verificar se o arquivo foi aberto com sucesso
    cmp rax, 0
    jl erro_abrir_arquivo
    mov [descritor_arquivo], rax

ler_arquivo:
    ; Ler um número do arquivo
    mov rax, 0             ; syscall read
    mov rdi, [descritor_arquivo]
    mov rsi, buffer
    mov rdx, 3             ; Ler 2 dígitos + newline
    syscall

    ; Verificar EOF
    cmp rax, 0
    je fechar_arquivo

    ; Escrever o número lido
    mov rax, 1             ; syscall write
    mov rdi, 1             ; stdout
    mov rsi, buffer
    mov rdx, 2             ; Apenas os dois primeiros caracteres
    syscall

    ; Escrever espaço entre os números
    mov rax, 1
    mov rdi, 1
    lea rsi, [newline]
    mov rdx, 1
    syscall

    jmp ler_arquivo

fechar_arquivo:
    ; Fechar o arquivo
    mov rax, 3             ; syscall close
    mov rdi, [descritor_arquivo]
    syscall

    ; Sair do programa
    mov rax, 60            ; syscall exit
    xor rdi, rdi
    syscall

erro_abrir_arquivo:
    ; Exibir erro e sair
    mov rax, 60            ; syscall exit
    mov rdi, 1             ; Código de erro
    syscall
