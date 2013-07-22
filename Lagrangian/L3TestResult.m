//  L3TestResult.m
//  Created by Rob Rix on 2012-11-12.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3TestResult.h"
#import "Lagrangian.h"

@l3_suite_interface(L3TestResult, "Test results")
@property L3TestResult *result;
@property L3CompositeTestResult *compositeResult;
@end

@l3_set_up {
	test.result = [L3TestResult testResultWithName:self.name file:self.file line:self.line startDate:[NSDate date]];
	test.compositeResult = [L3CompositeTestResult testResultWithName:self.name file:self.file line:self.line startDate:[NSDate date]];
}


@interface L3AbstractTestResult (L3TestResult) <L3TestResult>
@end

@interface L3AbstractTestResult ()

-(instancetype)initWithName:(NSString *)name file:(NSString *)file line:(NSUInteger)line startDate:(NSDate *)startDate;

@property (weak, nonatomic) id<L3TestResult> parent;

@property (copy, nonatomic, readonly) NSString *name;
@property (copy, nonatomic, readonly) NSString *file;
@property (assign, nonatomic, readonly) NSUInteger line;
@property (strong, nonatomic, readonly) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (assign, nonatomic) NSTimeInterval totalDuration;

@end

@implementation L3AbstractTestResult

#pragma mark Constructors

+(id<L3TestResult>)testResultWithName:(NSString *)name file:(NSString *)file line:(NSUInteger)line startDate:(NSDate *)startDate {
	return [[self alloc] initWithName:name file:file line:line startDate:startDate];
}

-(instancetype)initWithName:(NSString *)name file:(NSString *)file line:(NSUInteger)line startDate:(NSDate *)startDate {
	NSParameterAssert(name != nil);
	NSParameterAssert(startDate != nil);
	if ((self = [super init])) {
		_name = name;
		_file = file;
		_line = line;
		_startDate = startDate;
	}
	return self;
}


#pragma mark Total duration

-(NSTimeInterval)totalDuration {
	return [self.endDate timeIntervalSinceDate:self.startDate];
}


#pragma mark Success/failure

@l3_test("succeed when no exceptions or assertion failures occurred") {
	l3_assert(test.result.succeeded, l3_is(YES));
}

-(bool)succeeded {
	return !self.failed;
}

@l3_test("fail when assertion failures occur") {
	test.result.assertionFailureCount = 1;
	l3_assert(test.result.failed, l3_is(YES));
}

@l3_test("fail when unexpected exceptions occur") {
	test.result.exceptionCount = 1;
	l3_assert(test.result.failed, l3_is(YES));
}

-(bool)failed {
	return (self.assertionFailureCount + self.exceptionCount) > 0;
}


#pragma mark Composition

-(NSArray *)testResults {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

-(void)addTestResult:(L3TestResult *)child {
	[self doesNotRecognizeSelector:_cmd];
}

@end


@interface L3TestResult ()
@end

@implementation L3TestResult

#pragma mark Properties

-(bool)isComposite {
	return NO;
}


@l3_test("atomic results return the span between their start and end dates as their duration") {
	test.result.endDate = [NSDate dateWithTimeInterval:1 sinceDate:test.result.startDate];
	l3_assert(test.result.duration, l3_equals(1.0));
}

-(NSTimeInterval)duration {
	return self.totalDuration;
}


-(NSUInteger)testCaseCount {
	return 1;
}


@synthesize assertionCount = _assertionCount;
@synthesize assertionFailureCount = _assertionFailureCount;
@synthesize exceptionCount = _exceptionCount;


#pragma mark Inherited properties

@dynamic parent;
@dynamic name;
@dynamic startDate;
@dynamic endDate;
@dynamic totalDuration;
@dynamic testResults;
@dynamic succeeded;
@dynamic failed;

@end


@interface L3CompositeTestResult ()

@property (strong, nonatomic, readonly) NSMutableArray *mutableTestResults;

@end

@implementation L3CompositeTestResult

#pragma mark Constructors

-(instancetype)initWithName:(NSString *)name file:(NSString *)file line:(NSUInteger)line startDate:(NSDate *)startDate {
	if ((self = [super initWithName:name file:file line:line startDate:startDate])) {
		_mutableTestResults = [NSMutableArray new];
	}
	return self;
}


#pragma mark Properties

-(bool)isComposite {
	return YES;
}


#pragma mark Recursive properties

@l3_test("composite results sum their children’s durations") {
	L3TestResult *child = [L3TestResult testResultWithName:@"child" file:@"" __FILE__ line:__LINE__ startDate:[NSDate dateWithTimeIntervalSinceNow:-1]];
	child.endDate = [NSDate date];
	[test.compositeResult addTestResult:child];
	child = [L3TestResult testResultWithName:@"child" file:@"" __FILE__ line:__LINE__ startDate:[NSDate dateWithTimeIntervalSinceNow:-1]];
	child.endDate = [NSDate date];
	[test.compositeResult addTestResult:child];
	l3_assert(test.compositeResult.duration, l3_equalsWithEpsilon(2.0, 0.0001));
}

-(NSTimeInterval)duration {
	return [[self.testResults valueForKeyPath:@"@sum.duration"] doubleValue];
}

-(NSUInteger)testCaseCount {
	return [[self.testResults valueForKeyPath:@"@sum.testCaseCount"] unsignedIntegerValue];
}


-(NSUInteger)assertionCount {
	return [[self.testResults valueForKeyPath:@"@sum.assertionCount"] unsignedIntegerValue];
}

-(void)setAssertionCount:(NSUInteger)assertionCount {}

-(NSUInteger)assertionFailureCount {
	return [[self.testResults valueForKeyPath:@"@sum.assertionFailureCount"] unsignedIntegerValue];
}

-(void)setAssertionFailureCount:(NSUInteger)assertionFailureCount {}

-(NSUInteger)exceptionCount {
	return [[self.testResults valueForKeyPath:@"@sum.exceptionCount"] unsignedIntegerValue];
}

-(void)setExceptionCount:(NSUInteger)exceptionCount {}


#pragma mark Inherited properties

@dynamic parent;
@dynamic name;
@dynamic startDate;
@dynamic endDate;
@dynamic totalDuration;
@dynamic succeeded;
@dynamic failed;


#pragma mark Composite

-(NSArray *)testResults {
	return _mutableTestResults;
}

-(void)addTestResult:(L3TestResult *)child {
	[self.mutableTestResults addObject:child];
}

@end


@l3_suite_implementation (L3TestResult)
@end
