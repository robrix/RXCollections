//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXConvolution.h"
#import "RXFold.h"
#import "RXInterval.h"
#import "RXTuple.h"
#import "RXMap.h"
#import <Lagrangian/Lagrangian.h>

id<RXTraversal> RXConvolveWith(id<NSObject, NSCopying, NSFastEnumeration> sequences, RXConvolutionBlock block) {
	RXTuple *sequenceTraversals = RXConstructTuple(RXMap(sequences, ^id(id<NSObject, NSCopying, NSFastEnumeration> each, bool *stop) {
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

id<RXTraversal> RXConvolveWithF(id<NSObject, NSCopying, NSFastEnumeration> sequences, RXConvolutionFunction function) {
	return RXConvolveWith(sequences, ^id(NSUInteger count, const __unsafe_unretained id *objects, bool *stop) {
		return function(count, objects, stop);
	});
}

id (* const RXZipWith)(id<NSObject, NSCopying, NSFastEnumeration>, RXConvolutionBlock) = RXConvolveWith;
id (* const RXZipWithF)(id<NSObject, NSCopying, NSFastEnumeration>, RXConvolutionFunction) = RXConvolveWithF;

l3_addTestSubjectTypeWithFunction(RXConvolve)

l3_test(&RXConvolve, ^{
	NSArray *convoluted = RXConstructArray(RXConvolve(@[@[@0, @1, @2], @[@2, @3]]));
	l3_expect(convoluted.count).to.equal(@2);
	l3_expect(convoluted).to.equal(@[[RXTuple tupleWithArray:@[@0, @2]], [RXTuple tupleWithArray:@[@1, @3]]]);
	
	id<RXInterval> interval = RXIntervalByCount(0, 1, 128);
	convoluted = RXConstructArray(RXConvolve(@[interval.traversal, interval.traversal]));
	
	l3_expect(convoluted.lastObject).to.equal([RXTuple tupleWithObjects:(const id[]){@1, @1} count:2]);
})

id<RXTraversal> RXConvolve(id<NSObject, NSCopying, NSFastEnumeration> sequences) {
	return RXConvolveWith(sequences, ^id(NSUInteger count, id const objects[count], bool *stop) {
		return [RXTuple tupleWithObjects:objects count:count];
	});
}

id (* const RXZip)(id<NSObject, NSCopying, NSFastEnumeration>) = RXConvolve;
