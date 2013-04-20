//  RXConvolution.m
//  Created by Rob Rix on 2013-03-12.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXConvolution.h"
#import "RXFold.h"
#import "RXTuple.h"
#import "RXMap.h"

#import <Lagrangian/Lagrangian.h>

@l3_suite("RXConvolutionTraversal");

@interface RXConvolutionTraversalSource : NSObject <RXTraversalSource>
+(instancetype)sourceWithSequences:(RXTuple *)sequences block:(RXConvolutionBlock)block;

@property (nonatomic, strong, readonly) RXTuple *sequences;
@property (nonatomic, copy, readonly) RXConvolutionBlock block;
@end


id<RXTraversal> RXConvolveWith(id<NSFastEnumeration> sequences, RXConvolutionBlock block) {
	return [RXTraversal traversalWithSource:[RXConvolutionTraversalSource sourceWithSequences:RXConstructTuple(RXMap(sequences, ^id(id each) {
		return [RXTraversal traversalWithEnumeration:each];
	})) block:block]];
}

id (* const RXZipWith)(id<NSFastEnumeration>, RXConvolutionBlock) = RXConvolveWith;


@l3_test("transforms a tuple of sequences into a sequence of tuples") {
	NSArray *convoluted = RXConstructArray(RXConvolve(@[@[@0, @1], @[@2, @3]]));
	l3_assert(convoluted, (@[[RXTuple tupleWithArray:@[@0, @2]], [RXTuple tupleWithArray:@[@1, @3]]]));
}

@l3_test("enumerates to the length of the shortest sequence") {
	NSArray *convoluted = RXConstructArray(RXConvolve(@[@[@0, @1, @2], @[@2, @3]]));
	l3_assert(convoluted.count, 2);
}

id<RXTraversal> RXConvolve(id<NSFastEnumeration> sequences) {
	return RXConvolveWith(sequences, ^id(NSUInteger count, id const objects[count]) {
		return [RXTuple tupleWithObjects:objects count:count];
	});
}

id (* const RXZip)(id<NSFastEnumeration>) = RXConvolve;


@interface RXConvolutionTraversalSource ()
@property (nonatomic, strong, readwrite) RXTuple *sequences;
@property (nonatomic, copy, readwrite) RXConvolutionBlock block;
@end

@implementation RXConvolutionTraversalSource

+(instancetype)sourceWithSequences:(RXTuple *)sequences block:(RXConvolutionBlock)block {
	RXConvolutionTraversalSource *source = [self new];
	source.sequences = sequences;
	source.block = block;
	return source;
}

-(void)refillTraversal:(id<RXRefillableTraversal>)traversal {
	[traversal refillWithBlock:^{
		size_t arity = self.sequences.count;
		id objects[arity];
		NSUInteger i = 0;
		bool exhausted = NO;
		for (RXTraversal *sequence in self.sequences) {
			exhausted = exhausted || sequence.isExhausted;
			objects[i++] = [sequence consume];
		}
		if (!exhausted)
			[traversal produce:self.block(arity, objects)];
		return exhausted;
	}];
}

@end
