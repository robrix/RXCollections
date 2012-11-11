//  L3TestCase.h
//  Created by Rob Rix on 2012-11-08.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>
#import "L3Types.h"

@class L3TestSuite;

@interface L3TestCase : NSObject

+(instancetype)testCaseWithName:(NSString *)name function:(L3TestCaseFunction)function;

@property (copy, nonatomic, readonly) NSString *name;
@property (assign, nonatomic, readonly) L3TestCaseFunction function;

-(void)runInSuite:(L3TestSuite *)suite;

-(bool)assertThat:(id)object matches:(L3Pattern)pattern;

@end
