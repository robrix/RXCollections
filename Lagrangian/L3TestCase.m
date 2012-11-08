//  L3TestCase.m
//  Created by Rob Rix on 2012-11-08.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3TestCase.h"

@interface L3TestCase ()

@property (copy, nonatomic, readwrite) NSString *name;
@property (copy, nonatomic, readwrite) L3TestCaseImplementationBlock block;

@end

@implementation L3TestCase

+(instancetype)testCaseWithName:(NSString *)name function:(L3TestCaseImplementationFunction)function {
	return [[self alloc] initWithName:name function:function];
}

-(instancetype)initWithName:(NSString *)name function:(L3TestCaseImplementationFunction)function {
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

@end
