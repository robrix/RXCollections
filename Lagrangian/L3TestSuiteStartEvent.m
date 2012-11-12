//  L3TestSuiteStartEvent.m
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3TestSuiteStartEvent.h"

@implementation L3TestSuiteStartEvent

#pragma mark -
#pragma mark Constructors

+(instancetype)eventWithSource:(L3TestSuite<L3EventSource> *)source {
	return [super eventWithSource:source];
}


@dynamic source;


#pragma mark -
#pragma mark Visitors

-(id)acceptVisitor:(id<L3EventVisitor>)visitor {
	return [visitor testSuiteStartEvent:self];
}

@end
