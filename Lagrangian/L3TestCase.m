//  L3TestCase.m
//  Created by Rob Rix on 2012-11-08.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3TestCase.h"

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
		_block = [^(L3TestSuite *testSuite, L3TestCase *testCase){
			function(testSuite, testCase);
		} copy];
	}
	return self;
}


-(void)runInSuite:(L3TestSuite *)suite setUpFunction:(L3TestCaseSetUpFunction)setUp tearDownFunction:(L3TestCaseTearDownFunction)tearDown {
	NSLog(@"running test case %@", self.name);
	// flush state?
	// clone?
	// stack state for reentrancy?
	@autoreleasepool {
		if (setUp)
			setUp(suite, self);
		
		self.block(suite, self);
		
		if (tearDown)
			tearDown(suite, self);
	}
}

@end
