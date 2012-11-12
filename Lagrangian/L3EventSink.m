//  L3EventSink.m
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3EventSink.h"

@interface L3EventSink ()

@property (strong, nonatomic, readonly) NSMutableArray *mutableEvents;

@end

@implementation L3EventSink

-(id)init {
	if ((self = [super init])) {
		_mutableEvents = [NSMutableArray new];
	}
	return self;
}


#pragma mark -
#pragma mark Events

-(void)addEvent:(L3Event *)event {
	[self.mutableEvents addObject:event];
	[self.delegate eventSink:self didAddEvent:event];
}


-(NSArray *)events {
	return self.mutableEvents;
}

@end
