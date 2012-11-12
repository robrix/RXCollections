//  L3TestSuiteStartEvent.m
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3TestSuiteStartEvent.h"

@implementation L3TestSuiteStartEvent

#pragma mark -
#pragma mark Algebras

-(id)acceptAlgebra:(id<L3EventAlgebra>)algebra {
	return [algebra testSuiteStartEventWithTestSuite:self.testSuite date:self.date];
}

@end
