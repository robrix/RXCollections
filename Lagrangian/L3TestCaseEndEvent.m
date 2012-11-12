//  L3TestCaseEndEvent.m
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3TestCaseEndEvent.h"

@implementation L3TestCaseEndEvent

#pragma mark -
#pragma mark Algebras

-(id)acceptAlgebra:(id<L3EventAlgebra>)algebra {
	return [algebra testCaseEndEventWithTestCase:self.testCase date:self.date];
}

@end
