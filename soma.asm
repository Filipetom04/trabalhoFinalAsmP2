section .data
    nome_arquivo db "arquivo.txt", 0
    msg_resultado db "Soma: ", 0
    newline db 10, 0
    len_msg_resultado equ $-msg_resultado

section .bss
    buffer resb 3          ; 2 dígitos + newline
    descritor_arquivo resq 1 ; Descritor do arquivo (64 bits)
    soma resd 1            ; Armazenar a soma

section .text
    global _start

_start:
    ; Abrir o arquivo para leitura
    mov rax, 2             ; syscall para 'open' (64 bits)
    mov rdi, nome_arquivo  ; Nome do arquivo
    mov rsi, 0             ; Flags: O_RDONLY
    mov rdx, 0             ; Modo (não necessário para leitura)
    syscall

    ; Verificar se o arquivo foi aberto com sucesso
    cmp rax, 0
    jl erro_abrir_arquivo

    mov [descritor_arquivo], rax ; Salvar descritor do arquivo

    ; Inicializar a soma
    mov dword [soma], 0

ler_arquivo:
    ; Ler do arquivo
    mov rax, 0             ; syscall para 'read' (64 bits)
    mov rdi, [descritor_arquivo] ; Descritor do arquivo
    mov rsi, buffer        ; Endereço do buffer
    mov rdx, 3             ; Número de bytes a ler (2 dígitos + newline)
    syscall

    ; Verificar EOF
    cmp rax, 0
    je exibir_resultado

    ; Converter os dois dígitos ASCII para um número
    movzx eax, byte [buffer]   ; Primeiro dígito
    sub eax, '0'               ; Converter para número
    imul eax, 10               ; Multiplicar por 10 (dezena)
    movzx ebx, byte [buffer+1] ; Segundo dígito
    sub ebx, '0'               ; Converter para número
    add eax, ebx               ; Somar dezena e unidade

    ; Adicionar à soma total
    add [soma], eax

    ; Continuar lendo o arquivo
    jmp ler_arquivo

exibir_resultado:
    ; Fechar o arquivo
    mov rax, 3             ; syscall para 'close' (64 bits)
    mov rdi, [descritor_arquivo]
    syscall

    ; Exibir a mensagem "Soma: "
    mov rax, 1             ; syscall para 'write' (64 bits)
    mov rdi, 1             ; stdout
    mov rsi, msg_resultado
    mov rdx, len_msg_resultado
    syscall

    ; Converter a soma para ASCII e exibir
    mov eax, [soma]
    call exibir_numero

    ; Exibir uma nova linha
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; Sair do programa
    mov rax, 60            ; syscall para 'exit' (64 bits)
    xor rdi, rdi           ; Código de saída 0
    syscall

erro_abrir_arquivo:
    ; Exibir erro genérico e sair
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_resultado
    mov rdx, len_msg_resultado
    syscall
    jmp finalizar_programa

finalizar_programa:
    ; Sair do programa
    mov rax, 60            ; syscall para 'exit' (64 bits)
    xor rdi, rdi           ; Código de saída 0
    syscall

; Função para exibir um número em EAX
exibir_numero:
    push rax
    push rbx
    push rcx
    push rdx

    ; Converter o número em EAX para ASCII
    mov ecx, 10            ; Base 10
    mov ebx, 0             ; Contador de dígitos

converter_digitos:
    xor edx, edx           ; Limpar EDX para a divisão
    div ecx                ; Dividir EAX por 10
    add dl, '0'            ; Converter o resto para ASCII
    push rdx               ; Empilhar o dígito
    inc ebx                ; Incrementar contador de dígitos
    test eax, eax          ; Verificar se EAX é zero
    jnz converter_digitos  ; Continuar se não for zero

exibir_digitos:
    pop rax                ; Desempilhar o dígito
    mov [buffer], al       ; Colocar o dígito no buffer
    mov rax, 1             ; syscall para 'write' (64 bits)
    mov rdi, 1             ; stdout
    mov rsi, buffer        ; Endereço do buffer
    mov rdx, 1             ; Número de bytes a escrever
    syscall
    dec ebx                ; Decrementar contador de dígitos
    jnz exibir_digitos     ; Continuar se ainda houver dígitos

    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret
