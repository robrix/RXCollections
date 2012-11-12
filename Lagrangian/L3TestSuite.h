//  L3TestSuite.h
//  Created by Rob Rix on 2012-11-07.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>
#import "L3Types.h"
#import "L3Test.h"
#import "L3EventSource.h"

@class L3TestCase;

@interface L3TestSuite : NSObject <L3EventSource, L3Test>

+(instancetype)defaultSuite;

+(instancetype)testSuiteWithName:(NSString *)name;

@property (strong, nonatomic) Class stateClass;

@property (assign, nonatomic) L3TestCaseSetUpFunction setUpFunction;
@property (assign, nonatomic) L3TestCaseTearDownFunction tearDownFunction;

// must be unique by name within this collection
-(void)addTest:(id<L3Test>)test;

@property (copy, nonatomic, readonly) NSArray *tests;
@property (copy, nonatomic, readonly) NSDictionary *testsByName;

@end
