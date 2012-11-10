//  L3TestCase.m
//  Created by Rob Rix on 2012-11-08.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3TestCase.h"
#import "L3TestState.h"
#import "L3TestSuite.h"

@interface L3TestCase ()

@property (copy, nonatomic, readwrite) NSString *name;
@property (copy, nonatomic, readwrite) L3TestCaseBlock block;

@end

@implementation L3TestCase

+(instancetype)testCaseWithName:(NSString *)name function:(L3TestCaseFunction)function {
	return [[self alloc] initWithName:name function:function];
}

-(instancetype)initWithName:(NSString *)name function:(L3TestCaseFunction)function {
	NSParameterAssert(name != nil);
	NSParameterAssert(function != nil);
	if((self = [super init])) {
		_name = [name copy];
		_block = [^(L3TestState *testState, L3TestSuite *testSuite, L3TestCase *testCase){
			function(testState, testSuite, testCase);
		} copy];
	}
	return self;
}


-(void)runInSuite:(L3TestSuite *)suite {
	NSLog(@"running test case %@", self.name);
	// flush state?
	// clone?
	// stack state for reentrancy?
	@autoreleasepool {
		L3TestState *state = [suite.stateClass new];
		if (suite.setUpFunction)
			suite.setUpFunction(state, suite, self);
		
		self.block(state, suite, self);
		
		if (suite.tearDownFunction)
			suite.tearDownFunction(state, suite, self);
	}
}

@end
