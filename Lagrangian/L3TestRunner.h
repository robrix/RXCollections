//  L3TestRunner.h
//  Created by Rob Rix on 2012-11-09.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>
#import <Lagrangian/L3Configuration.h>

extern NSString * const L3TestRunnerRunTestsOnLaunchEnvironmentVariableName;
extern NSString * const L3TestRunnerSuitePredicateEnvironmentVariableName;

@class L3TestSuite;

#if L3_DEBUG

#define l3_main(argc, argv) \
	do { \
		if ([NSClassFromString(@"L3TestRunner") shouldRunTestsAtLaunch]) { \
			dispatch_main(); \
		} \
	} while(0)

#else

#define l3_main(argc, argv) \
	do {} while(0)

#endif

@interface L3TestRunner : NSObject

+(bool)shouldRunTestsAtLaunch;
+(bool)isRunningInApplication;

+(instancetype)runner;

@property (strong, nonatomic) NSPredicate *testSuitePredicate;

-(void)run; // starts running asynchronously
-(void)waitForTestsToComplete;

@end
