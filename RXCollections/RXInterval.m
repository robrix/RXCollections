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

@property (nonatomic) NSUInteger count;

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


#pragma mark RXEnumerator

-(bool)isEmpty {
	return self.count == 0;
}

l3_test(@selector(currentObject), ^{
	l3_expect([[RXIntervalEnumerator enumeratorWithInterval:(RXInterval){-M_PI, M_PI} count:3] currentObject]).to.equal(@-M_PI);
	l3_expect(RXConstructArray([RXIntervalEnumerator enumeratorWithInterval:(RXInterval){-M_PI, M_PI} count:3])).to.equal(@[@-M_PI, @0, @M_PI]);
	l3_expect(RXConstructArray([RXIntervalEnumerator enumeratorWithInterval:(RXInterval){.to = 1} count:64]).count).to.equal(@64);
})

-(NSNumber *)currentObject {
	return @(self.interval.to - self.stride * (self.count - 1));
}

-(void)consumeCurrentObject {
	NSParameterAssert(!self.isEmpty);
	
	self.count--;
}


#pragma mark NSEnumerator

-(NSNumber *)nextObject {
	NSNumber *currentObject;
	if (!self.isEmpty) {
		currentObject = self.currentObject;
		[self consumeCurrentObject];
	}
	return currentObject;
}


#pragma mark NSCopying

-(instancetype)copyWithZone:(NSZone *)zone {
	return [[self.class alloc] initWithInterval:self.interval absoluteStride:RXMagnitudeGetAbsoluteValue(self.stride) count:self.count];
}

@end
