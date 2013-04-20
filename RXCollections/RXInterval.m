//  RXInterval.m
//  Created by Rob Rix on 2013-03-01.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXFold.h"
#import "RXInterval.h"

#import <Lagrangian/Lagrangian.h>

@l3_suite("RXInterval");

@interface RXIntervalTraversalSource : NSObject <RXInterval, RXTraversalSource>
-(instancetype)initFromMagnitude:(RXMagnitude)from toMagnitude:(RXMagnitude)to length:(RXMagnitude)length absoluteStride:(RXMagnitude)stride count:(NSUInteger)count;

@property (nonatomic, readonly) RXMagnitude from;
@property (nonatomic, readonly) RXMagnitude to;
@property (nonatomic, readonly) RXMagnitude length;
@property (nonatomic, readonly) RXMagnitude stride;
@property (nonatomic, readonly) NSUInteger count;
@end


@l3_test("defaults to a stride of 1.0 if neither stride nor count is specified") {
	id<RXInterval> interval = RXInterval(0, 1);
	l3_assert(interval.stride, 1.0);
}

@l3_test("intervals are closed under default stride") {
	id<RXInterval> interval = RXInterval(0, 1);
	l3_assert(RXConstructArray(interval.traversal), (@[@0, @1]));
}

@l3_test("stride is positive when to is greater than from") {
	id<RXInterval> interval = RXInterval(0, 1);
	l3_assert(interval.stride, l3_greaterThan(0));
}

@l3_test("stride is negative when to is less than from") {
	id<RXInterval> interval = RXInterval(1, 0);
	l3_assert(interval.stride, l3_lessThan(0));
}

id<RXInterval> RXInterval(RXMagnitude from, RXMagnitude to) {
	return RXIntervalByStride(from, to, 1.0);
}


@l3_test("calculates count as the length divided by stride when stride is provided") {
	id<RXInterval> interval = RXIntervalByStride(0, 20, 5);
	l3_assert(RXConstructArray(interval.traversal), (@[@0, @5, @10, @15, @20]));
}

@l3_test("intervals are closed when specifying stride") {
	id<RXInterval> interval = RXIntervalByStride(0, 1, 0.5);
	l3_assert(RXConstructArray(interval.traversal), (@[@0, @0.5, @1]));
}

id<RXInterval> RXIntervalByStride(RXMagnitude from, RXMagnitude to, RXMagnitude stride) {
	RXMagnitude absoluteStride = RXMagnitudeGetAbsoluteValue(stride);
	NSCParameterAssert(absoluteStride > 0.0);
	
	RXMagnitude length = RXIntervalGetLength(from, to);
	return [[RXIntervalTraversalSource alloc] initFromMagnitude:from toMagnitude:to length:length absoluteStride:absoluteStride count:ceil((length / stride) + 1)];
}


@l3_test("calculates stride as the length required to take count steps across the closed interval when count is provided") {
	id<RXInterval> interval = RXIntervalByCount(0, 10, 5);
	l3_assert(interval.stride, 2.5f);
}

id<RXInterval> RXIntervalByCount(RXMagnitude from, RXMagnitude to, NSUInteger count) {
	NSCParameterAssert(count > 0);
	
	RXMagnitude length = RXIntervalGetLength(from, to);
	RXMagnitude absoluteStride = count > 1?
		length / (RXMagnitude)(count - 1)
	:	length;
	
	return [[RXIntervalTraversalSource alloc] initFromMagnitude:from toMagnitude:to length:length absoluteStride:absoluteStride count:count];
}


@implementation RXIntervalTraversalSource

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


#pragma mark RXTraversalSource

@l3_test("traverses the values in its interval at a given number of steps of a given stride") {
	l3_assert(RXConstructArray(RXIntervalByCount(-M_PI, M_PI, 3).traversal), l3_is(@[@-M_PI, @0, @M_PI]));
}

@l3_test("saves its place so it can traverse more values than fit in the buffer") {
	l3_assert(RXConstructArray(RXIntervalByCount(0, 1, 32).traversal).count, 32);
}

-(id<RXTraversal>)traversal {
	return RXTraversalWithSource(self);
}

-(void)refillTraversal:(id<RXRefillableTraversal>)traversal {
	[traversal refillWithBlock:^bool{
		[traversal produce:@(self.from + (self.stride * traversal.countProduced))];
		return traversal.countProduced >= self.count;
	}];
}

@end
