/*=====================================================================
 * fm.cpp
 *
 * f = fm(u,[numofchannel lengthofsignal])
 * The model of illumination change
 *
 * Copyright Han Gong 31/03/2014
 *===================================================================*/

/*
 function val = fm(wx,u)
% f = fm(wx,v)
% The model of shadow signal change
%
% Copyright Han Gong 31/03/2012

% start and end position of penumbra segment (poly)
pse = [-0.5,0.5]/u(7)+u(8);
val = zeros(size(wx,2),3);
seg1 = wx<pse(1);
seg2 = wx>pse(2);
seg3 = ~seg1|~seg2;
for i = 1:3
	% cubic curve
	p = u(i)*[-2,0,1.5,0.5]; % - 2*x^3 + (3*x)/2 + 1/2
	val(seg3,i) = polyval(p,u(7)*(wx(seg3)-u(8)))+u(i+3);
	val(seg1,i) = u(i+3);
    val(seg2,i) = u(i)+u(i+3);
end
 */
#include "mex.h"
#include "matrix.h"
#include <cmath>

#define NC 3

/* gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    double *x, *u, tmp, *val, *pse;
    size_t len;
    int i, j;

    x = mxGetPr(prhs[0]);  u = mxGetPr(prhs[1]); // get coordinates and para
    len = mxGetN(prhs[0]); // get signal length
    
    // allocate space for outputs
    plhs[0] = mxCreateDoubleMatrix(len, NC, mxREAL);
    plhs[1] = mxCreateDoubleMatrix(1, 2, mxREAL);
    val = mxGetPr(plhs[0]);
    pse = mxGetPr(plhs[1]);
    
    // compute start and end positions of a signal
    pse[0] = -0.5/u[6]+u[7]+0.5;
    pse[1] = 0.5/u[6]+u[7]+0.5;
    
    // compute poly values
    for (i=0;i<NC;i++) // for each channel
    {
        // for each position
        for (j=0;x[j]<pse[0]&&j<len;j++)
            val[j+i*len] = u[i+NC];
        for (;x[j]<=pse[1]&&j<len;j++)
        {
            tmp = u[6]*(x[j]-0.5-u[7]);// check!
            val[j+i*len] = u[i]*(-2.0*pow(tmp,3)+1.5*tmp+0.5)+u[i+NC];
        }
        tmp = u[i]+u[i+NC];
        for (;j<len;j++)
            val[j+i*len] = tmp;
    }
    
    return;
}
