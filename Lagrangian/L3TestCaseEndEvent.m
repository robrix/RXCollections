//  L3TestCaseEndEvent.m
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3TestCaseEndEvent.h"

@implementation L3TestCaseEndEvent

#pragma mark -
#pragma mark Constructors

+(instancetype)eventWithSource:(L3TestCase<L3EventSource> *)source {
	return [super eventWithSource:source];
}


@dynamic source;


#pragma mark -
#pragma mark Visitors

-(id)acceptVisitor:(id<L3EventVisitor>)visitor {
	return [visitor testCaseEndEvent:self];
}

@end
