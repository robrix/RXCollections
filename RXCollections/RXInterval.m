//  RXInterval.m
//  Created by Rob Rix on 2013-03-01.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXFold.h"
#import "RXInterval.h"

#import <Lagrangian/Lagrangian.h>

@interface RXIntervalEnumerable : NSObject <RXInterval>
-(instancetype)initFromMagnitude:(RXMagnitude)from toMagnitude:(RXMagnitude)to length:(RXMagnitude)length absoluteStride:(RXMagnitude)stride count:(NSUInteger)count;

@property (nonatomic, readonly) RXMagnitude from;
@property (nonatomic, readonly) RXMagnitude to;
@property (nonatomic, readonly) RXMagnitude length;
@property (nonatomic, readonly) RXMagnitude stride;
@property (nonatomic, readonly) NSUInteger count;
@end


l3_addTestSubjectTypeWithFunction(RXInterval)

l3_test(&RXInterval, ^{
	id<RXInterval> interval = RXInterval(0, 1);
	l3_expect(interval.stride).to.equal(@1);
	l3_expect(RXConstructArray(interval.traversal)).to.equal(@[@0, @1]);
	
	interval = RXInterval(1, 0);
	l3_expect(interval.stride).to.equal(@-1);
})

id<RXInterval> RXInterval(RXMagnitude from, RXMagnitude to) {
	return RXIntervalByStride(from, to, 1.0);
}

l3_addTestSubjectTypeWithFunction(RXIntervalByStride)

l3_test(&RXIntervalByStride, ^{
	id<RXInterval> interval = RXIntervalByStride(0, 20, 5);
	l3_expect(RXConstructArray(interval.traversal)).to.equal(@[@0, @5, @10, @15, @20]);
	
	interval = RXIntervalByStride(0, 1, 0.5);
	l3_expect(RXConstructArray(interval.traversal)).to.equal(@[@0, @0.5, @1]);
})

id<RXInterval> RXIntervalByStride(RXMagnitude from, RXMagnitude to, RXMagnitude stride) {
	RXMagnitude absoluteStride = RXMagnitudeGetAbsoluteValue(stride);
	NSCParameterAssert(absoluteStride > 0.0);
	
	RXMagnitude length = RXIntervalGetLength(from, to);
	return [[RXIntervalEnumerable alloc] initFromMagnitude:from toMagnitude:to length:length absoluteStride:absoluteStride count:ceil((length / stride) + 1)];
}


l3_addTestSubjectTypeWithFunction(RXIntervalByCount)

l3_test(&RXIntervalByCount, ^{
	id<RXInterval> interval = RXIntervalByCount(0, 10, 5);
	l3_expect(interval.stride).to.equal(@2.5f);
})

id<RXInterval> RXIntervalByCount(RXMagnitude from, RXMagnitude to, NSUInteger count) {
	NSCParameterAssert(count > 0);
	
	RXMagnitude length = RXIntervalGetLength(from, to);
	RXMagnitude absoluteStride = count > 1?
		length / (RXMagnitude)(count - 1)
	:	length;
	
	return [[RXIntervalEnumerable alloc] initFromMagnitude:from toMagnitude:to length:length absoluteStride:absoluteStride count:count];
}


@implementation RXIntervalEnumerable

#pragma mark Construction

-(instancetype)initFromMagnitude:(RXMagnitude)from toMagnitude:(RXMagnitude)to length:(RXMagnitude)length absoluteStride:(RXMagnitude)stride count:(NSUInteger)count {
	if ((self = [super init])) {
		_from = from;
		_to = to;
		_length = length;
		_stride = to > from?
			stride
		:	-stride;
		_count = count;
	}
	return self;
}


#pragma mark RXEnumerable

l3_test(@selector(traversal), ^{
	l3_expect(RXConstructArray(RXIntervalByCount(-M_PI, M_PI, 3).traversal)).to.equal(@[@-M_PI, @0, @M_PI]);
	l3_expect(RXConstructArray(RXIntervalByCount(0, 1, 32).traversal).count).to.equal(@32);
})

-(id<RXTraversal>)traversal {
	__block NSUInteger count = 0;
	return RXTraversalWithSource(^bool(id<RXRefillableTraversal> traversal) {
		[traversal addObject:@(self.from + (self.stride * count++))];
		return count >= self.count;
	});
}

@end
