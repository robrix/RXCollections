//  L3TestRunner.m
//  Created by Rob Rix on 2012-11-09.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Cocoa/Cocoa.h>
#import "L3TestRunner.h"
#import "L3TestSuite.h"

@interface L3TestRunner ()

@property (strong, nonatomic, readonly) NSMutableArray *testSuites;
@property (strong, nonatomic, readonly) NSMutableDictionary *mutableTestSuitesByName;
@property (strong, nonatomic, readonly) NSOperationQueue *queue;

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

-(instancetype)init {
	if ((self = [super init])) {
		_testSuites = [NSMutableArray new];
		_mutableTestSuitesByName = [NSMutableDictionary new];
		
		_queue = [NSOperationQueue new]; // should this actually be the main queue?
		_queue.maxConcurrentOperationCount = 1;
		
#if L3_TESTS || L3_RUN_TESTS_ON_LAUNCH
		_shouldRunAutomatically = YES;
#endif
		
		if (_shouldRunAutomatically && [NSApplication class]) { // weak linking
			__block id observer = [[NSNotificationCenter defaultCenter] addObserverForName:NSApplicationDidFinishLaunchingNotification object:nil queue:self.queue usingBlock:^(NSNotification *note) {
				if (self.shouldRunAutomatically)
					[self runTestSuites];
				
				[[NSNotificationCenter defaultCenter] removeObserver:observer name:NSApplicationDidFinishLaunchingNotification object:nil];
			}];
		}
	}
	return self;
}


-(NSDictionary *)testSuitesByName {
	return self.mutableTestSuitesByName;
}


-(void)addTestSuite:(L3TestSuite *)testSuite {
	NSParameterAssert(testSuite != nil);
	NSParameterAssert([self.testSuitesByName objectForKey:testSuite.name] == nil);
	
	[self.testSuites addObject:testSuite];
	[self.mutableTestSuitesByName setObject:testSuite forKey:testSuite.name];
}


-(void)runTestSuite:(L3TestSuite *)testSuite {
	NSParameterAssert(testSuite != nil);
	@autoreleasepool {
		[self.queue addOperationWithBlock:^{
			[testSuite runTestCases];
		}];
	}
}

-(void)runTestSuites {
	NSLog(@"running all test suites");
	for (L3TestSuite *testSuite in self.testSuites) {
		[self runTestSuite:testSuite];
	}
}

@end
