from PIL import Image
import numpy as np
import subprocess

filter = []
filter_size = 0
filter_str = ""
final_matrix = []
lines = []
chunck_size = 0
height = 0
width = 0

def image_proccess(image_path):
    global height, width, filter, filter_size, filter_str, final_matrix, chunck_size, lines
    image = np.array(Image.open(image_path).convert('L'))
    height = image.shape[0]
    width = image.shape[1]

    for i in range(0, height, chunck_size):
        for j in range(0, width, chunck_size):
            if i + 8 < height and j + 8 < width:
                matrix = image[i:i + 8, j:j + 8]
                matrix_str = '\n'.join([' '.join(map(str, row)) for row in matrix])

                input_str = f"5\n8 {filter_size}\n{matrix_str}\n{filter_str}\n"

                process = subprocess.Popen(['./project_no_extra_print'],
                                            stdin=subprocess.PIPE,
                                            stdout=subprocess.PIPE,
                                            stderr=subprocess.PIPE,
                                            shell=True)
                output, error = process.communicate(input=input_str.encode())

                output_lines = output.decode().splitlines()
                lines.extend(output_lines)

def make_matrix():
    global height, width, filter, filter_size, filter_str, final_matrix, chunck_size, lines

    for i in range(height // chunck_size):
        for j in range(chunck_size):
            row = []
            for k in range (width // chunck_size):
                try:
                    partail_row = [float(x) for x in lines[i * chunck_size * (width // chunck_size) + j + k * chunck_size].strip().split()]
                except:
                    pass
                row.extend(partail_row)
            final_matrix.append(row)
            

def make_changed_image(image_path):
    global height, width, filter, filter_size, filter_str, final_matrix, chunck_size, lines
    
    matrix_array = np.array(final_matrix)
    image = Image.fromarray(matrix_array.astype('uint8'))
    image.save(image_dest_path)

if __name__ == "__main__":
    filter_size = int(input("Enter filter matrix size:\n"))
    if filter_size > 8:
        print("Invalid input")
    else:
        filter = [[0] * filter_size for _ in range(filter_size)]
        chunck_size = 8 - filter_size + 1
        print("Enter matrix one:")
        for i in range(filter_size):
            filter[i] = list(map(float, input().split()))

        filter_str = '\n'.join([' '.join(map(str, row)) for row in filter])  # Convert matrix to string

        image_src_path = 'xmpl.jpg'
        image_proccess(image_src_path)
        make_matrix()
        image_dest_path = 'result.jpg'
        make_changed_image(image_dest_path)
