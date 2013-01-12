//  L3TestResult.h
//  Created by Rob Rix on 2012-11-12.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

@protocol L3TestResult <NSObject>

+(id<L3TestResult>)testResultWithName:(NSString *)name file:(NSString *)file line:(NSUInteger)line startDate:(NSDate *)startDate;

@property (assign, nonatomic, readonly, getter = isComposite) bool composite;

@property (weak, nonatomic) id<L3TestResult> parent;

@property (copy, nonatomic, readonly) NSString *name;
@property (copy, nonatomic, readwrite) NSString *file;
@property (assign, nonatomic, readonly) NSUInteger line;


@property (strong, nonatomic, readonly) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (assign, nonatomic, readonly) NSTimeInterval totalDuration; // span between startDate and endDate
@property (assign, nonatomic, readonly) NSTimeInterval duration; // sum of children’s durations if composite; otherwise totalDuration

@property (assign, nonatomic, readonly) NSUInteger testCaseCount;

@property (assign, nonatomic) NSUInteger assertionCount;
@property (assign, nonatomic) NSUInteger assertionFailureCount;
@property (assign, nonatomic) NSUInteger exceptionCount;

@property (nonatomic, readonly) bool succeeded;
@property (nonatomic, readonly) bool failed;

@property (nonatomic, readonly) NSArray *testResults;
-(void)addTestResult:(id<L3TestResult>)testResult;

@end

@interface L3AbstractTestResult : NSObject
@end

@interface L3TestResult : L3AbstractTestResult <L3TestResult>
@end

@interface L3CompositeTestResult : L3AbstractTestResult <L3TestResult>
@end
