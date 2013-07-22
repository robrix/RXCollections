//  L3TestCase.h
//  Created by Rob Rix on 2012-11-08.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>
#import <Lagrangian/L3Types.h>
#import <Lagrangian/L3Test.h>
#import <Lagrangian/L3EventObserver.h>

@class L3SourceReference;
@class L3TestSuite;

@interface L3TestCase : NSObject <L3Test>

#pragma mark Constructors

+(instancetype)testCaseWithName:(NSString *)name file:(NSString *)file line:(NSUInteger)line function:(L3TestCaseFunction)function;

@property (assign, nonatomic, readonly) L3TestCaseFunction function;


#pragma mark Steps

-(void)setUp:(L3TestStep *)step withState:(L3TestState *)state;
-(void)tearDown:(L3TestStep *)step withState:(L3TestState *)state;
-(bool)performStep:(L3TestStep *)step withState:(L3TestState *)state;


#pragma mark Assertions

@property (strong, nonatomic, readonly) L3SourceReference *sourceReferenceForCaseEvents;

-(bool)assertThat:(id)object matches:(L3Pattern)pattern sourceReference:(L3SourceReference *)assertion eventObserver:(id<L3EventObserver>)eventObserver;

@end
