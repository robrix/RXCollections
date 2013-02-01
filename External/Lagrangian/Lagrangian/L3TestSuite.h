//  L3TestSuite.h
//  Created by Rob Rix on 2012-11-07.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>
#import <Lagrangian/L3Types.h>
#import <Lagrangian/L3Test.h>

@class L3TestCase, L3TestStep;

extern NSString * const L3TestSuiteSetUpStepName;
extern NSString * const L3TestSuiteTearDownStepName;

extern NSString *L3MachOImagePathForAddress(void *address) __attribute__((weak_import));


@interface L3TestSuite : NSObject <L3Test>

#pragma mark Constructors

+(instancetype)defaultSuite;

+(instancetype)testSuiteWithName:(NSString *)name file:(NSString *)file line:(NSUInteger)line;
+(instancetype)testSuiteWithName:(NSString *)name;


#pragma mark Mach-O image path

@property (strong, nonatomic) NSString *imagePath;


#pragma mark State

@property (strong, nonatomic) Class stateClass;


#pragma mark Tests

// must be unique by name within this suite
-(void)addTest:(id<L3Test>)test;

@property (copy, nonatomic, readonly) NSArray *tests;
@property (copy, nonatomic, readonly) NSDictionary *testsByName;


#pragma mark Steps

-(void)addStep:(L3TestStep *)step;

@property (copy, nonatomic, readonly) NSDictionary *steps;

@end
