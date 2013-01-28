//  L3TestResultBuilder.h
//  Created by Rob Rix on 2012-11-13.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Lagrangian/L3EventObserver.h>

@class L3SourceReference;
@class L3TestResult;
@protocol L3TestResultBuilderDelegate;

@interface L3TestResultBuilder : NSObject <L3EventObserver>

@property (weak, nonatomic) id<L3TestResultBuilderDelegate> delegate;

@end

@protocol L3TestResultBuilderDelegate <NSObject>

-(void)testResultBuilder:(L3TestResultBuilder *)builder testResultDidStart:(L3TestResult *)result;
-(void)testResultBuilder:(L3TestResultBuilder *)builder testResult:(L3TestResult *)result assertionDidSucceedWithSourceReference:(L3SourceReference *)sourceReference;
-(void)testResultBuilder:(L3TestResultBuilder *)builder testResult:(L3TestResult *)result assertionDidFailWithSourceReference:(L3SourceReference *)sourceReference;
-(void)testResultBuilder:(L3TestResultBuilder *)builder testResultDidFinish:(L3TestResult *)result;

@end
