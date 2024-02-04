%include "asm_io.inc"

section .data
    choose_mode db "Choose the mode:", 10, "1 -> non parallel matrix dot", 10, "2 -> parallel matrix dot", 10
                db "3 -> non parallel matrix multiplication", 10, "4 -> parallel matrix multiplication", 10,
                db "5 -> non parallel convolution", 10, "6 -> parallel convolution", 10, 0
    enter_size db "Enter the matrixes sizes:", 10, 0
    enter_matrix1 db "Enter the matrix 1:", 10, 0
    enter_matrix2 db "Enter the matrix 2:", 10, 0
    result_frmt db "reslut = %d", 10, 0
    invalid_input_frmt db "invalid input", 10, 0

    matrix1 dd 64 dup(0)
    matrix2 dd 64 dup(0)
    result_matrix dd 64 dup(0)
    result dd 0
    temp1 dd 8 dup(0)
    temp2 dd 8 dup(0)
    size1 dd 0
    size2 dd 0

segment .text

    global my_main
    extern printf

    my_main:
        push rbp                    ; preLog
        push rbx
        push r12
        push r13
        push r14
        push r15

        sub rsp, 8                  ; stack alignment

        mov rdi, choose_mode
        call printf
        call read_int

        cmp rax, 1
        je first_mode           ; non_parallel_dot
        
        cmp rax, 2
        je second_mode          ; parallel_dot

        ; cmp rax, 3
        ; je non_parallel_mult

        ; cmp rax, 4
        ; je parallel_mult

        ; cmp rax, 5
        ; je convolution

        call invalid
        jmp end


        first_mode:
            call get_inputs
            mov eax, [size1]
            cmp eax, [size2]
            jne invalid_main

            mov rbx, 0
            call non_parallel_dot

            mov edi, [result]
            call print_float
            call print_nl
            jmp end

        second_mode:
            call get_inputs
            mov eax, [size1]
            cmp eax, [size2]
            jne invalid_main

            mov rbx, 0
            call parallel_dot

            mov edi, [result]
            call print_float
            call print_nl
            jmp end

        invalid_main:
            call invalid
            
        end:
            add rsp, 8

            pop r15
            pop r14
            pop r13
            pop r12
            pop rbx
            pop rbp

            ret


    get_inputs:
        push rbp                    ; preLog
        push rbx
        push r12
        push r13
        push r14
        push r15

        sub rsp, 8
    
        mov rdi, enter_size
        call printf

        call read_int
        cmp eax, 8
        jg invalid_input
        mov [size1], eax

        call read_int
        cmp eax, 8
        jg invalid_input
        mov [size2], eax

        mov rdi, enter_matrix1
        call printf

        xor r12, r12        ; row
        xor r13, r13        ; inner (column) index
        xor r15, r15        ; temp
        xor rbx, rbx        ; size
        mov ebx, [size1]  
        get_matrix_1:
            xor r13, r13
            in_get_matrix_1:
                call read_float
                mov r15, r12
                add r15, r13
                mov [matrix1 + r15], eax

                add r13, 4
                mov r15, rbx
                imul r15, 4
                cmp r13, r15
                jl in_get_matrix_1
            
            add r12, 32
            mov r15, rbx
            imul r15, 32
            cmp r12, r15
            jl get_matrix_1

        mov rdi, enter_matrix2
        call printf

        xor r12, r12        ; row
        xor r13, r13        ; inner (column) index
        xor r15, r15        ; temp
        xor rbx, rbx        ; size
        mov ebx, [size2]  
        get_matrix_2:
            xor r13, r13
            in_get_matrix_2:
                call read_float
                mov r15, r12
                add r15, r13
                mov [matrix2 + r15], eax

                add r13, 4
                mov r15, rbx
                imul r15, 4
                cmp r13, r15
                jl in_get_matrix_2
            
            add r12, 32
            mov r15, rbx
            imul r15, 32
            cmp r12, r15
            jl get_matrix_2
        
        jmp end_input
            
        invalid_input:
            call invalid

        end_input:
            add rsp,8               ; stack alignment

            pop r15
            pop r14
            pop r13
            pop r12
            pop rbx
            pop rbp

            ret

    non_parallel_dot:
        push rbp                    ; preLog
        push rbx
        push r12
        push r13
        push r14
        push r15

        sub rsp, 8

        mov r12, rax            ; r12 -> size for dot,
                                ; rbx -> base index,
                                ; r13, r14 -> index,
                                ; r15 -> temp
                                
        xor r13, r13                    ; set the first_index to 0
        xor r14, r14                    ; set the second_index to 0
        pxor xmm0, xmm0                 ; set the result to 0

        dotting1:
            xor r14, r14                    ; set the second_index to 0
            dotting2:
                mov r15, rbx
                add r15, r13
                add r15, r14
                movss xmm1, [matrix1 + r15]
                movss xmm2, [matrix2 + r15]
                mulss xmm1, xmm2
                addss xmm0, xmm1

                add r14, 4
                mov r15, r12
                imul r15, 4 
                cmp r14, r15
                jl dotting2

            add r13, 32
            mov r15, r12
            imul r15, 32
            cmp r13, r15
            jl dotting1

        movd [result], xmm0

        add rsp,8               ; stack alignment

        pop r15
        pop r14
        pop r13
        pop r12
        pop rbx
        pop rbp
        
        ret

    parallel_dot:
        push rbp                    ; preLog
        push rbx
        push r12
        push r13
        push r14
        push r15

        sub rsp, 8

        mov r12, rax            ; r12 -> size for dot,
                                ; rbx -> base index,
                                ; r13 -> counter,
                                ; r14 -> index,
                                ; r15 -> temp
        xor r13, r13                ; zero the counter
        vpxor ymm4, ymm4            ; zero the result

        dot:
            xor r14, r14
            vpxor ymm1, ymm1
            vpxor ymm2, ymm2
            vmovups [temp1], ymm1
            vmovups [temp2], ymm2
            
            fill_ymms:
                mov r15, r14
                imul r15, 4

                add r15, rbx
                mov eax, [matrix1 + r15]
                sub r15, rbx
                mov [temp1 + r15], eax
                add r15, rbx
                mov eax, [matrix2 + r15]
                sub r15, rbx
                mov [temp2 + r15], eax
                
                inc r14
                cmp r14, r12
                jl fill_ymms
            
            vmovups ymm1, [temp1]
            vmovups ymm2, [temp2]
            vmulps ymm3, ymm1, ymm2 
            vaddps ymm4, ymm4, ymm3

            add rbx, 32
            inc r13
            cmp r13, r12
            jl dot

        vmovups [temp1], ymm4
        xor r12, r12                ; counter
        pxor xmm1, xmm1             ; result
        sum:                                ; get sum of ymm4 components
            addss xmm1, [temp1 + 4 * r12]
            inc r12
            cmp r12, 8
            jl sum

        movd [result], xmm1

        add rsp,8               ; stack alignment

        pop r15
        pop r14
        pop r13
        pop r12
        pop rbx
        pop rbp

        ret

    invalid:
        sub rsp, 8

        mov rdi, invalid_input_frmt
        call printf
        
        mov rax, 60       ; syscall number for exit
        xor rdi, rdi      ; exit code 0
        syscall

        add rsp,8               ; stack alignment

        ret



; mov edi, [matrix2 + r15]
; call print_float
; call print_nl

; mov rdi, r12
; call print_int
; call print_nl
; mov rdi, r13
; call print_int
; call print_nl
; mov rdi, r14
; call print_int
; call print_nl
; mov rdi, r15
; call print_int
; call print_nl
; call print_nl