//  L3TestSuiteEndEvent.m
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3TestSuiteEndEvent.h"

@implementation L3TestSuiteEndEvent

#pragma mark -
#pragma mark Visitors

-(id)acceptVisitor:(id<L3EventVisitor>)visitor {
	return [visitor testSuiteEndEvent:self];
}

@end
