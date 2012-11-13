//  L3TestRunner.m
//  Created by Rob Rix on 2012-11-09.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Cocoa/Cocoa.h>
#import "L3TestRunner.h"
#import "L3TestSuite.h"
#import "L3Event.h"
#import "L3EventSink.h"
#import "L3OCUnitCompatibleEventFormatter.h"

@interface L3TestRunner () <L3EventSinkDelegate>

@property (strong, nonatomic, readonly) NSMutableArray *mutableTests;
@property (strong, nonatomic, readonly) NSMutableDictionary *mutableTestsByName;

@property (strong, nonatomic, readonly) L3EventSink *eventSink;
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
		
		_eventSink = [L3EventSink new];
		_eventSink.delegate = self;
		_eventFormatter = [L3OCUnitCompatibleEventFormatter new];
		
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
			[test runInContext:nil eventAlgebra:_eventSink];
			[self.queue addOperationWithBlock:^{
				if (_shouldRunAutomatically && [NSApplication class])
					[[NSApplication sharedApplication] terminate:nil];
				else if (_shouldRunAutomatically)
					exit(0);
			}];
		}];
	}
}


#pragma mark -
#pragma mark L3EventSinkDelegate

-(void)eventSink:(L3EventSink *)eventSink didAddEvent:(L3Event *)event {
	NSString *formattedEvent = [self.eventFormatter formatEvent:event];
	if (formattedEvent)
		printf("%s\n", formattedEvent.UTF8String);
}

@end
