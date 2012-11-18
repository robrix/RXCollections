//  L3Test.h
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

@protocol L3EventObserver;
@class L3TestSuite;

@protocol L3Test <NSObject>

@property (copy, nonatomic, readonly) NSString *name;

#pragma mark -
#pragma mark Source reference

@property (copy, nonatomic, readonly) NSString *file;
@property (assign, nonatomic, readonly) NSUInteger line;


#pragma mark -
#pragma mark Test composition

@property (nonatomic, readonly, getter = isComposite) bool composite;


#pragma mark -
#pragma mark Running

-(void)runInSuite:(L3TestSuite *)suite eventObserver:(id<L3EventObserver>)eventObserver;

@end
