#define TILE_WIDTH 16
__global__ void gemv_kernel(float* oA, float* iB, float* iC, int dim) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < size) {
        float sum = 0;
        for (int i = 0 ; i < dim ; ++i) {
            sum += iB[idx * dim + i] * iC[i];
        }
        oA[idx] = sum;
    }
};

__global__ void gemm_kernel(float* oA, float* iB, float* iC, int M, int N, int K) {
    // (M, N) * (N, K) -> (M, K)
    int bx = blockIdx.x;
    int by = blockIdx.y;
    int tx = threadIdx.x;
    int ty = threadIdx.y;
    float pvalue = 0;
    __shared__ float tileB[TILE_WIDTH][TILE_WIDTH];
    __shared__ float tileC[TILE_WIDTH][TILE_WIDTH];

    int phase = (N - 1) / TILE_WIDTH + 1;
    for (int i = 0 ; i < phase ; i++) {
        if (bx * TILE_WIDTH + tx < K && by * TILE_WIDTH + ty < M) {
            if (i * TILE_WIDTH + tx < N) 
                tileB[ty][tx] = iB[N * (by * TILE_WIDTH + ty) + i * TILE_WIDTH + tx];
            else
                tileB[ty][tx] = 0;
            if (i * TILE_WIDTH + ty < N)
                tileC[ty][tx] = iC[K * (i * TILE_WIDTH + ty) + bx * TILE_WIDTH + tx];
            else
                tileC[ty][tx] = 0;
        }
        __syncthreads();
        for (int j = 0 ; j < TILE_WIDTH ; j++) {
            pvalue += tileB[ty][j] * tileC[j][tx];
        }
        __syncthreads();
    }
    if (bx * TILE_WIDTH + tx < K && by * TILE_WIDTH + ty < M) {
        oA[(by * TILE_WIDTH + ty) * N + bx * TILE_WIDTH + tx] = pvalue;
    }
    
};