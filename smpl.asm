section .data
    vector1 dq 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0  ; First 8D vector
    vector2 dq 8.0, 7.0, 6.0, 5.0, 4.0, 3.0, 2.0, 1.0  ; Second 8D vector
    format_string db "Dot Product: %lf", 10, 0

section .text
    global my_main
    extern printf

my_main:
    sub rsp, 8               ; Stack alignment

    ; Load the vectors into YMM registers
    vmovupd ymm0, [vector1]
    vmovupd ymm1, [vector2]

    ; Multiply the corresponding elements of the vectors
    vmulpd ymm2, ymm0, ymm1

    ; Add the elements horizontally
    vhaddpd ymm2, ymm2, ymm2
    vhaddpd ymm2, ymm2, ymm2

    ; Display the dot product
    mov rdi, format_string
    vextractf128 xmm3, ymm2, 1  ; Extract the result to XMM register
    vcvtpd2ps xmm3, xmm3        ; Convert to float
    call printf

    add rsp, 8               ; Restore the stack pointer
    ret
