//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXConvolution.h"
#import "RXFold.h"
#import "RXInterval.h"
#import "RXTuple.h"
#import "RXMap.h"

#import <Lagrangian/Lagrangian.h>

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

id (* const RXZipWith)(id<NSObject, NSFastEnumeration>, RXConvolutionBlock) = RXConvolveWith;

l3_addTestSubjectTypeWithFunction(RXConvolve)

l3_test(&RXConvolve, ^{
	NSArray *convoluted = RXConstructArray(RXConvolve(@[@[@0, @1, @2], @[@2, @3]]));
	l3_expect(convoluted.count).to.equal(@2);
	l3_expect(convoluted).to.equal(@[[RXTuple tupleWithArray:@[@0, @2]], [RXTuple tupleWithArray:@[@1, @3]]]);
	
	id<RXFiniteEnumerator> interval = [RXIntervalEnumerator enumeratorWithInterval:(RXInterval){0, 1} count:128];
	convoluted = RXConstructArray(RXConvolve(@[[interval copyWithZone:NULL], [interval copyWithZone:NULL]]));
	
	l3_expect(convoluted.lastObject).to.equal([RXTuple tupleWithObjects:(const id[]){@1, @1} count:2]);
})

id<RXTraversal> RXConvolve(id<NSObject, NSFastEnumeration> sequences) {
	return RXConvolveWith(sequences, ^id(NSUInteger count, id const objects[count], bool *stop) {
		return [RXTuple tupleWithObjects:objects count:count];
	});
}

id (* const RXZip)(id<NSObject, NSFastEnumeration>) = RXConvolve;
