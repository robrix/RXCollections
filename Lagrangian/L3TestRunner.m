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

@interface L3TestRunner () <L3TestResultBuilderDelegate, L3TestResultFormatterDelegate>

@property (strong, nonatomic, readonly) NSMutableArray *mutableTests;
@property (strong, nonatomic, readonly) NSMutableDictionary *mutableTestsByName;

@property (strong, nonatomic, readonly) L3TestResultBuilder *testResultBuilder;
@property (strong, nonatomic, readonly) id<L3TestResultFormatter> eventFormatter;

@property (strong, nonatomic, readonly) NSOperationQueue *queue;

@property (strong, nonatomic, readonly) id<L3Test> test;

@property (assign, nonatomic, readonly) bool shouldRunAutomatically;

@end

@implementation L3TestRunner

#pragma mark -
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
	[L3TestRunner runner];
}

-(instancetype)init {
	if ((self = [super init])) {
		_mutableTests = [NSMutableArray new];
		_mutableTestsByName = [NSMutableDictionary new];
		
		_testResultBuilder = [L3TestResultBuilder new];
		_testResultBuilder.delegate = self;
		
		_eventFormatter = [L3OCUnitTestResultFormatter new];
		_eventFormatter.delegate = self;
		
		_queue = [NSOperationQueue new]; // should this actually be the main queue?
		_queue.maxConcurrentOperationCount = 1;
		
		_test = [L3TestSuite defaultSuite];
		
#if L3_TESTS || L3_RUN_TESTS_ON_LAUNCH
		_shouldRunAutomatically = YES;
#endif
		
		if (self.shouldRunAutomatically && [NSApplication class]) { // weak linking
			__block id observer = [[NSNotificationCenter defaultCenter] addObserverForName:NSApplicationDidFinishLaunchingNotification object:nil queue:self.queue usingBlock:^(NSNotification *note) {
				if (self.shouldRunAutomatically)
					[self runTest:self.test];
				
				[[NSNotificationCenter defaultCenter] removeObserver:observer name:NSApplicationDidFinishLaunchingNotification object:nil];
			}];
		}
	}
	return self;
}


#pragma mark -
#pragma mark Running

-(void)runTest:(id<L3Test>)test {
	NSParameterAssert(test != nil);
	
	[self.queue addOperationWithBlock:^{
		[test runInSuite:nil eventObserver:_testResultBuilder];
		if (self.shouldRunAutomatically) {
			system("/usr/bin/osascript -e 'tell application\"Xcode\" to activate'");
			
			if ([NSApplication class])
				[[NSApplication sharedApplication] terminate:nil];
			else
				exit(0);
		}
	}];
}


#pragma mark -
#pragma mark L3TestResultFormatterDelegate

-(void)formatter:(id<L3TestResultFormatter>)formatter didFormatResult:(NSString *)string {
	if (string)
		printf("%s\n", string.UTF8String);
}


#pragma mark -
#pragma mark L3TestResultBuilderDelegate

-(void)testResultBuilder:(L3TestResultBuilder *)builder testResultDidStart:(L3TestResult *)result {
	[_eventFormatter testResultBuilder:builder testResultDidStart:result];
}

-(void)testResultBuilder:(L3TestResultBuilder *)builder testResult:(L3TestResult *)result assertionDidSucceedWithSourceReference:(L3SourceReference *)sourceReference {
	[_eventFormatter testResultBuilder:builder testResult:result assertionDidSucceedWithSourceReference:sourceReference];
}

-(void)testResultBuilder:(L3TestResultBuilder *)builder testResult:(L3TestResult *)result assertionDidFailWithSourceReference:(L3SourceReference *)sourceReference {
	[_eventFormatter testResultBuilder:builder testResult:result assertionDidFailWithSourceReference:sourceReference];
}

-(void)testResultBuilder:(L3TestResultBuilder *)builder testResultDidFinish:(L3TestResult *)result {
	[_eventFormatter testResultBuilder:builder testResultDidFinish:result];
	
	if (result.parent == nil && self.shouldRunAutomatically && [NSUserNotification class]) { // weak linking
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
}

@end
