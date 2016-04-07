#pragma once
#include <cuda_runtime_api.h>
#include <stdbool.h>
#include <stdio.h>
#define NumP 512*10

#define circX 400.0f
#define circY 300.0f
#define circR 50.0f

#define lbound 200.0f
#define rbound 600.0f
#define bbound 100.0f
#define tbound 500.0f

#define initVx 0.0f
#define initVy -30.0f
#define initax 0.0f
#define initay -0.0f

#define Timestep 0.01f
#define effrad 100.0f
#define pressure 70.0f

#define gpuErrchk(ans) { gpuAssert((ans)); }
inline void gpuAssert(cudaError_t code)
{
   if (code != cudaSuccess)
   {
      fprintf(stderr,"GPUassert: %s\n", cudaGetErrorString(code));

   }
}
