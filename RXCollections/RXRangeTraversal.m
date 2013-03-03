//  RXRangeTraversal.m
//  Created by Rob Rix on 2013-03-01.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXRangeTraversal.h"
#import "RXFold.h"

#import <Lagrangian/Lagrangian.h>

@l3_suite("RXRangeTraversal");

typedef struct RXRangeTraversalState {
	unsigned long iterationCount;
	__unsafe_unretained id *items;
	unsigned long *mutations;
	NSUInteger count;
	unsigned long extra[4];
} RXRangeTraversalState;

@interface RXRangeTraversal ()
@end

static NSInteger RXRangeTraversalStrideWithMagnitude(NSUInteger magnitude, NSInteger from, NSInteger to);

@implementation RXRangeTraversal

#pragma mark Lifecycle

+(instancetype)traversalFromInteger:(NSInteger)from toInteger:(NSInteger)to byStrideWithMagnitude:(NSUInteger)magnitude {
	return [[self alloc] initFromInteger:from toInteger:to byStrideWithMagnitude:magnitude];
}

-(instancetype)initFromInteger:(NSInteger)from toInteger:(NSInteger)to byStrideWithMagnitude:(NSUInteger)magnitude {
	NSParameterAssert(magnitude > 0);
	
	if ((self = [super init])) {
		_from = from;
		_to = to;
		_stride = RXRangeTraversalStrideWithMagnitude(magnitude, from, to);
		_count = RXRangeTraversalCount(_stride, _from, _to);
	}
	return self;
}


@l3_test("stride is positive when to is greater than from") {
	l3_assert(RXRangeTraversalStrideWithMagnitude(1, 0, 1), 1);
}
@l3_test("stride is negative when to is less than from") {
	l3_assert(RXRangeTraversalStrideWithMagnitude(1, 1, 0), -1);
}

static inline NSInteger RXRangeTraversalStrideWithMagnitude(NSUInteger magnitude, NSInteger from, NSInteger to) {
	return to > from?
		magnitude
	:	-magnitude;
}


@l3_test("count includes both from and to") {
	l3_assert(RXRangeTraversalCount(1, 0, 1), 2);
}

@l3_test("count is 1 when from is equal to to") {
	l3_assert(RXRangeTraversalCount(1, 0, 0), 1);
}

@l3_test("count takes the stride into account") {
	l3_assert(RXRangeTraversalCount(-2, 7, 3), 3);
}

@l3_test("count does not require that the range end on a stride") {
	l3_assert(RXRangeTraversalCount(3, 1, 3), 1);
	l3_assert(RXRangeTraversalCount(3, 1, 4), 2);
	l3_assert(RXRangeTraversalCount(3, 1, 5), 2);
	l3_assert(RXRangeTraversalCount(3, 1, 6), 2);
	l3_assert(RXRangeTraversalCount(3, 1, 7), 3);
}

static inline NSUInteger RXRangeTraversalCount(NSInteger stride, NSInteger from, NSInteger to) {
	return ((to - from) / stride) + 1;
}


@l3_test("traverses the integers in its range inclusively") {
	l3_assert(RXConstructArray([RXRangeTraversal traversalFromInteger:0 toInteger:3 byStrideWithMagnitude:1]), l3_is(@[@0, @1, @2, @3]));
}

@l3_test("sanity check: unsigned long is sufficient to store NSUInteger") {
	l3_assert(sizeof(unsigned long), sizeof(NSUInteger));
}

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)fastEnumerationState objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
	RXRangeTraversalState *state = (RXRangeTraversalState *)fastEnumerationState;
	
	if (!state->iterationCount) {
		state->mutations = &state->iterationCount;
		state->count = self.count;
	}
	
	state->items = buffer;
	
	state->iterationCount++;
	
	NSInteger from = self.from;
	NSInteger stride = self.stride;
	NSUInteger stepCount = MIN(state->count, len);
	for (NSUInteger step = 0; step < stepCount; from += stride, step++) {
		__autoreleasing id *item = (__autoreleasing id *)(void *)buffer + step;
		*item = @(from);
	}
	
	state->count -= stepCount;
	
	return stepCount;
}

@end


id<RXTraversal> RXRange(NSInteger from, NSInteger to) {
	return [RXRangeTraversal traversalFromInteger:from toInteger:to byStrideWithMagnitude:1];
}
