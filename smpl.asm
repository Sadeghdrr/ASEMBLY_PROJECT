section .data
    mask_values dd 0xFFFFFFFF, 0xFFFFFFFF, 0x00000000, 0x00000000  ; Mask for vblendps
    valv db 0

section .text
global my_main
extern printf

my_main:
    ; Load source vectors into YMM registers
    vmovups ymm1, [source_vector1]
    vmovups ymm2, [source_vector2]

    ; Load the mask into XMM register
    vmovaps xmm3, [mask_values]

    ; Blend the elements based on the mask
    mov [valv], byte 64
    vblendps ymm3, ymm1, ymm2, 0b11000000

    ; Display the result
    vmovups [result_vector], ymm3
    mov rdi, result_format
    vmovups [result_vector], ymm3
    call printf

    ; Exit the program
    mov eax, 0
    ret

section .data
    source_vector1 dq 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0   ; Source vector 1
    source_vector2 dq 10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0  ; Source vector 2
    result_vector dq 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0   ; Result vector
    result_format db "Result: %f, %f, %f, %f, %f, %f, %f, %f", 10, 0  ; Format string for printf
