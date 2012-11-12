//  L3EventVisitor.h
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

@class L3TestSuiteStartEvent;
@class L3TestSuiteEndEvent;
@class L3TestCaseStartEvent;
@class L3TestCaseEndEvent;
@class L3AssertionFailureEvent;
@class L3AssertionSuccessEvent;

@protocol L3EventVisitor <NSObject>

-(id)testSuiteStartEvent:(L3TestSuiteStartEvent *)event;
-(id)testSuiteEndEvent:(L3TestSuiteEndEvent *)event;

-(id)testCaseStartEvent:(L3TestCaseStartEvent *)event;
-(id)testCaseEndEvent:(L3TestCaseEndEvent *)event;

-(id)assertionFailureEvent:(L3AssertionFailureEvent *)event;
-(id)assertionSuccessEvent:(L3AssertionSuccessEvent *)event;

@end
