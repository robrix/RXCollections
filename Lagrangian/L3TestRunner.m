//  L3TestRunner.m
//  Created by Rob Rix on 2012-11-09.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#if !TARGET_OS_IPHONE
#import <Cocoa/Cocoa.h>
#endif
#import "L3OCUnitTestResultFormatter.h"
#import "L3StringInflections.h"
#import "L3TestResult.h"
#import "L3TestResultBuilder.h"
#import "L3TestRunner.h"
#import "L3TestSuite.h"
#import "Lagrangian.h"

NSString * const L3TestRunnerRunTestsOnLaunchEnvironmentVariableName = @"L3_RUN_TESTS_ON_LAUNCH";
NSString * const L3TestRunnerSuitePredicateEnvironmentVariableName = @"L3_SUITE_PREDICATE";

@l3_suite_interface (L3TestRunner) <L3EventObserver>
@property L3TestRunner *runner;
@property NSMutableArray *events;
@end


@interface L3TestRunner () <L3TestResultFormatterDelegate, L3TestVisitor>

@property (strong, nonatomic, readonly) NSMutableArray *mutableTests;
@property (strong, nonatomic, readonly) NSMutableDictionary *mutableTestsByName;

@property (strong, nonatomic, readonly) L3TestResultBuilder *testResultBuilder;
@property (strong, nonatomic, readonly) id<L3TestResultFormatter> testResultFormatter;
@property (strong, nonatomic) id<L3EventObserver> eventObserver;

@property (strong, nonatomic, readonly) NSOperationQueue *queue;

@property (strong, nonatomic, readonly) id<L3Test> test;

-(void)runAtLaunch;

@end


@l3_set_up {
	test.runner = [L3TestRunner new];
	test.events = [NSMutableArray new];
	test.runner.eventObserver = test;
}

@l3_tear_down {
	test.runner.eventObserver = nil; // break the retain cycle
}


@implementation L3TestRunner

+(bool)shouldRunTestsAtLaunch {
	return [[NSProcessInfo processInfo].environment[L3TestRunnerRunTestsOnLaunchEnvironmentVariableName] boolValue];
}

+(bool)isRunningInApplication {
#if TARGET_OS_IPHONE
	return YES;
#else
	return
		([NSApplication class] != nil)
	&&	[[NSBundle mainBundle].bundlePath.pathExtension isEqualToString:@"app"];
#endif
}

+(NSPredicate *)defaultPredicate {
	NSString *environmentPredicateFormat = [NSProcessInfo processInfo].environment[L3TestRunnerSuitePredicateEnvironmentVariableName];
	NSPredicate *applicationPredicate = [NSPredicate predicateWithFormat:@"(imagePath = NULL) || (imagePath CONTAINS[cd] %@)", [NSBundle mainBundle].bundlePath.lastPathComponent];
	return
		(environmentPredicateFormat? [NSPredicate predicateWithFormat:environmentPredicateFormat] : nil)
	?:	(self.isRunningInApplication? applicationPredicate : nil);
}


#pragma mark Constructors

+(instancetype)runner {
	static L3TestRunner *runner = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		runner = [self new];
	});
	return runner;
}

static void __attribute__((constructor)) L3TestRunnerLoader() {
	L3TestRunner *runner = [L3TestRunner runner];
	
	if ([L3TestRunner shouldRunTestsAtLaunch]) {
		[runner runAtLaunch];
	}
}

-(instancetype)init {
	if ((self = [super init])) {
		_mutableTests = [NSMutableArray new];
		_mutableTestsByName = [NSMutableDictionary new];
		
		_testResultFormatter = [L3OCUnitTestResultFormatter new];
		_testResultFormatter.delegate = self;
		
		_testResultBuilder = [L3TestResultBuilder new];
		_testResultBuilder.delegate = _testResultFormatter;
		
		_eventObserver = _testResultBuilder;
		
		_queue = [NSOperationQueue new];
		_queue.maxConcurrentOperationCount = 1;
		
		_test = [L3TestSuite defaultSuite];
		
		_testSuitePredicate = [self.class defaultPredicate];
	}
	return self;
}


#pragma mark Running

-(void)runAtLaunch {
#if TARGET_OS_IPHONE
#else
	if ([self.class isRunningInApplication]) {
		__block id observer = [[NSNotificationCenter defaultCenter] addObserverForName:NSApplicationDidFinishLaunchingNotification object:nil queue:self.queue usingBlock:^(NSNotification *note) {
			
			[self run];
			
			[[NSNotificationCenter defaultCenter] removeObserver:observer name:NSApplicationDidFinishLaunchingNotification object:nil];
			
			[self.queue addOperationWithBlock:^{
				[[NSApplication sharedApplication] terminate:nil];
			}];
		}];
	} else {
		[self.queue addOperationWithBlock:^{
			[self run];
			
			[self.queue addOperationWithBlock:^{
				system("/usr/bin/osascript -e 'tell application \"Xcode\" to activate'");
				
				if ([self.class isRunningInApplication])
					[[NSApplication sharedApplication] terminate:nil];
				else
					exit(0);
			}];
		}];
	}
#endif
}

-(void)run {
	[self runTest:self.test];
}

-(void)waitForTestsToComplete {
	[self.queue waitUntilAllOperationsAreFinished];
}

-(void)runTest:(id<L3Test>)test {
	NSParameterAssert(test != nil);
	
	[test acceptVisitor:self];
}


#pragma mark L3TestResultFormatterDelegate

-(void)formatter:(id<L3TestResultFormatter>)formatter didFormatResult:(L3TestResult *)result asString:(NSString *)string {
	if (string) {
		fprintf(stdout, "%s\n", string.UTF8String);
		fflush(stdout);
	}
}


#pragma mark L3TestVisitor

static void test_function(L3TestState *state, L3TestCase *testCase) {}

@l3_test("generates start events for cases") {
	L3TestCase *testCase = [L3TestCase testCaseWithName:@"name" file:@"" __FILE__ line:__LINE__ function:test_function];
	
	[test.runner testCase:testCase inTestSuite:nil];
	
	[test.runner waitForTestsToComplete];

	if (l3_assert(test.events.count, l3_greaterThanOrEqualTo(1))) {
		NSDictionary *event = test.events[0];
		l3_assert(event[@"name"], l3_equals(@"name"));
		l3_assert(event[@"type"], l3_equals(@"start"));
	}
}

@l3_test("generates end events after running cases") {
	L3TestCase *testCase = [L3TestCase testCaseWithName:@"name" file:@"" __FILE__ line:__LINE__ function:test_function];
	
	[test.runner testCase:testCase inTestSuite:nil];
	
	[test.runner waitForTestsToComplete];
	
	l3_assert(test.events.count, l3_greaterThanOrEqualTo(1));
	NSDictionary *event = test.events.lastObject;
	l3_assert(event[@"name"], l3_equals(@"name"));
	l3_assert(event[@"type"], l3_equals(@"end"));
}

static void asynchronousTest(L3TestState *test, L3TestCase *self);
static void asynchronousTest(L3TestState *test, L3TestCase *self) {
	test.timeout = 0;
	l3_defer();
}

@l3_test("generates failures when asynchronous tests time out") {
	L3TestSuite *suite = [L3TestSuite testSuiteWithName:@"suite"];
	L3TestCase *testCase = [L3TestCase testCaseWithName:@"case" file:@"file.m" line:42 function:asynchronousTest];
	
	[test.runner testCase:testCase inTestSuite:suite];
	
	[test.runner waitForTestsToComplete];
	
	if (l3_assert(test.events.count, l3_greaterThanOrEqualTo(2))) {
		NSDictionary *event = test.events[test.events.count - 2];
		l3_assert(event[@"type"], l3_equals(@"failure"));
		l3_assert([event[@"sourceReference"] subject], l3_equals(testCase));
	}
}

-(void)testCase:(L3TestCase *)testCase inTestSuite:(L3TestSuite *)suite {
//	if (!self.testCasePredicate || [self.testCasePredicate evaluateWithObject:testCase])
	
	[self.queue addOperationWithBlock:^{
		[self.eventObserver testStartEventWithTest:testCase date:[NSDate date]];
		
		L3TestState *state = [[suite.stateClass alloc] initWithSuite:suite eventObserver:self.eventObserver];
		
		[testCase setUp:suite.steps[L3TestSuiteSetUpStepName] withState:state];
		
		testCase.function(state, testCase);
		
		if (state.isDeferred)
			[testCase assertThat:l3_to_object([state wait]) matches:l3_to_pattern(YES) sourceReference:testCase.sourceReferenceForCaseEvents eventObserver:self.eventObserver];
		
		[testCase tearDown:suite.steps[L3TestSuiteTearDownStepName] withState:state];
		
		[self.eventObserver testEndEventWithTest:testCase date:[NSDate date]];
	}];
}


@l3_test("generates start events for suites") {
	L3TestSuite *testSuite = [L3TestSuite testSuiteWithName:[NSString stringWithFormat:@"%@ test suite", self.name]];
	
	[test.runner testSuite:testSuite inTestSuite:nil withChildren:^{}];
	
	[test.runner waitForTestsToComplete];
	
	if (l3_assert(test.events.count, l3_greaterThanOrEqualTo(1))) {
		NSDictionary *event = test.events[0];
		l3_assert(event[@"name"], l3_equals(testSuite.name));
		l3_assert(event[@"type"], l3_equals(@"start"));
	}
}

@l3_test("generates end events after running suites") {
	L3TestSuite *testSuite = [L3TestSuite testSuiteWithName:[NSString stringWithFormat:@"%@ test suite", self.name]];
	
	[test.runner testSuite:testSuite inTestSuite:nil withChildren:^{}];
	
	[test.runner waitForTestsToComplete];
	
	NSDictionary *event = test.events.lastObject;
	l3_assert(event[@"name"], l3_equals(testSuite.name));
	l3_assert(event[@"type"], l3_equals(@"end"));
}

@l3_test("filters test suites with a predicate") {
	test.runner.testSuitePredicate = [NSPredicate predicateWithBlock:^BOOL(L3TestSuite *evaluatedObject, NSDictionary *bindings) {
		return NO;
	}];
	
	L3TestSuite *suite = [L3TestSuite testSuiteWithName:@"suite"];
	
	[test.runner testSuite:suite inTestSuite:nil withChildren:^{}];
	
	l3_assert(test.events, l3_equals(@[]));
}

-(void)testSuite:(L3TestSuite *)testSuite inTestSuite:(L3TestSuite *)suite withChildren:(void(^)())block {
	if (!self.testSuitePredicate || [self.testSuitePredicate evaluateWithObject:testSuite]) {
		[self.queue addOperationWithBlock:^{
			[self.eventObserver testStartEventWithTest:testSuite date:[NSDate date]];
		}];
		
		block();
		
		[self.queue addOperationWithBlock:^{
			[self.eventObserver testEndEventWithTest:testSuite date:[NSDate date]];
		}];
	}
}

@end

@l3_suite_implementation (L3TestRunner)

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
	[self.events addObject:@{ @"sourceReference": sourceReference, @"date": date, @"type": @"failure" }];
}

@end
