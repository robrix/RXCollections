//  L3TestSuite.m
//  Created by Rob Rix on 2012-11-07.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3TestCase.h"
#import "L3TestSuite.h"
#import "L3TestState.h"

@interface L3TestSuite ()

@property (strong, nonatomic, readonly) NSMutableArray *testCases;
@property (strong, nonatomic, readonly) NSMutableDictionary *mutableTestCasesByName;
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
		_mutableTestCasesByName = [NSMutableDictionary new];
		_stateClass = [L3TestState class];
	}
	return self;
}


-(NSDictionary *)testCasesByName {
	return self.mutableTestCasesByName;
}


-(void)setStateClass:(Class)stateClass {
	NSAssert(stateClass != nil, @"No state class found for suite ‘%@’. Did you forget to add a @l3_suite_implementation for this suite? Did you add one but give it the wrong name?", self.name);
	_stateClass = stateClass;
}


-(void)addTestCase:(L3TestCase *)testCase {
	NSParameterAssert(testCase != nil);
	NSParameterAssert([self.testCasesByName objectForKey:testCase.name] == nil);
	
	[self.testCases addObject:testCase];
	[self.mutableTestCasesByName setObject:testCase forKey:testCase.name];
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
		[testCase runInSuite:self];
	}
}

-(void)runTestCases {
	NSLog(@"running all tests in %@", self.name);
	for (L3TestCase *testCase in self.testCases) {
		[self runTestCase:testCase];
	}
}

@end
