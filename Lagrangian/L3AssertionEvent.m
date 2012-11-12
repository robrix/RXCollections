//  L3AssertionEvent.m
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3AssertionEvent.h"

@implementation L3AssertionEvent

#pragma mark -
#pragma mark Constructors

+(instancetype)eventWithAssertionReference:(L3AssertionReference *)assertionReference {
	return [[self alloc] initWithAssertion:assertionReference];
}

-(instancetype)initWithAssertion:(L3AssertionReference *)assertionReference {
	if ((self = [super init])) {
		_assertionReference = assertionReference;
	}
	return self;
}

@end
