//  L3AssertionEvent.m
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3AssertionEvent.h"

@implementation L3AssertionEvent

#pragma mark -
#pragma mark Constructors

+(instancetype)eventWithAssertion:(L3AssertionReference *)assertion source:(id<L3EventSource>)source {
	return [[self alloc] initWithAssertion:assertion source:source];
}

-(instancetype)initWithAssertion:(L3AssertionReference *)assertion source:(id<L3EventSource>)source {
	if ((self = [super initWithSource:source])) {
		_assertion = assertion;
	}
	return self;
}

@end
