#include "MurmurHash3.h"
#include <stdlib.h>
#include <stdio.h>
#include <windows.h>
#include <fstream>
#include <iostream>
#include <sstream>
#include <omp.h>

using namespace std;

string benchmark(char* payload, int size, unsigned int times, uint32_t* out, void (*fptr)(const void*, int, uint32_t, void*)) {
	stringstream output;
	output << "[";
	for (unsigned int j = 0; j<10; j++) {
		double start = omp_get_wtime();
		uint32_t* outx86_32 = (uint32_t*)malloc(sizeof(uint32_t));
		for (unsigned int i = 0; i<times; i++) {
			fptr(payload, size, 0, outx86_32);
		}
		free(outx86_32);
		double end = omp_get_wtime();

		if (j != 0) {
			output << ", ";
		}
		output << end - start;
	}
	output << "]";
	return output.str();
}

void benchmark_scenarios(char* payload, void(*fptr)(const void*, int, uint32_t, void*)) {
	uint32_t* out = (uint32_t*)malloc(sizeof(uint32_t)* 4);
	cout << "  \"pl_5B\": "     << benchmark(payload, 5, 50000000, out, fptr)      << "," << endl;
	cout << "  \"pl_15B\": "    << benchmark(payload, 15, 25000000, out, fptr)     << "," << endl;
	cout << "  \"pl_256B\": "   << benchmark(payload, 256, 5000000, out, fptr)     << "," << endl;
	cout << "  \"pl_256KiB\": " << benchmark(payload, 256 * 1024, 5000, out, fptr) << "," << endl;
	cout << "  \"pl_256MiB\": " << benchmark(payload, 256 * 1024 * 1024, 10, out, fptr)   << endl;
	free(out);
}

int main( int argc, const char* argv[] ) {

	// Generate the payload in memory
	unsigned int size = 256*1024*1024;
	char* payload = (char*)malloc(size);
	for(unsigned int i=0; i<size; i++) {
		payload[i] = (char)(((i*4)%25)+'A');
	}

	// Execute all scenarios and write to the standard output in JSON format
	cout << "{" << endl;
	cout << " \"x86_32\": {" << endl;
	benchmark_scenarios(payload, &MurmurHash3_x86_32);
	cout << " }," << endl;
	cout << " \"x86_128\": {" << endl;
	benchmark_scenarios(payload, &MurmurHash3_x86_128);
	cout << " }," << endl;
	cout << " \"x64_128\": {" << endl;
	benchmark_scenarios(payload, &MurmurHash3_x64_128);
	cout << " }" << endl;
	cout << "}" << endl;

	// Free payload
	free(payload);

	return 0;
}

