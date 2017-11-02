#include "mex.h"
#include "matrix.h"
#include "math.h"
#include "time.h"
#include <iostream>
using namespace std;

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] ){
    double *segment_cost = (double *)mxGetData(prhs[0]);
    const mwSize *segment_size = mxGetDimensions(prhs[0]);
    int number_segments = segment_size[0];
    int max_disparity = segment_size[1];
    
    double *pixel_cost = (double *)mxGetData(prhs[1]);
    double *segments = (double *)mxGetData(prhs[2]);
    const mwSize *image_size = mxGetDimensions(prhs[2]);
    int rows = image_size[0];
    int cols = image_size[1];    
    
    double *param1 = (double *)mxGetData(prhs[3]);
    double segment_weight = param1[0];
    
    double *param2 = (double *)mxGetData(prhs[4]);
    double pixel_weight = param2[0];
    

    int *segment_disparity = new int [number_segments];
     
    int disparity;
    double current_cost, min_cost;
	for(int i = 0; i < number_segments; i++){
		disparity = 0;
		min_cost = 10000000;
		for(int d = 0; d < max_disparity; d++){
            current_cost = segment_cost[d * number_segments + i];
			if( current_cost < min_cost ){
				min_cost = current_cost;
                disparity = d;
			}
		}
        segment_disparity[i] = disparity;
	}        
    
    
    int segment_index;
    for(int i = 0; i < cols*rows; i++){
        segment_index = segments[i];
        if( segment_disparity[segment_index] > 0 ){
            for(int d = 0; d < max_disparity; d++){
                pixel_cost[i+cols*rows*d] = pixel_weight*pixel_cost[i+cols*rows*d] + segment_weight*segment_cost[segment_index+d*number_segments];
            }            
        }else{
            for(int d = 0; d < max_disparity; d++){
                pixel_cost[i+cols*rows*d] = 0;
            }
        }
    }
    
    delete [] segment_disparity;
    
}
