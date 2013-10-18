#import <Foundation/Foundation.h>
#import <RXCollections/RXSparseArray.h>
#import <mach/mach.h>

@class L3Benchmark;
@interface L3BenchmarkInterval : NSObject

+(instancetype)currentInterval;

@property (nonatomic, readonly) NSTimeInterval time;
@property (nonatomic, readonly) NSInteger space;

-(instancetype)subtract:(L3BenchmarkInterval *)other;

@end


@interface L3BenchmarkResult : NSObject

-(instancetype)initWithBenchmark:(L3Benchmark *)benchmark subject:(id)subject startInterval:(L3BenchmarkInterval *)startInterval endInterval:(L3BenchmarkInterval *)endInterval iterationCount:(NSUInteger)iterationCount;

@property (nonatomic, readonly) L3Benchmark *benchmark;
@property (nonatomic, readonly) id subject;

@property (nonatomic, readonly) L3BenchmarkInterval *startInterval;
@property (nonatomic, readonly) L3BenchmarkInterval *endInterval;
@property (nonatomic, readonly) L3BenchmarkInterval *interval;

@property (nonatomic, readonly) NSUInteger iterationCount;

@end


typedef id (^L3BenchmarkBlock)(NSUInteger count);

@interface L3Benchmark : NSObject

-(instancetype)initWithName:(NSString *)name block:(L3BenchmarkBlock)block;

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) L3BenchmarkBlock block;

-(L3BenchmarkResult *)runNumberOfIterations:(NSUInteger)iterationCount;

@end


@implementation L3BenchmarkInterval

+(NSInteger)currentSpace {
	struct mach_task_basic_info info;
	mach_msg_type_number_t size = sizeof(info);
	kern_return_t kerr = task_info(mach_task_self(),
								   MACH_TASK_BASIC_INFO,
								   (task_info_t)&info,
								   &size);
	return kerr == KERN_SUCCESS?
		info.resident_size
	:	-1;
}

+(NSTimeInterval)currentTime {
	return [NSDate timeIntervalSinceReferenceDate];
}

+(instancetype)currentInterval {
	NSInteger space = [self currentSpace];
	return [[self alloc] initWithTime:[self currentTime] space:space];
}

-(instancetype)initWithTime:(NSTimeInterval)time space:(NSInteger)space {
	if ((self = [super init])) {
		_time = time;
		_space = space;
	}
	return self;
}

-(instancetype)subtract:(L3BenchmarkInterval *)other {
	return [[self.class alloc] initWithTime:self.time - other.time space:self.space - other.space];
}

-(NSString *)description {
	return [NSString stringWithFormat:@"%gs, %liB", self.time, self.space];
}

@end


@implementation L3BenchmarkResult

-(instancetype)initWithBenchmark:(L3Benchmark *)benchmark subject:(id)subject startInterval:(L3BenchmarkInterval *)startInterval endInterval:(L3BenchmarkInterval *)endInterval iterationCount:(NSUInteger)iterationCount {
	if ((self = [super init])) {
		_benchmark = benchmark;
		_subject = subject;
		_startInterval = startInterval;
		_endInterval = endInterval;
		_interval = [endInterval subtract:startInterval];
		_iterationCount = iterationCount;
	}
	return self;
}

-(NSString *)description {
	return [NSString stringWithFormat:@"<L3BenchmarkResult: %@ @ %@>", self.benchmark.name, self.interval];
}

@end


@implementation L3Benchmark

-(instancetype)initWithName:(NSString *)name block:(L3BenchmarkBlock)block {
	if ((self = [super init])) {
		_name = [name copy];
		_block = [block copy];
	}
	return self;
}

-(L3BenchmarkResult *)runNumberOfIterations:(NSUInteger)iterationCount {
	id subject;
	L3BenchmarkInterval *start = [L3BenchmarkInterval currentInterval], *end;
	@autoreleasepool {
		subject = self.block(iterationCount);
		
		end = [L3BenchmarkInterval currentInterval];
	}
	
	return [[L3BenchmarkResult alloc] initWithBenchmark:self subject:subject startInterval:start endInterval:end iterationCount:iterationCount];
}

@end

int main(int argc, const char *argv[argc]) {
	@autoreleasepool {
		srandomdev();
		static const NSUInteger iterations = 1000;
		
		L3Benchmark *sortedSlotsBenchmark = [[L3Benchmark alloc] initWithName:@"RXMutableSparseArray" block:^(NSUInteger count) {
			NSMutableArray *array = [[RXMutableSparseArray alloc] initWithCapacity:count];
			
			for (NSUInteger i = 0; i < count; i++) {
				[array insertObject:@YES atIndex:random()];
			}
			
			return array;
		}];
		
		L3Benchmark *dictionaryBenchmark = [[L3Benchmark alloc] initWithName:@"NSMutableDictionary" block:^(NSUInteger count) {
			NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:count];
			
			for (NSUInteger i = 0; i < count; i++) {
				[dictionary setObject:@YES forKey:@(random())];
			}
			
			return dictionary;
		}];
		
		L3BenchmarkResult *sortedSlotsResult = [sortedSlotsBenchmark runNumberOfIterations:iterations];
		L3BenchmarkResult *dictionaryResult = [dictionaryBenchmark runNumberOfIterations:iterations];
		NSLog(@"%@", sortedSlotsResult);
		NSLog(@"%@", dictionaryResult);
		NSLog(@"%@", [sortedSlotsResult.interval subtract:dictionaryResult.interval]);
	}
    return EXIT_SUCCESS;
}
