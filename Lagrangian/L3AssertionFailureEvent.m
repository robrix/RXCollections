//  L3AssertionFailureEvent.m
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3AssertionFailureEvent.h"

@implementation L3AssertionFailureEvent

#pragma mark -
#pragma mark Visitors

-(id)acceptVisitor:(id<L3EventVisitor>)visitor {
	return [visitor assertionFailureEvent:self];
}

@end
