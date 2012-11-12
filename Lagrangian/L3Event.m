//  L3Event.m
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3Event.h"

@interface L3Event ()
@end

@implementation L3Event

#pragma mark -
#pragma mark Constructors

-(instancetype)initWithDate:(NSDate *)date {
	if ((self = [super init])) {
		_date = date ?: [NSDate date];
	}
	return self;
}


#pragma mark -
#pragma mark Algebras

-(id)acceptAlgebra:(id<L3EventAlgebra>)algebra {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

@end
