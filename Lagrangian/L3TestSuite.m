//  L3TestSuite.m
//  Created by Rob Rix on 2012-11-07.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3TestCase.h"
#import "L3TestSuite.h"

@interface L3TestSuite ()

@property (strong, nonatomic) NSMutableArray *testCases;
@property (strong, nonatomic, readwrite) NSMutableDictionary *testCasesByName;
//@property (strong, nonatomic) NSMutableArray *setUpBlocks;
//@property (strong, nonatomic) NSMutableArray *tearDownBlocks;

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
		_testCasesByName = [NSMutableDictionary new];
	}
	return self;
}


-(void)addTestCase:(L3TestCase *)testCase {
	NSParameterAssert(testCase != nil);
	NSParameterAssert([self.testCasesByName objectForKey:testCase.name] == nil);
	
	[self.testCases addObject:testCase];
	[self.testCasesByName setObject:testCase forKey:testCase.name];
}

//-(void)addSetUpFunction:(L3TestCaseSetUpFunction)function {
//	
//}
//
//-(void)addTearDownFunction:(L3TestCaseTearDownFunction)function {
//	
//}


-(void)runTestCase:(L3TestCase *)testCase {
	NSParameterAssert(testCase != nil);
	@autoreleasepool {
		[testCase runInSuite:self setUpFunction:self.setUpFunction tearDownFunction:self.tearDownFunction];
	}
}

-(void)runTestCases {
	for (L3TestCase *testCase in self.testCases) {
		[self runTestCase:testCase];
	}
}

@end
