//  L3Test.h
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Lagrangian/L3EventObserver.h>
#import <Lagrangian/L3TestVisitor.h>

@class L3TestSuite;

@protocol L3Test <NSObject>

@property (copy, nonatomic, readonly) NSString *name;


#pragma mark Source reference

@property (copy, nonatomic, readonly) NSString *file;
@property (assign, nonatomic, readonly) NSUInteger line;


#pragma mark Test composition

@property (nonatomic, readonly, getter = isComposite) bool composite;


#pragma mark Visiting

-(void)acceptVisitor:(id<L3TestVisitor>)visitor inTestSuite:(L3TestSuite *)parentSuite;
// assumes nil parent
-(void)acceptVisitor:(id<L3TestVisitor>)visitor;

@end
