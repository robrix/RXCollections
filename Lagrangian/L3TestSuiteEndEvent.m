//  L3TestSuiteEndEvent.m
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3TestSuiteEndEvent.h"

@implementation L3TestSuiteEndEvent

#pragma mark -
#pragma mark Constructors

+(instancetype)eventWithTestSuite:(L3TestSuite *)testSuite {
	return [[self alloc] initWithTestSuite:testSuite];
}

-(instancetype)initWithTestSuite:(L3TestSuite *)testSuite {
	if ((self = [super init])) {
		_testSuite = testSuite;
	}
	return self;
}


#pragma mark -
#pragma mark Visitors

-(id)acceptVisitor:(id<L3EventVisitor>)visitor {
	return [visitor testSuiteEndEvent:self];
}


#pragma mark -
#pragma mark Algebras

-(id)acceptAlgebra:(id<L3EventAlgebra>)algebra {
	return [algebra testSuiteEndEventWithTestSuite:self.testSuite];
}

@end
