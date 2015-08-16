//
//  Benchmark.h
//  LastTestORBSlam
//
//  Created by Alexander on 28.05.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AG_BENCHMARK(__identifier) \
for (BOOL finished = ![AGBenchmark startMeasureWithIdentifier:__identifier]; !finished; finished = YES, [AGBenchmark stopMeasureWithIdentifier:__identifier])

#if defined __cplusplus
extern "C" {
#endif
    
void AGBenchmarkBlock(NSString *, void(^)());
    
#if defined __cplusplus
};
#endif


typedef NS_OPTIONS(NSUInteger, AGBenchmarkLog)
{
    AGBenchmarkLogTotal = 1 << 0,
    AGBenchmarkLogAverage = 1 << 1,
    AGBenchmarkLogLastNTimesAvg = 1 << 2,
    AGBenchmarkLogCallTimes = 1 << 3
};

@interface AGBenchmark : NSObject

// by default all is enabled
+ (void)setLogingInformatin:(AGBenchmarkLog)logInfo;

// return in most cases true; This is use for define BENCHMARK(@"") macros
+ (BOOL)startMeasureWithIdentifier:(NSString *)identifier;
+ (BOOL)stopMeasureWithIdentifier:(NSString *)identifier;

+ (void)logBenchmarkInfo;
+ (NSString *)getBenchmarkInfoString;
+ (NSArray *)getBenchmarkInfo;

@end



@interface AGBenchmarkInfo : NSObject
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSTimeInterval total;
@property (nonatomic, readonly) NSTimeInterval average;
@property (nonatomic, readonly) NSTimeInterval lastTenTimes;
@property (nonatomic, readonly) NSInteger callTimes;
@end
