//  L3TestResult.h
//  Created by Rob Rix on 2012-11-12.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

@interface L3TestResult : NSObject

+(instancetype)testResultWithName:(NSString *)name startDate:(NSDate *)startDate;

@property (strong, nonatomic) L3TestResult *parent; // this really only exists to make stacks easier; nil it out on pop or you get retain cycles

@property (copy, nonatomic, readonly) NSString *name;
@property (strong, nonatomic, readonly) NSDate *startDate;
@property (assign, nonatomic) NSTimeInterval duration;
@property (assign, nonatomic) NSUInteger testCaseCount;
@property (assign, nonatomic) NSUInteger assertionCount;
@property (assign, nonatomic) NSUInteger assertionFailureCount;
@property (assign, nonatomic) NSUInteger exceptionCount;

@property (nonatomic, readonly) bool succeeded;
@property (nonatomic, readonly) bool failed;

@property (nonatomic, readonly) NSArray *testResults;
-(void)addTestResult:(L3TestResult *)testResult;

@end
