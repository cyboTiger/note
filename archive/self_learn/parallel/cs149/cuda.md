## Grid, Block, and Thread
![cuda grid](image-1.png)

each block has shared memory for all threads within the block.

each thread has its own private memory.

## CUDA Thread Block Scheduling
+ one block is mapped to one SMM core (streaming multiprocessor core)

![alt text](image-2.png)


![alt text](image.png)

### warp
+ warp is the execution context storage for CUDA threads.
+ a warp consists of 32 threads, each thread is an instruction bank.

## Matrix Multiplication in CUDA

![alt text](image-3.png)

![alt text](image-4.png)

![alt text](image-5.png)

## Parallel Reduction in CUDA
![alt text](image-6.png)

sequential addressing > interleaved addressing