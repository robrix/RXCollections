//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXFold.h"
#import "RXInterval.h"

#import <Lagrangian/Lagrangian.h>

l3_addTestSubjectTypeWithFunction(RXIntervalMakeWithLength)

l3_test(&RXIntervalMakeWithLength, ^{
	RXInterval interval = RXIntervalMakeWithLength(1, 3);
	l3_expect(interval.from).to.equal(@1);
	l3_expect(interval.to).to.equal(@4);
})


@interface RXIntervalEnumerator ()

// redeclared as a property so that @dynamic will work properly
@property (nonatomic, readonly) NSNumber *nextObject;

@end

@implementation RXIntervalEnumerator

+(instancetype)enumeratorWithInterval:(RXInterval)interval {
	return [self enumeratorWithInterval:interval stride:1.0];
}

+(instancetype)enumeratorWithInterval:(RXInterval)interval stride:(RXMagnitude)stride {
	RXMagnitude absoluteStride = RXMagnitudeGetAbsoluteValue(stride);
	NSParameterAssert(absoluteStride > 0.0);
	
	return [[self alloc] initWithInterval:interval absoluteStride:absoluteStride count:ceil((RXIntervalGetLength(interval) / absoluteStride) + 1)];
}

+(instancetype)enumeratorWithInterval:(RXInterval)interval count:(NSUInteger)count {
	NSParameterAssert(count > 0);
	
	RXMagnitude length = RXIntervalGetLength(interval);
	RXMagnitude absoluteStride = count > 1?
		length / (RXMagnitude)(count - 1)
	:	length;
	
	return [[self alloc] initWithInterval:interval absoluteStride:absoluteStride count:count];
}

-(instancetype)initWithInterval:(RXInterval)interval absoluteStride:(RXMagnitude)stride count:(NSUInteger)count {
	if ((self = [super init])) {
		_interval = interval;
		_stride = interval.to > interval.from?
			stride
		:	-stride;
		_count = count;
	}
	return self;
}


#pragma mark RXBatchEnumerator

l3_test(@selector(countOfObjectsProducedInBatch:count:), ^{
	l3_expect([RXIntervalEnumerator enumeratorWithInterval:(RXInterval){-M_PI, M_PI} count:3].currentObject).to.equal(@-M_PI);
	l3_expect(RXConstructArray([RXIntervalEnumerator enumeratorWithInterval:(RXInterval){-M_PI, M_PI} count:3])).to.equal(@[@-M_PI, @0, @M_PI]);
	l3_expect(RXConstructArray([RXIntervalEnumerator enumeratorWithInterval:(RXInterval){.to = 1} count:64]).count).to.equal(@64);
})

-(NSUInteger)countOfObjectsProducedInBatch:(id __strong [])batch count:(NSUInteger)count; {
	NSUInteger produced = MIN(count, _count);
	
	id __strong *stop = batch + produced;
	while (batch < stop) {
		*batch = @(_interval.to - _stride * (stop - batch - 1));
		batch++;
	}
	
	_count -= produced;
	
	return produced;
}


@dynamic nextObject;


#pragma mark NSCopying

-(instancetype)copyWithZone:(NSZone *)zone {
	RXIntervalEnumerator *copy = [super copyWithZone:zone];
	copy->_interval = _interval;
	copy->_stride = _stride;
	copy->_count = _count;
	return copy;
}

@end
