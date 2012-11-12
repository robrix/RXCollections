//  L3EventAlgebra.h
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>
#import "L3EventSource.h"

@class L3TestSuite;
@class L3TestCase;
@class L3AssertionReference;

@protocol L3EventAlgebra <NSObject>

-(id)testSuiteStartEventWithSource:(L3TestSuite<L3EventSource> *)source;
-(id)testSuiteEndEventWithSource:(L3TestSuite<L3EventSource> *)source;

-(id)testCaseStartEventWithSource:(L3TestCase<L3EventSource> *)source;
-(id)testCaseEndEventWithSource:(L3TestCase<L3EventSource> *)source;

-(id)assertionFailureWithAssertionReference:(L3AssertionReference *)assertionReference source:(id<L3EventSource>)source;
-(id)assertionSuccessWithAssertionReference:(L3AssertionReference *)assertionReference source:(id<L3EventSource>)source;

@end
