import numpy as np
import time

def mult_matrix():
    size = int(input("Enter matrix size (upto 8) (only one input, because n*n mult):\n"))
    if size > 8:
        print("Invalid input")
        return

    matrix1 = [[0] * size for _ in range(size)]
    matrix2 = [[0] * size for _ in range(size)]

    print("Enter matrix one:")
    for i in range(size):
        matrix1[i] = list(map(float, input().split()))

    print("Enter matrix two:")
    for i in range(size):
        matrix2[i] = list(map(float, input().split()))

    loop_counter = 100000
    result = [[0] * size for _ in range(size)]

    for o in range(loop_counter):
        for i in range(size):
            for j in range(size):
                temp = 0
                for k in range(size):
                    temp += matrix1[i][k] * matrix2[k][j]
                result[i][j] = temp

    for i in range(size):
        for j in range(size):
            print("{:.3f}".format(result[i][j]), end=" ")
        print()

def convolution():
    size1, size2 = map(int, input("Enter matrix sizes (upto 8) (two input):\n").split())
    if size1 > 8 or size2 > 8 or size1 < size2:
        print("Invalid input")
        return

    matrix1 = [[0] * size1 for _ in range(size1)]
    matrix2 = [[0] * size2 for _ in range(size2)]

    print("Enter matrix one:")
    for i in range(size1):
        matrix1[i] = list(map(float, input().split()))

    print("Enter matrix two:")
    for i in range(size2):
        matrix2[i] = list(map(float, input().split()))

    loop_counter = 100000
    size3 = size1 + 1 - size2
    result = [[0] * size3 for _ in range(size3)]
    tmp_vec1 = [0] * (size2 * size2)
    tmp_vec2 = [0] * (size2 * size2)

    for o in range(loop_counter):
        for i in range(size3):
            for j in range(size3):
                for k in range(size2):
                    for l in range(size2):
                        tmp_vec1[size2 * k + l] = matrix1[i + k][j + l]
                
                for k in range(size2):
                    for l in range(size2):
                        tmp_vec2[k * size2 + l] = matrix2[k][l]
                
                temp = 0
                for k in range(size2 * size2):
                    temp += tmp_vec1[k] * tmp_vec2[k]
                result[i][j] = temp

    for i in range(size3):
        for j in range(size3):
            print("{:.3f}".format(result[i][j]), end=" ")
        print()


if __name__ == "__main__":
    choice = int(input("Choose what you want to do:\n1 -> Matrix Multiplication\n2 -> Matrix Convolution\n"))
    
    start_time = time.time()
    if choice == 1:
        mult_matrix()
    elif choice == 2:
        convolution()
    else:
        print("Invalid Input")
    print("Runtime: {:.6f} seconds".format(time.time() - start_time))
