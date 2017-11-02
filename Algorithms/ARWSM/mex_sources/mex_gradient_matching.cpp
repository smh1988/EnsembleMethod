#include "mex.h"
#include "matrix.h"
#include "math.h"
#include "time.h"
#include <iostream>
using namespace std;

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] ){
    double *left_vertical_image = (double *)mxGetData(prhs[0]);
    double *left_horizontal_gradient = (double *)mxGetData(prhs[1]);
    
    double *right_vertical_gradient = (double *)mxGetData(prhs[2]);
    double *right_horizontal_gradient = (double *)mxGetData(prhs[3]);

    const mwSize *size = mxGetDimensions(prhs[0]);
    int rows = size[0];
    int cols = size[1];
    
    double *param = (double *)mxGetData(prhs[4]);
    double max_disparity = (int)param[0];
    
    double *param2 = (double *)mxGetData(prhs[5]);
    double truncation = param2[0];
    
    plhs[0] = mxCreateNumericMatrix(rows * cols, max_disparity, mxDOUBLE_CLASS, mxREAL);
	double *left_cost = (double *)mxGetData( plhs[0] );    
    
    plhs[1] = mxCreateNumericMatrix(rows * cols, max_disparity, mxDOUBLE_CLASS, mxREAL);
	double *right_cost = (double *)mxGetData( plhs[1] );        
    
    
    int count = 0;
    double diff = 0;
    for(int d = 0; d < max_disparity; d++){
        for(int i = 0; i < cols; i++){
            for(int j = 0; j < rows; j++){
                if( i-d >= 0 ){
                    diff = abs(left_vertical_image[i*rows+j] - right_vertical_gradient[(i-d)*rows+j]);
                    if( diff > truncation){
                        left_cost[count] = truncation;
                    }else{
                        left_cost[count] = diff;
                    }
                    diff = abs(left_horizontal_gradient[i*rows+j] - right_horizontal_gradient[(i-d)*rows+j]);
                    if( diff > truncation){
                        left_cost[count] += truncation;
                    }else{
                        left_cost[count] += diff;
                    }                    
                }else{
                    left_cost[count] = truncation*2;
                }
                
                if( i+d < cols ){
                    diff = abs(left_vertical_image[(i+d)*rows+j] - right_vertical_gradient[i*rows+j]);
                    if( diff > truncation){
                        right_cost[count] = truncation;
                    }else{
                        right_cost[count] = diff;
                    }
                    diff = abs(left_horizontal_gradient[(i+d)*rows+j] - right_horizontal_gradient[i*rows+j]);
                    if( diff > truncation){
                        right_cost[count] += truncation;
                    }else{
                        right_cost[count] += diff;
                    }                    
                }else{
                    right_cost[count] = truncation*2;
                }
                count++;
            }
        }
    }
    
  
    
}