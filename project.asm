%include "asm_io.inc"

section .data
    choose_mode db "Choose the mode:", 10, "1 -> non parallel matrix dot", 10, "2 -> parallel matrix dot", 10
                db "3 -> non parallel matrix multiplication", 10, "4 -> parallel matrix multiplication", 10,
                db "5 -> parallel convolution", 10, 0
    enter_size db "Enter the matrixes sizes:", 10, 0
    enter_matrix1 db "Enter the matrix 1:", 10, 0
    enter_matrix2 db "Enter the matrix 2:", 10, 0
    result_frmt db "reslut = %d", 10, 0
    invalid_input_frmt db "invalid input", 10, 0
    xmm5_value dd 1.0, 1.0, 1.0, 1.0

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

        cmp rax, 3
        je third_mode

        cmp rax, 4
        je forth_mode

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

            mov edi, eax
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

            mov edi, eax
            call print_float
            call print_nl
            jmp end

        third_mode:
            call get_inputs
            mov eax, [size1]
            cmp eax, [size2]
            jne invalid_main

            call non_parallel_mult
            call print_result_matrix
            jmp end

        forth_mode:
            call get_inputs
            mov eax, [size1]
            cmp eax, [size2]
            jne invalid_main

            call parallel_mult
            call print_result_matrix
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

    print_result_matrix:
        push rbp                    ; preLog
        push rbx
        push r12
        push r13
        push r14
        push r15

        sub rsp, 8


        mov eax, [size1]
        mov r12, rax
        xor r13, r13
        xor r14, r14
        print_loop:
            xor r14, r14
            print_row:
                mov r15, r13
                imul r15, 32
                mov rbx, r14
                imul rbx, 4
                add r15, rbx

                mov edi, result_matrix[r15]
                call print_float

                inc r14
                cmp r14, r12
                jl print_row
            
            call print_nl
            inc r13
            cmp r13, r12
            jl print_loop
        
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

        movd eax, xmm0

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
                                ; r15 -> temp
        xor r13, r13                ; zero the counter
        vpxor ymm4, ymm4            ; zero the result

        dot:
            mov r15, r13
            imul r15, 32

            vmovups ymm1, matrix1[rbx]
            vmovups ymm2, matrix2[r15]
            vmulps ymm3, ymm1, ymm2 
            vaddps ymm4, ymm4, ymm3

            add rbx, 32
            inc r13
            cmp r13, r12
            jl dot

        movups  xmm5, [xmm5_value]
        vextractf128 xmm1, ymm4, 0
        vextractf128 xmm2, ymm4, 1
        dpps xmm1, xmm5, 0xF1
        dpps xmm2, xmm5, 0xF1
        addps xmm1, xmm2

        movups [temp1], xmm1
        mov eax, [temp1]
        
        add rsp,8               ; stack alignment

        pop r15
        pop r14
        pop r13
        pop r12
        pop rbx
        pop rbp

        ret

    non_parallel_mult:
        push rbp                    ; preLog
        push rbx
        push r12
        push r13
        push r14
        push r15

        sub rsp, 8

        mov r12, rax            ; r12 -> size,
        xor rbp, rbp            ; rbp -> row index
        xor rbx, rbx            ; rbx -> column index
        xor r13, r13            ; r13 -> counter,
                                ; r14 , r15 -> temp
        row_change:
            xor rbx, rbx
            column_change:
                pxor xmm3, xmm3
                xor r13, r13
                mult:
                    mov r15, rbp
                    imul r15, 32
                    mov r14, r13
                    imul r14, 4
                    add r15, r14
                    movss xmm1, matrix1[r15]

                    mov r15, r13
                    imul r15, 32
                    mov r14, rbx
                    imul r14, 4
                    add r15, r14
                    movss xmm2, matrix2[r15]

                    mulss xmm1, xmm2
                    addss xmm3, xmm1

                    inc r13
                    cmp r13, r12
                    jl mult
                
                mov r15, rbp
                imul r15, 32
                mov r14, rbx
                imul r14, 4
                add r15, r14
                movd result_matrix[r15], xmm3

                inc rbx
                cmp rbx, r12
                jl column_change

            inc rbp
            cmp rbp, r12
            jl row_change

        add rsp,8               ; stack alignment

        pop r15
        pop r14
        pop r13
        pop r12
        pop rbx
        pop rbp

        ret

    parallel_mult:
        push rbp                    ; preLog
        push rbx
        push r12
        push r13
        push r14
        push r15

        sub rsp, 8                  ; stack alignment


        
        add rsp, 8

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

; movups [temp1], xmm2
; mov edi, [temp1]
; call print_float
; mov edi, [temp1 + 4]
; call print_float
; mov edi, [temp1 + 8]
; call print_float
; mov edi, [temp1 + 12]
; call print_float
; call print_nl
; call print_nl