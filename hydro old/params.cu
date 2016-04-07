#include "params.h"
//#include "definitions.h"
#include <math.h>
#include <stdlib.h>

float *x;
float *y;
float *Vx;
float *Vy;
float *ax;
float *ay;


extern "C" void InitData()
{
    int numBytes = NumP*sizeof(float);
  gpuErrchk(cudaHostAlloc((void**)&x,numBytes,
  cudaHostAllocWriteCombined | cudaHostAllocMapped ));
  gpuErrchk(cudaHostAlloc((void**)&y,numBytes,
  cudaHostAllocWriteCombined | cudaHostAllocMapped ));
  gpuErrchk(cudaHostAlloc((void**)&Vx,numBytes,
  cudaHostAllocWriteCombined | cudaHostAllocMapped ));
  gpuErrchk(cudaHostAlloc((void**)&Vy,numBytes,
  cudaHostAllocWriteCombined | cudaHostAllocMapped ));
  gpuErrchk(cudaHostAlloc((void**)&ax,numBytes,
  cudaHostAllocWriteCombined | cudaHostAllocMapped ));
  gpuErrchk(cudaHostAlloc((void**)&ay,numBytes,
  cudaHostAllocWriteCombined | cudaHostAllocMapped ));

  int i;
  for (i=0; i<NumP; i++)
  {
    do
    {
       x[i] = lbound + (rbound - lbound)*rand()/RAND_MAX;
       y[i] = bbound + (tbound - bbound)*rand()/RAND_MAX;
    } while(( x[i]- circX)*( x[i]- circX)+
  ( y[i]-circY)*( y[i]-circY)<circR*circR);
     Vx[i] = initVx;
     Vy[i] = initVy;
     ax[i] = initax;
     ay[i] = initay;
  }
}
