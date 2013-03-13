//  RXIntervalTraversal.m
//  Created by Rob Rix on 2013-03-01.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXIntervalTraversal.h"
#import "RXFold.h"

#import <Lagrangian/Lagrangian.h>

@l3_suite("RXIntervalTraversal");

typedef struct RXIntervalTraversalState {
	unsigned long iterationCount;
	__unsafe_unretained id *items;
	unsigned long *mutations;
	RXMagnitude from;
	NSUInteger count;
	unsigned long extra[3];
} RXIntervalTraversalState;

@interface RXIntervalTraversal ()
@end

static RXMagnitude RXIntervalTraversalStrideWithMagnitude(RXMagnitude magnitude, RXMagnitude from, RXMagnitude to);

@implementation RXIntervalTraversal

#pragma mark Construction

@l3_test("defaults to a stride of 1.0 if neither stride nor count is specified") {
	RXIntervalTraversal *traversal = [RXIntervalTraversal traversalWithInterval:RXIntervalMake(0, 1)];
	l3_assert(traversal.stride, 1.0);
}

@l3_test("intervals are closed under default stride") {
	RXIntervalTraversal *traversal = [RXIntervalTraversal traversalWithInterval:RXIntervalMake(0, 1)];
	l3_assert(RXConstructArray(traversal), (@[@0, @1]));
}

+(instancetype)traversalWithInterval:(RXInterval)interval {
	return [self traversalWithInterval:interval stride:1.0];
}


@l3_test("calculates count as the length divided by stride when stride is provided") {
	RXIntervalTraversal *traversal = [RXIntervalTraversal traversalWithInterval:RXIntervalMake(0, 20) stride:5];
	l3_assert(RXConstructArray(traversal), (@[@0, @5, @10, @15, @20]));
}

@l3_test("intervals are closed when specifying stride") {
	RXIntervalTraversal *traversal = [RXIntervalTraversal traversalWithInterval:RXIntervalMake(0, 1) stride:0.5];
	l3_assert(RXConstructArray(traversal), (@[@0, @0.5, @1]));
}

+(instancetype)traversalWithInterval:(RXInterval)interval stride:(RXMagnitude)stride {
	RXMagnitude absoluteStride = RXMagnitudeGetAbsoluteValue(stride);
	NSParameterAssert(absoluteStride > 0.0);
	
	RXMagnitude length = RXIntervalGetLength(interval);
	
	return [[self alloc] initWithInterval:interval length:length absoluteStride:absoluteStride count:ceil((length / stride) + 1)];
}


@l3_test("calculates stride as the length required to take count steps across the closed interval when count is provided") {
	RXIntervalTraversal *traversal = [RXIntervalTraversal traversalWithInterval:RXIntervalMake(0, 10) count:5];
	l3_assert(traversal.stride, 2.5f);
}

+(instancetype)traversalWithInterval:(RXInterval)interval count:(NSUInteger)count {
	NSParameterAssert(count > 0);
	
	RXMagnitude length = RXIntervalGetLength(interval);
	RXMagnitude absoluteStride = count > 1?
		length / (RXMagnitude)(count - 1)
	:	length;
	
	return [[self alloc] initWithInterval:interval length:length absoluteStride:absoluteStride count:count];
}


@l3_test("stride is positive when to is greater than from") {
	RXIntervalTraversal *traversal = [RXIntervalTraversal traversalWithInterval:RXIntervalMake(0, 1)];
	l3_assert(traversal.stride, 1);
}

@l3_test("stride is negative when to is less than from") {
	RXIntervalTraversal *traversal = [RXIntervalTraversal traversalWithInterval:RXIntervalMake(1, 0)];
	l3_assert(traversal.stride, -1);
}

// this method trusts its caller to check the arguments it provides; therefore, it is private
-(instancetype)initWithInterval:(RXInterval)interval length:(RXMagnitude)length absoluteStride:(RXMagnitude)stride count:(NSUInteger)count {
	if ((self = [super init])) {
		_interval = interval;
		_length = length;
		_stride = interval.to > interval.from?
			stride
		:	-stride;
		_count = count;
	}
	return self;
}


@l3_test("traverses the values in its interval at a given number of steps of a given stride") {
	l3_assert(RXConstructArray([RXIntervalTraversal traversalWithInterval:RXIntervalMake(-M_PI, M_PI) count:3]), l3_is(@[@-M_PI, @0, @M_PI]));
}

@l3_test("saves its place so it can traverse more values than fit in the buffer") {
	l3_assert(RXConstructArray([RXIntervalTraversal traversalWithInterval:RXIntervalMake(0, 1) count:32]).count, 32);
}

@l3_test("sanity check: unsigned long is sufficient to store NSUInteger") {
	l3_assert(sizeof(unsigned long), sizeof(NSUInteger));
}

@l3_test("sanity check: unsigned long is sufficient to store RXMagnitude") {
	l3_assert(sizeof(unsigned long), sizeof(RXMagnitude));
}

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)fastEnumerationState objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
	RXIntervalTraversalState *state = (RXIntervalTraversalState *)fastEnumerationState;
	
	if (!state->iterationCount) {
		state->mutations = state->extra;
		state->count = self.count;
		state->from = self.interval.from;
	}
	
	state->items = buffer;
	
	state->iterationCount++;
	
	RXMagnitude stride = self.stride;
	NSUInteger stepCount = MIN(state->count, len);
	for (NSUInteger step = 0; step < stepCount; state->from += stride, step++) {
		RXTraversalElement *item = (RXTraversalElement *)(void *)buffer + step;
		*item = @(state->from);
	}
	
	state->count -= stepCount;
	
	return stepCount;
}

@end
