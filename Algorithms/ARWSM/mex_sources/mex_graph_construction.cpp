#include "mex.h"
#include "matrix.h"
#include "math.h"
#include "time.h"
#include <iostream>
using namespace std;

#define maximum_neighbor 200

struct Segment{
  double intensity;
  int neighbor[maximum_neighbor];
  double diff[maximum_neighbor];
  double total;
  int number_neighbors;
  int number_pixels;
};

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] ){
    double *left_image = (double *)mxGetData(prhs[0]);
    double *right_image = (double *)mxGetData(prhs[1]);
    const mwSize *image_size = mxGetDimensions(prhs[0]);
    int rows = image_size[0];
    int cols = image_size[1];    
    double  *left_segments = (double *)mxGetData(prhs[2]);
    double  *right_segments = (double  *)mxGetData(prhs[3]);
    double *param1 = (double *)mxGetData(prhs[4]);
    double *param2 = (double *)mxGetData(prhs[5]);
    double sigma_e = param1[0];
    double tau_e = param2[0];
    double *param3 = (double *)mxGetData(prhs[6]);
    double threshold = param3[0];
    
    int number_left_segments = 0;
    int number_right_segments = 0;    
    int idx, left_idx = 0, right_idx = 0;
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
    
    Segment *struct_left_segments = new Segment [number_left_segments];
    Segment *struct_right_segments = new Segment [number_right_segments];
    for(int i = 0; i < number_left_segments; i++){
        struct_left_segments[i].intensity = 0;
        struct_left_segments[i].number_pixels = 0;
        struct_left_segments[i].number_neighbors = 0;
        struct_left_segments[i].total = 0;
    }
    for(int i = 0; i < number_right_segments; i++){
        struct_right_segments[i].intensity = 0;
        struct_right_segments[i].number_pixels = 0;
        struct_right_segments[i].number_neighbors = 0;
        struct_right_segments[i].total = 0;
    }    
    
    for(int i = 0; i < cols; i++){
        for(int j = 0; j < rows; j++){
            idx = i*rows+j;
            left_idx = left_segments[idx];
            struct_left_segments[left_idx].intensity += left_image[idx];
            struct_left_segments[left_idx].number_pixels++;
        
            right_idx = right_segments[idx];
            struct_right_segments[right_idx].intensity += right_image[idx];
            struct_right_segments[right_idx].number_pixels++;
        }
    }
    
    for(int i = 0; i < number_left_segments; i++){
        struct_left_segments[i].intensity = struct_left_segments[i].intensity / struct_left_segments[i].number_pixels;
    }
    
    for(int i = 0; i < number_right_segments; i++){
        struct_right_segments[i].intensity = struct_right_segments[i].intensity / struct_right_segments[i].number_pixels;
    }
    

    double diff;
    int compared_msk, left_msk, right_msk;
    bool tmp = false;
    double threshold_truncate = 0.0001;
    for(int i = 0; i < cols; i++){
        for(int j = 0; j < rows; j++){
            idx = i*rows+j;
            left_msk = left_segments[idx];
            if( j-1 > 0 ){
                if( left_msk != left_segments[i*rows+j-1] ){
                    compared_msk = left_segments[i*rows+j-1];
                    tmp = true;
                    for(int k = 0; k < struct_left_segments[left_msk].number_neighbors; k++){
                        if( struct_left_segments[left_msk].neighbor[k] == compared_msk ){
                            tmp = false;
                            break;
                        }
                    }
                    if(tmp){
                        diff = struct_left_segments[left_msk].intensity - struct_left_segments[compared_msk].intensity;
                        if( abs(diff) < threshold){
                            diff = (1 - tau_e) * exp( - ( diff * diff ) / sigma_e ) + tau_e;
//                             diff = (1 - tau_e) * exp( - abs( diff ) / sigma_e ) + tau_e;
                        }else{
                            diff = threshold_truncate;
                        }
                        struct_left_segments[left_msk].diff[ struct_left_segments[left_msk].number_neighbors ] = diff;
                        struct_left_segments[left_msk].total += diff;
                        struct_left_segments[left_msk].neighbor[ struct_left_segments[left_msk].number_neighbors++ ] = compared_msk;
                    }
                }
            }
            if(i-1 > 0){
                if( left_msk != left_segments[(i-1)*rows+j] ){
                    compared_msk = left_segments[(i-1)*rows+j];      
                    tmp = true;
                    for(int k = 0; k < struct_left_segments[left_msk].number_neighbors; k++){
                        if( struct_left_segments[left_msk].neighbor[k] == compared_msk ){
                            tmp = false;
                            break;
                        }
                    }
                    if(tmp){
                        diff = struct_left_segments[left_msk].intensity - struct_left_segments[compared_msk].intensity;
                        if( abs(diff) < threshold){
                            diff = (1 - tau_e) * exp( - ( diff * diff ) / sigma_e ) + tau_e;
//                             diff = (1 - tau_e) * exp( - abs( diff ) / sigma_e ) + tau_e;
                        }else{
                            diff = threshold_truncate;
                        }
                        struct_left_segments[left_msk].diff[ struct_left_segments[left_msk].number_neighbors ] = diff;
                        struct_left_segments[left_msk].total += diff;
                        struct_left_segments[left_msk].neighbor[ struct_left_segments[left_msk].number_neighbors++ ] = compared_msk;
                    }                
                }                
            }
            if( j+1 < rows){
                if( left_msk != left_segments[i*rows+j+1] ){
                    compared_msk = left_segments[i*rows+j+1];      
                    tmp = true;
                    for(int k = 0; k < struct_left_segments[left_msk].number_neighbors; k++){
                        if( struct_left_segments[left_msk].neighbor[k] == compared_msk ){
                            tmp = false;
                            break;
                        }
                    }
                    if(tmp){
                        diff = struct_left_segments[left_msk].intensity - struct_left_segments[compared_msk].intensity;
                        if( abs(diff) < threshold){
                            diff = (1 - tau_e) * exp( - ( diff * diff ) / sigma_e ) + tau_e;
//                             diff = (1 - tau_e) * exp( - abs( diff ) / sigma_e ) + tau_e;
                        }else{
                            diff = threshold_truncate;
                        }
                        struct_left_segments[left_msk].diff[ struct_left_segments[left_msk].number_neighbors ] = diff;
                        struct_left_segments[left_msk].total += diff;
                        struct_left_segments[left_msk].neighbor[ struct_left_segments[left_msk].number_neighbors++ ] = compared_msk;
                    }                
                }                
            }
            if(i+1 < cols){
                if( left_msk != left_segments[(i+1)*rows+j] ){
                    compared_msk = left_segments[(i+1)*rows+j];      
                    tmp = true;
                    for(int k = 0; k < struct_left_segments[left_msk].number_neighbors; k++){
                        if( struct_left_segments[left_msk].neighbor[k] == compared_msk ){
                            tmp = false;
                            break;
                        }
                    }
                    if(tmp){
                        diff = struct_left_segments[left_msk].intensity - struct_left_segments[compared_msk].intensity;
                        if( abs(diff) < threshold){
                            diff = (1 - tau_e) * exp( - ( diff * diff ) / sigma_e ) + tau_e;
//                             diff = (1 - tau_e) * exp( - abs( diff ) / sigma_e ) + tau_e;
                        }else{
                            diff = threshold_truncate;
                        }
                        struct_left_segments[left_msk].diff[ struct_left_segments[left_msk].number_neighbors ] = diff;
                        struct_left_segments[left_msk].total += diff;
                        struct_left_segments[left_msk].neighbor[ struct_left_segments[left_msk].number_neighbors++ ] = compared_msk;
                    }                
                }                 
            }
            
            
            
            right_msk = right_segments[idx];
            if(j-1 > 0){
                if( right_msk != right_segments[i*rows+j-1] ){
                    compared_msk = right_segments[i*rows+j-1];
                    tmp = true;
                    for(int k = 0; k < struct_right_segments[right_msk].number_neighbors; k++){
                        if( struct_right_segments[right_msk].neighbor[k] == compared_msk ){
                            tmp = false;
                            break;
                        }
                    }
                    if(tmp){
                        diff = struct_right_segments[right_msk].intensity - struct_right_segments[compared_msk].intensity;
                        if( abs(diff) < threshold){
                            diff = (1 - tau_e) * exp( - ( diff * diff ) / sigma_e ) + tau_e;
//                             diff = (1 - tau_e) * exp( - abs( diff ) / sigma_e ) + tau_e;
                        }else{
                            diff = threshold_truncate;
                        }
                        struct_right_segments[right_msk].diff[ struct_right_segments[right_msk].number_neighbors ] = diff;
                        struct_right_segments[right_msk].total += diff;
                        struct_right_segments[right_msk].neighbor[ struct_right_segments[right_msk].number_neighbors++ ] = compared_msk;
                    } 
                }            
            }
            
            if(i-1 > 0){
                if( right_msk != right_segments[(i-1)*rows+j] ){
                    compared_msk = right_segments[(i-1)*rows+j];   
                    tmp = true;
                    for(int k = 0; k < struct_right_segments[right_msk].number_neighbors; k++){
                        if( struct_right_segments[right_msk].neighbor[k] == compared_msk ){
                            tmp = false;
                            break;
                        }
                    }
                    if(tmp){
                        diff = struct_right_segments[right_msk].intensity - struct_right_segments[compared_msk].intensity;
                        if( abs(diff) < threshold){
                            diff = (1 - tau_e) * exp( - ( diff * diff ) / sigma_e ) + tau_e;
//                             diff = (1 - tau_e) * exp( - abs( diff ) / sigma_e ) + tau_e;
                        }else{
                            diff = threshold_truncate;
                        }
                        struct_right_segments[right_msk].diff[ struct_right_segments[right_msk].number_neighbors ] = diff;
                        struct_right_segments[right_msk].total += diff;
                        struct_right_segments[right_msk].neighbor[ struct_right_segments[right_msk].number_neighbors++ ] = compared_msk;
                    }                 
                }                
            }
     
            if(j+1 < rows){
                if( right_msk != right_segments[i*rows+j+1] ){
                    compared_msk = right_segments[i*rows+j+1];
                    tmp = true;
                    for(int k = 0; k < struct_right_segments[right_msk].number_neighbors; k++){
                        if( struct_right_segments[right_msk].neighbor[k] == compared_msk ){
                            tmp = false;
                            break;
                        }
                    }
                    if(tmp){
                        diff = struct_right_segments[right_msk].intensity - struct_right_segments[compared_msk].intensity;
                        if( abs(diff) < threshold){
                            diff = (1 - tau_e) * exp( - ( diff * diff ) / sigma_e ) + tau_e;
//                             diff = (1 - tau_e) * exp( - abs( diff ) / sigma_e ) + tau_e;
                        }else{
                            diff = threshold_truncate;
                        }
                        struct_right_segments[right_msk].diff[ struct_right_segments[right_msk].number_neighbors ] = diff;
                        struct_right_segments[right_msk].total += diff;
                        struct_right_segments[right_msk].neighbor[ struct_right_segments[right_msk].number_neighbors++ ] = compared_msk;
                    } 
                }                
            }

            if(i+1 < cols){
                if( right_msk != right_segments[(i+1)*rows+j] ){
                    compared_msk = right_segments[(i+1)*rows+j];   
                    tmp = true;
                    for(int k = 0; k < struct_right_segments[right_msk].number_neighbors; k++){
                        if( struct_right_segments[right_msk].neighbor[k] == compared_msk ){
                            tmp = false;
                            break;
                        }
                    }
                    if(tmp){
                        diff = struct_right_segments[right_msk].intensity - struct_right_segments[compared_msk].intensity;
                        if( abs(diff) < threshold){
                            diff = (1 - tau_e) * exp( - ( diff * diff ) / sigma_e ) + tau_e;
//                             diff = (1 - tau_e) * exp( - abs( diff ) / sigma_e ) + tau_e;
                        }else{
                            diff = threshold_truncate;
                        }
                        struct_right_segments[right_msk].diff[ struct_right_segments[right_msk].number_neighbors ] = diff;
                        struct_right_segments[right_msk].total += diff;
                        struct_right_segments[right_msk].neighbor[ struct_right_segments[right_msk].number_neighbors++ ] = compared_msk;
                    }                 
                }                
            }             
        }
    }    

    int number_left_edges = 0;
    for(int i = 0; i < number_left_segments; i++){
        number_left_edges += struct_left_segments[i].number_neighbors;
    }
    
    int number_right_edges = 0;
    for(int i = 0; i < number_right_segments; i++){
        number_right_edges += struct_right_segments[i].number_neighbors;
    }    
    
    plhs[0] = mxCreateNumericMatrix(number_left_edges, 3, mxDOUBLE_CLASS, mxREAL);
	double *left_graph = (double *)mxGetData( plhs[0] );
    
    plhs[1] = mxCreateNumericMatrix(number_right_edges, 3, mxDOUBLE_CLASS, mxREAL);
	double *right_graph = (double *)mxGetData( plhs[1] );
    
    int left_count = 0;
    int right_count = 0;
    for(int i = 0; i < number_left_segments; i++){
        for(int j = 0; j < struct_left_segments[i].number_neighbors; j++){
            left_graph[left_count] = i;
            idx = struct_left_segments[i].neighbor[j];
            left_graph[left_count+number_left_edges] = idx;
            left_graph[left_count+number_left_edges*2] = struct_left_segments[i].diff[j] / struct_left_segments[i].total;
            left_count++;
        }
    }
    
    for(int i = 0; i < number_right_segments; i++){
        for(int j = 0; j < struct_right_segments[i].number_neighbors; j++){
            right_graph[right_count] = i;
            idx = struct_right_segments[i].neighbor[j];
            right_graph[right_count+number_right_edges] = idx;
            right_graph[right_count+number_right_edges*2] = struct_right_segments[i].diff[j] / struct_right_segments[i].total;
            right_count++;
        }
    }    
    
    
    
    
    plhs[2] = mxCreateNumericMatrix(maximum_neighbor*2, number_left_segments, mxDOUBLE_CLASS, mxREAL);
	double *left_neighborhoods = (double *)mxGetData( plhs[2] );
    
    plhs[3] = mxCreateNumericMatrix(maximum_neighbor*2, number_right_segments, mxDOUBLE_CLASS, mxREAL);
	double *right_neighborhoods = (double *)mxGetData( plhs[3] );    
    
    for(int i = 0; i < number_left_segments; i++){
        left_neighborhoods[i*maximum_neighbor*2] = struct_left_segments[i].number_neighbors;
        for(int j = 0; j < struct_left_segments[i].number_neighbors; j++){
            left_neighborhoods[i*maximum_neighbor*2+j*2+1] = struct_left_segments[i].neighbor[j];
            left_neighborhoods[i*maximum_neighbor*2+j*2+2] = struct_left_segments[i].diff[j];
        }
    }
    
    for(int i = 0; i < number_right_segments; i++){
        right_neighborhoods[i*maximum_neighbor*2] = struct_right_segments[i].number_neighbors;
        for(int j = 0; j < struct_right_segments[i].number_neighbors; j++){
            right_neighborhoods[i*maximum_neighbor*2+j*2+1] = struct_right_segments[i].neighbor[j];
            right_neighborhoods[i*maximum_neighbor*2+j*2+2] = struct_right_segments[i].diff[j];
        }
    }    
    
    
    delete [] struct_left_segments;
    delete [] struct_right_segments;
    
}