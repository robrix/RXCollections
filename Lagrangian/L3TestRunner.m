//  L3TestRunner.m
//  Created by Rob Rix on 2012-11-09.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Cocoa/Cocoa.h>
#import "L3OCUnitCompatibleEventFormatter.h"
#import "L3TestResult.h"
#import "L3TestRunner.h"
#import "L3TestSuite.h"

@interface L3TestRunner () <L3EventFormatterDelegate>

@property (strong, nonatomic, readonly) NSMutableArray *mutableTests;
@property (strong, nonatomic, readonly) NSMutableDictionary *mutableTestsByName;

@property (strong, nonatomic, readonly) id<L3EventFormatter> eventFormatter;

@property (strong, nonatomic, readonly) NSOperationQueue *queue;

@property (strong, nonatomic, readonly) id<L3Test> test;

@property (assign, nonatomic, readonly) bool shouldRunAutomatically;

@end

@implementation L3TestRunner

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
		
		_eventFormatter = [L3OCUnitCompatibleEventFormatter new];
		_eventFormatter.delegate = self;
		
		_queue = [NSOperationQueue new]; // should this actually be the main queue?
		_queue.maxConcurrentOperationCount = 1;
		
		_test = [L3TestSuite defaultSuite];
		
#if L3_TESTS || L3_RUN_TESTS_ON_LAUNCH
		_shouldRunAutomatically = YES;
#endif
		
		if (_shouldRunAutomatically && [NSApplication class]) { // weak linking
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
	
	@autoreleasepool {
		[self.queue addOperationWithBlock:^{
			[test runInContext:nil eventAlgebra:_eventFormatter];
			[self.queue addOperationWithBlock:^{
				if (_shouldRunAutomatically) {
					system("/usr/bin/osascript -e 'tell application\"Xcode\" to activate'");
					
					if ([NSApplication class])
						[[NSApplication sharedApplication] terminate:nil];
					else
						exit(0);
				}
			}];
		}];
	}
}


#pragma mark -
#pragma mark L3EventFormatterDelegate

-(void)formatter:(id<L3EventFormatter>)formatter didFormatEventWithResultString:(NSString *)string {
	if (string)
		printf("%s\n", string.UTF8String);
}

-(void)formatter:(id<L3EventFormatter>)formatter didFinishFormattingEventsWithFinalTestResult:(L3TestResult *)testResult {
	if ([NSUserNotification class]) { // weak linking
		NSUserNotification *notification = [NSUserNotification new];
		notification.title = testResult.succeeded?
			NSLocalizedString(@"Tests passed", @"The title of user notifications shown when all tests passed.")
		:	NSLocalizedString(@"Tests failed", @"The title of user notifications shown when one or more tests failed.");
		notification.subtitle = [NSString stringWithFormat:@"%lu tests, %lu assertions, %lu failures", testResult.testCaseCount, testResult.assertionCount, testResult.assertionFailureCount];
		[[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
	}
}

@end
