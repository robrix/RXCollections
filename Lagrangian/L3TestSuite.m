//  L3TestSuite.m
//  Created by Rob Rix on 2012-11-07.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3TestCase.h"
#import "L3TestSuite.h"
#import "L3TestState.h"
#import "Lagrangian.h"

@l3_suite_interface(L3TestSuite, "Test suites") <L3EventObserver>
@property NSMutableArray *events;
@end

@l3_set_up {
	test.events = [NSMutableArray new];
}


NSString * const L3TestSuiteSetUpStepName = @"set up";
NSString * const L3TestSuiteTearDownStepName = @"tear down";


@interface L3TestSuite ()

@property (copy, nonatomic, readwrite) NSString *name;

@property (copy, nonatomic, readwrite) NSString *file;
@property (assign, nonatomic, readwrite) NSUInteger line;

@property (strong, nonatomic, readonly) NSMutableArray *mutableTests;
@property (strong, nonatomic, readonly) NSMutableDictionary *mutableTestsByName;

@property (strong, nonatomic, readonly) NSMutableDictionary *mutableSteps;

@property (strong, nonatomic, readonly) NSOperationQueue *queue;

@end

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


+(instancetype)testSuiteWithName:(NSString *)name file:(NSString *)file line:(NSUInteger)line {
	return [[self alloc] initWithName:name file:file line:line];
}

+(instancetype)testSuiteWithName:(NSString *)name {
	return [[self alloc] initWithName:name file:nil line:0];
}

-(instancetype)initWithName:(NSString *)name file:(NSString *)file line:(NSUInteger)line {
	NSParameterAssert(name != nil);
	if ((self = [super init])) {
		_name = [name copy];
		
		_file = [file copy];
		_line = line;
		
		_stateClass = [L3TestState class];
		
		_mutableTests = [NSMutableArray new];
		_mutableTestsByName = [NSMutableDictionary new];
		
		_mutableSteps = [NSMutableDictionary new];
		
		_queue = [NSOperationQueue new];
		_queue.maxConcurrentOperationCount = 1;
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
#pragma mark Steps

-(void)addStep:(L3TestStep *)step {
	NSParameterAssert(step != nil);
	NSParameterAssert([self.steps objectForKey:step.name] == nil);
	
	[self.mutableSteps setObject:step forKey:step.name];
}


-(NSDictionary *)steps {
	return self.mutableSteps;
}


#pragma mark -
#pragma mark L3Test

@l3_test("generate test start events when starting to run") {
	L3TestSuite *testSuite = [L3TestSuite testSuiteWithName:[NSString stringWithFormat:@"%@ test suite", _case.name]];
	[testSuite runInSuite:nil eventObserver:test];
	if (l3_assert(test.events.count, l3_greaterThanOrEqualTo(1u))) {
		NSDictionary *event = test.events[0];
		l3_assert(event[@"name"], l3_equals(testSuite.name));
		l3_assert(event[@"type"], l3_equals(@"start"));
	}
}

@l3_test("generate test end events when done running") {
	L3TestSuite *testSuite = [L3TestSuite testSuiteWithName:[NSString stringWithFormat:@"%@ test suite", _case.name]];
	[testSuite runInSuite:nil eventObserver:test];
	NSDictionary *event = test.events.lastObject;
	l3_assert(event[@"name"], l3_equals(testSuite.name));
	l3_assert(event[@"type"], l3_equals(@"end"));
}

-(void)runInSuite:(L3TestSuite *)suite eventObserver:(id<L3EventObserver>)eventObserver {
	self.queue.suspended = YES;
	
	[self.queue addOperationWithBlock:^{
		[eventObserver testStartEventWithTest:self date:[NSDate date]];
	}];
	
	for (id<L3Test> test in self.tests) {
		[self.queue addOperationWithBlock:^{
			[test runInSuite:self eventObserver:eventObserver];
		}];
	}
	
	[self.queue addOperationWithBlock:^{
		[eventObserver testEndEventWithTest:self date:[NSDate date]];
	}];
	self.queue.suspended = NO;
	
	[self.queue waitUntilAllOperationsAreFinished];
}


-(bool)isComposite {
	return YES;
}

@end

@l3_suite_implementation (L3TestSuite)

-(void)testStartEventWithTest:(id<L3Test>)test date:(NSDate *)date {
	[self.events addObject:@{ @"name": test.name, @"date": date, @"type": @"start" }];
}

-(void)testEndEventWithTest:(id<L3Test>)test date:(NSDate *)date {
	[self.events addObject:@{ @"name": test.name, @"date": date, @"type": @"end" }];
}

-(void)assertionSuccessWithSourceReference:(L3SourceReference *)sourceReference date:(NSDate *)date {
	[self.events addObject:@{ @"sourceReference": sourceReference, @"date": date, @"type": @"success" }];
}

-(void)assertionFailureWithSourceReference:(L3SourceReference *)sourceReference date:(NSDate *)date {
	[self.events addObject:@{ @"sourceReference": sourceReference, @"date": date, @"type": @"success" }];
}

@end
