//  RXConvolutionTraversal.m
//  Created by Rob Rix on 2013-03-12.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXConvolutionTraversal.h"
#import "RXFold.h"
#import "RXTuple.h"
#import "RXMap.h"

#import <Lagrangian/Lagrangian.h>

@l3_suite("RXConvolutionTraversal");

typedef struct RXConvolutionTraversalEnumerationState {
	unsigned long iterationCount;
	__unsafe_unretained id *items;
	unsigned long *mutations;
	__unsafe_unretained RXTuple *sequenceEnumerations;
	unsigned long extra[4];
} RXConvolutionTraversalEnumerationState;

@implementation RXConvolutionTraversal

#pragma mark Construction

+(instancetype)traversalWithSequences:(id<RXTraversal>)sequences block:(RXConvolutionBlock)block {
	return [[self alloc] initWithSequences:sequences block:block];
}

-(instancetype)initWithSequences:(id<RXTraversal>)sequences block:(RXConvolutionBlock)block {
	if ((self = [super init])) {
		_sequences = sequences;
	}
	return self;
}


#pragma mark NSFastEnumeration

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)fastEnumerationState objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
	RXConvolutionTraversalEnumerationState *state = (RXConvolutionTraversalEnumerationState *)fastEnumerationState;
	if (state->iterationCount == 0) {
		state->mutations = state->extra;
		
		RXTraversalElement *sequenceEnumerations = (RXTraversalElement *)(void *)&state->sequenceEnumerations;
		*sequenceEnumerations = [RXTuple tupleWithArray:RXConstructArray(RXMap(self.sequences, ^(id sequence){ return [NSMutableData dataWithCapacity:sizeof(NSFastEnumerationState)]; }))];
	}
	
	state->iterationCount++;
	
	
	
	return 0;
}

@end


id<RXTraversal> RXConvolveWith(id<RXTraversal> sequences, RXConvolutionBlock block) {
	return [RXConvolutionTraversal traversalWithSequences:sequences block:block];
}

id (* const RXZipWith)(id<RXTraversal>, RXConvolutionBlock) = RXConvolveWith;


@l3_test("transforms a tuple of sequences into a sequence of tuples") {
	NSArray *convoluted = RXConstructArray(RXConvolve(@[@[@0, @1], @[@2, @3]]));
	l3_assert(convoluted, (@[@[@0, @2], @[@1, @3]]));
}

id<RXTraversal> RXConvolve(id<RXTraversal> sequences) {
	return RXConvolveWith(sequences, ^id(NSUInteger count, id const objects[count]) {
		return [RXTuple tupleWithObjects:objects count:count];
	});
}

id (* const RXZip)(id<RXTraversal>) = RXConvolve;
