//  L3EventAlgebra.h
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

@class L3TestSuite;
@class L3TestCase;
@class L3AssertionReference;

@protocol L3EventAlgebra <NSObject>

-(id)testSuiteStartEventWithTestSuite:(L3TestSuite *)testSuite date:(NSDate *)date;
-(id)testSuiteEndEventWithTestSuite:(L3TestSuite *)testSuite date:(NSDate *)date;

-(id)testCaseStartEventWithTestCase:(L3TestCase *)testCase date:(NSDate *)date;
-(id)testCaseEndEventWithTestCase:(L3TestCase *)testCase date:(NSDate *)date;

-(id)assertionFailureWithAssertionReference:(L3AssertionReference *)assertionReference date:(NSDate *)date;
-(id)assertionSuccessWithAssertionReference:(L3AssertionReference *)assertionReference date:(NSDate *)date;

@end
