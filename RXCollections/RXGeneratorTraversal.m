//  RXGeneratorTraversal.m
//  Created by Rob Rix on 2013-03-09.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXFold.h"
#import "RXGeneratorTraversal.h"
#import "RXTuple.h"

#import <Lagrangian/Lagrangian.h>

@l3_suite("RXGeneratorTraversal");

typedef struct RXGeneratorTraversalState {
	unsigned long state;
	__unsafe_unretained id *items;
	unsigned long *mutations;
	__unsafe_unretained id<NSCopying> context;
	__unsafe_unretained RXGeneratorBlock generatorBlock;
	unsigned long extra[3];
} RXGeneratorTraversalState;

typedef NS_ENUM(unsigned long, RXGeneratorTraversalCurrentState) {
	RXGeneratorTraversalCurrentStateActive = 1,
	RXGeneratorTraversalCurrentStateComplete = 2,
};

@implementation RXGeneratorTraversal

#pragma mark Construction

+(instancetype)generatorWithBlock:(RXGeneratorBlock)block {
	return [self generatorWithContext:nil block:block];
}

+(instancetype)generatorWithContext:(id<NSCopying>)context block:(RXGeneratorBlock)block {
	return [[self alloc] initWithContext:context block:block];
}

-(instancetype)initWithContext:(id<NSCopying>)context block:(RXGeneratorBlock)block {
	if ((self = [super init])) {
		_context = context;
		_block = [block copy];
	}
	return self;
}


#pragma mark NSFastEnumeration

static RXGeneratorBlock RXFibonacciGenerator() {
	return [^(RXTuple **tuple, bool *stop) {
		NSNumber *previous = (*tuple)[1], *next = @([(*tuple)[0] unsignedIntegerValue] + [previous unsignedIntegerValue]);
		*tuple = [RXTuple tupleWithArray:@[previous, next]];
		return previous;
	} copy];
}

@l3_test("enumerates generated objects") {
	NSMutableArray *series = [NSMutableArray new];
	for (NSNumber *number in [RXGeneratorTraversal generatorWithContext:[RXTuple tupleWithArray:@[@0, @1]] block:RXFibonacciGenerator()]) {
		[series addObject:number];
		if (series.count == 12)
			break;
	}
	l3_assert(series, (@[@1, @1, @2, @3, @5, @8, @13, @21, @34, @55, @89, @144]));
}

static RXGeneratorBlock RXIntegerGenerator(NSUInteger n) {
	return [^(NSNumber **context, bool *stop) {
		NSUInteger current = (*context).unsignedIntegerValue;
		*context = @(current + 1);
		if (current >= n)
			*stop = YES;
		return @(current);
	} copy];
}

@l3_test("stops enumerating when requested to by the generator") {
	NSArray *integers = RXConstructArray([RXGeneratorTraversal generatorWithBlock:RXIntegerGenerator(3)]);
	l3_assert(integers, (@[@0, @1, @2, @3]));
}

-(NSUInteger)populateObjects:(__autoreleasing id [])objects count:(NSUInteger)count state:(RXGeneratorTraversalState *)state {
	bool stop = NO;
	__autoreleasing id *contextRef = (__autoreleasing id *)(void *)&(state->context);
	NSUInteger i = 0;
	while ((i < count) && !stop) {
		objects[i++] = state->generatorBlock(contextRef, &stop);
	}
	if ((stop == YES) || (i == 0))
		state->state = RXGeneratorTraversalCurrentStateComplete;
	return i;
}

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)fastEnumerationState objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
	RXGeneratorTraversalState *state = (RXGeneratorTraversalState *)fastEnumerationState;
	__autoreleasing RXGeneratorBlock *generatorBlock = (__autoreleasing RXGeneratorBlock *)(void *)&(state->generatorBlock);
	__autoreleasing id<NSCopying> *context = (__autoreleasing id<NSCopying> *)(void *)&(state->context);
	if (!state->state) {
		state->state = RXGeneratorTraversalCurrentStateActive;
		state->mutations = state->extra;
		*context = [self.context copyWithZone:NULL];
		*generatorBlock = self.block;
	}
	
	NSUInteger count = 0;
	if (state->state != RXGeneratorTraversalCurrentStateComplete)
		count = [self populateObjects:(__autoreleasing id *)(void *)buffer count:len state:state];
	
	state->items = buffer;
	
	return count;
}

@end
