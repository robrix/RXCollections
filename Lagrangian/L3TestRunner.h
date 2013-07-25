#ifndef L3_TEST_RUNNER_H
#define L3_TEST_RUNNER_H

#if __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

#import <Lagrangian/L3Defines.h>

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

//-(void)runTests:(NSArray *)tests; // starts running asynchronously
-(void)waitForTestsToComplete;

@end

#endif // L3_TEST_RUNNER