; -----------------------------------------------------------------------------------------------------------
; Sadegh Sargeran
; 401106039
; Project Assembly - Parallel and NonParallel programming comparing
; Computer Structures
; Prof. Jahangir
; -----------------------------------------------------------------------------------------------------------

%include "asm_io.inc"

section .data
    choose_mode db "Choose the mode:", 10, "1 -> non parallel matrix dot", 10, "2 -> parallel matrix dot", 10
                db "3 -> non parallel matrix multiplication", 10, "4 -> parallel matrix multiplication", 10,
                db "5 -> parallel convolution", 10, 0
    enter_size db "Enter the matrixes sizes:", 10, 0
    enter_matrix1 db "Enter the matrix 1:", 10, 0
    enter_matrix2 db "Enter the matrix 2:", 10, 0
    invalid_input_frmt db "invalid input", 10, 0
    matrix_size equ 64
    matrix_row_size equ 32
    matrix_half_row_size equ 16
    loop_counter dq 1000000

    matrix1 dd matrix_size dup(0)
    matrix2 dd matrix_size dup(0)
    result_matrix dd matrix_size dup(0)
    result_size dd 0
    size1 dd 0
    size2 dd 0

segment .text

    global my_main
    extern printf

    my_main:
        push rbp                            ; preLog
        push rbx
        push r12
        push r13
        push r14
        push r15

        sub rsp, 8                          ; stack alignment

        mov rdi, choose_mode
        call printf
        call read_int                       ; choose which function is about to be used
        cmp r10, 0                          ; input must be integer
        je invalid_input                    ; terminate the program if the inputs were invalid
        
        cmp rax, 1
        je first_mode                       ; non_parallel_dot
        
        cmp rax, 2
        je second_mode                      ; parallel_dot

        cmp rax, 3
        je third_mode                       ; non parallel multiplication

        cmp rax, 4          
        je forth_mode                       ; parallel multiplication

        cmp rax, 5          
        je fifth_mode                       ; convolution

        call invalid                        ; bad input
        jmp end


        first_mode:
            call get_inputs                 ; get matrixes and their sizes
            mov eax, [size1]
            cmp eax, [size2]                ; in dotting, sizes must be equal
            jne invalid_main                ; terminate the program if the inputs were invalid

            mov rbx, 0                      ; set the beginning index for dotting (up left index)
            call non_parallel_dot           ; call selected function

            mov edi, eax
            call print_float                ; print the stored result from eax
            call print_nl
            jmp end                         ; end program

        second_mode:
            call get_inputs                 ; get matrixes and their sizes
            mov eax, [size1]
            cmp eax, [size2]                ; in dotting, sizes must be equal
            jne invalid_main                ; terminate the program if the inputs were invalid

            mov rbx, 0                      ; set the beginning index for dotting (up left index)
            call parallel_dot               ; call selected function

            mov edi, eax
            call print_float                ; print the stored result from eax
            call print_nl
            jmp end                         ; end program

        third_mode:
            call get_inputs                 ; get matrixes and their sizes
            mov eax, [size1]
            cmp eax, [size2]                ; in square matrix multiplying, sizes must be equal
            jne invalid_main                ; terminate the program if the inputs were invalid

            mov r13, [loop_counter]                ; set a loop for getting comparable runtime
            loop3:
                call non_parallel_mult      ; call selected function
                dec r13
                cmp r13, 0
                jg loop3
            
            call print_result_matrix        ; print the result matrix stored in memory
            jmp end                         ; end program

        forth_mode:
            call get_inputs                 ; get matrixes and their sizes
            mov eax, [size1]
            cmp eax, [size2]                ; in square matrix multiplying, sizes must be equal
            jne invalid_main                ; terminate the program if the inputs were invalid

            call inverse_matrix_2           ; calculate the transposed of matrix2 and stored it in itself 

            mov r13, [loop_counter]                 ; set a loop for getting comparable runtime
            loop4:
                call parallel_mult          ; call selected function
                dec r13
                cmp r13, 0
                jg loop4
            
            call print_result_matrix        ; print the result matrix stored in memory
            jmp end                         ; end program

        fifth_mode:
            call get_inputs                 ; get matrixes and their sizes
            mov eax, [size1]
            cmp eax, [size2]                ; in convolution, filter matrix's size must be smaller than the main matrix
            jl invalid_main                 ; terminate the program if the inputs were invalid

            mov r13, [loop_counter]                ; set a loop for getting comparable runtime
            loop5:
                call convolution            ; call selected function
                dec r13
                cmp r13, 0
                jg loop5
            
            call print_result_matrix        ; print the result matrix stored in memory
            jmp end                         ; end program

        invalid_main:
            call invalid                    ; terminate the program if the inputs were invalid
            
        end:
            add rsp, 8                      ; stack alignment

            pop r15                         ; prolog
            pop r14
            pop r13
            pop r12
            pop rbx
            pop rbp

            ret


    get_inputs:
        push rbp                            ; preLog
        push rbx
        push r12
        push r13
        push r14
        push r15

        sub rsp, 8                          ; stack alignment
   
        mov rdi, enter_size                 ; print enter_size dialogue
        call printf

        call read_int                       ; read first matrix's size
        cmp r10, 0                          ; input must be integer
        je invalid_input                    ; terminate the program if the inputs were invalid
        cmp eax, 8                          ; sizes must be under 8
        jg invalid_input                    ; terminate the program if the inputs were invalid
        cmp eax, 1                          ; sizes must be above 0
        jl invalid_input                    ; terminate the program if the inputs were invalid
        mov [size1], eax                    ; store the size in memory

        call read_int                       ; read second matrix's size
        cmp r10, 0                          ; input must be integer
        je invalid_input                    ; terminate the program if the inputs were invalid
        cmp eax, 8                          ; sizes must be under 8
        jg invalid_input                    ; terminate the program if the inputs were invalid
        cmp eax, 1                          ; sizes must be above 0
        jl invalid_input                    ; terminate the program if the inputs were invalid
        mov [size2], eax                    ; store the size in memory

        mov rdi, enter_matrix1              ; print enterMatrix1 dialogue
        call printf

        xor r12, r12            ; row index
        xor r13, r13            ; inner (column) index
        xor r15, r15            ; temp var
        xor rbx, rbx            ; size
        mov ebx, [size1]                    ; store size from memory to rbx
        get_matrix_1:
            xor r13, r13                    ; column index = 0
            in_get_matrix_1:
                call read_float             ; get input from user
                cmp r10, 0                  ; input must be integer
                je invalid_input            ; terminate the program if the inputs were invalid
                mov r15, r12
                add r15, r13                ; calculate current index's offset -> r15 = matrix_row_size * row + column
                mov [matrix1 + r15], eax    ; store input in current index

                add r13, 4                  ; r13 (column index) += 4    *{sizeof(float) = 4byte}
                mov r15, rbx
                imul r15, 4                 ; turn size of matrix into address format   *{size_of_matrix * sizeof(float)}
                cmp r13, r15                ; compare current index in row (column index) with size of matrix
                jl in_get_matrix_1
            
            add r12, matrix_row_size        ; r12 (row index) += matrix_row_size    *{matrix_row_size = 8*sizeof(float)} {sizeof(float) = 4byte}
            mov r15, rbx
            imul r15, matrix_row_size       ; turn size of matrix into address format   *{size_of_matrix * matrix_row_size}
            cmp r12, r15                    ; compare current row index with size of matrix
            jl get_matrix_1

        mov rdi, enter_matrix2              ; repeat exact functionality for matrix 2
        call printf

        xor r12, r12            ; row
        xor r13, r13            ; inner (column) index
        xor r15, r15            ; temp
        xor rbx, rbx            ; size
        mov ebx, [size2]  
        get_matrix_2:
            xor r13, r13
            in_get_matrix_2:
                call read_float
                cmp r10, 0      
                je invalid_input
                mov r15, r12
                add r15, r13
                mov [matrix2 + r15], eax

                add r13, 4
                mov r15, rbx
                imul r15, 4
                cmp r13, r15
                jl in_get_matrix_2
            
            add r12, matrix_row_size
            mov r15, rbx
            imul r15, matrix_row_size
            cmp r12, r15
            jl get_matrix_2
        
        jmp end_input
            
        invalid_input:
            call invalid                    ; terminate the program if the inputs were invalid

        end_input:
            add rsp,8                       ; stack alignment

            pop r15                         ; prolog
            pop r14
            pop r13
            pop r12
            pop rbx
            pop rbp

            ret

    print_result_matrix:
        push rbp                            ; preLog
        push rbx
        push r12
        push r13
        push r14
        push r15

        sub rsp, 8                          ; stack alignment


        mov eax, [result_size]              ; read the size of result matrix from memory

        mov r12, rax            ; r12 -> size
        xor r13, r13            ; r13 -> row index
        xor r14, r14            ; r14 -> column index
        print_loop:
            xor r14, r14                    ; column index = 0
            print_row:
                mov r15, r13                
                imul r15, matrix_row_size   ; row_index * matrix_row_size
                mov rbx, r14
                imul rbx, 4                 ; column_index * sizeof(float)
                add r15, rbx                ; calculate current index's offset -> row_index * matrix_row_size + column_index * sizeof(float)

                mov edi, result_matrix[r15]
                call print_float            ; print current index from result matrix

                inc r14
                cmp r14, r12                ; compare column index with size of result matrix
                jl print_row
            
            call print_nl
            inc r13
            cmp r13, r12                    ; compare row index with size of result matrix
            jl print_loop
        
        add rsp,8                           ; stack alignment

        pop r15                             ; prolog
        pop r14
        pop r13
        pop r12
        pop rbx
        pop rbp

        ret

    non_parallel_dot:
        push rbp                                ; preLog
        push rbx
        push r12
        push r13
        push r14
        push r15

        sub rsp, 8                              ; stack alignment

        mov r12, rax            ; r12 -> size for dot,
                                ; rbx -> base offset address,
                                ; r13, r14 -> row and column offset address,
                                ; r15 -> temp
                                
        xor r13, r13                            ; set the row offset address to 0
        pxor xmm0, xmm0                         ; set the result to 0

        dotting1:
            xor r14, r14                        ; set the column offset address to 0
            dotting2:
                mov r15, rbx                    ; base (offset address)
                add r15, r13                    ; row (offset address)
                add r15, r14                    ; calculate the current offset address -> row (offset address) + column (offset address) + base (offset address)

                movss xmm1, [matrix1 + r15]     ; load the index from matrix1
                movss xmm2, [matrix2 + r15]     ; load the index from matrix2
                mulss xmm1, xmm2                ; matrix1[i][j] * matrix2[i][j]
                addss xmm0, xmm1                ; add the answer to result var

                add r14, 4                      ; column offset address += sizeof(float) [= 4 byte]
                mov r15, r12
                imul r15, 4                     ; calculate the address form of dot-size -> dot-size * sizeof(float)
                cmp r14, r15                    ; compare column index with matrix size
                jl dotting2

            add r13, matrix_row_size            ; row offset address += matrix_row_size [= 8 * sizeof(float)]
            mov r15, r12
            imul r15, matrix_row_size           ; calculate the address form of dot-size -> dot-size * matrix_row_size
            cmp r13, r15                        ; compare column index with matrix size
            jl dotting1

        movd eax, xmm0                          ; store final answer in eax register  (return value)

        add rsp,8                               ; stack alignment

        pop r15                                 ; prolog
        pop r14
        pop r13
        pop r12
        pop rbx
        pop rbp
        
        ret

    parallel_dot:
        push rbp                                ; preLog
        push rbx
        push r12
        push r13
        push r14
        push r15

        sub rsp, 8                              ; stack alignment

        mov r12, rax            ; r12 -> size for dot,
                                ; rbx -> base offset address,
                                ; r13 -> row counter,
                                ; r15 -> temp

        xor r13, r13                            ; zero the row counter
        pxor xmm9, xmm9                         ; zero the result

        dot:
            mov r15, r13
            imul r15, matrix_row_size           ; calculate the row offset address -> row counter * matrix_row_size

            movups xmm3, matrix2[r15]           ; get the first half of matrix2's row
            add r15, matrix_half_row_size
            movups xmm4, matrix2[r15]           ; get the second half of matrix2's row

            movups xmm1, matrix1[rbx]           ; load first 4 bytes from base offset address
            add rbx, matrix_half_row_size       ; base offset += 4 * 4 bytes (matrix_half_row_size)
            movups xmm2, matrix1[rbx]           ; load second 4 bytes from base offset address
            add rbx, matrix_half_row_size       ; base offset += 4 * 4 bytes (matrix_half_row_size)

            dpps xmm3, xmm1, 0xF1               ; dot the first halfs
            dpps xmm4, xmm2, 0xF1               ; dot the second halfs
            addps xmm4, xmm3                    ; get sum of two halfs' dot
            addss xmm9, xmm4                    ; add sum to total result
            
            inc r13
            cmp r13, r12                        ; compare with dot-size
            jl dot
        
        movd eax, xmm9                          ; return result 
    
        add rsp,8               ; stack alignment

        pop r15
        pop r14
        pop r13
        pop r12
        pop rbx
        pop rbp

        ret

    non_parallel_mult:
        push rbp                                ; preLog
        push rbx
        push r12
        push r13
        push r14
        push r15

        sub rsp, 8                              ; stack alignment

        mov [result_size], eax                  ; set the output matrix size equal to input matrix's size

        mov r12, rax            ; r12 -> size,
        xor rbp, rbp            ; rbp -> row index
        xor rbx, rbx            ; rbx -> column index
        xor r13, r13            ; r13 -> counter,
                                ; r14 , r15 -> temp
        row_change:
            xor rbx, rbx                        ; set column index to 0
            column_change:
                pxor xmm3, xmm3                 ; reset the result xmm register
                xor r13, r13                    ; reset the multiplication counter
                mult:
                    mov r15, rbp
                    imul r15, matrix_row_size   ; row_index * matrix_row_size
                    mov r14, r13
                    imul r14, 4                 ; counter * sizeof(float)
                    add r15, r14                ; calculate current index's offset from matrix1 -> row_index * matrix_row_size + counter * sizeof(float)    *{retreive [i, k] index}
                    movss xmm1, matrix1[r15]    ; load the matrix one index to xmm1

                    mov r15, r13
                    imul r15, matrix_row_size   ; counter * matrix_row_size
                    mov r14, rbx
                    imul r14, 4                 ; column_index * sizeof(float)
                    add r15, r14                ; calculate current index's offset from matrix2 -> counter * matrix_row_size + column_index * sizeof(float)    *{retreive [k, j] index}
                    movss xmm2, matrix2[r15]    ; load the matrix two index to xmm2

                    mulss xmm1, xmm2            ; matrix1[i][k] * matrix2[k][j]     *{i=row_index  j=column_index  k=counter}
                    addss xmm3, xmm1            ; add the previous ans to total result

                    inc r13
                    cmp r13, r12                ; compare multiplication counter with matrix size
                    jl mult
                
                mov r15, rbp
                imul r15, matrix_row_size       ; row_index * matrix_row_size
                mov r14, rbx
                imul r14, 4                     ; column_index * sizeof(float)
                add r15, r14                    ; calculate current result index's offset -> row_index * matrix_row_size + column_index * sizeof(float)
                movd result_matrix[r15], xmm3   ; store result in [i, j] index of result matrix in memory

                inc rbx
                cmp rbx, r12                    ; compare column index with matrix size
                jl column_change

            inc rbp
            cmp rbp, r12                        ; compare row index with matrix size
            jl row_change

        add rsp,8                               ; stack alignment

        pop r15                                 ; prolog
        pop r14
        pop r13
        pop r12
        pop rbx
        pop rbp

        ret

    parallel_mult:
        push rbp                            ; preLog
        push rbx
        push r12
        push r13
        push r14
        push r15

        sub rsp, 8                          ; stack alignment

        mov eax, [size1]
        mov [result_size], eax              ; store the output size (that is equal to input size) in memory

        mov r12, rax            ; r12 -> size,
        xor rbp, rbp            ; rbp -> row index
        xor rbx, rbx            ; rbx -> column index
                                ; r14 , r15 -> temp

        row_loop:
            xor rbx, rbx
            mov r14, rbp
            imul r14, matrix_row_size       ; calculate the offset address of first element of the row from first matrix (rbp == index)  -> row_index * matrix_row_size
            movups xmm1, matrix1[r14]       ; store the first half of the row in xmm1
            add r14, matrix_half_row_size   ; calculate the offset address of first element of the second half of row
            movups xmm2, matrix1[r14]       ; store the second half of the row in xmm2

            column_loop:
                mov r15, rbx
                imul r15, matrix_row_size   ; calculate the offset address of first element of the column from second matrix (rbx == index)  -> column_index * matrix_row_size
                                            ; actually we are calculating the offset address of the first element of the row from traposed form of matrix two
                movups xmm3, matrix2[r15]   ; store the first half of the column in xmm3
                add r15, matrix_half_row_size   ; calculate the offset address of first element of the second half of column
                movups xmm4, matrix2[r15]   ; store the second half of the column in xmm4

                dpps xmm3, xmm1, 0xF1       ; dot the first halfs and store it in first 4 byte of xmm3
                dpps xmm4, xmm2, 0xF1       ; dot the second halfs and store it in first 4 byte of xmm4
                addps xmm4, xmm3            ; add the previous results and store it in first 4 byte of xmm4

                mov r14, rbp
                imul r14, matrix_row_size       ; row_index * matrix_row_size
                mov r15, rbx
                imul r15, 4                     ; column_index * sizeof(float)
                add r15, r14                    ; calculate current index's offset -> row_index * matrix_row_size + column_index * sizeof(float)
                movd result_matrix[r15], xmm4   ; move the final result from first 4 byte of xmm4 to memory

                inc rbx
                cmp rbx, r12                ; compare column index with matrix's size
                jl column_loop
            
            inc rbp
            cmp rbp, r12                    ; compare row index with matrix's size
            jl row_loop
           
        add rsp, 8                          ; stack alignment

        pop r15
        pop r14
        pop r13
        pop r12
        pop rbx
        pop rbp

        ret

    convolution:
        push rbp                            ; preLog
        push rbx
        push r12
        push r13
        push r14
        push r15

        sub rsp, 8                          ; stack alignment
      
        mov eax, [size1]                    ; n
        mov ebx, [size2]                    ; m
        inc eax                             ; +1
        sub eax, ebx                        ; calculate size of output of convolution function = n - m + 1

        mov [result_size], eax              ; store output size in memory

        mov r12, rax            ; r12 -> size,
        xor rbp, rbp            ; rbp -> row index
        xor r13, r13            ; r13 -> column index
                                ; rbx -> base index
                                ; r14 , r15 -> temp

        conv_row:
            xor r13, r13                    ; column index = 0
            conv_column:
                mov r14, rbp
                mov r15, r13
                imul r14, matrix_row_size   ; row_index * matrix_row_size
                imul r15, 4                 ; column_index * sizeof(float)
                add r15, r14                ; calculate current index's offset -> row_index * matrix_row_size + column_index * sizeof(float)

                mov rbx, r15                ; pass base index input to parallel_dot
                mov rax, r12                ; pass size of filter input to parallel_dot
                call parallel_dot           ; dot filter matrix with its picture on main matrix with calculated base index (upper left index of picture)

                mov result_matrix[r15], eax ; store dot output in result matrix

                inc r13
                cmp r13, r12                ; compare column index with matrix's size
                jl conv_column
            
            inc rbp
            cmp rbp, r12                    ; compare row index with matrix's size
            jl conv_row
            
        add rsp, 8                          ; stack alignment

        pop r15                             ; prolog
        pop r14
        pop r13
        pop r12
        pop rbx
        pop rbp

        ret
    
    inverse_matrix_2:
        push rbp                            ; preLog
        push rbx
        push r12
        push r13
        push r14
        push r15

        sub rsp, 8                          ; stack alignment

        xor rcx, rcx
        mov ecx, [size2]        ; rcx -> size
        mov r12, 0              ; r12 -> row index

        transpose_loop:
            mov r13, r12        ; r13 -> column index
            inc r13                         ; start from [i, i+1]

            transpose_inner_loop:
                mov r14, r12
                mov r15, r13
                imul r14, matrix_row_size   ; i = row_index * matrix_row_size
                imul r15, 4                 ; j = column_index * sizeof(float)
                add r14, r15                ; calculate source index's offset -> i + j       *{[i,j] index}
                mov ebx, matrix2[r14]       ; store source in ebx

                mov r14, r12
                mov r15, r13
                imul r14, 4                 ; i = row_index * sizeof(float)
                imul r15, matrix_row_size   ; j = column_index * matrix_row_size
                add r14, r15                ; calculate destination index's offset -> i + j       *{[j,i] index}
                mov ebp, matrix2[r14]       ; store destination in ebp
                mov matrix2[r14], ebx       ; store source in destination index

                mov r14, r12
                mov r15, r13
                imul r14, matrix_row_size   ; i = row_index * matrix_row_size
                imul r15, 4                 ; j = column_index * sizeof(float)
                add r14, r15                ; calculate source index's offset -> i + j       *{[i,j] index}
                mov matrix2[r14], ebp       ; store destination in source index

                inc r13
                cmp r13, rcx                ; compare column index with matrix's size
                jl transpose_inner_loop

            inc r12
            cmp r12, rcx                    ; compare row index with matrix's size
            jl transpose_loop
        
        add rsp, 8                          ; stack alignment

        pop r15                             ; prolog
        pop r14
        pop r13
        pop r12
        pop rbx
        pop rbp

        ret



    invalid:
        sub rsp, 8                          ; stack alignment

        mov rdi, invalid_input_frmt         ; print invalid input dialogue
        call printf
        
        mov rax, 60                         ; syscall number for exit
        xor rdi, rdi                        ; exit code 0
        syscall                             ; terminate

        add rsp,8                           ; stack alignment

        ret


; -------------------- debugging codes -----------------------

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

; mov eax, [size1]
; mov r12, rax
; xor r13, r13
; xor r14, r14
; print_loop2:
;     xor r14, r14
;     print_row2:
;         mov r15, r13
;         imul r15, matrix_row_size
;         mov rbx, r14
;         imul rbx, 4
;         add r15, rbx

;         mov edi, matrix2[r15]
;         call print_float

;         inc r14
;         cmp r14, r12
;         jl print_row2
    
;     call print_nl
;     inc r13
;     cmp r13, r12
;     jl print_loop2
; call print_nl