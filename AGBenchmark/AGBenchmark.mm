//
//  Benchmark.m
//  LastTestORBSlam
//
//  Created by Alexander on 28.05.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import "AGBenchmark.h"
#import "AGBenchmarkCPPWrapper.h"
#import <vector>
#include <pthread.h>
#import <string.h>

#define CAPTURE_LAST_N_TIMES 10

#define INITALIZE_DICTIONARY_AND_LOCK_MUTEX \
\
dispatch_once(&onceToken, ^{ \
    pthread_mutex_init(&mutex, NULL); \
    identifierToIndexDictionary = [NSMutableDictionary new]; \
}); \
AGBenchmarkNamespace::Lock lock(&mutex);

namespace AGBenchmarkNamespace {
    class Lock {
    public:
        Lock(pthread_mutex_t *mutex);
        ~Lock();
    private:
        pthread_mutex_t *_mutex;
    };
    
    Lock::Lock(pthread_mutex_t *mutex) {
        _mutex = mutex;
        pthread_mutex_lock(_mutex);
    }
    
    Lock::~Lock() {
        pthread_mutex_unlock(_mutex);
    }
}

@interface AGBenchmarkInfo(hidden)
- (id)initWithName:(NSString *)name total:(NSTimeInterval)total average:(NSTimeInterval)average lastTenTimes:(NSTimeInterval)lastTenTimes callTimes:(NSInteger)callTimes;
@end

@interface AGStringWithTotalTime : NSObject
@property (nonatomic, assign) double totalTime;
@property (nonatomic, strong) NSString *str;

- (instancetype)initWithStr:(NSString *)str totalTime:(double)totalTime;
@end


struct AGMeasurmentInfo {
    double totalTime;
    unsigned long timesExecuted;
    CFAbsoluteTime lastStartTime;
    double lastNTimes[CAPTURE_LAST_N_TIMES];
    unsigned long startNTimesIdx;
};


void AGBenchmarkBlock(NSString *str, void(^block)()) {
    [AGBenchmark startMeasureWithIdentifier:str];
    block();
    [AGBenchmark stopMeasureWithIdentifier:str];
}

@implementation AGBenchmark
static NSMutableDictionary *identifierToIndexDictionary;
static dispatch_once_t onceToken;
static std::vector<AGMeasurmentInfo> measurmentVector;
static pthread_mutex_t mutex;
static AGBenchmarkLog _logInfo = AGBenchmarkLogAverage | AGBenchmarkLogCallTimes | AGBenchmarkLogLastNTimesAvg | AGBenchmarkLogTotal;


bool AGBenchmark_start(std::string identifier) {
    return [AGBenchmark startMeasureWithIdentifier:[NSString stringWithCString:identifier.c_str() encoding:[NSString defaultCStringEncoding]]];
}

bool AGBenchmark_stop(std::string identifier) {
    return [AGBenchmark stopMeasureWithIdentifier:[NSString stringWithCString:identifier.c_str() encoding:[NSString defaultCStringEncoding]]];
}


+ (void)setLogingInformatin:(AGBenchmarkLog)logInfo {
    _logInfo = logInfo;
}

+ (BOOL)startMeasureWithIdentifier:(NSString *)identifier {
    INITALIZE_DICTIONARY_AND_LOCK_MUTEX
    
    NSNumber *number = identifierToIndexDictionary[identifier];
    if (!number) {
        identifierToIndexDictionary[identifier] = @(measurmentVector.size());
        AGMeasurmentInfo info = {};
        info.lastStartTime = CFAbsoluteTimeGetCurrent();
        measurmentVector.push_back(info);
    } else {
        NSInteger idx = [number integerValue];
        if (measurmentVector[idx].lastStartTime >= 0) {
            NSAssert1(NO, @"Do not start measurment before you stop measurment with same identifier. Identifier: %@", identifier);
            return NO;
        }
        measurmentVector[idx].lastStartTime = CFAbsoluteTimeGetCurrent();
    }
    return YES;
}

+ (BOOL)stopMeasureWithIdentifier:(NSString *)identifier {
    INITALIZE_DICTIONARY_AND_LOCK_MUTEX
    
    NSNumber *number = identifierToIndexDictionary[identifier];
    BOOL isStartedMesurment = YES;
    if (number) {
        NSInteger idx = [number integerValue];
        isStartedMesurment = measurmentVector[idx].lastStartTime >= 0;
        if (isStartedMesurment) {
            AGMeasurmentInfo &measure = measurmentVector[idx];
            CFAbsoluteTime time = CFAbsoluteTimeGetCurrent() - measurmentVector[idx].lastStartTime;
            measure.totalTime += time;
            measure.timesExecuted++;
            measure.lastStartTime = -1;
            measure.lastNTimes[measure.startNTimesIdx % CAPTURE_LAST_N_TIMES] = time;
            measure.startNTimesIdx++;
        }
    }
    
    NSAssert1(isStartedMesurment, @"Start measurment before stop it. Identifier: %@", identifier);
    return NO;
}

+ (NSString *)getBenchmarkInfoString {
    INITALIZE_DICTIONARY_AND_LOCK_MUTEX
    
    NSMutableArray *stringWithTimeArr = [NSMutableArray new];
    for (NSString *key in identifierToIndexDictionary) {
        NSInteger idx = [identifierToIndexDictionary[key] integerValue];
        double totalTime = measurmentVector[idx].totalTime;
        long timesExecuted = measurmentVector[idx].timesExecuted;
        
        double lastTimesTotal = 0;
        long avaiableLastMeasurmentCount = MIN(measurmentVector[idx].startNTimesIdx, CAPTURE_LAST_N_TIMES);
        for (long i = 0; i < avaiableLastMeasurmentCount; i++) {
            lastTimesTotal += measurmentVector[idx].lastNTimes[i];
        }
        
        NSMutableString *str = [NSMutableString stringWithFormat:@"\"%@\":", key];
        if (_logInfo & AGBenchmarkLogTotal) {
            [str appendFormat:@" total: %.3lf;", totalTime];
        }
        if (_logInfo & AGBenchmarkLogAverage) {
            [str appendFormat:@" average: %.6lf;", totalTime / (double)timesExecuted];
        }
        if (_logInfo & AGBenchmarkLogLastNTimesAvg) {
            [str appendFormat:@" last %ld times avg: %.6lf;", avaiableLastMeasurmentCount, lastTimesTotal / (double)avaiableLastMeasurmentCount];
        }
        if (_logInfo & AGBenchmarkLogTotal) {
            [str appendFormat:@" call times: %ld;", timesExecuted];
        }

        [stringWithTimeArr addObject:[[AGStringWithTotalTime alloc] initWithStr:str totalTime:totalTime]];
    }
    [stringWithTimeArr sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"totalTime" ascending:YES]]];
    NSString *str = [NSString stringWithFormat:@"(%@) Benchmark:\n%@", [self currTime], [stringWithTimeArr componentsJoinedByString:@"\n"]];
    return str;
}

+ (NSString *)currTime {
    static NSDateFormatter *df = [NSDateFormatter new];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        df.dateFormat = @"HH:mm:ss.SSS";
    });
    return [df stringFromDate:[NSDate date]];
}

+ (void)logBenchmarkInfo {
    printf("%s\n", [[self getBenchmarkInfoString] UTF8String]);
}

+ (NSArray *)getBenchmarkInfo {
    NSMutableArray *result = [NSMutableArray new];
    for (NSString *key in identifierToIndexDictionary) {
        NSInteger idx = [identifierToIndexDictionary[key] integerValue];
        double totalTime = measurmentVector[idx].totalTime;
        long timesExecuted = measurmentVector[idx].timesExecuted;
        
        double lastTimesTotal = 0;
        long avaiableLastMeasurmentCount = MIN(measurmentVector[idx].startNTimesIdx, CAPTURE_LAST_N_TIMES);
        for (long i = 0; i < avaiableLastMeasurmentCount; i++) {
            lastTimesTotal += measurmentVector[idx].lastNTimes[i];
        }
        
        double lastTimes = lastTimesTotal / (double)avaiableLastMeasurmentCount;
        id info = [[AGBenchmarkInfo alloc] initWithName:key total:totalTime average:totalTime / (double)timesExecuted lastTenTimes:lastTimes callTimes:timesExecuted];
        [result addObject:info];
    }
    return result;
}

@end



@implementation AGStringWithTotalTime
- (instancetype)initWithStr:(NSString *)str totalTime:(double)totalTime
{
    self = [super init];
    if (self) {
        _str = str;
        _totalTime = totalTime;
    }
    return self;
}
- (NSString *)description {
    return _str;
}
@end

@implementation AGBenchmarkInfo

- (id)initWithName:(NSString *)name total:(NSTimeInterval)total average:(NSTimeInterval)average lastTenTimes:(NSTimeInterval)lastTenTimes callTimes:(NSInteger)callTimes {
    self = [super init];
    if (self) {
        _name = name;
        _total = total;
        _average = average;
        _lastTenTimes = lastTenTimes;
        _callTimes = callTimes;
    }
    return self;
}

@end
