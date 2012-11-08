//  L3TestCase.h
//  Created by Rob Rix on 2012-11-08.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

@class L3TestCase;
@class L3TestSuite;

typedef void(*L3TestCaseImplementationFunction)(L3TestSuite *, L3TestCase *);
typedef void(^L3TestCaseImplementationBlock)(L3TestSuite *, L3TestCase *);

@interface L3TestCase : NSObject

+(instancetype)testCaseWithName:(NSString *)name function:(L3TestCaseImplementationFunction)function;

@property (copy, nonatomic, readonly) NSString *name;

@end
