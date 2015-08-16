//
//  BenchmarkObjCWrapper.h
//  LastTestORBSlam
//
//  Created by Alexander on 28.05.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#ifndef __LastTestORBSlam__BenchmarkCPPWrapper__
#define __LastTestORBSlam__BenchmarkCPPWrapper__

#import <string>


#define AG_BENCHMARK_CPP(__identifier) \
for (bool finished = !Benchmark_start(__identifier); !finished; finished = true, Benchmark_stop(__identifier))

// This wrappers for C++ code.
// http://stackoverflow.com/questions/1061005/calling-objective-c-method-from-c-method

bool AGBenchmark_start(std::string identifier);
bool AGBenchmark_stop(std::string identifier);

#endif /* defined(__LastTestORBSlam__BenchmarkCPPWrapper__) */
