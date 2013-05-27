//  RXConvolution.m
//  Created by Rob Rix on 2013-03-12.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXConvolution.h"
#import "RXFold.h"
#import "RXInterval.h"
#import "RXTuple.h"
#import "RXMap.h"

#import <Lagrangian/Lagrangian.h>

@l3_suite("RXConvolutionTraversal");

id<RXTraversal> RXConvolveWith(id<NSObject, NSFastEnumeration> sequences, RXConvolutionBlock block) {
	RXTuple *sequenceTraversals = RXConstructTuple(RXMap(sequences, ^id(id<NSObject, NSFastEnumeration> each, bool *stop) {
		return RXTraversalWithEnumeration(each);
	}));
	return RXTraversalWithSource(^bool(id<RXRefillableTraversal> traversal) {
		size_t arity = sequenceTraversals.count;
		id objects[arity];
		NSUInteger i = 0;
		bool exhausted = NO;
		for (id<RXTraversal> sequence in sequenceTraversals) {
			exhausted = exhausted || sequence.isExhausted;
			objects[i++] = [sequence nextObject];
		}
		if (!exhausted)
			[traversal addObject:block(arity, objects, &exhausted)];
		return exhausted;
	});
}

id<RXTraversal> RXConvolveWithF(id<NSObject, NSFastEnumeration> sequences, RXConvolutionFunction function) {
	return RXConvolveWith(sequences, ^id(NSUInteger count, const __unsafe_unretained id *objects, bool *stop) {
		return function(count, objects, stop);
	});
}

id (* const RXZipWith)(id<NSObject, NSFastEnumeration>, RXConvolutionBlock) = RXConvolveWith;
id (* const RXZipWithF)(id<NSObject, NSFastEnumeration>, RXConvolutionFunction) = RXConvolveWithF;


@l3_test("transforms a tuple of sequences into a sequence of tuples") {
	NSArray *convoluted = RXConstructArray(RXConvolve(@[@[@0, @1], @[@2, @3]]));
	l3_assert(convoluted, (@[[RXTuple tupleWithArray:@[@0, @2]], [RXTuple tupleWithArray:@[@1, @3]]]));
}

@l3_test("enumerates to the length of the shortest sequence") {
	NSArray *convoluted = RXConstructArray(RXConvolve(@[@[@0, @1, @2], @[@2, @3]]));
	l3_assert(convoluted.count, 2);
}

@l3_test("enumerates the sequences correctly across multiple refills") {
	id<RXInterval> interval = RXIntervalByCount(0, 1, 128);
	NSArray *convoluted = RXConstructArray(RXConvolve(@[interval.traversal, interval.traversal]));
	l3_assert(convoluted.lastObject, l3_is([RXTuple tupleWithObjects:(const id[]){@1, @1} count:2]));
}

id<RXTraversal> RXConvolve(id<NSObject, NSFastEnumeration> sequences) {
	return RXConvolveWith(sequences, ^id(NSUInteger count, id const objects[count], bool *stop) {
		return [RXTuple tupleWithObjects:objects count:count];
	});
}

id (* const RXZip)(id<NSObject, NSFastEnumeration>) = RXConvolve;
