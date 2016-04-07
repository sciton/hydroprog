#include "params.h"
//#include "definitions.h"
#include <math.h>
#include <stdlib.h>

float x[NumP];
float y[NumP];
float Vx[NumP];
float Vy[NumP];
float ax[NumP];
float ay[NumP];

void InitData()
{
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
