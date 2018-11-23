#include <math.h>
#include <matrix.h>
#include <mex.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (nrhs != 1)
        mexErrMsgTxt("Must have 1 argument.");
    //declare varaibles
    mxArray *arr_in, *arr_out; 
    const mwSize *dims;
    int dimx, dimy, dimz;
    
    //set input and output value
    arr_in = mxDuplicateArray(prhs[0]);
    dims = mxGetDimesions(prhs[0]);
    dimy = (int)dims[0];dimx = (int)dims[1];dimz = (int)dims[2];
    arr_out = mxCreateDoubleMatrix(dimy, dimx, dimz, mxREAL);
    
    //calculate except the boundary points
    for(i = 1; i < dimz-1; i++)
    {
        for(j = 1; j < dimy-1; j++)
        {
            for(k = 1; k < dimx-1; k++)
            {
                
            }
        }
    }
    
    mexPrintf("Hello World!\n");
}