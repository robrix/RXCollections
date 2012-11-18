//  L3TestState.h
//  Created by Rob Rix on 2012-11-10.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

@class L3TestSuite;

@interface L3TestState : NSObject

-(instancetype)initWithSuite:(L3TestSuite *)suite;

@property (strong, nonatomic, readonly) L3TestSuite *suite;

#pragma mark -
#pragma mark Test state

// subscripting support for arbitrary object state
-(id)objectForKeyedSubscript:(NSString *)key;
-(void)setObject:(id)object forKeyedSubscript:(NSString *)key;

#pragma mark -
#pragma mark Asynchrony

-(void)deferCompletion;
@property (assign, nonatomic, readonly, getter = isDeferred) bool deferred;
-(void)complete;
-(bool)wait;
-(bool)waitWithTimeout:(NSTimeInterval)interval;

@end
