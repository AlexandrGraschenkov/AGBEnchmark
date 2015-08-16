//
//  ViewController.m
//  ExampleBenchmarkUsage
//
//  Created by Alexander on 16.08.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import "ViewController.h"
#import "AGBenchmark.h"

@interface ViewController ()
{
    dispatch_queue_t bg;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    bg = dispatch_queue_create("Bg", DISPATCH_QUEUE_SERIAL);
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:[AGBenchmark class] selector:@selector(logBenchmarkInfo) userInfo:nil repeats:YES];
    
//    [AGBenchmark setLogingInformatin:AGBenchmarkLogLastNTimesAvg];
    dispatch_async(bg, ^{
        [self compareSortAlgoritms];
    });
    
    AGBenchmarkBlock(@"NSLog method", ^{
        NSLog(@"123");
    });
}

- (void)compareSortAlgoritms {
    NSMutableArray *arr1 = [self generateRandomArr];
    NSMutableArray *arr2 = [arr1 mutableCopy];
    
    AG_BENCHMARK(@"Default sort algoritm") {
        [arr1 sortUsingSelector:@selector(compare:)];
    }
    AG_BENCHMARK(@"Insertion sort algoritm") {
        [self insertionSort:arr2];
    }
    
    if (![self checkIsSorted:arr2]) {
        NSLog(@"The insertion sort algorithm not work");
    }
    
    // For avoid nested call, call stack may overflow
    dispatch_async(bg, ^{
        [self compareSortAlgoritms];
    });
}

- (NSMutableArray *)generateRandomArr {
    NSMutableArray *result = [NSMutableArray new];
    for (NSInteger i = 0; i < 10000; i++) {
        NSInteger randInt = arc4random() % 1000000;
        [result addObject:@(randInt)];
    }
    return result;
}

- (void)insertionSort:(NSMutableArray *)arr {
    NSInteger count = arr.count;
    for (NSInteger i = 0; i < count-1; i++) {
        NSInteger minIdx = i;
        for (NSInteger j = i + 1; j < count; j++) {
            if ([arr[minIdx] compare:arr[j]] == NSOrderedDescending) {
                minIdx = j;
            }
        }
        if (minIdx != i) {
            [arr exchangeObjectAtIndex:minIdx withObjectAtIndex:i];
        }
    }
}

- (BOOL)checkIsSorted:(NSMutableArray *)arr {
    for (NSInteger i = 0; i < arr.count - 1; i++) {
        if ([arr[i] compare:arr[i+1]] == NSOrderedDescending) {
            return false;
        }
    }
    return true;
}

@end


