#AGBenchmark

This is simple library for benchmark your ObjC, Swift and C++ code. You can watch how much time your code is spend. Some times algorithms begin work longer during the time.

For check how long the part of your code is executed, simple call:

###### Obj-C
```objective-c
AG_BENCHMARK(@"Sort algorithm") {
	[arr sortUsingSelector:@selector(compare:)];
}
```

###### C++
```c++
AG_BENCHMARK("Sort algorithm") {
	[arr sortUsingSelector:@selector(compare:)];
}
```

###### Swift
```swift
AGBenchmarkBlock("Sort algorithm") {
	arr.sortUsingSelector("compare:")
}
```

And then call `[AGBenchmark logBenchmarkInfo]`. Or you can call this method in timer:

###### ObjC
```objective-c
[NSTimer scheduledTimerWithTimeInterval:5.0 target:[AGBenchmark class] selector:@selector(logBenchmarkInfo) userInfo:nil repeats:YES];
```

In result you will get in log something like this:

```
(17:57:53.399) Benchmark:
"Default sort algoritm": total: 2.039; average: 0.005526; last 10 times avg: 0.005344; call times: 369;
"Insertion sort algoritm": total: 1485.237; average: 4.035970; last 10 times avg: 3.960172; call times: 368;
```

## Contact

Alexandr Graschenkov: alexandr.graschenkov91@gmail.com

## License

MagicPie is available under the MIT license.

Copyright © 2015 Alexandr Graschenkov.