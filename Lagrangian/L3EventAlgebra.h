//  L3EventAlgebra.h
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

@protocol L3Test;

@class L3AssertionReference;

@protocol L3EventAlgebra <NSObject>

-(id)testStartEventWithTest:(id<L3Test>)test date:(NSDate *)date;
-(id)testEndEventWithTest:(id<L3Test>)test date:(NSDate *)date;

-(id)assertionFailureWithAssertionReference:(L3AssertionReference *)assertionReference date:(NSDate *)date;
-(id)assertionSuccessWithAssertionReference:(L3AssertionReference *)assertionReference date:(NSDate *)date;

@end
