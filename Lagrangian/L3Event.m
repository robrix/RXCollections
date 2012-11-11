//  L3Event.m
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3Event.h"

@interface L3Event ()

@property (strong, nonatomic, readonly) id source;

@end

@implementation L3Event

#pragma mark -
#pragma mark Constructors

+(instancetype)eventWithState:(L3EventState)state source:(id)source {
	return [[self alloc] initWithState:state source:source];
}

-(instancetype)initWithState:(L3EventState)state source:(id)source {
	if ((self = [super init])) {
		_state = state;
		_source = source;
		_date = [NSDate date];
	}
	return self;
}

@end
