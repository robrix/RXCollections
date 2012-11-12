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

+(instancetype)eventWithState:(L3EventState)state source:(id<L3EventSource>)source {
	return [[self alloc] initWithState:state source:source];
}

-(instancetype)initWithState:(L3EventState)state source:(id<L3EventSource>)source {
	if ((self = [super init])) {
		_state = state;
		_source = source;
		_date = [NSDate date];
	}
	return self;
}


#pragma mark -
#pragma mark Visitors

-(id)acceptVisitor:(id<L3EventVisitor>)visitor {
	id result = nil;
	switch (self.state) {
		case L3EventStateStarted:
			result = [visitor startedEvent:self];
			break;
		
		case L3EventStateEnded:
			result = [visitor endedEvent:self];
			break;
			
		case L3EventStateSucceeded:
			result = [visitor succeededEvent:self];
			break;
			
		case L3EventStateFailed:
			result = [visitor failedEvent:self];
			break;
			
		default:
			result = [visitor unknownEvent:self];
			break;
	}
	return result;
}

@end
