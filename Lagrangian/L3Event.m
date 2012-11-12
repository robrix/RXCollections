//  L3Event.m
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3Event.h"

@interface L3Event ()

@property (nonatomic, readwrite) NSDate *date;

@end

@implementation L3Event

#pragma mark -
#pragma mark Constructors

+(instancetype)eventWithSource:(id<L3EventSource>)source {
	return [(L3Event *)[self alloc] initWithSource:source];
}

-(instancetype)initWithSource:(id<L3EventSource>)source {
	if ((self = [super init])) {
		_source = source;
		_date = [NSDate date];
	}
	return self;
}


#pragma mark -
#pragma mark Visitors

-(id)acceptVisitor:(id<L3EventVisitor>)visitor {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

@end
