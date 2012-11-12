//  L3TestSuiteStartEvent.m
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3TestSuiteStartEvent.h"

@implementation L3TestSuiteStartEvent

#pragma mark -
#pragma mark Constructors

+(instancetype)eventWithTestSuite:(L3TestSuite *)testSuite date:(NSDate *)date {
	return [[self alloc] initWithTestSuite:testSuite date:date];
}

-(instancetype)initWithTestSuite:(L3TestSuite *)testSuite date:(NSDate *)date {
	if ((self = [super initWithDate:date])) {
		_testSuite = testSuite;
	}
	return self;
}


#pragma mark -
#pragma mark Algebras

-(id)acceptAlgebra:(id<L3EventAlgebra>)algebra {
	return [algebra testSuiteStartEventWithTestSuite:self.testSuite date:self.date];
}

@end
