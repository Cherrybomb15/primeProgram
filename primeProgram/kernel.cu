
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "math.h"
#include <iostream>
#include "Timer.h"

using namespace std;

#include <stdio.h>

__global__ void findPrimes(const int a, const int b, int* arr)
{
	int i = blockDim.x * blockIdx.x + threadIdx.x;
	const int c = i + a;

	bool go = true;

	if (c - 1 < b)
	{
		for (int k = 2; k < 7; k++)
		{
			if (c % k == 0)
			{
				arr[i] = 0;
				go = false;
			}
		}

		for (int j = 7; j < sqrtf(c) + 1 && go; j+=2)
		{
			if (c % j == 0)
			{
				arr[i] = 0;
				go = false;
			}
		}
	}

	if ((go && c - 1 < b) || c == 2 || c == 3 || c == 5)
	{
		arr[i] = c;
	}
}

int printPrimes(int* arr, int size)
{
	int k = 0;
	for (int i = 0; i < size; i++)
	{
		if (arr[i] != 0)
		{
			k++;
			//printf("%d ", arr[i]);
		}
	}

	return k;
}

int firstPrime(int* arr, int size)
{
	int i = 0;
	while (arr[i] == 0)
	{
		i++;
	}
	return arr[i];
}

int lastPrime(int* arr, int size)
{
	int i = size - 1;

	while (arr[i] == 0)
	{
		i--;
	}
	return arr[i];
}




int main()
{
	int a;
	int b;

	int comps;

	cout << "Lower bound: ";
	cin >> a;

	cout << "Upper bound: ";
	cin >> b;

	cout << "Threads per block: ";
	cin >> comps;

	Timer h;

	const int size = sizeof(int) * (b - a + 1);

	int* h_arr = (int*)malloc(size);

	int* d_arr;
	cudaMalloc(&d_arr, size);

	cudaMemcpy(d_arr, h_arr, size, cudaMemcpyHostToDevice);

	findPrimes << <((b - a + 1) / comps) + 1, comps >> > (a, b, d_arr);
	//findPrimes << <gridSize, blockSize >> > (a, b, d_arr);

	cudaMemcpy(h_arr, d_arr, size, cudaMemcpyDeviceToHost);

	cudaFree(d_arr);

	int lmoa = printPrimes(h_arr, b - a + 1);

	cout << "\nWhoa there are " << lmoa << " primes!!!" << "\n" <<
		"First prime: " << firstPrime(h_arr, b - a + 1) <<
		"\n Last prime: " << lastPrime(h_arr, b - a + 1);
	
	free(h_arr);

	cout << "\nTime passed:" << h.elapsed() <<
		"seconds. \n Blocks * threads: " <<
		(b - a + 1) / comps << " * " << comps;
}