#include "ex2.h"

double dotp_naive(double* x, double* y, int arr_size) {
    double global_sum = 0.0;
    for (int i = 0; i < arr_size; i++)
        global_sum += x[i] * y[i];
    return global_sum;
}

// Critical Keyword
double dotp_critical(double* x, double* y, int arr_size) {
    double global_sum = 0.0;
    #pragma omp critical
    {
        for (int i = 0; i < arr_size; i++) {
            global_sum += x[i] * y[i];
        }
    }
    return global_sum;
}

// Reduction Keyword
double dotp_reduction(double* x, double* y, int arr_size) {
    double global_sum = 0.0;
    #pragma omp parallel for reduction(+:global_sum)
    for (int i = 0; i < arr_size; i++) {
        global_sum += x[i] * y[i];
    }
    return global_sum;
}

// Manual Reduction
double dotp_manual_reduction(double* x, double* y, int arr_size) {
    double global_sum = 0.0;
    #pragma omp parallel
    {
        double local_sum = 0.0;
        for (int i = 0; i < arr_size; i++) {
            local_sum += x[i] * y[i];
        }
        #pragma omp critical
        {
            global_sum += local_sum;
        }
    }
    return global_sum;
}
