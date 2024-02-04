void my_main();

int main() {
  my_main();
  
  return 0;
}




// #include <stdio.h>
// #include <stdlib.h>

// float *my_main(int mode, int *sizes, float *matrix1, float *matrix2);

// int main() {
//     int mode = 0;
//     int *sizes = malloc(sizeof(int) * 2);
//     float *matrix1, *matrix2;

//     printf("Choose the mode:\n1 -> non parallel matrix dot\n2 -> parallel matrix dot\n");
//     printf("3 -> non parallel matrix multiplication\n4 -> parallel matrix multiplication\n");
//     printf("5 -> non parallel convolution\n6 -> parallel convolution\n");

//     scanf("%d", &mode);

//     printf("Enter the matrixes sizes:\n");
//     scanf("%d", &sizes[0]);
//     scanf("%d", &sizes[1]);

//     matrix1 = malloc(sizeof(int) * sizes[0] * sizes[0]);
//     matrix2 = malloc(sizeof(int) * sizes[1] * sizes[1]);

//     for (int i = 0; i < sizes[0] * sizes[0]; i++)
//         scanf("%f", &matrix1[i]);
//     for (int i = 0; i < sizes[1] * sizes[1]; i++)
//         scanf("%f", &matrix2[i]);

//     switch (mode) {
//         case 1:
//         case 2:
//         case 3:
//         case 4:
//             if (sizes[0] != sizes[1]) {
//                 printf("Invalid input!\n");
//                 return 0;
//             }
//             break;

//         case 5:
//         case 6:
//             if (sizes[0] < sizes[1]) {
//                 printf("Invalid input!\n");
//                 return 0;
//             }
//             break;

//         default:
//             printf("Invalid input!\n");
//             return 0;
//     }

//     float *result;
//     result = my_main(mode, sizes, matrix1, matrix2);

//     if (mode == 1 || mode == 2) printf("%.5f", result[0]);
//     else if (mode == 3 || mode == 4) {
//         for (int i = 0; i < sizes[0]; i++) {
//             for (int j = 0; j < sizes[0]; j++) {
//                 printf("%6.3f ", result[i * sizes[0] + j]);
//             }
//             printf("\n");
//         }
//     } else {
//         for (int i = 0; i < sizes[0] - sizes[1] + 1; i++) {
//             for (int j = 0; j < sizes[0] - sizes[1] + 1; j++) {
//                 printf("%6.3f ", result[i * (sizes[0] - sizes[1] + 1) + j]);
//             }
//             printf("\n");
//         }
//     }

//     return 0;
// }
