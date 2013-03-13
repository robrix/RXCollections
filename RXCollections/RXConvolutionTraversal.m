//  RXConvolutionTraversal.m
//  Created by Rob Rix on 2013-03-12.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXConvolutionTraversal.h"
#import "RXTuple.h"

#import <Lagrangian/Lagrangian.h>

@l3_suite("RXConvolutionTraversal");

typedef struct RXConvolutionTraversalEnumerationState {
	unsigned long iterationCount;
	__unsafe_unretained id *items;
	unsigned long *mutations;
	__unsafe_unretained RXTuple *sequenceEnumerations;
	unsigned long extra;
} RXConvolutionTraversalEnumerationState;

@implementation RXConvolutionTraversal

#pragma mark Construction

+(instancetype)traversalWithSequences:(id<RXFiniteTraversal>)sequences block:(RXConvolutionBlock)block {
	return [[self alloc] initWithSequences:sequences block:block];
}

-(instancetype)initWithSequences:(id<RXFiniteTraversal>)sequences block:(RXConvolutionBlock)block {
	if ((self = [super init])) {
		_sequences = sequences;
	}
	return self;
}


#pragma mark NSFastEnumeration

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
	
	
	return 0;
}

@end


id<RXTraversal> RXConvolveWith(id<RXFiniteTraversal> sequences, RXConvolutionBlock block) {
	return [RXConvolutionTraversal traversalWithSequences:sequences block:block];
}

id (* const RXZipWith)(id<RXFiniteTraversal>, RXConvolutionBlock) = RXConvolveWith;


@l3_test("transforms a tuple of sequences into a sequence of tuples") {
	l3_assert(RXConvolve(@[@[@0, @1], @[@2, @3]]), (@[@[@0, @2], @[@1, @3]]));
}

id<RXTraversal> RXConvolve(id<RXFiniteTraversal> sequences) {
	return RXConvolveWith(sequences, ^id(NSUInteger count, id const objects[count]) {
		return [RXTuple tupleWithObjects:objects count:count];
	});
}

id (* const RXZip)(id<RXFiniteTraversal>) = RXConvolve;
