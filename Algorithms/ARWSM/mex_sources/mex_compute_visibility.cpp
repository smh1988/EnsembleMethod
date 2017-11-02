#include "mex.h"
#include "matrix.h"
#include "math.h"
#include "time.h"
#include <iostream>
using namespace std;

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] ){
    
    double *left_segment_coordinates = (double *)mxGetData(prhs[0]);
    double *right_segment_coordinates = (double *)mxGetData(prhs[1]);
    
    double *left_segment_cost = (double *)mxGetData(prhs[2]);
    const mwSize *left_segment_size = mxGetDimensions(prhs[2]);
    int number_left_segments = left_segment_size[0];
    int max_disparity = left_segment_size[1];
    
    double *right_segment_cost = (double *)mxGetData(prhs[3]);
    const mwSize *right_segment_size = mxGetDimensions(prhs[3]);
    int number_right_segments = right_segment_size[0];
    
    double  *left_segments = (double *)mxGetData(prhs[4]);
    double  *right_segments = (double  *)mxGetData(prhs[5]);
    const mwSize *image_size = mxGetDimensions(prhs[4]);
    int rows = image_size[0];
    int cols = image_size[1];     
    
    double *param = (double *)mxGetData(prhs[6]);
    int threshold = param[0];
    
    int *left_disparity = new int [number_left_segments];
    int *right_disparity = new int [number_right_segments];
     
    
    int disparity;
    double current_cost, min_cost;
	for(int i = 0; i < number_left_segments; i++){
		disparity = 0;
		min_cost = 10000000;
		for(int d = 0; d < max_disparity; d++){
            current_cost = left_segment_cost[d * number_left_segments + i];
			if( current_cost < min_cost ){
				min_cost = current_cost;
                disparity = d;
			}
		}
        left_disparity[i] = disparity;
	}    
    
	for(int i = 0; i < number_right_segments; i++){
		disparity = 0;
		min_cost = 10000000;
		for(int d = 0; d < max_disparity; d++){
            current_cost = right_segment_cost[d * number_right_segments + i];
			if( current_cost < min_cost ){
				min_cost = current_cost;
                disparity = d;
			}
		}
        right_disparity[i] = disparity;
	}        
    
    int x,y,idx;
    int x0,y0;
    for(int i = 0; i < number_left_segments; i++){
        disparity = left_disparity[i];
        x = left_segment_coordinates[i*4] + 0.5 - disparity;
        y = left_segment_coordinates[i*4+1] + 0.5;
        if( x >= 0 && x < cols ){
            idx = right_segments[x*rows+y];
            if( abs( disparity - right_disparity[idx] ) > threshold ){
                for(int d = 0; d < max_disparity; d++){
                    left_segment_cost[d*number_left_segments+i] = 0;
                }
            }
        }else{
            x = left_segment_coordinates[i*4];
            idx = right_segments[y*cols+x];
            if( abs( disparity - right_disparity[idx]) > threshold ){
                for(int d = 0; d < max_disparity; d++){
                    left_segment_cost[d*number_left_segments+i] = 0;
                }
            }          
        }
    }
    
    for(int i = 0; i < number_right_segments; i++){
        disparity = right_disparity[i];
        x = right_segment_coordinates[i*4] + 0.5 + disparity;
        y = right_segment_coordinates[i*4+1] + 0.5;
        if( x >= 0 && x < cols ){
            idx = left_segments[x*rows+y];
            if( abs( disparity - left_disparity[idx]) > threshold ){
                for(int d = 0; d < max_disparity; d++){
                    right_segment_cost[d*number_right_segments+i] = 0;
                }
            }
        }else{
            x = right_segment_coordinates[i*4];
            idx = left_segments[y*cols+x];
            if( abs( disparity - left_disparity[idx] ) > threshold ){
                for(int d = 0; d < max_disparity; d++){
                    right_segment_cost[d*number_right_segments+i] = 0;
                }
            }       
        }
    }    
    
    
    
    
    delete [] left_disparity;
    delete [] right_disparity;
}
