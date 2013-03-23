//  RXFastEnumerationState.m
//  Created by Rob Rix on 2013-03-21.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXFastEnumerationState.h"

@implementation RXFastEnumerationState {
	__autoreleasing id *_items;
	unsigned long *_mutations;
}

+(instancetype)newWithNSFastEnumerationState:(NSFastEnumerationState *)state {
	state->state = (unsigned long)self;
	RXFastEnumerationState *instance = (__bridge RXFastEnumerationState *)state;
	return instance;
}


-(__unsafe_unretained id *)itemsBuffer {
	return (__unsafe_unretained id *)(void *)self.items;
}

-(void)setItemsBuffer:(__unsafe_unretained id *)itemsBuffer {
	self.items = (__autoreleasing id *)(void *)itemsBuffer;
}

@end
