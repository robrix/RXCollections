//  L3TestVisitor.h
//  Created by Rob Rix on 2012-12-15.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

@class L3TestCase;
@class L3TestSuite;

@protocol L3TestVisitor <NSObject>

-(void)testCase:(L3TestCase *)testCase inTestSuite:(L3TestSuite *)suite;
-(void)testSuite:(L3TestSuite *)testSuite inTestSuite:(L3TestSuite *)suite withChildren:(void(^)())block;

@end
