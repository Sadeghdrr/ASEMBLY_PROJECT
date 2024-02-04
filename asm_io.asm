segment .data
print_int_format: db        "%ld ", 0

print_float_format: db      "%6.3lf ", 0

read_int_format: db         "%ld", 0

read_float_format: db       "%f", 0

print_hex_format: db        "%x", 0



segment .text
    global print_int
    global print_char
    global print_string
    global print_float
    global print_nl
    global read_int
    global read_char
    global read_float
    global print_hex

    extern printf
    extern putchar
    extern puts
    extern scanf
    extern getchar

print_hex:
    sub rsp, 8

    mov rsi, rdi

    mov rdi, print_hex_format
    mov rax, 1 ; setting rax (al) to number of vector inputs
    call printf
    
    add rsp, 8 ; clearing local variables from stack

    ret

print_int:
    sub rsp, 8

    mov rsi, rdi

    mov rdi, print_int_format
    mov rax, 1 ; setting rax (al) to number of vector inputs
    call printf
    
    add rsp, 8 ; clearing local variables from stack

    ret

print_float:
    sub rsp, 8

    pxor xmm0, xmm0

    mov eax, edi
    movd xmm0, eax
    cvtss2sd xmm0, xmm0
    
    mov rdi, print_float_format
    mov rax, 1

    call printf

    add rsp, 8

    ret


print_char:
    sub rsp, 8

    call putchar
    
    add rsp, 8 ; clearing local variables from stack

    ret


print_string:
    sub rsp, 8

    call puts
    
    add rsp, 8 ; clearing local variables from stack

    ret


print_nl:
    sub rsp, 8

    mov rdi, 10
    call putchar
    
    add rsp, 8 ; clearing local variables from stack

    ret


read_int:
    sub rsp, 8

    mov rsi, rsp
    mov rdi, read_int_format
    mov rax, 1 ; setting rax (al) to number of vector inputs
    call scanf

    mov rax, [rsp]

    add rsp, 8 ; clearing local variables from stack

    ret

read_float:
    push rbp                    ; preLog
    push rbx
    push r12
    push r13
    push r14
    push r15
    
    sub rsp, 8

    mov rsi, rsp
    mov rdi, read_float_format
    mov rax, 1
    call scanf

    mov eax, dword [rsp]

    add rsp, 8

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp

    ret

read_char:
    sub rsp, 8

    call getchar

    add rsp, 8 ; clearing local variables from stack

    ret
