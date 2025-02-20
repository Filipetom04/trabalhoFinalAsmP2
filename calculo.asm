section .data
    msg_soma db "Soma: ", 0
    msg_sub db "Sub: ", 0
    msg_mult db "Mult: ", 0
    msg_div db "Div: ", 0
    newline db 10, 0

section .bss
    buffer resb 10   ; Buffer para armazenar os resultados

section .text
    global _start

_start:
    ; Executar soma
    call executar_soma
    call esperar_filho
    
    ; Executar subtração
    call executar_sub
    call esperar_filho
    
    ; Executar multiplicação
    call executar_mult
    call esperar_filho
    
    ; Executar divisão
    call executar_div
    call esperar_filho
    
    ; Finalizar o programa
    mov rax, 60       ; syscall exit
    xor rdi, rdi
    syscall

executar_soma:
    mov rax, 57       ; syscall fork
    syscall
    test rax, rax     ; Verifica se é o processo filho
    jnz fim_soma      ; Se não for filho, sai
    mov rax, 59       ; syscall execve
    mov rdi, soma_cmd ; Comando
    mov rsi, soma_args ; Argumentos
    xor rdx, rdx      ; Nenhuma variável de ambiente
    syscall
fim_soma:
    ret

executar_sub:
    mov rax, 57       ; syscall fork
    syscall
    test rax, rax
    jnz fim_sub
    mov rax, 59
    mov rdi, sub_cmd
    mov rsi, sub_args
    xor rdx, rdx
    syscall
fim_sub:
    ret

executar_mult:
    mov rax, 57
    syscall
    test rax, rax
    jnz fim_mult
    mov rax, 59
    mov rdi, mult_cmd
    mov rsi, mult_args
    xor rdx, rdx
    syscall
fim_mult:
    ret

executar_div:
    mov rax, 57
    syscall
    test rax, rax
    jnz fim_div
    mov rax, 59
    mov rdi, div_cmd
    mov rsi, div_args
    xor rdx, rdx
    syscall
fim_div:
    ret

esperar_filho:
    mov rax, 61       ; syscall waitpid
    mov rdi, -1       ; Espera qualquer filho
    xor rsi, rsi
    xor rdx, rdx
    syscall
    ret

section .data
    soma_cmd db "./soma", 0
    soma_args dq soma_cmd, 0
    sub_cmd db "./sub", 0
    sub_args dq sub_cmd, 0
    mult_cmd db "./mult", 0
    mult_args dq mult_cmd, 0
    div_cmd db "./div", 0
    div_args dq div_cmd, 0
