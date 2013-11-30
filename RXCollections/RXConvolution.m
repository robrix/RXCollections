//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXConvolution.h"
#import "RXFastEnumerator.h"
#import "RXFold.h"
#import "RXGenerator.h"
#import "RXInterval.h"
#import "RXTuple.h"
#import "RXMap.h"

#import <Lagrangian/Lagrangian.h>

id<RXEnumerator> RXConvolveWith(id<NSObject, NSFastEnumeration> sequences, RXConvolutionBlock block) {
	RXTuple *sequenceEnumerators = RXConstructTuple(RXMap(sequences, ^id<RXEnumerator>(id<NSObject, NSFastEnumeration> each) {
		return [[RXFastEnumerator alloc] initWithEnumeration:each];
	}));
	
	return [[RXGenerator alloc] initWithBlock:^(RXGenerator *convolution){
		size_t arity = sequenceEnumerators.count;
		id objects[arity];
		NSUInteger i = 0;
		bool shouldStop = NO;
		for (id<RXEnumerator> sequence in sequenceEnumerators) {
			id object = [sequence nextObject];
			objects[i++] = object;
			shouldStop = shouldStop || object == nil;
		}
		return shouldStop? nil : block(arity, objects);
	}];
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

id<RXEnumerator> RXConvolve(id<NSObject, NSFastEnumeration> sequences) {
	return RXConvolveWith(sequences, ^id(NSUInteger count, id const objects[count]) {
		return [RXTuple tupleWithObjects:objects count:count];
	});
}

id (* const RXZip)(id<NSObject, NSFastEnumeration>) = RXConvolve;
