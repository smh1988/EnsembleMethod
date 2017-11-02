#include "mex.h"
#include "matrix.h"
#include "math.h"
#include "time.h"
#include <iostream>
using namespace std;

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] ){
    
    double *left_segment_cost = (double *)mxGetData(prhs[0]);
    const mwSize *left_segment_size = mxGetDimensions(prhs[0]);
    int number_left_segments = left_segment_size[0];
    int max_disparity = left_segment_size[1];
    
    double *right_segment_cost = (double *)mxGetData(prhs[1]);
    const mwSize *right_segment_size = mxGetDimensions(prhs[1]);
    int number_right_segments = right_segment_size[0];
    
    double *left_neighborhoods = (double *)mxGetData(prhs[2]);
    double *right_neighborhoods = (double *)mxGetData(prhs[3]);
    const mwSize *neighbor_size = mxGetDimensions(prhs[2]);
    int rows_neighborhoods = neighbor_size[0];    
    
    double *penalty_function = (double *)mxGetData(prhs[4]);
    
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
    
    for(int i = 0; i < number_left_segments;i++){
        double normalization = 1;
        double disparity = left_disparity[i];
        int average_disparity = 0;
        if( disparity < 1 ){
            disparity = 0;
            normalization = 0;
        }
        
        for(int j = 0; j < left_neighborhoods[i*rows_neighborhoods]; j++){
            int neighbor_index = left_neighborhoods[i*rows_neighborhoods+j*2+1];
            double diff = left_neighborhoods[i*rows_neighborhoods+j*2+2];
            double neighbor_disparity = left_disparity[neighbor_index];
            if( neighbor_disparity > 0 ){
                disparity += neighbor_disparity * diff;
                normalization += diff;
            }
        }
        
        if(normalization > 0 ){
            average_disparity = disparity / normalization + 0.5;
        }
        for(int d = 0; d < max_disparity; d++){
            left_segment_cost[d*number_left_segments+i] = 
                    ( left_segment_cost[d*number_left_segments+i] + penalty_function[ average_disparity*max_disparity+d ] )/2;
        }
        
    }
    
    for(int i = 0; i < number_right_segments;i++){
        double normalization = 1;
        double disparity = right_disparity[i];
        int average_disparity = 0;
        if( disparity < 1 ){
            disparity = 0;
            normalization = 0;
        }
        
        for(int j = 0; j < right_neighborhoods[i*rows_neighborhoods]; j++){
            int neighbor_index = right_neighborhoods[i*rows_neighborhoods+j*2+1];
            double diff = right_neighborhoods[i*rows_neighborhoods+j*2+2];
            double neighbor_disparity = right_disparity[neighbor_index];
            if( neighbor_disparity > 0){
                disparity += neighbor_disparity * diff;
                normalization += diff;
            }
        }
        if(normalization > 0 ){
            average_disparity = disparity / normalization + 0.5;
        }
        for(int d = 0; d < max_disparity; d++){
            right_segment_cost[d * number_right_segments+i] = 
                    ( right_segment_cost[d * number_right_segments+i] + penalty_function[ average_disparity * max_disparity + d ] )/2;
        }
    }    
    
    
    delete [] left_disparity;
    delete [] right_disparity;    
}
