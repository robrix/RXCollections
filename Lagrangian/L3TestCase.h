//  L3TestCase.h
//  Created by Rob Rix on 2012-11-08.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>
#import "L3Types.h"
#import "L3Test.h"
#import "L3EventObserver.h"

@class L3AssertionReference;
@class L3TestSuite;

@interface L3TestCase : NSObject <L3Test>

#pragma mark -
#pragma mark Constructors

+(instancetype)testCaseWithName:(NSString *)name function:(L3TestCaseFunction)function;

@property (assign, nonatomic, readonly) L3TestCaseFunction function;

@property (weak, nonatomic, readonly) id<L3EventObserver> eventObserver;


#pragma mark -
#pragma mark Steps

-(void)performStep:(L3TestStep *)step withState:(L3TestState *)state;


#pragma mark -
#pragma mark Assertions

-(bool)assertThat:(id)object matches:(L3Pattern)pattern assertionReference:(L3AssertionReference *)assertion eventObserver:(id<L3EventObserver>)eventObserver;

@end
