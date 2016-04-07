#include "params.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <cuda_profiler_api.h>

__global__
void accelerate(
  float *devx,
  float *devy,
  float *devVx,
  float *devVy,
  float *devax,
  float *devay)
  {
    int i = threadIdx.x+blockIdx.x*blockDim.x;
    int j = 0;
    float dist;
    devax[i] = initax;
    devay[i] = initay;
    for (j = 0; j<NumP; j++)
      if (i!=j)
      {
        dist = (devx[i]-devx[j])*(devx[i]-devx[j])
        +(devy[i]-devy[j])*(devy[i]-devy[j]);
        if (dist<effrad)
        {
          devax[i] = devax[i]+pressure*(devx[i]-devx[j])/dist;
          devay[i] = devay[i]+pressure*(devy[i]-devy[j])/dist;
        }
      }
  }

__global__
void newcoord(
  float *devx,
  float *devy,
  float *devVx,
  float *devVy,
  float *devax,
  float *devay)
  {
    float r,a,b,rx,ry;

    int i = threadIdx.x+blockIdx.x*blockDim.x;

    devx[i] = devx[i]+devVx[i]*Timestep+
                  devax[i]*Timestep*Timestep/2.0;
    devy[i] = devy[i]+devVy[i]*Timestep+
                  devay[i]*Timestep*Timestep/2.0;
    devVx[i] = devVx[i] + devax[i]*Timestep;
    devVy[i] = devVy[i] + devay[i]*Timestep;
    if (devy[i] < bbound)
        {
            // Vy[i] = -Vy[i];
            devy[i] = tbound;
            devVx[i] = initVx;//5.0*rand()/RAND_MAX;
            devVy[i] = initVy;
        }
      if (devy[i] > tbound)
           devVy[i] = -devVy[i];
      if ((devx[i] > rbound) || (devx[i] < lbound))
        {
          devVx[i] = -devVx[i];
        }
      if ((devx[i]-circX)*(devx[i]-circX)+
      (devy[i]-circY)*(devy[i]-circY)<circR*circR)
      {
          rx=devx[i]-circX;
          ry=devy[i]-circY;
          r = rx*rx+ry*ry;
          a = devVx[i]*ry-devVy[i]*rx;
          b = devVx[i]*rx+devVy[i]*ry;

          devVy[i] = -((a*rx+b*ry)/r);
          devVx[i] = a/ry + (rx/ry)*devVy[i];
      }
  }

extern "C" void Step()
{
  float *devx;
  float *devy;
  float *devVx;
  float *devVy;
  float *devax;
  float *devay;

  float *circx;
  float *circy;
  float *circr;

cudaProfilerStart();
  int numBytes = NumP*sizeof(float);
  cudaMalloc((void**)&devx, numBytes);
  cudaMalloc((void**)&devy, numBytes);
  cudaMalloc((void**)&devVx, numBytes);
  cudaMalloc((void**)&devVy, numBytes);
  cudaMalloc((void**)&devax, numBytes);
  cudaMalloc((void**)&devay, numBytes);
  cudaMalloc((void**)&circx, sizeof(float));
  cudaMalloc((void**)&circy, sizeof(float));
  cudaMalloc((void**)&circr, sizeof(float));

  cudaMemcpy(devx, &x[0], numBytes, cudaMemcpyHostToDevice);
  cudaMemcpy(devy, &y[0], numBytes, cudaMemcpyHostToDevice);
  cudaMemcpy(devVx, &Vx[0], numBytes, cudaMemcpyHostToDevice);
  cudaMemcpy(devVy, &Vy[0], numBytes, cudaMemcpyHostToDevice);
  cudaMemcpy(devax, &ax[0], numBytes, cudaMemcpyHostToDevice);
  cudaMemcpy(devay, &ay[0], numBytes, cudaMemcpyHostToDevice);
  // cudaMemcpy(circx, &circX, sizeof(float), cudaMemcpyHostToDevice);
  // cudaMemcpy(circy, &circY, sizeof(float), cudaMemcpyHostToDevice);
  // cudaMemcpy(circr, &circR, sizeof(float), cudaMemcpyHostToDevice);


  dim3 threads = dim3(512,1);
  dim3 blocks = dim3((int)(NumP/threads.x),1);

  accelerate<<<blocks, threads>>>
    (devx,
      devy,
      devVx,
      devVy,
      devax,
      devay);

  newcoord<<<blocks, threads>>>
  (devx,
    devy,
    devVx,
    devVy,
    devax,
    devay);

  cudaMemcpy(&x[0], devx, numBytes, cudaMemcpyDeviceToHost);
  cudaMemcpy(&y[0], devy, numBytes, cudaMemcpyDeviceToHost);
  cudaMemcpy(&Vx[0], devVx, numBytes, cudaMemcpyDeviceToHost);
  cudaMemcpy(&Vy[0], devVy, numBytes, cudaMemcpyDeviceToHost);
  cudaMemcpy(&ax[0], devax, numBytes, cudaMemcpyDeviceToHost);
  cudaMemcpy(&ay[0], devay, numBytes, cudaMemcpyDeviceToHost);

  cudaFree(devx);
  cudaFree(devy);
  cudaFree(devVx);
  cudaFree(devVy);
  cudaFree(devax);
  cudaFree(devay);
  cudaFree(circx);
  cudaFree(circy);
  cudaFree(circr);
cudaProfilerStop();
  // int i = 0;
  // int j = 0;
  // float r,dist;
  // float a,b,rx,ry;
  // for (i = 0; i<NumP; i++)
  // {
  //   x[i] = x[i]+Vx[i]*Timestep+
  //                 ax[i]*Timestep*Timestep/2.0;
  //   y[i] = y[i]+Vy[i]*Timestep+
  //                 ay[i]*Timestep*Timestep/2.0;
  //   Vx[i] = Vx[i] + ax[i]*Timestep;
  //   Vy[i] = Vy[i] + ay[i]*Timestep;
  //   for (j = 0; j<NumP; j++)
  //     if (i!=j)
  //     {
  //       dist = (x[i]-x[j])*(x[i]-x[j])
  //       +(y[i]-y[j])*(y[i]-y[j]);
  //       if (dist<effrad)
  //       {
  //         ax[i] = ax[i]+(x[i]-x[j])/dist;
  //         ay[i] = ay[i]+(y[i]-y[j])/dist;
  //       }
  //     }
  //     if (y[i] < bbound)
  //       {
  //           // Vy[i] = -Vy[i];
  //           y[i] = tbound;
  //           Vx[i] = initVx;//5.0*rand()/RAND_MAX;
  //           Vy[i] = initVy;
  //       }
  //     if (y[i] > tbound)
  //          Vy[i] = -Vy[i];
  //     if ((x[i] > rbound) || (x[i] < lbound))
  //       {
  //         Vx[i] = -Vx[i];
  //       }
  //     if ((x[i]-circX)*(x[i]-circX)+
  //     (y[i]-circY)*(y[i]-circY)<circR*circR)
  //     {
  //         rx=x[i]-circX;
  //         ry=y[i]-circY;
  //         r = rx*rx+ry*ry;
  //         a = Vx[i]*ry-Vy[i]*rx;
  //         b = Vx[i]*rx+Vy[i]*ry;
  //
  //         Vy[i] = -((a*rx+b*ry)/r);
  //         Vx[i] = a/ry + (rx/ry)*Vy[i];
  //     }
  // }
}
