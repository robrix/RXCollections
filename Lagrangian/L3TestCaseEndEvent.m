//  L3TestCaseEndEvent.m
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3TestCaseEndEvent.h"

@implementation L3TestCaseEndEvent

#pragma mark -
#pragma mark Constructors

+(instancetype)eventWithTestCase:(L3TestCase *)testCase {
	return [[self alloc] initWithTestCase:testCase];
}

-(instancetype)initWithTestCase:(L3TestCase *)testCase {
	if ((self = [super init])) {
		_testCase = testCase;
	}
	return self;
}


#pragma mark -
#pragma mark Visitors

-(id)acceptVisitor:(id<L3EventVisitor>)visitor {
	return [visitor testCaseEndEvent:self];
}


#pragma mark -
#pragma mark Algebras

-(id)acceptAlgebra:(id<L3EventAlgebra>)algebra {
	return [algebra testCaseEndEventWithTestCase:self.testCase];
}

@end
