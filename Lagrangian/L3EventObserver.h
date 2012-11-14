//  L3EventObserver.h
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

@protocol L3Test;

@class L3AssertionReference;

@protocol L3EventObserver <NSObject>

-(void)testStartEventWithTest:(id<L3Test>)test date:(NSDate *)date;
-(void)testEndEventWithTest:(id<L3Test>)test date:(NSDate *)date;

-(void)assertionFailureWithAssertionReference:(L3AssertionReference *)assertionReference date:(NSDate *)date;
-(void)assertionSuccessWithAssertionReference:(L3AssertionReference *)assertionReference date:(NSDate *)date;

@end
