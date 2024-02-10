from PIL import Image
import numpy as np
import subprocess

filter = []
filter_size = 0
filter_str = ""
final_matrix = []
chunck_size = 0
height = 0
width = 0

def image_proccess(image_path):
    global height, width, filter, filter_size, filter_str, final_matrix, chunck_size
    image = np.array(Image.open(image_path).convert('L'))                                   # Open and convert image to grayscale
    height = image.shape[0]
    width = image.shape[1]
    open('result.txt', 'w').close()

    for i in range(0, height, chunck_size):
        for j in range(0, width, chunck_size):
            if i+8 < height and j+8 < width:
                matrix = image[i:i+8, j:j+8]                                            # Extract 8x8 matrix
                matrix_str = '\n'.join([' '.join(map(str, row)) for row in matrix])     # Convert matrix to string
                input_file = open('input.txt', 'w')
                input_file.write(f"5\n8 {filter_size}\n{matrix_str}\n{filter_str}\n")     # Write matrix to file
                input_file.close()
                run_project()

def make_matrix():
    global height, width, filter, filter_size, filter_str, final_matrix, chunck_size

    with open('result.txt', 'r') as result:
        lines = result.readlines()

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
    global height, width, filter, filter_size, filter_str, final_matrix, chunck_size
    
    matrix_array = np.array(final_matrix)
    image = Image.fromarray(matrix_array.astype('uint8'))
    image.save(image_dest_path)

# Run the executable file "./project_no_extra_print" with input.txt and append output to result.txt
def run_project():
    subprocess.run(['./project_no_extra_print'], stdin=open('input.txt', 'r'), stdout=open('result.txt', 'a'), shell=True)

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
