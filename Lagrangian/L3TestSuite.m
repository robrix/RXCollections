//  L3TestSuite.m
//  Created by Rob Rix on 2012-11-07.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3TestCase.h"
#import "L3TestSuite.h"
#import "L3TestState.h"
#import "Lagrangian.h"

@interface L3TestSuite () <L3TestContext>

@property (copy, nonatomic, readwrite) NSString *name;

@property (strong, nonatomic, readonly) NSMutableArray *mutableTests;
@property (strong, nonatomic, readonly) NSMutableDictionary *mutableTestsByName;

@end

@l3_suite("Test suites", L3TestSuite) <L3EventAlgebra>
@property NSMutableArray *events;
@end

@l3_set_up {
	test.events = [NSMutableArray new];
}

@implementation L3TestSuite

#pragma mark -
#pragma mark Constructors

+(instancetype)defaultSuite {
	static L3TestSuite *defaultSuite = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		defaultSuite = [self testSuiteWithName:[NSBundle mainBundle].bundlePath.lastPathComponent ?: [NSProcessInfo processInfo].processName];
	});
	return defaultSuite;
}


+(instancetype)testSuiteWithName:(NSString *)name {
	return [[self alloc] initWithName:name];
}

-(instancetype)initWithName:(NSString *)name {
	NSParameterAssert(name != nil);
	if ((self = [super init])) {
		_name = [name copy];
		_mutableTests = [NSMutableArray new];
		_mutableTestsByName = [NSMutableDictionary new];
		_stateClass = [L3TestState class];
	}
	return self;
}


#pragma mark -
#pragma mark Tests

-(void)addTest:(id<L3Test>)test {
	NSParameterAssert(test != nil);
	NSParameterAssert([self.testsByName objectForKey:test.name] == nil);
	
	[self.mutableTests addObject:test];
	[self.mutableTestsByName setObject:test forKey:test.name];
}


-(NSArray *)tests {
	return self.mutableTests;
}

-(NSDictionary *)testsByName {
	return self.mutableTestsByName;
}


-(void)setStateClass:(Class)stateClass {
	NSAssert(stateClass != nil, @"No state class found for suite ‘%@’. Did you forget to add a @l3_suite_implementation for this suite? Did you add one but give it the wrong name?", self.name);
	_stateClass = stateClass;
}


#pragma mark -
#pragma mark L3Test

@l3_test("generate test start events when starting to run") {
	L3TestSuite *testSuite = [L3TestSuite testSuiteWithName:[NSString stringWithFormat:@"%@ test suite", _case.name]];
	[testSuite runInContext:nil eventAlgebra:test];
	if (l3_assert(test.events.count, l3_greaterThanOrEqualTo(1u))) {
		NSDictionary *event = test.events[0];
		l3_assert(event[@"name"], l3_equals(testSuite.name));
		l3_assert(event[@"type"], l3_equals(@"start"));
	}
}

@l3_test("generate test end events when done running") {
	L3TestSuite *testSuite = [L3TestSuite testSuiteWithName:[NSString stringWithFormat:@"%@ test suite", _case.name]];
	[testSuite runInContext:nil eventAlgebra:test];
	NSDictionary *event = test.events.lastObject;
	l3_assert(event[@"name"], l3_equals(testSuite.name));
	l3_assert(event[@"type"], l3_equals(@"end"));
}

-(void)runInContext:(id<L3TestContext>)context eventAlgebra:(id<L3EventAlgebra>)eventAlgebra {
	[eventAlgebra testStartEventWithTest:self date:[NSDate date]];
	for (id<L3Test> test in self.tests) {
		[test runInContext:self eventAlgebra:eventAlgebra];
	}
	[eventAlgebra testEndEventWithTest:self date:[NSDate date]];
}


-(bool)isComposite {
	return YES;
}

@end

@l3_suite_implementation (L3TestSuite)

-(id)testStartEventWithTest:(id<L3Test>)test date:(NSDate *)date {
	[self.events addObject:@{ @"name": test.name, @"date": date, @"type": @"start" }];
	return nil;
}

-(id)testEndEventWithTest:(id<L3Test>)test date:(NSDate *)date {
	[self.events addObject:@{ @"name": test.name, @"date": date, @"type": @"end" }];
	return nil;
}

-(id)assertionSuccessWithAssertionReference:(L3AssertionReference *)assertionReference date:(NSDate *)date {
	[self.events addObject:@{ @"assertionReference": assertionReference, @"date": date, @"type": @"success" }];
	return nil;
}

-(id)assertionFailureWithAssertionReference:(L3AssertionReference *)assertionReference date:(NSDate *)date {
	[self.events addObject:@{ @"assertionReference": assertionReference, @"date": date, @"type": @"success" }];
	return nil;
}

@end
