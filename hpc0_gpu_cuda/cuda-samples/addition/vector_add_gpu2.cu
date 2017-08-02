// SDSC Summer Institute 2017
// Andreas Goetz (agoetz@sdsc.edu)

// CUDA program to add two vectors in parallel on the GPU
// version 2:
// launch a fixed number of blocks and threads
//

#include<stdio.h>

// define vector length, number of blocks NBL and threads per block TPB
#define N (255*2047)
#define NBL 256
#define TPB 128

//
// CUDA device function that adds two integer vectors
//
__global__ void add(int *a, int *b, int *c, int n){

  int tid = threadIdx.x + blockIdx.x * blockDim.x;
  int stride = gridDim.x * blockDim.x;

  while (tid < n) {
    c[tid] = a[tid] + b[tid];
    tid += stride;
  }

}

//
// main program
//
int main(void){

  int h_a[N], h_b[N], h_c[N];
  int *d_a, *d_b, *d_c;
  int size = N * sizeof(int);
  int i, err;

  // allocate device memory
  cudaMalloc((void **)&d_a, size);
  cudaMalloc((void **)&d_b, size);
  cudaMalloc((void **)&d_c, size);

  // initialize vectors
  for (i=0; i<N; i++){
    h_a[i] = i+1;
    h_b[i] = i+1;
  }

  // copy input data to device
  cudaMemcpy(d_a, h_a, size, cudaMemcpyHostToDevice);
  cudaMemcpy(d_b, h_b, size, cudaMemcpyHostToDevice);

  // add vectors by launching a sufficient number of blocks of the add() kernel
  printf("\nLaunching vector addition kernel...\n");
  printf("Vector length     = %d\n",N);
  printf("Blocks            = %d\n",NBL);
  printf("Threads per block = %d\n",TPB);
  printf("Kernel copies     = %d\n",NBL*TPB);
  add<<<NBL,TPB>>>(d_a, d_b, d_c, N);

  // copy results back to host
  cudaMemcpy(h_c, d_c, size, cudaMemcpyDeviceToHost);

  // deallocate memory
  cudaFree(d_a);
  cudaFree(d_b);
  cudaFree(d_c);

  // check results
  err = 0;
  for (i=0; i<N; i++){
    if (h_c[i] != 2*(i+1)) err = 1;
  }
  if (err != 0){
    printf("\n Error, %d elements do not match!\n\n", err);
  } else {
    printf("\n Success! All elements match.\n\n");
  }

  return 0;

}
