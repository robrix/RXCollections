//  L3TestSuite.h
//  Created by Rob Rix on 2012-11-07.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

@class L3TestCase;

@interface L3TestSuite : NSObject

+(instancetype)testSuiteWithName:(NSString *)name;

@property (copy, nonatomic, readonly) NSString *name;

-(void)addTestCase:(L3TestCase *)testCase;

@end
