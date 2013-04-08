//  RXSequence.m
//  Created by Rob Rix on 2013-03-30.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXSequence.h"

const NSUInteger RXSequenceEnumerationStateObjectBufferCapacity = 16;

@implementation RXSequenceEnumerationState {
	__strong id _objectBuffer[RXSequenceEnumerationStateObjectBufferCapacity];
}

-(id)init {
	if ((self = [super init])) {
		self.objects = self.objectBuffer;
	}
	return self;
}

-(__strong id *)objectBuffer {
	return _objectBuffer;
}

-(NSUInteger)capacity {
	return sizeof _objectBuffer / sizeof *_objectBuffer;
}

@end


@implementation NSArray (RXSequence)

-(bool)retrieveObjectsWithState:(RXSequenceEnumerationState *)state {
	NSFastEnumerationState fastEnumerationState = {};
	__unsafe_unretained id objects[16];
	state.count = [self countByEnumeratingWithState:&fastEnumerationState objects:objects count:sizeof objects / sizeof *objects];
	state.objects = (id __strong *)(void *)fastEnumerationState.itemsPtr;
	state.context = self;
	return state.count != self.count;
}

@end
