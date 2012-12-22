//  L3TestRunner.m
//  Created by Rob Rix on 2012-11-09.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Cocoa/Cocoa.h>
#import "L3OCUnitTestResultFormatter.h"
#import "L3StringInflections.h"
#import "L3TestResult.h"
#import "L3TestResultBuilder.h"
#import "L3TestRunner.h"
#import "L3TestSuite.h"
#import "Lagrangian.h"

@l3_suite_interface (L3TestRunner) <L3EventObserver>
@property L3TestRunner *runner;
@property NSMutableArray *events;
@end


@interface L3TestRunner () <L3TestResultBuilderDelegate, L3TestResultFormatterDelegate, L3TestVisitor>

@property (strong, nonatomic, readonly) NSMutableArray *mutableTests;
@property (strong, nonatomic, readonly) NSMutableDictionary *mutableTestsByName;

@property (strong, nonatomic, readonly) L3TestResultBuilder *testResultBuilder;
@property (strong, nonatomic, readonly) id<L3TestResultFormatter> testResultFormatter;
@property (strong, nonatomic) id<L3EventObserver> eventObserver;

@property (strong, nonatomic, readonly) NSOperationQueue *queue;

@property (strong, nonatomic) NSPredicate *testSuitePredicate;

@property (strong, nonatomic, readonly) id<L3Test> test;

@property (assign, nonatomic) bool didRunAutomatically;

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
	[runner self]; // silences a warning
		
	// fixme: this decision needs to be made elsewhere
#if L3_RUN_TESTS_ON_LAUNCH
	[runner runAtLaunch];
#endif
}

-(instancetype)init {
	if ((self = [super init])) {
		_mutableTests = [NSMutableArray new];
		_mutableTestsByName = [NSMutableDictionary new];
		
		_testResultBuilder = [L3TestResultBuilder new];
		_testResultBuilder.delegate = self;
		
		_testResultFormatter = [L3OCUnitTestResultFormatter new];
		_testResultFormatter.delegate = self;
		
		_eventObserver = _testResultBuilder;
		
		_queue = [NSOperationQueue new]; // should this actually be the main queue?
		_queue.maxConcurrentOperationCount = 1;
		
		_test = [L3TestSuite defaultSuite];
	}
	return self;
}


#pragma mark Running

-(void)runAtLaunch {
	if ([NSApplication class]) {
		__block id observer = [[NSNotificationCenter defaultCenter] addObserverForName:NSApplicationDidFinishLaunchingNotification object:nil queue:self.queue usingBlock:^(NSNotification *note) {
			
			self.didRunAutomatically = YES;
			
			[self run];
			
			[[NSNotificationCenter defaultCenter] removeObserver:observer name:NSApplicationDidFinishLaunchingNotification object:nil];
		}];
	} else {
		[self run];
	}
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

-(void)formatter:(id<L3TestResultFormatter>)formatter didFormatResult:(NSString *)string {
	if (string)
		printf("%s\n", string.UTF8String);
}


#pragma mark L3TestResultBuilderDelegate

-(void)testResultBuilder:(L3TestResultBuilder *)builder testResultDidStart:(L3TestResult *)result {
	[self.testResultFormatter testResultBuilder:builder testResultDidStart:result];
}

-(void)testResultBuilder:(L3TestResultBuilder *)builder testResult:(L3TestResult *)result assertionDidSucceedWithSourceReference:(L3SourceReference *)sourceReference {
	[self.testResultFormatter testResultBuilder:builder testResult:result assertionDidSucceedWithSourceReference:sourceReference];
}

-(void)testResultBuilder:(L3TestResultBuilder *)builder testResult:(L3TestResult *)result assertionDidFailWithSourceReference:(L3SourceReference *)sourceReference {
	[self.testResultFormatter testResultBuilder:builder testResult:result assertionDidFailWithSourceReference:sourceReference];
}

-(void)testResultBuilder:(L3TestResultBuilder *)builder testResultDidFinish:(L3TestResult *)result {
	[self.testResultFormatter testResultBuilder:builder testResultDidFinish:result];
	
	if (result.parent == nil && self.didRunAutomatically) {
		if([NSUserNotification class]) { // weak linking
			NSUserNotification *notification = [NSUserNotification new];
			notification.title = result.succeeded?
			NSLocalizedString(@"Tests passed", @"The title of user notifications shown when all tests passed.")
			:	NSLocalizedString(@"Tests failed", @"The title of user notifications shown when one or more tests failed.");
			notification.subtitle = [NSString stringWithFormat:@"%@, %@, %@",
									 [L3StringInflections cardinalizeNoun:@"test" count:result.testCaseCount],
									 [L3StringInflections cardinalizeNoun:@"assertion" count:result.assertionCount],
									 [L3StringInflections cardinalizeNoun:@"failure" count:result.assertionFailureCount]];
			[[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
		}
		
		[self.queue addOperationWithBlock:^{
			system("/usr/bin/osascript -e 'tell application \"Xcode\" to activate'");
			
			if ([NSApplication class])
				[[NSApplication sharedApplication] terminate:nil];
			else
				exit(0);
		}];
		
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

static void asynchronousTest(L3TestState *test, L3TestCase *_case);
static void asynchronousTest(L3TestState *test, L3TestCase *_case) {
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
		
		L3TestStep *setUp = suite.steps[L3TestSuiteSetUpStepName];
		if (setUp)
			[testCase performStep:setUp withState:state];
		
		testCase.function(state, testCase);
		
		if (state.isDeferred)
			[testCase assertThat:l3_to_object([state wait]) matches:l3_to_pattern(YES) sourceReference:testCase.sourceReferenceForCaseEvents eventObserver:self.eventObserver];
		
		L3TestStep *tearDown = suite.steps[L3TestSuiteTearDownStepName];
		if (tearDown)
			[testCase performStep:tearDown withState:state];
		
		[self.eventObserver testEndEventWithTest:testCase date:[NSDate date]];
	}];
}


@l3_test("generates start events for suites") {
	L3TestSuite *testSuite = [L3TestSuite testSuiteWithName:[NSString stringWithFormat:@"%@ test suite", _case.name]];
	
	[test.runner testSuite:testSuite inTestSuite:nil withChildren:^{}];
	
	[test.runner waitForTestsToComplete];
	
	if (l3_assert(test.events.count, l3_greaterThanOrEqualTo(1))) {
		NSDictionary *event = test.events[0];
		l3_assert(event[@"name"], l3_equals(testSuite.name));
		l3_assert(event[@"type"], l3_equals(@"start"));
	}
}

@l3_test("generates end events after running suites") {
	L3TestSuite *testSuite = [L3TestSuite testSuiteWithName:[NSString stringWithFormat:@"%@ test suite", _case.name]];
	
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
