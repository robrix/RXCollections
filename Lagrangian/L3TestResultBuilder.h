//  L3TestResultBuilder.h
//  Created by Rob Rix on 2012-11-13.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3EventObserver.h"

@class L3AssertionReference;
@class L3TestResult;
@protocol L3TestResultBuilderDelegate;

@interface L3TestResultBuilder : NSObject <L3EventObserver>

@property (weak, nonatomic) id<L3TestResultBuilderDelegate> delegate;

@end

@protocol L3TestResultBuilderDelegate <NSObject>

-(void)testResultBuilder:(L3TestResultBuilder *)builder testResultDidStart:(L3TestResult *)result;
-(void)testResultBuilder:(L3TestResultBuilder *)builder testResult:(L3TestResult *)result didChangeWithSuccessfulAssertionReference:(L3AssertionReference *)assertionReference;
-(void)testResultBuilder:(L3TestResultBuilder *)builder testResult:(L3TestResult *)result didChangeWithFailedAssertionReference:(L3AssertionReference *)assertionReference;
-(void)testResultBuilder:(L3TestResultBuilder *)builder testResultDidFinish:(L3TestResult *)result;

@end
