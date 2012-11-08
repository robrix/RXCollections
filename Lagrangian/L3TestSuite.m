//  L3TestSuite.m
//  Created by Rob Rix on 2012-11-07.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3TestCase.h"
#import "L3TestSuite.h"

@interface L3TestSuite ()

@property (strong, nonatomic) NSMutableArray *testCases;

@end

@implementation L3TestSuite

+(instancetype)testSuiteWithName:(NSString *)name {
	return [[self alloc] initWithName:name];
}

-(instancetype)initWithName:(NSString *)name {
	NSParameterAssert(name != nil);
	if ((self = [super init])) {
		_name = [name copy];
		_testCases = [NSMutableArray new];
	}
	return self;
}


-(void)addTestCase:(L3TestCase *)testCase {
	NSParameterAssert(testCase != nil);
	[self.testCases addObject:testCase];
}

@end
