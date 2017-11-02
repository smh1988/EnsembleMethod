#include "mex.h"
#include "matrix.h"
#include "math.h"
#include "time.h"
#include <iostream>
using namespace std;

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] ){
    double *left_image = (double *)mxGetData(prhs[0]);
    double *right_image = (double *)mxGetData(prhs[1]);

    const mwSize *size = mxGetDimensions(prhs[0]);
    int rows = size[0];
    int cols = size[1];
    
    double *param = (double *)mxGetData(prhs[2]);
    int max_disparity = (int)param[0];
    
    double *param2 = (double *)mxGetData(prhs[3]);
    unsigned int truncation = (unsigned int)param2[0];
    
    unsigned char *lookup_table = (unsigned char *)mxGetData(prhs[4]);
    
    plhs[0] = mxCreateNumericMatrix(rows * cols, max_disparity, mxDOUBLE_CLASS, mxREAL);
	double *left_cost = (double *)mxGetData( plhs[0] );
    
    plhs[1] = mxCreateNumericMatrix(rows * cols, max_disparity, mxDOUBLE_CLASS, mxREAL);
	double *right_cost = (double *)mxGetData( plhs[1] );
    
    plhs[2] = mxCreateNumericMatrix(rows, cols, mxINT32_CLASS, mxREAL);
	int *left_census_image = (int *)mxGetData( plhs[2] );    
    
    plhs[3] = mxCreateNumericMatrix(rows, cols, mxINT32_CLASS, mxREAL);
	int *right_census_image = (int *)mxGetData( plhs[3] );        
    
	int census = 0;
	int bit = 0;
	int m = 5;
	int n = 5;
	int shift_count = 0;

	for(int x = m/2; x < cols - m/2; x++){
		for(int y = n/2; y < rows - n/2; y++){
			census = 0;
			shift_count = 0;
			for(int i = x - m/2; i <=  x + m/2; i++){
				for(int j = y - n/2; j <= y + n/2; j++){
					if(shift_count != m*n/2){
						census <<= 1;
						if( left_image[i*rows+j] < left_image[x*rows+y] ){
							bit = 1;
                        }else{
							bit = 0;
                        }
						census = census + bit;
					}
					shift_count++;
				}
			}
			left_census_image[x*rows+y] = census;
		}
	}    
    
	for(int x = m/2; x < cols - m/2; x++){
		for(int y = n/2; y < rows - n/2; y++){
			census = 0;
			shift_count = 0;
			for(int i = x - m/2; i <=  x + m/2; i++){
				for(int j = y - n/2; j <= y + n/2; j++){
					if(shift_count != m*n/2){
						census <<= 1;
						if( right_image[i*rows+j] < right_image[x*rows+y] ){
							bit = 1;
                        }else{
							bit = 0;
                        }
						census = census + bit;
					}
					shift_count++;
				}
			}
			right_census_image[x*rows+y] = census;
		}
	}     
    
    
    int count = 0;
    int tmp = 0;
    char diff;
    for(int d = 0; d < max_disparity; d++){
        for(int i = 0; i < cols; i++){
            for(int j = 0; j < rows; j++){
                if( i-d >= 0 ){
                    tmp = left_census_image[i*rows+j] ^ right_census_image[(i-d)*rows+j];
                    diff = lookup_table[tmp];
                    if( diff > truncation ){
                        left_cost[count] = truncation;
                    }else{
                        left_cost[count] = diff;
                    }
                }else{
                    left_cost[count] = truncation;
                }
                if( i+d < cols ){
                    tmp = left_census_image[(i+d)*rows+j] ^ right_census_image[i*rows+j];
                    diff = lookup_table[tmp];
                    if( diff > truncation ){
                        right_cost[count] = truncation;
                    }else{
                        right_cost[count] = diff;
                    }
                }else{
                    right_cost[count] = truncation;
                }
                count++;
            }
        }
    }    
    
}