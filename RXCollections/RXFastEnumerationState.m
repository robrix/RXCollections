//  RXFastEnumerationState.m
//  Created by Rob Rix on 2013-03-21.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXFastEnumerationState.h"

@interface RXHeapFastEnumerationState : NSObject <RXFastEnumerationState>
@end

@implementation RXFastEnumerationState {
	__autoreleasing id *_items;
	unsigned long *_mutations;
}

@synthesize items = _items;
@synthesize mutations = _mutations;

+(id<RXFastEnumerationState>)stateWithNSFastEnumerationState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)count initializationHandler:(void(^)(id<RXFastEnumerationState> state))block NS_RETURNS_RETAINED {
	bool needsInitialization = state->state == 0;
	if (needsInitialization)
		state->state = (unsigned long)self;
	RXFastEnumerationState *instance = (__bridge RXFastEnumerationState *)state;
	if (needsInitialization) {
		instance.mutations = &(state->state);
		instance.itemsBuffer = buffer;
		if (block)
			block(instance);
	}
	return instance;
}

+(id<RXFastEnumerationState>)state {
	return [RXHeapFastEnumerationState new];
}


-(NSFastEnumerationState *)NSFastEnumerationState {
	return (__bridge void *)self;
}


-(__unsafe_unretained id *)itemsBuffer {
	return (__unsafe_unretained id *)(void *)self.items;
}

-(void)setItemsBuffer:(__unsafe_unretained id *)itemsBuffer {
	self.items = (__autoreleasing id *)(void *)itemsBuffer;
}


-(__unsafe_unretained const id *)constItems {
	return self.itemsBuffer;
}

-(void)setConstItems:(__unsafe_unretained const id *)constItems {
	self.itemsBuffer = (__unsafe_unretained id *)constItems;
}

@end


@implementation RXHeapFastEnumerationState {
	NSFastEnumerationState _NSFastEnumerationState;
}

-(NSFastEnumerationState *)NSFastEnumerationState {
	return &_NSFastEnumerationState;
}


-(__autoreleasing id *)items {
	return (__autoreleasing id *)(void *)_NSFastEnumerationState.itemsPtr;
}

-(void)setItems:(__autoreleasing id *)items {
	_NSFastEnumerationState.itemsPtr = (__unsafe_unretained id *)(void *)items;
}


-(__unsafe_unretained id *)itemsBuffer {
	return _NSFastEnumerationState.itemsPtr;
}

-(void)setItemsBuffer:(__unsafe_unretained id *)itemsBuffer {
	_NSFastEnumerationState.itemsPtr = itemsBuffer;
}


-(__unsafe_unretained const id *)constItems {
	return _NSFastEnumerationState.itemsPtr;
}

-(void)setConstItems:(__unsafe_unretained const id *)constItems {
	_NSFastEnumerationState.itemsPtr = (__unsafe_unretained id *)(void *)constItems;
}


-(unsigned long *)mutations {
	return _NSFastEnumerationState.mutationsPtr;
}

-(void)setMutations:(unsigned long *)mutations {
	_NSFastEnumerationState.mutationsPtr = mutations;
}

@end
