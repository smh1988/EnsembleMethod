#include "mex.h"
#include "matrix.h"
#include "math.h"
#include "time.h"
#include <iostream>
using namespace std;

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] ){
    
    double *left_image = (double *)mxGetData(prhs[0]);
    double *right_image = (double *)mxGetData(prhs[1]);    
    double *left_pixel_cost = (double *)mxGetData(prhs[2]);
    double *right_pixel_cost = (double *)mxGetData(prhs[3]);
    const mwSize *cost_size = mxGetDimensions(prhs[2]);
    int max_disparity = cost_size[1];
    
    double  *left_segments = (double *)mxGetData(prhs[4]);
    double  *right_segments = (double  *)mxGetData(prhs[5]);
    const mwSize *image_size = mxGetDimensions(prhs[4]);
    int rows = image_size[0];
    int cols = image_size[1];
    
    int number_left_segments = 0;
    int number_right_segments = 0;
    
    int idx;
    int left_idx = 0;
    int right_idx = 0;
    for(int i = 0; i < cols; i++){
        for(int j = 0; j < rows; j++){
            idx = i*rows+j;
            left_idx = left_segments[idx];
            if( number_left_segments < left_idx ){
                number_left_segments = left_idx;
            }            
            right_idx = right_segments[idx];
            if( number_right_segments < right_idx ){
                number_right_segments = right_idx;
            }            
        }
    }
    
    number_left_segments = number_left_segments + 1;
    number_right_segments = number_right_segments + 1;
    
    plhs[0] = mxCreateNumericMatrix(4, number_left_segments, mxDOUBLE_CLASS, mxREAL);
	double *left_segment_coordinates = (double *)mxGetData( plhs[0] );
    
    plhs[1] = mxCreateNumericMatrix(4, number_right_segments, mxDOUBLE_CLASS, mxREAL);
	double *right_segment_coordinates = (double *)mxGetData( plhs[1] );    
    
    for(int i = 0; i < cols; i++){
        for(int j = 0; j < rows; j++){
            idx = i*rows+j;
            left_idx = left_segments[idx];
            left_segment_coordinates[left_idx*4] += i;
            left_segment_coordinates[left_idx*4+1] += j;
            left_segment_coordinates[left_idx*4+2] += left_image[idx];
            left_segment_coordinates[left_idx*4+3] += 1;
            
            right_idx = right_segments[idx];
            right_segment_coordinates[right_idx*4] += i;
            right_segment_coordinates[right_idx*4+1] += j;
            right_segment_coordinates[right_idx*4+2] += right_image[idx];
            right_segment_coordinates[right_idx*4+3] += 1;            
        }
    }
    
    for(int i = 0; i < number_left_segments; i++){
        left_segment_coordinates[i*4] = left_segment_coordinates[i*4] / left_segment_coordinates[i*4+3];
        left_segment_coordinates[i*4+1] = left_segment_coordinates[i*4+1] / left_segment_coordinates[i*4+3];
        left_segment_coordinates[i*4+2] = left_segment_coordinates[i*4+2] / left_segment_coordinates[i*4+3];
    }
    for(int i = 0; i < number_right_segments; i++){
        right_segment_coordinates[i*4] = right_segment_coordinates[i*4] / right_segment_coordinates[i*4+3];
        right_segment_coordinates[i*4+1] = right_segment_coordinates[i*4+1] / right_segment_coordinates[i*4+3];
        right_segment_coordinates[i*4+2] = right_segment_coordinates[i*4+2] / right_segment_coordinates[i*4+3];
    }
    
    plhs[2] = mxCreateNumericMatrix(number_left_segments, max_disparity, mxDOUBLE_CLASS, mxREAL);
	double *left_segment_cost = (double *)mxGetData( plhs[2] );    
    plhs[3] = mxCreateNumericMatrix(number_right_segments, max_disparity, mxDOUBLE_CLASS, mxREAL);
	double *right_segment_cost = (double *)mxGetData( plhs[3] );        
    
    for(int i = 0; i < rows*cols; i++){
        left_idx = left_segments[i];
        right_idx = right_segments[i];
        for(int j = 0; j < max_disparity; j++){
            left_segment_cost[j*number_left_segments+left_idx] += left_pixel_cost[j*rows*cols+i];
            right_segment_cost[j*number_right_segments+right_idx] += right_pixel_cost[j*rows*cols+i];
        }
    }
    
    for(int i = 0; i < number_left_segments; i++){
        for(int d = 0; d < max_disparity; d++){
            left_segment_cost[d*number_left_segments+i] = left_segment_cost[d*number_left_segments+i] / left_segment_coordinates[i*4+3];
        }
    }
    
    for(int i = 0; i < number_right_segments; i++){
        for(int d = 0; d < max_disparity; d++){
            right_segment_cost[d*number_right_segments+i] = right_segment_cost[d*number_right_segments+i] / right_segment_coordinates[i*4+3];
        }
    }    
    

}