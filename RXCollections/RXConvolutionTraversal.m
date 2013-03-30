//  RXConvolutionTraversal.m
//  Created by Rob Rix on 2013-03-12.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXConvolutionTraversal.h"
#import "RXFastEnumerationState.h"
#import "RXFold.h"
#import "RXTuple.h"
#import "RXMap.h"

#import <Lagrangian/Lagrangian.h>

@l3_suite("RXConvolutionTraversal");

@interface RXConvolutionEnumerationState : RXFastEnumerationState

+(instancetype)stateWithNSFastEnumerationState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)count sequences:(id<RXTraversal>)sequences;

@property (nonatomic, strong) RXTuple *sequenceEnumerations;

@end

@interface RXConvolutionSequenceEnumerationState : RXHeapFastEnumerationState

+(instancetype)stateWithSequence:(id<NSFastEnumeration>)sequence;

-(id)nextObject;

-(NSUInteger)countByEnumerating;

@end

@implementation RXConvolutionTraversal

#pragma mark Construction

+(instancetype)traversalWithSequences:(id<RXTraversal>)sequences block:(RXConvolutionBlock)block {
	return [[self alloc] initWithSequences:sequences block:block];
}

-(instancetype)initWithSequences:(id<RXTraversal>)sequences block:(RXConvolutionBlock)block {
	if ((self = [super init])) {
		_sequences = sequences;
		_block = [block copy];
	}
	return self;
}


#pragma mark NSFastEnumeration

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)fastEnumerationState objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
	RXConvolutionEnumerationState *state = [RXConvolutionEnumerationState stateWithNSFastEnumerationState:fastEnumerationState objects:buffer count:len sequences:self.sequences];
	NSUInteger count = [RXMin(state.sequenceEnumerations, @(len), ^(id each) {
		return @([each countByEnumerating]);
	}) unsignedIntegerValue];
	
	for (NSUInteger i = 0; i < count; i++) {
		size_t arity = state.sequenceEnumerations.count;
		id objects[arity];
		NSUInteger j = 0;
		for (RXConvolutionSequenceEnumerationState *sequenceState in state.sequenceEnumerations) {
			objects[j++] = [sequenceState nextObject];
		}
		
		state.items[i] = self.block(arity, objects);
	}
	
	return count;
}

@end

@implementation RXConvolutionEnumerationState

+(instancetype)stateWithNSFastEnumerationState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)count sequences:(id<RXTraversal>)sequences {
	return [RXConvolutionEnumerationState stateWithNSFastEnumerationState:state objects:buffer count:count initializationHandler:^(RXConvolutionEnumerationState *state) {
		state.sequenceEnumerations = [RXTuple tupleWithArray:RXConstructArray(RXMap(sequences, ^(id<NSFastEnumeration> sequence){
			return [RXConvolutionSequenceEnumerationState stateWithSequence:sequence];
		}))];
	}];
}

@end

@interface RXConvolutionSequenceEnumerationState ()

@property (nonatomic, readonly) id<NSFastEnumeration> sequence;
@property (nonatomic, readonly) __unsafe_unretained id *objects;
@property (nonatomic, readwrite) NSUInteger countProduced;
@property (nonatomic) NSUInteger countConsumed;

@end

@implementation RXConvolutionSequenceEnumerationState {
	__unsafe_unretained id _objects[16];
}

+(instancetype)stateWithSequence:(id<NSFastEnumeration>)sequence {
	RXConvolutionSequenceEnumerationState *state = [self new];
	state->_sequence = sequence;
	return state;
}

-(__unsafe_unretained id *)objects {
	return _objects;
}

-(size_t)capacity {
	return sizeof(_objects) / sizeof(*_objects);
}


-(id)nextObject {
	return self.NSFastEnumerationState->itemsPtr[self.countConsumed++];
}


-(NSUInteger)countByEnumerating {
	if (self.countConsumed == self.countProduced) {
		self.countConsumed = 0;
		self.countProduced = [self.sequence countByEnumeratingWithState:self.NSFastEnumerationState objects:self.objects count:self.capacity];
	}
	return self.countProduced - self.countConsumed;
}

@end


id<RXTraversal> RXConvolveWith(id<RXTraversal> sequences, RXConvolutionBlock block) {
	return [RXConvolutionTraversal traversalWithSequences:sequences block:block];
}

id (* const RXZipWith)(id<RXTraversal>, RXConvolutionBlock) = RXConvolveWith;


@l3_test("transforms a tuple of sequences into a sequence of tuples") {
	NSArray *convoluted = RXConstructArray(RXConvolve(@[@[@0, @1], @[@2, @3]]));
	l3_assert(convoluted, (@[[RXTuple tupleWithArray:@[@0, @2]], [RXTuple tupleWithArray:@[@1, @3]]]));
}

@l3_test("enumerates to the length of the shortest sequence") {
	NSArray *convoluted = RXConstructArray(RXConvolve(@[@[@0, @1, @2], @[@2, @3]]));
	l3_assert(convoluted.count, 2);
}

id<RXTraversal> RXConvolve(id<RXTraversal> sequences) {
	return RXConvolveWith(sequences, ^id(NSUInteger count, id const objects[count]) {
		return [RXTuple tupleWithObjects:objects count:count];
	});
}

id (* const RXZip)(id<RXTraversal>) = RXConvolve;
