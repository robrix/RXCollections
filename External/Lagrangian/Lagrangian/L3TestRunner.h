#ifndef L3_TEST_RUNNER_H
#define L3_TEST_RUNNER_H

#import <Foundation/Foundation.h>
#import <Lagrangian/L3Defines.h>

L3_EXTERN NSString * const L3TestRunnerRunTestsOnLaunchEnvironmentVariableName;
L3_EXTERN NSString * const L3TestRunnerSubjectEnvironmentVariableName;

#if defined(L3_DEBUG)

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

@class L3Test;

@interface L3TestRunner : NSObject

+(bool)shouldRunTestsAtLaunch;
+(bool)isRunningInApplication;

-(void)enqueueTests:(NSArray *)tests;
-(void)enqueueTest:(L3Test *)test;

/**
 Blocks until all tests have completed.
 
 @return True if the tests completed successfully, and false otherwise.
 */
-(bool)waitForTestsToComplete;

@end

#endif // L3_TEST_RUNNER
