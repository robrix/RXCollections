//  L3TestResult.m
//  Created by Rob Rix on 2012-11-12.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3TestResult.h"
#import "Lagrangian.h"

@interface L3TestResult ()

@property (strong, nonatomic, readonly) NSMutableArray *mutableTestResults;

@end

@implementation L3TestResult

@l3_suite("Test results");

#pragma mark -
#pragma mark Constructors

+(instancetype)testResultWithName:(NSString *)name startDate:(NSDate *)startDate {
	return [[self alloc] initWithName:name startDate:startDate];
}

-(instancetype)initWithName:(NSString *)name startDate:(NSDate *)startDate {
	NSParameterAssert(name != nil);
	NSParameterAssert(startDate != nil);
	if ((self = [super init])) {
		_name = name;
		_startDate = startDate;
		_mutableTestResults = [NSMutableArray new];
	}
	return self;
}


@l3_test("store duration") {
	L3TestResult *result = [L3TestResult testResultWithName:@"name" startDate:[NSDate date]];
	result.duration = 1.0;
	l3_assert(result.duration, l3_is(1.0));
}

@l3_test("sum their children’s durations with their own") {
	L3TestResult *result = [L3TestResult testResultWithName:@"parent" startDate:[NSDate date]];
	result.duration = 1.0;
	L3TestResult *child = [L3TestResult testResultWithName:@"child" startDate:[NSDate date]];
	child.duration = 1.0;
	[result addTestResult:child];
	l3_assert(result.duration, l3_is(2.0));
}


#pragma mark -
#pragma mark Composition

-(NSArray *)testResults {
	return _mutableTestResults;
}

-(void)addTestResult:(L3TestResult *)child {
	[self.mutableTestResults addObject:child];
	_duration += child.duration;
	_testCaseCount += child.testCaseCount;
	_assertionCount += child.assertionCount;
	_assertionFailureCount += child.assertionFailureCount;
	_exceptionCount += child.exceptionCount;
}

@end
