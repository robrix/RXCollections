//  L3TestCase.h
//  Created by Rob Rix on 2012-11-08.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>
#import "L3Types.h"
#import "L3Test.h"
#import "L3EventSource.h"

@class L3AssertionReference;
@class L3EventSink;
@class L3TestSuite;

@interface L3TestCase : NSObject <L3EventSource, L3Test>

+(instancetype)testCaseWithName:(NSString *)name function:(L3TestCaseFunction)function;

@property (assign, nonatomic, readonly) L3TestCaseFunction function;

@property (weak, nonatomic, readonly) L3EventSink *eventSink;

-(bool)assertThat:(id)object matches:(L3Pattern)pattern assertionReference:(L3AssertionReference *)assertion collectingEventsInto:(L3EventSink *)eventSink;

@end
